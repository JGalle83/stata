/*
#########################################################################
# graphplinkhet
# a command to plot distribution from *hwe plink file
#
# command: graphplinkhet, het(input-file) 
# options: 
#          sd(num) ..... standard deviations from mean to falg in output file
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

program graphplinkhet
syntax , het(string asis) [sd(real 4)]

di in white"#########################################################################"
di in white"# graphplinkhet                                                        "
di in white"# version:       2a                                                      "
di in white"# Creation Date: 21April2017                                             "
di in white"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di in white"#########################################################################"
di in white"# This is a script to plot the output from het file from the --het "
di in white"# routine in plink.                                                      " 
di in white"# The input data comes in standard format from the imiss output          "
di in white"# -----------------------------------------------------------------------"
di in white"# Dependencies : tabbed.pl via ${tabbed}                                 "
di in white"# -----------------------------------------------------------------------"
di in white"# Syntax : graphplinkhet, het(filename) [sd(real 4)]            "
di in white"# for filename, .het is not needed                                     "
di in white"#########################################################################"
preserve
di in white"# > check path of plink *.het file is true"
qui { // *.het
	capture confirm file "`het'.het"
	if _rc==0 {
		noi di in green"# >> `het'.het found"
		}
	else {
		noi di in red"# >> `het'.het not found "
		noi di in red"# >> help: do not include .het in filename  "
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
di in white"# > processing *.het"
qui { 
	!$tabbed `het'.het
	import delim using `het'.het.tabbed, clear case(lower)
	erase `het'.het.tabbed
	for var fid iid: tostring X, replace force
	for var ohom   : destring X, replace force
	for var ohom   : lab var X "Homozygosity (observed)"
	sum ohom
	di in white"# >> calculateing standard deviation of ohom"
	gen sd   = `r(sd)'
	gen _ohom = ohom - `r(mean)'
	gen threshold = 0
	replace threshold = 1 if _ohom <  -(`sd' * sd) 
	replace threshold = 1 if _ohom >   (`sd' * sd) 
	gen u = (`sd' * sd) 
	gen l = -(`sd' * sd) 
	foreach i in u l { 
		sum `i'
		global `i'l `r(max)'
		}
	gen xu = round(((2+`sd') * sd),1000)
	gen xl = round(-((2+`sd') * sd),1000)
	foreach i in u l { 
		sum x`i'
		global `i'x `r(max)'
		}	
	count
	global nIND `r(N)'
	noi di in white`"# >> ${nIND} individuals imported from *.het"'
	count if threshold == 1
	global nINDlow `r(N)'
	global sd_tmp `sd'
	noi di in white`"# >> ${nINDlow} individuals with heterozygosity outside the ${sd_tmp}x threshold"'
	}
di in white"# > plotting heterozygosity to tmpHET.gph"
qui{
	sum ohom
	if `r(min)' != `r(max)' {
		tw hist _ohom,  ///
		   xtitle("Adjuster Homozygosity") ///
		   xlabel(${ux} 0 ${lx}) ///
		   xline(${ul}  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   xline(${ll}  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("Individuals in dataset; N = ${nIND}" ///
		           "Individuals with Homozygosity < `sd' * Std. Dev. from Mean ; N = ${nINDlow}") ///
		   nodraw saving(tmpHET.gph, replace)
		}
	}
di in white"# > exporting individual ids where heterozygosity outside the ${sd_tmp}x threshold to tmpHET.indlist"
qui {
	outsheet fid iid if threshold == 1 using tempHET.indlist, non noq replace
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
restore
end;
	

