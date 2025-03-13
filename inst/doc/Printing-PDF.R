## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----results='asis', echo=FALSE, message=FALSE--------------------------------
library(surveytable)
set_opts(output = "kableExtra")
set_survey(namcs2019sv)

## ----results='asis'-----------------------------------------------------------
tab("AGER")

## ----results='asis'-----------------------------------------------------------
for (vr in c("AGER", "SEX")) {
  print( tab_subset(vr, "MAJOR", "Preventive care") )
}

## -----------------------------------------------------------------------------
set_opts(output = "kableExtra")

## ----results='asis', echo=FALSE-----------------------------------------------
tab("AGER")

## -----------------------------------------------------------------------------
set_opts(output = "auto")

## ----results='asis', echo=FALSE-----------------------------------------------
tab("AGER")

## -----------------------------------------------------------------------------
tab("AGER") |> as.data.frame()

## -----------------------------------------------------------------------------
set_opts(count = "1k")
tab("AGER") |> gt::gt()

## ----results='asis', echo=FALSE-----------------------------------------------
tab("AGER")

## ----results='asis', echo=FALSE-----------------------------------------------
tab("AGER")

