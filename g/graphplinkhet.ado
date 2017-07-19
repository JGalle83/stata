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
noi di"#########################################################################"
noi di"# graphplinkhet                                                        "
noi di"# version:       2a                                                      "
noi di"# Creation Date: 21April2017                                             "
noi di"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
noi di"#########################################################################"
noi di"# This is a script to plot the output from het file from the --het "
noi di"# routine in plink.                                                      " 
noi di"# The input data comes in standard format from the imiss output          "
noi di"# -----------------------------------------------------------------------"
noi di"# Dependencies : tabbed.pl via ${tabbed}                                 "
noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : graphplinkhet, het(filename) [sd(real 4)]            "
noi di"# for filename, .het is not needed                                     "
noi di"#########################################################################"
qui { 
	preserve
	!$tabbed `het'.het
	import delim using `het'.het.tabbed, clear case(lower)
	erase `het'.het.tabbed
	for var fid iid: tostring X, replace force
	for var ohom   : destring X, replace force
	for var ohom   : lab var X "Homozygosity (observed)"
	sum ohom
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
	gen xu = round((4 * sd),1000)
	gen xl = round(-(4 * sd),1000)
	foreach i in u l { 
		sum x`i'
		global x`i' `r(max)'
		}
		
	count
	global nIND `r(N)'
	count if threshold == 1
	global nINDlow `r(N)'
	sum ohom
	noi di"-plotting individual heterozygosity distribution to tmpHET.gph"
	if `r(min)' != `r(max)' {
		tw hist _ohom,  ///
		   xlabel(${xl} 0 ${xu}) ///
		   xline(${ul}  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   xline(${ll}  , lpattern(dash) lwidth(vthin) lcolor(red)) ///
		   legend(off) ///
		   caption("Individuals in dataset; N = ${nIND}" ///
		           "Individuals with Homozygosity < `sd' * Std. Dev. from Mean ; N = ${nINDlow}") ///
		   nodraw saving(tmpHET.gph, replace)
		}
	noi di"-exporting excessive heterozygous/homozygous individuals pairs to tempHET.indlist"
	outsheet fid iid if threshold == 1 using tempHET.indlist, non noq replace
	restore
	}
	display "done!"
	end;
	

