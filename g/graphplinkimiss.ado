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

syntax , imiss(string asis) [mind(real 0.05)]
noi di"#########################################################################"
noi di"# graphplinkimiss                                                        "
noi di"# version:       2a                                                      "
noi di"# Creation Date: 21April2017                                             "
noi di"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
noi di"#########################################################################"
noi di"# This is a script to plot the output from imiss file from the --missing "
noi di"# routine in plink.                                                      " 
noi di"# The input data comes in standard format from the imiss output          "
noi di"# -----------------------------------------------------------------------"
noi di"# Dependencies : tabbed.pl via ${tabbed}                                 "
noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : graphplinkimiss, imiss(filename) [mind(real 0.05)]            "
noi di"# for filename, .imiss is not needed                                     "
noi di"#########################################################################"
qui { 
	preserve
	!$tabbed `imiss'.imiss
	import delim using `imiss'.imiss.tabbed, clear case(lower)
	erase `imiss'.imiss.tabbed
	for var fid iid: tostring X, replace force
	for var f_miss : destring X, replace force
	count
	global nIND `r(N)'
  count if f_miss > `mind'
	global nINDlow `r(N)'
	sum f_miss
	noi di"-plotting individual missingness distribution to tmpIMISS.gph"
	if `r(min)' != `r(max)' {
		tw hist f_miss , width(0.002) start(0) percent                       ///
		   xline(`mind'  , lpattern(dash) lwidth(vthin) lcolor(red))        ///
		   legend(off) ///
		   caption("Individuals in dataset; N = ${nIND}" ///
		           "Individuals with missingness > `mind' ; N = ${nINDlow}") ///
		   nodraw saving(tmpIMISS.gph, replace)
		}
	restore
	}
	display "done!"
	end;
	
