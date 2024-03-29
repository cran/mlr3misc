% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/enframe.R
\name{enframe}
\alias{enframe}
\alias{deframe}
\title{Convert a Named Vector into a data.table and Vice Versa}
\usage{
enframe(x, name = "name", value = "value")

deframe(x)
}
\arguments{
\item{x}{(\code{vector()} (\code{enframe()}) or \code{data.frame()} (\code{deframe()}))\cr
Vector to convert to a \code{\link[data.table:data.table]{data.table::data.table()}}.}

\item{name}{(\code{character(1)})\cr
Name for the first column with names.}

\item{value}{(\code{character(1)})\cr
Name for the second column with values.}
}
\value{
\code{\link[data.table:data.table]{data.table::data.table()}} or named \code{vector}.
}
\description{
\code{enframe()} returns a \code{\link[data.table:data.table]{data.table::data.table()}} with two columns:
The names of \code{x} (or \code{seq_along(x)} if unnamed) and the values of \code{x}.

\code{deframe()} converts a two-column data.frame to a named vector.
If the data.frame only has a single column, an unnamed vector is returned.
}
\examples{
x = 1:3
enframe(x)

x = set_names(1:3, letters[1:3])
enframe(x, value = "x_values")
}
