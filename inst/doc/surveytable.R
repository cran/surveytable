## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
head(iris)

## ---- results=FALSE, message=FALSE, warning=FALSE-----------------------------
library("surveytable")

## -----------------------------------------------------------------------------
class(namcs2019sv_df$AGER)
class(namcs2019sv_df$PAYNOCHG)
class(namcs2019sv_df$AGE)

## -----------------------------------------------------------------------------
attr(namcs2019sv_df$AGE, "label")

## -----------------------------------------------------------------------------
mysurvey = survey::svydesign(ids = ~ CPSUM
  , strata = ~ CSTRATM
  , weights = ~ PATWT
  , data = namcs2019sv_df)

## -----------------------------------------------------------------------------
attr(mysurvey, "label") = "NAMCS 2019 PUF"

## -----------------------------------------------------------------------------
identical(namcs2019sv, mysurvey)

## -----------------------------------------------------------------------------
set_survey(namcs2019sv)

## ---- results='asis'----------------------------------------------------------
var_list("age")

## ---- results='asis'----------------------------------------------------------
tab("AGER")

## ---- results='asis'----------------------------------------------------------
tab("PAYNOCHG")

## ---- results='asis'----------------------------------------------------------
tab("SPECCAT.bad")

## ---- results='asis'----------------------------------------------------------
tab("SPECCAT.bad", drop_na = TRUE)

## ---- results='asis'----------------------------------------------------------
tab("MDDO", "SPECCAT", "MSA")

## ---- results='asis'----------------------------------------------------------
total()

## ---- results='asis'----------------------------------------------------------
tab_subset("AGER", "SEX")

## ---- results='asis'----------------------------------------------------------
tab_cross("AGER", "SEX")

## ---- results='asis'----------------------------------------------------------
tab("NUMMED")

## ---- results='asis'----------------------------------------------------------
tab_subset("NUMMED", "AGER")

## ---- results='asis'----------------------------------------------------------
tab_subset("AGER", "SPECCAT", test = TRUE)

## ---- results='asis'----------------------------------------------------------
tab_subset("MRI", "SPECCAT", test = TRUE)

## ---- results='asis'----------------------------------------------------------
tab_subset("NUMMED", "AGER", test = TRUE)

## ---- results='asis'----------------------------------------------------------
tab_subset("NUMMED", "SPECCAT", test = TRUE)

## ---- results='asis'----------------------------------------------------------
tab("SPECCAT", test = TRUE)

## -----------------------------------------------------------------------------
class(uspop2019)
names(uspop2019)

## -----------------------------------------------------------------------------
uspop2019$total

## ---- results='asis'----------------------------------------------------------
total_rate(uspop2019$total)

## -----------------------------------------------------------------------------
uspop2019$AGER

## ---- results='asis'----------------------------------------------------------
tab_rate("AGER", uspop2019$AGER)

## -----------------------------------------------------------------------------
uspop2019$`AGER x SEX`

## ---- results='asis'----------------------------------------------------------
tab_subset_rate("AGER", "SEX", uspop2019$`AGER x SEX`)

## ---- results='asis'----------------------------------------------------------
tab("MAJOR")

## ---- results='asis'----------------------------------------------------------
var_case("Preventive care visits", "MAJOR", "Preventive care")
tab("Preventive care visits")

## ---- results='asis'----------------------------------------------------------
var_case("Surgery-related visits"
  , "MAJOR"
  , c("Pre-surgery", "Post-surgery"))
tab("Surgery-related visits")

## ---- results='asis'----------------------------------------------------------
tab("PRIMCARE")

## ---- results='asis'----------------------------------------------------------
var_collapse("PRIMCARE", "Unknown if PCP", c("Unknown", "Blank"))
tab("PRIMCARE")

## ---- results='asis'----------------------------------------------------------
tab("AGE")

## ---- results='asis'----------------------------------------------------------
var_cut("Age group", "AGE"
        , c(-Inf, 0, 4, 14, 64, Inf)
        , c("Under 1", "1-4", "5-14", "15-64", "65 and over") )
tab("Age group")

## ---- results='asis'----------------------------------------------------------
var_any("Imaging services"
  , c("ANYIMAGE", "BONEDENS", "CATSCAN", "ECHOCARD", "OTHULTRA"
  , "MAMMO", "MRI", "XRAY", "OTHIMAGE"))
tab("Imaging services")

## -----------------------------------------------------------------------------
var_cross("Age x Sex", "AGER", "SEX")

## ---- results='asis'----------------------------------------------------------
var_copy("Age group", "AGER")
var_collapse("Age group", "65+", c("65-74 years", "75 years and over"))
var_collapse("Age group", "25-64", c("25-44 years", "45-64 years"))
tab("AGER", "Age group")

## -----------------------------------------------------------------------------
class(namcs2019sv$variables)

## -----------------------------------------------------------------------------
namcs2019sv$variables$`Medicare and Medicaid` = ( 
  namcs2019sv$variables$PAYMCARE & namcs2019sv$variables$PAYMCAID)
set_survey(namcs2019sv)

## ---- results='asis'----------------------------------------------------------
tab("Medicare and Medicaid")

## -----------------------------------------------------------------------------
var_cross("newvar", "MAJOR", "AGER")
# This should give NULL. The new variable does not exist here:
namcs2019sv$variables$newvar
# Rather, the new variable is here:
str(surveytable:::env$survey$variables$newvar)

## -----------------------------------------------------------------------------
tmp_file = tempfile(fileext = ".csv")
suppressMessages( set_output(csv = tmp_file) )

## ---- results='asis'----------------------------------------------------------
tab("MDDO", "SPECCAT", "MSA")

## -----------------------------------------------------------------------------
set_output(csv = "")

