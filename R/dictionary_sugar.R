#' @title A Quick Way to Initialize Objects from Dictionaries
#'
#' @description
#' Given a [Dictionary], retrieve objects with provided keys.
#' * `dictionary_sugar_get()` to retrieve a single object with key `.key`.
#' * `dictionary_sugar_mget()` to retrieve a list of objects with keys `.keys`.
#' * `dictionary_sugar()` is deprecated in favor of `dictionary_sugar_get()`.
#' * If `.key` or `.keys` is missing, the dictionary itself is returned.
#'
#' Arguments in `...` must be named and are consumed in the following order:
#'
#' 1. All arguments whose names match the name of an argument of the constructor
#'   are passed to the `$get()` method of the [Dictionary] for construction.
#' 2. All arguments whose names match the name of a parameter of the [paradox::ParamSet] of the
#'   constructed object are set as parameters. If there is no [paradox::ParamSet] in `obj$param_set`, this
#'   step is skipped.
#' 3. All remaining arguments are assumed to be regular fields of the constructed R6 instance, and
#'   are assigned via [`<-`].
#'
#' @param dict ([Dictionary]).
#' @param .key (`character(1)`)\cr
#'   Key of the object to construct.
#' @param .keys (`character()`)\cr
#'   Keys of the objects to construct.
#' @param ... (`any`)\cr
#'   See description.
#' @param .dicts_suggest (named `list()`)
#'   Named list of [dictionaries][Dictionary] used to look up suggestions for `.key` if `.key` does not exist in `dict`.
#'
#' @return [R6::R6Class()]
#'
#' @examples
#' library(R6)
#' item = R6Class("Item", public = list(x = 0))
#' d = Dictionary$new()
#' d$add("key", item)
#' dictionary_sugar_get(d, "key", x = 2)
#'
#' @export
dictionary_sugar_get = function(dict, .key, ..., .dicts_suggest = NULL) {
  assert_class(dict, "Dictionary")
  if (missing(.key)) {
    return(dict)
  }
  assert_string(.key)
  assert_list(.dicts_suggest, "Dictionary", any.missing = FALSE, min.len = 1, unique = TRUE, names = "named", null.ok = TRUE)
  if (...length() == 0L) {
    return(dictionary_get(dict, .key, .dicts_suggest = .dicts_suggest))
  }
  dots = assert_list(list(...), .var.name = "additional arguments passed to Dictionary")
  assert_list(dots[!is.na(names2(dots))], names = "unique", .var.name = "named arguments passed to Dictionary")

  obj = dictionary_retrieve_item(dict, .key, .dicts_suggest)
  if (length(dots) == 0L) {
    return(assert_r6(dictionary_initialize_item(.key, obj)))
  }

  # pass args to constructor and remove them
  constructor_args = get_constructor_formals(obj$value)
  ii = is.na(names2(dots)) | names2(dots) %in% constructor_args
  instance = assert_r6(dictionary_initialize_item(.key, obj, dots[ii]))
  dots = dots[!ii]

  # set params in ParamSet
  if (length(dots) && exists("param_set", envir = instance, inherits = FALSE)) {
    param_ids = instance$param_set$ids()
    ii = names(dots) %in% param_ids
    if (any(ii)) {
      instance$param_set$values = insert_named(instance$param_set$values, dots[ii])
      dots = dots[!ii]
    }
  } else {
    param_ids = character()
  }

  # remaining args go into fields
  if (length(dots)) {
    ndots = names(dots)
    for (i in seq_along(dots)) {
      nn = ndots[[i]]
      if (!exists(nn, envir = instance, inherits = FALSE)) {
        stopf("Cannot set argument '%s' for '%s' (not a constructor argument, not a parameter, not a field).%s",
          nn, class(instance)[1L], did_you_mean(nn, c(constructor_args, param_ids, setdiff(names(instance), ".__enclos_env__")))) # nolint
      }
      instance[[nn]] = dots[[i]]
    }
  }

  return(instance)
}

#' @rdname dictionary_sugar_get
#' @export
dictionary_sugar = dictionary_sugar_get

#' @rdname dictionary_sugar_get
#' @export
dictionary_sugar_mget = function(dict, .keys, ..., .dicts_suggest = NULL) {
  if (missing(.keys)) {
    return(dict)
  }
  objs = lapply(.keys, dictionary_sugar_get, dict = dict, .dicts_suggest = .dicts_suggest, ...)
  if (!is.null(names(.keys))) {
    nn = names2(.keys)
    ii = which(!is.na(nn))
    for (i in ii) {
      objs[[i]]$id = nn[i]
    }
  }
  names(objs) = map_chr(objs, "id")
  objs
}

get_constructor_formals = function(x) {
  if (inherits(x, "R6ClassGenerator")) {
    # recursively search for class constructor
    while (is.null(x$public_methods$initialize)) {
      x = x$get_inherit()
      if (is.null(x)) {
        return(character())
      }
    }
    return(names2(formals(x$public_methods$initialize)))
  }

  if (is.function(x)) {
    return(names2(formals(x)))
  }

  return(character())
}

fields = function(x) {
  c(setdiff(names(x$public_methods), c("initialize", "clone", "print", "format")), names(x$active))
}

#' @title A Quick Way to Initialize Objects from Dictionaries with Incremented ID
#'
#' @description
#' Covenience wrapper around [dictionary_sugar_get] and [dictionary_sugar_mget] to allow easier avoidance of ID
#' clashes which is useful when the same object is used multiple times and the ids have to be unique.
#' Let `<key>` be the key of the object to retrieve. When passing the `<key>_<n>` to this
#' function, where `<n>` is any natural number, the object with key `<key>` is retrieved and the
#' suffix `_<n>` is appended to the id after the object is constructed.
#'
#' @param dict ([Dictionary])\cr
#'   Dictionary from which to retrieve an element.
#' @param .key (`character(1)`)\cr
#'   Key of the object to construct - possibly with a suffix of the form `_<n>` which will be appended to the id.
#' @param .keys (`character()`)\cr
#'   Keys of the objects to construct - possibly with suffixes of the form `_<n>` which will be appended to the ids.
#' @param ... (`any`)\cr
#'   See description of [mlr3misc::dictionary_sugar].
#' @param .dicts_suggest (named `list()`)
#'   Named list of [dictionaries][Dictionary] used to look up suggestions for `.key` if `.key` does not exist in `dict`.
#'
#' @return An element from the dictionary.
#'
#' @examples
#' d = Dictionary$new()
#' d$add("a", R6::R6Class("A", public = list(id = "a")))
#' d$add("b", R6::R6Class("B", public = list(id = "c")))
#' obj1 = dictionary_sugar_inc_get(d, "a_1")
#' obj1$id
#'
#' obj2 = dictionary_sugar_inc_get(d, "b_1")
#' obj2$id
#'
#' objs = dictionary_sugar_inc_mget(d, c("a_10", "b_2"))
#' map(objs, "id")
#'
#' @export
dictionary_sugar_inc_get = function(dict, .key, ..., .dicts_suggest = NULL) {
  m = regexpr("_\\d+$", .key)
  if (attr(m, "match.length") == -1L)  {
    return(dictionary_sugar_get(dict = dict, .key = .key, ..., .dicts_suggest = .dicts_suggest))
  }
  split = regmatches(.key, m, invert = NA)[[1L]]
  newkey = split[[1L]]
  suffix = split[[2L]]
  obj = dictionary_sugar_get(dict = dict, .key = newkey, ..., .dicts_suggest = .dicts_suggest)
  obj$id = paste0(obj$id, suffix)
  obj
}

#' @rdname dictionary_sugar_inc_get
#' @export
dictionary_sugar_inc_mget = function(dict, .keys, ..., .dicts_suggest = NULL) {
  objs = lapply(.keys, dictionary_sugar_inc_get, dict = dict, ..., .dicts_suggest = .dicts_suggest)
  if (!is.null(names(.keys))) {
    nn = names2(.keys)
    ii = which(!is.na(nn))
    for (i in ii) {
      objs[[i]]$id = nn[i]
    }
  }
  names(objs) = map_chr(objs, "id")
  objs
}
