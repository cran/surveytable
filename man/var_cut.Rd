% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/var_cut.R
\name{var_cut}
\alias{var_cut}
\title{Convert numeric to factor}
\usage{
var_cut(newvr, vr, breaks, labels)
}
\arguments{
\item{newvr}{name of the new factor variable to be created}

\item{vr}{numeric variable}

\item{breaks}{see \code{\link[=cut]{cut()}}}

\item{labels}{see \code{\link[=cut]{cut()}}}
}
\value{
Survey object
}
\description{
Create a new categorical variable based on a numeric variable.
}
\examples{
set_survey(namcs2019sv)
# In some data systems, variables might contain "special values". For example,
# negative values might indicate unknowns (which should be coded as `NA`).
# Though in this particular data, there are no unknowns.
var_cut("Age group"
  , "AGE"
  , c(-Inf, -0.1, 0, 4, 14, 64, Inf)
  , c(NA, "Under 1", "1-4", "5-14", "15-64", "65 and over"))
tab("Age group")
}
\seealso{
Other variables: 
\code{\link{var_all}()},
\code{\link{var_any}()},
\code{\link{var_case}()},
\code{\link{var_collapse}()},
\code{\link{var_copy}()},
\code{\link{var_cross}()},
\code{\link{var_not}()}
}
\concept{variables}
