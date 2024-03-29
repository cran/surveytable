#' Tabulate variables
#'
#' Tabulate categorical (factor), logical, or numeric variables.
#'
#' For categorical and logical variables, presents the
#' estimated counts, their standard errors (SEs) and confidence
#' intervals (CIs), percentages, and their SEs and CIs. Checks
#' the presentation guidelines for counts and percentages and flags
#' estimates if, according to the guidelines,
#' they should be suppressed, footnoted, or reviewed by an analyst.
#'
#' For numeric variables, presents the percentage of observations with
#' known values, the mean of known values, the standard error of the mean (SEM), and
#' the standard deviation (SD).
#'
#' CIs are calculated at the 95% confidence level. CIs for
#' count estimates are the log Student's t CIs, with adaptations
#' for complex surveys. CIs for percentage estimates are
#' the Korn and Graubard CIs.
#'
#' @param ...     names of variables (in quotes)
#' @param test    perform hypothesis tests?
#' @param alpha   significance level for tests
#' @param drop_na drop missing values (`NA`)? Categorical variables only.
#' @param max_levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param csv     name of a CSV file
#'
#' @return A list of tables or a single table.
#' @family tables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' tab("AGER")
#' tab("MDDO", "SPECCAT", "MSA")
#'
#' # Numeric variables
#' tab("NUMMED")
#'
#' # Hypothesis testing with categorical variables
#' tab("AGER", test = TRUE)
tab = function(...
               , test = FALSE, alpha = 0.05
               , drop_na = getOption("surveytable.drop_na")
               , max_levels = getOption("surveytable.max_levels")
               , csv = getOption("surveytable.csv")
               ) {
	ret = list()
	if (...length() > 0) {
	  assert_that(test %in% c(TRUE, FALSE)
	              , alpha > 0, alpha < 0.5)
	  design = .load_survey()
	  nm = names(design$variables)
		for (ii in 1:...length()) {
			vr = ...elt(ii)
			if (!(vr %in% nm)) {
			  warning(vr, ": variable not in the data.")
			  next
			}
			if (is.logical(design$variables[,vr])
			    || is.factor(design$variables[,vr]) ) {
			  ret[[vr]] = .tab_factor(design = design
                      , vr = vr
                      , drop_na = drop_na
                      , max_levels = max_levels
                      , csv = csv)
			  if (test) {
			    ret[[paste0(vr, " - test")]] = .test_factor(design = design
                                            , vr = vr
                                            , drop_na = drop_na
                                            , alpha = alpha
                                            , csv = csv)
			  }
			} else if (is.numeric(design$variables[,vr])) {
			  ret[[vr]] = .tab_numeric(design = design
                      , vr = vr
                      , csv = csv)
			} else {
        warning(vr, ": must be logical, factor, or numeric. Is "
                , class(design$variables[,vr]))
			}
		}
	}

	class(ret) = "surveytable_list"
	if (length(ret) == 1L) ret[[1]] else ret
}

.tab_factor = function(design, vr, drop_na, max_levels, csv) {
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))

	lbl = .getvarname(design, vr)
	if (is.logical(design$variables[,vr])) {
		design$variables[,vr] %<>% factor
	}
	assert_that(is.factor(design$variables[,vr])
		, msg = paste0(vr, ": must be either factor or logical. Is ",
			class(design$variables[,vr])[1] ))
	design$variables[,vr] %<>% droplevels
	if (drop_na) {
	  design = design[which(!is.na(design$variables[,vr])),]
	  if(inherits(design, "svyrep.design")) {
	    design$prob = 1 / design$pweights
	  }
	  lbl %<>% paste("(knowns only)")
	} else {
	  design$variables[,vr] %<>% .fix_factor
	}
	assert_that(noNA(design$variables[,vr]), noNA(levels(design$variables[,vr])))
	attr(design$variables[,vr], "label") = lbl

	nlv = nlevels(design$variables[,vr])
	if (nlv < 2) {
    assert_that(all(design$variables[,vr] == design$variables[1,vr]))
	  mp = .total(design)
	  assert_that(ncol(mp) %in% c(4L, 5L))
	  fa = attr(mp, "footer")
	  mp = cbind(
	    data.frame(Level = design$variables[1,vr])
      , mp)
	  if (!is.null(fa)) {
	    attr(mp, "footer") = fa
	  }
	  attr(mp, "num") = 2:5
	  attr(mp, "title") = .getvarname(design, vr)
    return(.write_out(mp, csv = csv))
	} else if (nlv > max_levels) {
	  # don't use assert_that
	  # if multiple tables are being produced, want to go to the next table
	  warning(vr
          , ": categorical variable with too many levels: "
          , nlv, ", but ", max_levels
          , " allowed. Try increasing the max_levels argument or "
          , "see ?set_output"
          )
	  return(invisible(NULL))
	}

	frm = as.formula(paste0("~ `", vr, "`"))

	##
	counts = svyby(frm, frm, design, unwtd.count)$counts
	assert_that(length(counts) == nlv)
	if (getOption("surveytable.check_present")) {
	  pro = getOption("surveytable.present_restricted") %>% do.call(list(counts))
	} else {
		pro = list(flags = rep("", length(counts)), has.flag = c())
	}

	##
	sto = svytotal(frm, design) # , deff = TRUE)
	mmcr = data.frame(x = as.numeric(sto)
		, s = sqrt(diag(attr(sto, "var"))) )
  mmcr$samp.size = .calc_samp_size(design = design, vr = vr, counts = counts)
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
	lvs = design$variables[,vr] %>% levels
	assert_that( noNA(lvs) )
	ret = NULL
	for (lv in lvs) {
		design$variables$.tmp = NULL
		design$variables$.tmp = (design$variables[,vr] == lv)
		# Korn and Graubard, 1998
		xp = if ( getOption("surveytable.adjust_svyciprop") ) {
		  svyciprop_adjusted(~ .tmp, design, method="beta", level = 0.95
		      , df_method = getOption("surveytable.adjust_svyciprop.df_method"))
		} else {
		  svyciprop(~ .tmp, design, method="beta", level = 0.95)
		}
		ret1 = data.frame(Proportion = xp %>% as.numeric
		                  , SE = attr(xp, "var") %>% as.numeric %>% sqrt)

		ci = attr(xp, "ci") %>% t %>% data.frame
		names(ci) = c("LL", "UL")
		if (is.na(ci$LL)) ci$LL = 0
		if (is.na(ci$UL)) ci$UL = 1
		ret1 %<>% cbind(ci)

		ret1$`n numerator` = sum(design$variables$.tmp)
		ret1$`n denominator` = length(design$variables$.tmp)
		ret = rbind(ret, ret1)
	}
	ret$degf = df1

	if (getOption("surveytable.check_present")) {
	  ppo = getOption("surveytable.present_prop") %>% do.call(list(ret))
	} else {
		nlvs = design$variables[, vr] %>% nlevels
		ppo = list(flags = rep("", nlvs), has.flag = c())
	}

	mp2 = getOption("surveytable.tx_prct") %>% do.call(list(ret[,c("Proportion", "SE", "LL", "UL")]))
	names(mp2) = getOption("surveytable.names_prct")

	##
	assert_that(nrow(mmc) == nrow(mp2)
    , nrow(mmc) == nrow(mmcr)
		, nrow(mmc) == length(pro$flags)
		, nrow(mmc) == length(pco$flags)
		, nrow(mmc) == length(ppo$flags) )

	mp = cbind(mmc, mp2)
	flags = paste(pro$flags, pco$flags, ppo$flags) %>% trimws
	if (any(nzchar(flags))) {
		mp$Flags = flags
	}

	##
	rownames(mp) = NULL
	mp = cbind(data.frame(Level = lvs), mp)

  attr(mp, "num") = 2:5
  attr(mp, "title") = .getvarname(design, vr)
	mp %<>% .add_flags( c(pro$has.flag, pco$has.flag, ppo$has.flag) )
	.write_out(mp, csv = csv)
}

.add_flags = function(df1, has.flag) {
  if (!getOption("surveytable.check_present")) {
    attr(df1, "footer") = NULL
  } else if (is.null(has.flag)) {
	  attr(df1, "footer") = "(Checked presentation standards. Nothing to report.)"
	} else {
		v1 = c()
		for (ff in has.flag) {
			v1 %<>% c(switch(ff
				, R = "R: If the data is confidential, suppress *all* estimates, SE's, CI's, etc."
				, Cx = "Cx: suppress count (and rate)"
				, Cr = "Cr: footnote count - RSE" # .present_count_3030
  			, Cdf = "Cdf: review count (and rate) - degrees of freedom"
				, Px = "Px: suppress percent"
				, Pc = "Pc: footnote percent - complement"
				, Pdf = "Pdf: review percent - degrees of freedom"
				, P0 = "P0: review percent - 0% or 100%"
				, paste0(ff, ": unknown flag!")
			))
		}
		attr(df1, "footer") = v1 %>% paste(collapse="; ")
	}
  df1
}


.calc_samp_size = function(design, vr, counts) {

  # In svytotal(frm, design, deff = TRUE), DEff sometimes
  # appears incorrect. If no variability, DEff = Inf.
  # Calculating "Kish's Effective Sample Size" directly, bypassing DEff
  #	deff = attr(sto, "deff") %>% diag

  design$wi = 1 / design$prob
  design$wi[design$prob <= 0] = 0
  design$wi2 = design$wi^2
  sum_wi = by(design$wi, design$variables[,vr], sum) %>% as.numeric
  sum_wi2 = by(design$wi2, design$variables[,vr], sum) %>% as.numeric
  neff = sum_wi^2 / sum_wi2
  assert_that(length(neff) == length(counts))
  pmin(counts, neff)
}
