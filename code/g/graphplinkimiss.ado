/*
#########################################################################
# graphplinkimiss
# a command to plot distribution from *imiss plink file
#
# command: graphplinkimiss, imiss(input-file) 
# options: 
#          mind(num) ..... missingness by individual threshold
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
program graphplinkimiss

syntax , imiss(string asis) [mind(real 0.02)]
di in white"#########################################################################"
di in white"# graphplinkimiss                                                        "
di in white"# version:       2a                                                      "
di in white"# Creation Date: 21April2017                                             "
di in white"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di in white"#########################################################################"
di in white"# This is a script to plot the output from imiss file from the --missing "
di in white"# routine in plink.                                                      " 
di in white"# The input data comes in standard format from the imiss output          "
di in white"# -----------------------------------------------------------------------"
di in white"# Dependencies : tabbed.pl via ${tabbed}                                 "
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
preserve
di in white"# > check path of plink *.imiss file is true"
qui { // *.imiss
	capture confirm file "`imiss'.imiss"
	if _rc==0 {
		noi di in green"# >> `imiss'.imiss found"
		}
	else {
		noi di in red"# >> `imiss'.imiss not found "
		noi di in red"# >> help: do not include .imiss in filename  "
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
di in white"# > processing *.imiss"
qui {
	!$tabbed `imiss'.imiss
	import delim using `imiss'.imiss.tabbed, clear case(lower)
	erase `imiss'.imiss.tabbed
	for var fid iid: tostring X, replace force
	for var f_miss : destring X, replace force
	count
	global nIND `r(N)'
	noi di in white`"# >> ${nIND} individuals imported from *.imiss"'
	count if f_miss > `mind'
	global nINDlow `r(N)'
	global mind_tmp `mind'
	noi di in white`"# >> ${nINDlow} individuals with missingess > ${mind_tmp}"'
	}
di in white"# > plotting missingness to tmpIMISS.gph"
qui{
	sum f_miss
	if `r(min)' != `r(max)' {
		tw hist f_miss , width(0.005) start(0) percent                       ///
		   xlabel(0(0.005)0.05)                                              ///
		   xline(`mind'  , lpattern(dash) lwidth(vthin) lcolor(red))         ///
		   legend(off) ///
		   caption("Individuals in dataset; N = ${nIND}" ///
		           "Individuals with missingness > `mind' ; N = ${nINDlow}") ///
		   nodraw saving(tmpIMISS.gph, replace)
		}
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
restore
end;
	
