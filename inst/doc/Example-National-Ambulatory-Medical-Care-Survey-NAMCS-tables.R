## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE
  # , comment = "#>"
)

## ----results=FALSE, message=FALSE, warning=FALSE------------------------------
library(surveytable)

## ----results='asis'-----------------------------------------------------------
set_survey(namcs2019sv)

## ----results='asis'-----------------------------------------------------------
set_opts(mode = "NCHS")

## ----results='asis'-----------------------------------------------------------
total()
tab("MDDO", "SPECCAT", "MSA")

## -----------------------------------------------------------------------------
class(uspop2019)
names(uspop2019)

## -----------------------------------------------------------------------------
uspop2019$total

## ----results='asis'-----------------------------------------------------------
total_rate(uspop2019$total)

## -----------------------------------------------------------------------------
uspop2019$MSA

## ----results='asis'-----------------------------------------------------------
tab_rate("MSA", uspop2019$MSA)

## ----results='asis'-----------------------------------------------------------
tab_rate("MDDO", uspop2019$total)
tab_rate("SPECCAT", uspop2019$total)

## ----results='asis'-----------------------------------------------------------
var_list("age")

## -----------------------------------------------------------------------------
var_cut("Age group", "AGE"
        , c(-Inf, 0, 4, 14, 64, Inf)
        , c("Under 1", "1-4", "5-14", "15-64", "65 and over") )

## ----results='asis'-----------------------------------------------------------
tab("AGER", "Age group", "SEX")
tab_cross("AGER", "SEX")

## ----results='asis'-----------------------------------------------------------
tab_rate("AGER", uspop2019$AGER)
tab_rate("Age group", uspop2019$`Age group`)
tab_rate("SEX", uspop2019$SEX)

## -----------------------------------------------------------------------------
uspop2019$`AGER x SEX`

## ----results='asis'-----------------------------------------------------------
tab_subset_rate("AGER", "SEX", uspop2019$`AGER x SEX`)

## ----results='asis'-----------------------------------------------------------
#
var_all("Medicare and Medicaid", c("PAYMCARE", "PAYMCAID"))

#
var_any("Payment used", c("PAYPRIV", "PAYMCARE", "PAYMCAID"
  , "PAYWKCMP", "PAYOTH", "PAYDK"))
var_not("No other payment used", "Payment used")

var_all("Self-pay", c("PAYSELF", "No other payment used"))
var_all("No charge", c("PAYNOCHG", "No other payment used"))
var_any("No insurance", c("Self-pay", "No charge"))

#
var_case("No pay", "NOPAY", "No categories marked")
var_any("Unknown or blank", c("PAYDK", "No pay"))

##
tab("PAYPRIV", "PAYMCARE", "PAYMCAID", "Medicare and Medicaid"
  , "No insurance", "Self-pay", "No charge"
  , "PAYWKCMP", "PAYOTH", "Unknown or blank")

## -----------------------------------------------------------------------------
var_collapse("PRIMCARE", "Unknown if PCP", c("Unknown", "Blank"))
var_collapse("REFER", "Unknown if referred", c("Unknown", "Blank"))

## ----results='asis'-----------------------------------------------------------
tab("PRIMCARE", "REFER", "SENBEFOR")

## ----results='asis'-----------------------------------------------------------
tab_subset("PRIMCARE", "SENBEFOR")
tab_subset("REFER", "SENBEFOR")

## -----------------------------------------------------------------------------
var_cut("Age group", "AGE"
        , c(-Inf, 0, 4, 14, 64, Inf)
        , c("Under 1", "1-4", "5-14", "15-64", "65 and over") )
var_cross("Age x Sex", "AGER", "SEX")

## ----results='asis'-----------------------------------------------------------
tab("MAJOR")

## ----results='asis'-----------------------------------------------------------
tab_subset("AGER", "MAJOR", "Preventive care")
tab_subset("Age group", "MAJOR", "Preventive care")
tab_subset("SEX", "MAJOR", "Preventive care")
tab_subset("Age x Sex", "MAJOR", "Preventive care")

## ----results='asis'-----------------------------------------------------------
for (vr in c("AGER", "Age group", "SEX", "Age x Sex")) {
	print( tab_subset(vr, "MAJOR", "Preventive care") )
}

## -----------------------------------------------------------------------------
for (vr in c("AGER", "Age group", "SEX", "Age x Sex")) {
	var_cross("tmp", "MAJOR", vr)
	for (lvl in levels(surveytable:::env$survey$variables[,vr])) {
		tab_subset("SPECCAT", "tmp", paste0("Preventive care: ", lvl))
	}
}
set_opts(csv = "")

## ----results='asis'-----------------------------------------------------------
vr = "AGER"
var_cross("tmp", "MAJOR", vr)
lvl = levels(surveytable:::env$survey$variables[,vr])[1]
tab_subset("SPECCAT", "tmp", paste0("Preventive care: ", lvl))

