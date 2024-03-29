% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/catn.R
\name{catn}
\alias{catn}
\title{Function for Formatted Output}
\usage{
catn(..., file = "")
}
\arguments{
\item{...}{(\code{any})\cr
Arguments passed down to \code{\link[base:paste]{base::paste0()}}.}

\item{file}{(\code{character(1)})\cr
Passed to \code{\link[base:cat]{base::cat()}}.}
}
\description{
Wrapper around \code{\link[base:cat]{base::cat()}} with a line break.
Elements are converted to character and concatenate with \code{\link[base:paste]{base::paste0()}}.
If a vector is passed, elements are collapsed with line breaks.
}
\examples{
catn(c("Line 1", "Line 2"))
}
