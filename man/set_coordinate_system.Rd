% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aurin_helpers.R
\name{set_coordinate_system}
\alias{set_coordinate_system}
\title{Set the coordinate system for a simple features dataset.}
\usage{
set_coordinate_system(data, srid)
}
\arguments{
\item{data}{simple features dataset}

\item{srid}{A numeric identifier of a coordinate system}
}
\value{
A simple features file
}
\description{
Set the coordinate system for a simple features dataset.
}
\examples{
\dontrun{set_coordinate_system(aurin_data, srid = 4326)}
}
