.lpe_n = function(counts, th.n = 5) {
	has.flag = c()
	flags = rep("", length(counts))

	#
	c.bad = 1:(th.n - 1)
	c.bad %<>% c(sum(counts) - c.bad)
	bool = (counts %in% c.bad)
	if (any(bool)) {
		f1 = "R"
		flags[bool] %<>% paste(f1)
		has.flag %<>% c(f1)
	}
	list(
	  id = "NCHS presentation standards"
	  , descriptions = c(R =
      "R: If the data is confidential, suppress **all** estimates, SE's, CI's, etc.")
	  , flags = flags
	  , has.flag = has.flag)
}

# Table A https://www.cdc.gov/nchs/data/series/sr_02/sr02-200.pdf
.lpe_counts = function(mmcr) {
  has.flag = c()
  flags = rep("", nrow(mmcr))

  mmcr$rci = (mmcr$ul - mmcr$ll) / mmcr$x
  mmcr$Display = (mmcr$samp.size >= 10 & mmcr$rci <= 1.60)

  bool = (!mmcr$Display)
  if (any(bool)) {
    f1 = "Cx"
    flags[bool] %<>% paste(f1)
    has.flag %<>% c(f1)
  }

  bool = (mmcr$Display & mmcr$degf < 8)
  if (any(bool)) {
    f1 = "Cdf"
    flags[bool] %<>% paste(f1)
    has.flag %<>% c(f1)
  }

  list(
    id = "NCHS presentation standards"
    , descriptions = c(Cx = "Cx: suppress count (and rate)"
      , Cdf = "Cdf: review count (and rate) - degrees of freedom")
    , flags = flags, has.flag = has.flag)
}

.lpe_counts_3030 = function(mmcr
	, th.n = 30, th.rse = 0.30) {
	has.flag = c()
	flags = rep("", nrow(mmcr))

	mmcr$rse = mmcr$s / mmcr$x
	mmcr$rse[mmcr$x <= 0] = Inf

	bool.n = (mmcr$counts < th.n)
	if (any(bool.n)) {
		f1 = "Cx"
		flags[bool.n] %<>% paste(f1)
		has.flag %<>% c(f1)
	}

	bool.rse = (!bool.n & mmcr$rse >= th.rse)
	if (any(bool.rse)) {
		f1 = "Cr"
		flags[bool.rse] %<>% paste(f1)
		has.flag %<>% c(f1)
	}

	list(
	  id = "30 / 30 rule"
	  , descriptions = c(Cx = "Cx: suppress count (and rate)"
      , Cr = "Cr: footnote count - RSE")
	  , flags = flags
	  , has.flag = has.flag)
}

.lpe_percents = function(ret) {
	ret$`n effective` = with(ret, Proportion * (1 - Proportion) / (SE ^ 2))
	ret$`CI width` = with(ret, UL - LL)

	idx.bad = (ret$`n numerator` == 0L | ret$`n numerator` == ret$`n denominator`)
	ret$`n effective`[idx.bad] = ret$`n denominator`[idx.bad]
	ret$`CI width`[idx.bad] = 0

	idx.nbig = (ret$`n effective` > ret$`n denominator`)
	ret$`n effective`[idx.nbig] = ret$`n denominator`[idx.nbig]

	ret$`relative CI width` = with(ret, `CI width` / Proportion)

	#
	ret$Display = as.logical(NA)
	ret$Display[idx.30 <- (ret$`n effective` < 30)] = FALSE # "no: Effective sample size < 30"
	ret$Display[!idx.30
		& (idx.s <- (ret$`CI width` <= 0.05))] = TRUE # "YES: Absolute confidence interval width < 5%"
	ret$Display[!(idx.30 | idx.s)
		& (idx.l <- (ret$`CI width` >= 0.30))] = FALSE # "no: Absolute confidence interval width > 30%"
	ret$Display[!(idx.30 | idx.s | idx.l)
		& (idx.r <- (ret$`relative CI width` > 1.30))] = FALSE # "no: Relative confidence interval width > 130%"
	ret$Display[!(idx.30 | idx.s | idx.l) & !idx.r] = TRUE # "YES: Relative confidence interval width < 130%"
	assert_that( noNA(ret$Display) )

	#
	has.flag = c()
	flags = rep("", nrow(ret))
	bool = (!ret$Display)
	if (any(bool)) {
		f1 = "Px"
		flags[bool] %<>% paste(f1)
		has.flag %<>% c(f1)
	}

	bool = ( ret$Display & !(idx.30 | idx.s | idx.l) & !idx.r
		& (idx.c <- (ret$`CI width` / (1 - ret$Proportion) > 1.30)) )
	if (any(bool)) {
		f1 = "Pc"
		flags[bool] %<>% paste(f1)
		has.flag %<>% c(f1)
	}

	bool = (ret$Display & ret$degf < 8)
	if (any(bool)) {
		f1 = "Pdf"
		flags[bool] %<>% paste(f1)
		has.flag %<>% c(f1)
	}

	bool = (ret$Display & (
		ret$`n numerator` == 0L | ret$`n numerator` == ret$`n denominator`))
	if (any(bool)) {
		f1 = "P0"
		flags[bool] %<>% paste(f1)
		has.flag %<>% c(f1)
	}

	list(
	  id = "NCHS presentation standards"
	  , descriptions = c(Px = "Px: suppress percent"
             , Pc = "Pc: footnote percent - complement"
             , Pdf = "Pdf: review percent - degrees of freedom"
             , P0 = "P0: review percent - 0% or 100%")
	  , flags = flags
	  , has.flag = has.flag)
}
