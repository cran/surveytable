% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/svyciprop_adjusted.R
\name{svyciprop_adjusted}
\alias{svyciprop_adjusted}
\title{Confidence intervals for proportions, adjusted for degrees of freedom}
\usage{
svyciprop_adjusted(
  formula,
  design,
  method = c("logit", "likelihood", "asin", "beta", "mean", "xlogit"),
  level = 0.95,
  df_method,
  ...
)
}
\arguments{
\item{formula}{see \code{survey::svyciprop()}.}

\item{design}{see \code{survey::svyciprop()}.}

\item{method}{see \code{survey::svyciprop()}.}

\item{level}{see \code{survey::svyciprop()}.}

\item{df_method}{how \code{df} should be calculated: "default" or "NHIS".}

\item{...}{see \code{survey::svyciprop()}.

\code{df_method}: for "default", \code{df = degf(design)}; for "NHIS", \code{df = nrow(design) - 1}.}
}
\value{
The point estimate of the proportion, with the confidence interval as an attribute.
}
\description{
A version of \code{survey::svyciprop()} that adjusts for the degrees of freedom when \code{method = "beta"}.
}
\details{
Written by Makram Talih in 2019.

To use this function in tabulations, type: \code{options(surveytable.adjust_svyciprop = TRUE)}.
}
\examples{
set_survey(namcs2019sv)
options(surveytable.adjust_svyciprop = TRUE)
tab("AGER")
options(surveytable.adjust_svyciprop = FALSE)
tab("AGER")
}
