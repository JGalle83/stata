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
di in white"#########################################################################"
di in white"# graphplinkhwe                                                          "
di in white"# version:       2a                                                      "
di in white"# Creation Date: 21April2017                                             "
di in white"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di in white"#########################################################################"
di in white"# This is a script to plot the output from hwe file from the --hardy     "
di in white"# routine in plink.                                                      " 
di in white"# The input data comes in standard format from the hwe output.           "
di in white"# -----------------------------------------------------------------------"
di in white"# Dependencies : tabbed.pl via ${tabbed}                                 "
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
preserve
di in white"# > check path of plink *.hwe file is true"
qui { // *.hwe
	capture confirm file "`hwe'.hwe"
	if _rc==0 {
		noi di in green"# >> `hwe'.hwe found"
		}
	else {
		noi di in red"# >> `hwe'.hwe not found "
		noi di in red"# >> help: do not include .hwe in filename  "
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
di in white"# > processing *.hwe"
qui {
	!$tabbed `hwe'.hwe
	import delim using `hwe'.hwe.tabbed, clear case(lower)
	erase `hwe'.hwe.tabbed
	for var p : destring X, replace force
	replace test =  "ALL" if test == "ALL(NP)" 
	keep if test == "ALL"
	for var p : lab var X "HWE (p)"
	count
	global nSNPs `r(N)'
	noi di in white`"# >> ${nSNPs} snps imported from *.hwe"'
	count if p <1e-`threshold' 
	global nSNPslow `r(N)'
	global threshold_tmp `threshold'
	noi di in white`"# >> ${nSNPslow} SNPs with HWE deviation < p <1e-${threshold_tmp}"'
	}
di in white"# > plotting HWE (P) deviation to tmpHWE.gph"
qui{
	sum p
	gen log10p = -log10(p)
	di in white"# >> pruning dataset for plotting"
	di in white"# >>> pruning if p > 1E-4"
	drop if log10p < 4
	di in white"# >>> applying ceiling to data for p < 1E-20"
	replace log10p = 20 if log10p >= 20
	if `r(min)' != `r(max)' {
		tw hist log10p , width(1) start(4) percent ///
		   xlabel(0(5)20) ///
		   xline(`threshold'  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with HWE P < 1e-`threshold' ; N = ${nSNPslow}") ///
		   nodraw saving(tmpHWE.gph, replace)
		}
	}
di in white"# > exporting HWE (P) deviation SNPs to  tmpHWE.snplist"
qui { 
	outsheet snp if p <1e-`threshold' using tempHWE.snplist, non noq replace
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
restore
end;
	
