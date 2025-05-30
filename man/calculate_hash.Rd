% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_hash.R
\name{calculate_hash}
\alias{calculate_hash}
\title{Calculate a Hash for Multiple Objects}
\usage{
calculate_hash(...)
}
\arguments{
\item{...}{(\code{any})\cr
Objects to hash.}
}
\value{
(\code{character(1)}).
}
\description{
Calls \code{\link[digest:digest]{digest::digest()}} using the 'xxhash64' algorithm after applying \code{\link{hash_input}} to each object.
To customize the hashing behaviour, you can overwrite \code{\link{hash_input}} for specific classes.
For \code{data.table} objects, \code{\link{hash_input}} is applied to all columns, so you can overwrite \code{\link{hash_input}} for
columns of a specific class.
Objects that don't have a specific method are hashed as is.
}
\examples{
calculate_hash(iris, 1, "a")
}
