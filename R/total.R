#' Total count
#'
#' @param csv     name of a CSV file
#'
#' @return A table
#' @family tables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' total()
total = function(csv = getOption("surveytable.csv") ) {
  design = .load_survey()
  m1 = .total(design)
  assert_that(ncol(m1) %in% c(4L, 5L))
  attr(m1, "num") = 1:4
  attr(m1, "title") = "Total"

  .write_out(m1, csv = csv)
}

.total = function(design) {
  design$variables$Total = 1

  ##
  counts = nrow(design$variables)
  if (getOption("surveytable.check_present")) {
    pro = getOption("surveytable.present_restricted") %>% do.call(list(counts))
  } else {
    pro = list(flags = rep("", length(counts)), has.flag = c())
  }

  ##
  sto = svytotal(~Total, design) # , deff = TRUE)
  mmcr = data.frame(x = as.numeric(sto)
              , s = sqrt(diag(attr(sto, "var"))) )
  mmcr$samp.size = .calc_samp_size(design = design, vr = "Total", counts = counts)
  mmcr$counts = counts

  df1 = degf(design)
  mmcr$degf = df1

  # Equation 24 https://www.cdc.gov/nchs/data/series/sr_02/sr02-200.pdf
  # DF should be as here, not just sample size.
  mmcr$k = qt(0.975, pmax(mmcr$samp.size - 1, 0.1)) * mmcr$s / mmcr$x
  mmcr$lnx = log(mmcr$x)
  mmcr$ll = exp(mmcr$lnx - mmcr$k)
  mmcr$ul = exp(mmcr$lnx + mmcr$k)

  if (getOption("surveytable.check_present")) {
    pco = getOption("surveytable.present_count") %>% do.call(list(mmcr))
  } else {
    pco = list(flags = rep("", nrow(mmcr)), has.flag = c())
  }

  mmcr = mmcr[,c("x", "s", "ll", "ul")]
  mmc = getOption("surveytable.tx_count") %>% do.call(list(mmcr))
  names(mmc) = getOption("surveytable.names_count")

  ##
  assert_that(nrow(mmc) == 1
              , nrow(mmcr) == 1
              , nrow(mmc) == length(pro$flags)
              , nrow(mmc) == length(pco$flags))

  mp = mmc
  flags = paste(pro$flags, pco$flags) %>% trimws
  if (any(nzchar(flags))) {
    mp$Flags = flags
  }
  mp %<>% .add_flags( c(pro$has.flag, pco$has.flag) )

  ##
  rownames(mp) = NULL
  mp
}
