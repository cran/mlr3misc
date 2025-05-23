% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/printf.R
\name{printf}
\alias{printf}
\alias{catf}
\alias{messagef}
\alias{warningf}
\alias{stopf}
\title{Functions for Formatted Output and Conditions}
\usage{
catf(msg, ..., file = "", wrap = FALSE)

messagef(msg, ..., wrap = FALSE, class = NULL)

warningf(msg, ..., wrap = FALSE, class = NULL)

stopf(msg, ..., wrap = FALSE, class = NULL)
}
\arguments{
\item{msg}{(\code{character(1)})\cr
Format string passed to \code{\link[base:sprintf]{base::sprintf()}}.}

\item{...}{(\code{any})\cr
Arguments passed down to \code{\link[base:sprintf]{base::sprintf()}}.}

\item{file}{(\code{character(1)})\cr
Passed to \code{\link[base:cat]{base::cat()}}.}

\item{wrap}{(\code{integer(1)} | \code{logical(1)})\cr
If set to a positive integer, \code{\link[base:strwrap]{base::strwrap()}} is used to wrap the string to the provided width.
If set to \code{TRUE}, the width defaults to \code{0.9 * getOption("width")}.
If set to \code{FALSE}, wrapping is disabled (default).
If wrapping is enabled, all whitespace characters (\verb{[[:space:]]}) are converted to spaces,
and consecutive spaces are converted to a single space.}

\item{class}{(\code{character()})\cr
Class of the condition (for errors and warnings).}
}
\description{
\code{catf()}, \code{messagef()}, \code{warningf()} and \code{stopf()} are wrappers around \code{\link[base:cat]{base::cat()}},
\code{\link[base:message]{base::message()}}, \code{\link[base:warning]{base::warning()}} and \code{\link[base:stop]{base::stop()}}, respectively.
}
\details{
For leanified R6 classes, the call included in the condition is the method call
and not the call into the leanified method.
}
\section{Errors and Warnings}{

Errors and warnings get the classes \verb{mlr3\{error, warning\}} and also inherit from
\verb{simple\{Error, Warning\}}.
It is possible to give errors and warnings their own class via the \code{class} argument.
Doing this, allows to suppress selective conditions via calling handlers, see e.g.
\code{\link{globalCallingHandlers}}.

When a function throws such a condition that the user might want to disable,
a section \emph{Errors and Warnings} should be included in the function documention,
describing the condition and its class.
}

\examples{
messagef("
  This is a rather long \%s
  on multiple lines
  which will get wrapped.
", "string", wrap = 15)
}
