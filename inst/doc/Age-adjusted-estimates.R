## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----results='asis'-----------------------------------------------------------
library(surveytable)

set_survey(nhis2024a)
set_opts(mode = "nchs", adj = "nhis")

tab("dis3_indicator")

## ----results='asis'-----------------------------------------------------------
tab("alot_diff")

## ----results='asis'-----------------------------------------------------------
tab_subset("dis3_indicator", "sex_a")

## ----results='asis'-----------------------------------------------------------
tab_subset("alot_diff", "sex_a")

## ----results='asis'-----------------------------------------------------------
tab("age_group_std")

## -----------------------------------------------------------------------------
uspop_example$age_group_std

## ----results='asis', message=FALSE--------------------------------------------
set_survey(
  nhis2024a
  , aa_vr = "age_group_std"
  , aa_pop = uspop_example$age_group_std
)
set_opts(mode = "nchs", adj = "nhis")

## ----results='asis'-----------------------------------------------------------
tab("dis3_indicator")

## ----results='asis'-----------------------------------------------------------
tab("alot_diff")

## ----results='asis'-----------------------------------------------------------
tab_subset("dis3_indicator", "sex_a")

## ----results='asis'-----------------------------------------------------------
tab_subset("alot_diff", "sex_a")

## ----results='asis'-----------------------------------------------------------
tab("age_group_std")

## -----------------------------------------------------------------------------
uspop_example$age_group_std_prop

## ----results='asis', message=FALSE--------------------------------------------
set_survey(
  nhis2024a
  , aa_vr = "age_group_std"
  , aa_pop = uspop_example$age_group_std_prop
)
set_opts(mode = "nchs", adj = "nhis")

tab("dis3_indicator")

