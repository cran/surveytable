## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE
  # , comment = "#>"
)

## -----------------------------------------------------------------------------
library(surveytable)

## ----results='asis'-----------------------------------------------------------
set_survey(rccsu2018)

## ----results='asis'-----------------------------------------------------------
set_opts(mode = "NCHS")

## ----results='asis'-----------------------------------------------------------
set_survey(rccsu2018, mode = "NCHS")

## ----results='asis'-----------------------------------------------------------
tab("sex")

## ----results='asis'-----------------------------------------------------------
var_list("race")
tab("raceeth2")

## ----results='asis'-----------------------------------------------------------
var_collapse("raceeth2"
             , "Another race or ethnicity"
             , c("Hispanic", "Other"))
tab("raceeth2")

## ----results='asis'-----------------------------------------------------------
var_list("age")

## ----results='asis'-----------------------------------------------------------
var_cut("Age", "age2"
        , c(-Inf, 64, 74, 84, Inf)
        , c("Under 65", "65-74", "75-84", "85 and over") )
tab("Age")

## ----results='asis'-----------------------------------------------------------
tab("medicaid2")

## ----results='asis'-----------------------------------------------------------
tab("medicaid2", drop_na = TRUE)

## ----results='asis'-----------------------------------------------------------
tab_subset("medicaid2", "Age", drop_na = TRUE)

## ----results='asis'-----------------------------------------------------------
tab("hbp")

## ----results='asis'-----------------------------------------------------------
tab("hbp", "alz", "depress", "arth", "diabetes", "heartdise", "osteo"
    , "copd", "stroke", "cancer"
    , drop_na = TRUE)

## -----------------------------------------------------------------------------
class(rccsu2018$variables)

## ----results='asis'-----------------------------------------------------------
rccsu2018$variables$num_cc = 0
for (vr in c("hbp", "alz", "depress", "arth", "diabetes", "heartdise", "osteo"
             , "copd", "stroke", "cancer")) {
  idx = which(rccsu2018$variables[,vr])
  rccsu2018$variables$num_cc[idx] = rccsu2018$variables$num_cc[idx] + 1
}
set_survey(rccsu2018, mode = "NCHS")

## ----results='asis'-----------------------------------------------------------
var_cut("Number of chronic conditions", "num_cc"
        , c(-Inf, 0, 1, 3, 10, Inf)
        , c("0", "1", "2-3", "4-10", "??"))
tab("Number of chronic conditions")

## ----results='asis'-----------------------------------------------------------
tab("bathhlp")

## ----results='asis'-----------------------------------------------------------
for (vr in c("bathhlp", "walkhlp", "dreshlp", "transhlp", "toilhlp", "eathlp")) {
  var_collapse(vr
    , "Needs assistance"
    , c("NEED HELP OR SUPERVISION FROM ANOTHER PERSON"
      , "USE OF AN ASSISTIVE DEVICE"
      , "BOTH"))
  var_collapse(vr, NA, "MISSING")
}

tab("bathhlp", "walkhlp", "dreshlp", "transhlp", "toilhlp", "eathlp", drop_na = TRUE)

## ----results='asis'-----------------------------------------------------------
rccsu2018$variables$num_adl = 0
for (vr in c("bathhlp", "walkhlp", "dreshlp", "transhlp", "toilhlp", "eathlp")) {
  idx = which(rccsu2018$variables[,vr] %in%
    c("NEED HELP OR SUPERVISION FROM ANOTHER PERSON"
      , "USE OF AN ASSISTIVE DEVICE"
      , "BOTH"))
  rccsu2018$variables$num_adl[idx] = rccsu2018$variables$num_adl[idx] + 1
}
set_survey(rccsu2018, mode = "NCHS")

## ----results='asis'-----------------------------------------------------------
var_cut("Number of ADLs", "num_adl"
        , c(-Inf, 0, 2, 6, Inf)
        , c("0", "1-2", "3-6", "??"))
tab("Number of ADLs")

