/*
#########################################################################
# graphplinkhwe
# a command to plot distribution from *hwe plink file
#
# command: graphplinkhwe, hwe(input-file) 
# options: 
#          threshold(num) ..... -log10P to flag in output-file 
#
# dependencies: 
# tabbed.pl must be set to be called via ${tabbed}
#
# =======================================================================
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 10th September 2015
#########################################################################
*/
program graphplinkhwe

syntax , hwe(string asis) [threshold(real 6)]
noi di"#########################################################################"
noi di"# graphPLINKhwe                                                          "
noi di"# version:       2a                                                      "
noi di"# Creation Date: 21April2017                                             "
noi di"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
noi di"#########################################################################"
noi di"# This is a script to plot the output from hwe file from the --hardy     "
noi di"# routine in plink.                                                      " 
noi di"# The input data comes in standard format from the hwe output.           "

noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : graphplinkhwe, hwe(filename) [threshold(real 6)]                   "
noi di"# for filename, .hwe is not needed                                       "
noi di"#########################################################################"
qui { 
	preserve
	!$tabbed `hwe'.hwe
	import delim using `hwe'.hwe.tabbed, clear case(lower)
	!del `hwe'.hwe.tabbed
	for var p : destring X, replace force
	replace test =  "ALL" if test == "ALL(NP)" 
	keep if test == "ALL"
	for var p : lab var X "HWE (p)"
	count
	global nSNPs `r(N)'
	count if p <1e-`threshold' 
	global nSNPslow `r(N)'
	sum p
	gen log10p = -log10(p)
	drop if log10p < 4
	replace log10p = 20 if log10p >= 20
	noi di"-plotting hwe-P distribution to tmpHWE.gph (min 1e-4 to 1E-20)"
	if `r(min)' != `r(max)' {
		tw hist log10p , width(1) start(4) percent ///
		   xline(`threshold'  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with HWE P < 1e-`threshold' ; N = ${nSNPslow}") ///
		   nodraw saving(tmpHWE.gph, replace)
		}
	noi di"-exporting snps with excessive hew-P to tempHWE.snplist"
	outsheet snp if p <1e-`threshold' using tempHWE.snplist, non noq replace
	restore
	}
	display "done!"
	end;
	
