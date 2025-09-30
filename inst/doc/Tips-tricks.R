## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE
  # , comment = "#>"
)

## ----results='asis', message=FALSE--------------------------------------------
library(surveytable)
set_survey(namcs2019sv)
tab_subset("AGER", "SPECCAT", test = "65-74 years")

## ----results='asis', message=FALSE--------------------------------------------
library(surveytable)
set_survey(namcs2019sv)

## ----echo=FALSE---------------------------------------------------------------
set_opts(output = "raw")
print( tab("SPECCAT", test = TRUE), destination = "")
set_opts(reset = TRUE)

## ----results='asis', message=FALSE--------------------------------------------
library(surveytable)
set_survey(namcs2019sv)

## ----results='asis'-----------------------------------------------------------
tab_subset("NUMMED", "AGER")

## ----results='asis'-----------------------------------------------------------
newsurvey = survey_subset(namcs2019sv, NUMMED > 0
  , label = "NAMCS 2019 PUF: NUMMED 1+")
set_survey(newsurvey)

## ----results='asis'-----------------------------------------------------------
tab_subset("NUMMED", "AGER")

