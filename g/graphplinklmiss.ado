/*
#########################################################################
# graphplinklmiss
# a command to plot distribution from *imiss plink file
#
# command: graphplinklmiss, lmiss(input-file) 
# options: 
#          geno(num) ..... missingness by genotype threshold
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
program graphplinklmiss
syntax , lmiss(string asis) [geno(real 0.05)]
noi di"#########################################################################"
noi di"# graphplinklmiss                                                          "
noi di"# version:       2a                                                      "
noi di"# Creation Date: 21April2017                                             "
noi di"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
noi di"#########################################################################"
noi di"# This is a script to plot the output from lmiss file from the --missing "
noi di"# routine in plink.                                                      " 
noi di"# The input data comes in standard format from the lmiss output.         "
noi di"# -----------------------------------------------------------------------"
noi di"# Dependencies : tabbed.pl via ${tabbed}                                 "
noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : graphplinklmiss, lmiss(filename) [geno(real 0.05)]                 "
noi di"# for filename, .lmiss is not needed                                       "
noi di"#########################################################################"
qui { 
	preserve
	!$tabbed `lmiss'.lmiss
	import delim using `lmiss'.lmiss.tabbed, clear case(lower)
	erase `lmiss'.lmiss.tabbed
	for var f_miss : destring X, replace force
	for var f_miss : lab var X "Frequency of Missing Genotypes per SNP"
	count
	global nSNPs `r(N)'
        count if f_miss > `geno'
	global nSNPlow `r(N)'
	replace f_miss = 0.1 if f_miss >0.1 & f_miss !=.
	sum f_miss
	noi di"-plotting marker missingness distribution to tmpLMISS.gph"
	if `r(min)' != `r(max)' {
		tw hist f_miss , width(0.01) start(0) percent ///
		   xlabel(0(0.01)0.1) ///
		   xline(`geno'  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with missingness > `geno' ; N = ${nSNPlow}" ///
		           "SNPs with missingness > 0.1 are recoded to 0.1 for plotting") ///
		   nodraw saving(tmpLMISS.gph, replace)
		}
	restore
	}
	display "done!"
	end;
	
