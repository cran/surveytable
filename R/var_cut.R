#' Convert numeric to factor
#'
#' Create a new categorical variable based on a numeric variable.
#'
#' @param newvr   name of the new factor variable to be created
#' @param vr numeric variable
#' @param breaks see [`cut()`]
#' @param labels see [`cut()`]
#'
#' @return Survey object
#' @family variables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' # In some data systems, variables might contain "special values". For example,
#' # negative values might indicate unknowns (which should be coded as `NA`).
#' # Though in this particular data, there are no unknowns.
#' var_cut("Age group"
#'   , "AGE"
#'   , c(-Inf, -0.1, 0, 4, 14, 64, Inf)
#'   , c(NA, "Under 1", "1-4", "5-14", "15-64", "65 and over"))
#' tab("Age group")
var_cut = function(newvr, vr, breaks, labels) {
  design = .load_survey()
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(is.numeric(design$variables[,vr])
            , msg = paste0(vr, ": must be numeric. Is ", class(design$variables[,vr])[1] ))
  if(newvr %in% nm) {
    warning(newvr, ": overwriting a variable that already exists.")
  }

  design$variables[,newvr] = cut(x = design$variables[,vr]
                                 , breaks = breaks, labels = labels)
  # attr(design$variables[,newvr], "label") = paste(.getvarname(design, vr), "(categorized)")
  env$survey = design
}
