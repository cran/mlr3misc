#' @title Key-Value Storage
#'
#' @description
#' A key-value store for [R6::R6] objects.
#' On retrieval of an object, the following applies:
#'
#' * If the object is a `R6ClassGenerator`, it is initialized with `new()`.
#' * If the object is a function, it is called and must return an instance of a [R6::R6] object.
#' * If the object is an instance of a R6 class, it is returned as-is.
#'
#' Default argument required for construction can be stored alongside their constructors by passing them to `$add()`.
#'
#' @section S3 methods:
#' * `as.data.table(d)`\cr
#'   [Dictionary] -> [data.table::data.table()]\cr
#'   Converts the dictionary to a [data.table::data.table()].
#'
#' @family Dictionary
#' @export
#' @examples
#' library(R6)
#' item1 = R6Class("Item", public = list(x = 1))
#' item2 = R6Class("Item", public = list(x = 2))
#' d = Dictionary$new()
#' d$add("a", item1)
#' d$add("b", item2)
#' d$add("c", item1$new())
#' d$keys()
#' d$get("a")
#' d$mget(c("a", "b"))
Dictionary = R6::R6Class("Dictionary",
  public = list(
    #' @field items (`environment()`)\cr
    #' Stores the items of the dictionary
    items = NULL,

    #' @description
    #' Construct a new Dictionary.
    initialize = function() {
      self$items = new.env(parent = emptyenv())
    },

    #' @description
    #' Format object as simple string.
    #' @param ... (ignored).
    format = function(...) {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Print object.
    print = function() {
      keys = self$keys()
      catf(sprintf("%s with %i stored values", format(self), length(keys)))
      catf(str_indent("Keys:", keys))
    },

    #' @description
    #' Returns all keys which comply to the regular expression `pattern`.
    #' If `pattern` is `NULL` (default), all keys are returned.
    #'
    #' @param pattern (`character(1)`).
    #'
    #' @return `character()` of keys.
    keys = function(pattern = NULL) {
      keys = ls(self$items, all.names = TRUE)
      if (!is.null(pattern)) {
        assert_string(pattern)
        keys = keys[grepl(pattern, keys)]
      }
      keys
    },

    #' @description
    #' Returns a logical vector with `TRUE` at its i-th position if the i-th key exists.
    #'
    #' @param keys (`character()`).
    #'
    #' @return `logical()`.
    has = function(keys) {
      assert_character(keys, min.chars = 1L, any.missing = FALSE)
      set_names(map_lgl(keys, exists, envir = self$items, inherits = FALSE), keys)
    },

    #' @description
    #' Retrieves object with key `key` from the dictionary.
    #' Additional arguments must be named and are passed to the constructor of the stored object.
    #'
    #' @param key (`character(1)`).
    #'
    #' @param ... (`any`)\cr
    #' Passed down to constructor.
    #'
    #' @param .prototype (`logical(1)`)\cr
    #'   Whether to construct a prototype object.
    #'
    #' @return Object with corresponding key.
    get = function(key, ..., .prototype = FALSE) {
      assert_string(key, min.chars = 1L)
      assert_flag(.prototype)
      args = list(...)
      if (.prototype) {
        args = insert_named(self$prototype_args(key), args)
      }

      invoke(dictionary_get, self = self, key = key, .args = args)
    },

    #' @description
    #' Returns objects with keys `keys` in a list named with `keys`.
    #' Additional arguments must be named and are passed to the constructors of the stored objects.
    #'
    #' @param keys (`character()`).
    #'
    #' @param ... (`any`)\cr
    #' Passed down to constructor.
    #'
    #' @return Named `list()` of objects with corresponding keys.
    mget = function(keys, ...) {
      assert_character(keys, min.chars = 1L, any.missing = FALSE)
      set_names(lapply(keys, self$get, ...), keys)
    },

    #' @description
    #' Adds object `value` to the dictionary with key `key`, potentially overwriting a previously stored item.
    #' Additional arguments in `...` must be named and are passed as default arguments to `value` during construction.
    #'
    #' @param key (`character(1)`).
    #'
    #' @param value (`any`).
    #'
    #' @param ... (`any`)\cr
    #' Passed down to constructor.
    #'
    #' @param .prototype_args (`list()`)\cr
    #'   List of arguments to construct a prototype object.
    #'   Can be used when objects have construction arguments without defaults.
    #'
    #' @return `Dictionary`.
    add = function(key, value, ..., .prototype_args = list()) {
      assert_string(key, min.chars = 1L)
      assert(check_class(value, "R6ClassGenerator"), check_r6(value), check_function(value))

      dots = assert_list(list(...), names = "unique", .var.name = "additional arguments passed to Dictionary")
      assert_list(.prototype_args, names = "unique", .var.name = "prototype arguments")
      assign(x = key, value = list(value = value, pars = dots, prototype_args = .prototype_args), envir = self$items) # nolint
      invisible(self)
    },

    #' @description
    #' Removes objects with from the dictionary.
    #'
    #' @param keys (`character()`)\cr
    #' Keys of objects to remove.
    #'
    #' @return `Dictionary`.
    remove = function(keys) {
      i = wf(!self$has(keys))
      if (length(i)) {
        stopf("Element with key '%s' not found!%s", keys[i], did_you_mean(key, self$keys()))
      }
      rm(list = keys, envir = self$items)
      invisible(self)
    },

    #' @description
    #' Returns the arguments required to construct a simple prototype of the object.
    #'
    #' @param key (`character(1)`)\cr
    #'   Key of object to query for required arguments.
    #'
    #' @return `list()` of prototype arguments
    prototype_args = function(key) {
      assert_string(key, min.chars = 1L)
      self$items[[key]][["prototype_args"]]
    }
  )
)

dictionary_get = function(self, key, ..., .dicts_suggest = NULL) {
  obj = dictionary_retrieve_item(self, key, .dicts_suggest)
  dots = assert_list(list(...), names = "unique", .var.name = "arguments passed to Dictionary")
  dictionary_initialize_item(key, obj, dots)
}

dictionary_retrieve_item = function(self, key, dicts_suggest = NULL) {
  obj = get0(key, envir = self$items, inherits = FALSE, ifnotfound = NULL)
  if (is.null(obj)) {
    stopf("Element with key '%s' not found in %s!%s%s", key, class(self)[1L],
          did_you_mean(key, self$keys()),
          did_you_mean_dicts(key, dicts_suggest))
  }
  obj
}

dictionary_initialize_item = function(key, obj, cargs = list()) {
  cargs = c(cargs[is.na(names2(cargs))],
    insert_named(obj$pars, cargs[!is.na(names2(cargs))]))

  constructor = obj$value
  if (inherits(constructor, "R6ClassGenerator")) {
    do.call(constructor$new, cargs)
  } else if (is.function(constructor)) {
    do.call(constructor, cargs)
  } else if (is.R6(constructor) && exists("clone", envir = constructor)) {
    constructor$clone(deep = TRUE)
  } else {
    constructor
  }
}

#' @export
as.data.table.Dictionary = function(x, ...) {
  setkeyv(as.data.table(list(key = x$keys())), "key")[]
}
