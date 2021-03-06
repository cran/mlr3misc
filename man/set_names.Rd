% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/set_names.R
\name{set_names}
\alias{set_names}
\alias{set_col_names}
\title{Set Names}
\usage{
set_names(x, nm = x, ...)

set_col_names(x, nm, ...)
}
\arguments{
\item{x}{(\code{any}.)\cr
Object to set names for.}

\item{nm}{(\code{character()} | \verb{function()})\cr
New names, or a function which transforms already existing names.}

\item{...}{(\code{any})\cr
Passed down to \code{nm} if \code{nm} is a function.}
}
\value{
\code{x} with updated names.
}
\description{
Sets the names (or colnames) of \code{x} to \code{nm}.
If \code{nm} is a function, it is used to transform the already existing names of \code{x}.
}
\examples{
x = letters[1:3]

# name x with itself:
x = set_names(x)
print(x)

# convert names to uppercase
x = set_names(x, toupper)
print(x)
}
