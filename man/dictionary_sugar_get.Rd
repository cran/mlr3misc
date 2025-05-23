% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dictionary_sugar.R
\name{dictionary_sugar_get}
\alias{dictionary_sugar_get}
\alias{dictionary_sugar}
\alias{dictionary_sugar_mget}
\title{A Quick Way to Initialize Objects from Dictionaries}
\usage{
dictionary_sugar_get(dict, .key, ..., .dicts_suggest = NULL)

dictionary_sugar(dict, .key, ..., .dicts_suggest = NULL)

dictionary_sugar_mget(dict, .keys, ..., .dicts_suggest = NULL)
}
\arguments{
\item{dict}{(\link{Dictionary}).}

\item{.key}{(\code{character(1)})\cr
Key of the object to construct.}

\item{...}{(\code{any})\cr
See description.}

\item{.dicts_suggest}{(named \code{list()})
Named list of \link[=Dictionary]{dictionaries} used to look up suggestions for \code{.key} if \code{.key} does not exist in \code{dict}.}

\item{.keys}{(\code{character()})\cr
Keys of the objects to construct.}
}
\value{
\code{\link[R6:R6Class]{R6::R6Class()}}
}
\description{
Given a \link{Dictionary}, retrieve objects with provided keys.
\itemize{
\item \code{dictionary_sugar_get()} to retrieve a single object with key \code{.key}.
\item \code{dictionary_sugar_mget()} to retrieve a list of objects with keys \code{.keys}.
\item \code{dictionary_sugar()} is deprecated in favor of \code{dictionary_sugar_get()}.
\item If \code{.key} or \code{.keys} is missing, the dictionary itself is returned.
}

Arguments in \code{...} must be named and are consumed in the following order:
\enumerate{
\item All arguments whose names match the name of an argument of the constructor
are passed to the \verb{$get()} method of the \link{Dictionary} for construction.
\item All arguments whose names match the name of a parameter of the \link[paradox:ParamSet]{paradox::ParamSet} of the
constructed object are set as parameters. If there is no \link[paradox:ParamSet]{paradox::ParamSet} in \code{obj$param_set}, this
step is skipped.
\item All remaining arguments are assumed to be regular fields of the constructed R6 instance, and
are assigned via \code{\link{<-}}.
}
}
\examples{
library(R6)
item = R6Class("Item", public = list(x = 0))
d = Dictionary$new()
d$add("key", item)
dictionary_sugar_get(d, "key", x = 2)

}
