/*
#########################################################################
# graphplinkfrq
# a command to plot distribution from *frq.counts plink file
#
# command: graphplinkfrq, frq(input-file) 
# options: 
#          maf(num) ..... minor/major allele frequency line to plot
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
program graphplinkfrq
syntax , frq(string asis) 

di in white"#########################################################################"
di in white"# graphplinkfrq                                                          "
di in white"# version:       2a                                                      "
di in white"# Creation Date: 21April2017                                             "
di in white"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di in white"#########################################################################"
di in white"# This is a script to plot the output from frq.counts file from the --freq      "
di in white"# routine in plink.                                                      " 
di in white"# The input data comes in standard format from the frq.counts output.         "
di in white"# -----------------------------------------------------------------------"
di in white"# Dependencies : tabbed.pl via ${tabbed}                                 "
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
di in white"# > check path of plink *.frq.counts file is true"
preserve
qui { // *.frq.counts
	capture confirm file "`frq'.frq.counts"
	if _rc==0 {
		noi di in green"# >> `frq'.frq.counts found"
		}
	else {
		noi di in red"# >> `frq'.frq.counts not found "
		noi di in red"# >> help: do not include .frq.counts in filename  "
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
di in white"# > processing *.frq.counts"
qui {
	!$tabbed `frq'.frq.counts
	import delim using `frq'.frq.counts.tabbed, clear case(lower)
	erase `frq'.frq.counts.tabbed
	for var c1 c2 : destring X, replace force
	for var c1 c2 : drop if  X == .
	gen maf = round(c1/(c1+c2),0.001)
	for var maf : lab var X "minor allele frequency"
	count
	global nSNPs `r(N)'
	noi di in white`"# >> ${nSNPs} snps imported from *.frq.counts"'
	count if c1 < 5
	global nSNPlow `r(N)'
	noi di in white`"# >> ${nSNPlow} snps with frequency counts < 5"'
	gen total = c1 + c2
	sum total
	global mac5 = 5/`r(max)'
	}
di in white"# > plotting frequency to tmpFRQ.gph"
qui {
	sum maf
	if `r(min)' != `r(max)' {
		tw hist maf,  width(0.004) start(0) percent ///
		   xlabel(0(.1)0.5) ///
		   xline($mac5 , lpattern(dash) lwidth(vthin) lcolor(red) ) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with mac < 5 ; N = ${nSNPlow}" ///
							 "mac 5 = $mac5 %") ///
		   nodraw saving(tmpFRQ.gph, replace)
		}
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
restore
end;
	
