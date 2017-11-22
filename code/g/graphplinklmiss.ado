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

di in white"#########################################################################"
di in white"# graphplinklmiss                                                          "
di in white"# version:       2a                                                      "
di in white"# Creation Date: 21April2017                                             "
di in white"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di in white"#########################################################################"
di in white"# This is a script to plot the output from lmiss file from the --missing "
di in white"# routine in plink.                                                      " 
di in white"# The input data comes in standard format from the lmiss output.         "
di in white"# -----------------------------------------------------------------------"
di in white"# Dependencies : tabbed.pl via ${tabbed}                                 "
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
preserve
di in white"# > check path of plink *.lmiss file is true"
qui { // *.lmiss
	capture confirm file "`lmiss'.lmiss"
	if _rc==0 {
		noi di in green"# >> `lmiss'.lmiss found"
		}
	else {
		noi di in red"# >> `lmiss'.lmiss not found "
		noi di in red"# >> help: do not include .lmiss in filename  "
		noi di in red"# >> exiting "
		exit
		}
	}
di in white"# > check path of dependent software is true                            "
qui { // tabbed
	clear
	set obs 1
	gen a = "$tabbed"
	replace a = subinstr(a,"perl ","capture confirm file ",.)
	outsheet a using _ooo.do, non noq replace
	do _ooo.do
	if _rc==0 {
		noi di in green"# >> the tabbed.pl script exists and is correctly assigned as  $tabbed"
		noi di in green"# >>> ensuring perl is working on your system and can be called from the command-line"
		clear 
		set obs 10
		gen a = "a b c d"
		outsheet a using test_pl.txt, noq replace
		!$tabbed test_pl.txt
		capture confirm file "test_pl.txt.tabbed"
		if _rc==0 {
			noi di in green"# >>>> the tabbed.pl script is working"
			}
		else {
			noi di in red"# >>>> the tabbed.pl script did not work"
			noi di in red"# >>>> download and install active perl on your computer https://www.activestate.com/activeperl/downloads"
			exit
			}
		!del test_pl.*
		}
	else {
		noi di in red"# >> tabbed.pl does not exists; download executable from https://github.com/ricanney/perl "
		noi di in red"# >> set tabbed.pl location using;  "
		noi di in red`"# >> global tabbed "folder\file"  "'
		exit
		}
	erase _ooo.do
	}
di in white"# > processing *.lmiss"
qui {
	!$tabbed `lmiss'.lmiss
	import delim using `lmiss'.lmiss.tabbed, clear case(lower)
	erase `lmiss'.lmiss.tabbed
	for var f_miss : destring X, replace force
	for var f_miss : lab var X "Frequency of Missing Genotypes per SNP"
	count
	global nSNPs `r(N)'
	noi di in white`"# >> ${nSNPs} snps imported from *.lmiss"'
    count if f_miss > `geno'
	global nSNPlow `r(N)'
	global geno_tmp `geno'
	noi di in white`"# >> ${nSNPlow} snps with missingess > ${geno_tmp}"'
	replace f_miss = 0.1 if f_miss >0.1 & f_miss !=.
	}
di in white"# > plotting missingness to tmpLMISS.gph"
qui {
	sum f_miss
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
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
restore
end;
	
