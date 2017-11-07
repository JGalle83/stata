/*
#########################################################################
# graphplinkfrq
# a command to plot distribution from *frq plink file
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
noi di"#########################################################################"
noi di"# graphplinkfrq                                                          "
noi di"# version:       2a                                                      "
noi di"# Creation Date: 21April2017                                             "
noi di"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
noi di"#########################################################################"
noi di"# This is a script to plot the output from frq file from the --freq      "
noi di"# routine in plink.                                                      " 
noi di"# The input data comes in standard format from the frq output.         "
noi di"# -----------------------------------------------------------------------"
noi di"# Dependencies : tabbed.pl via ${tabbed}                                 "
noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : graphplinkfrq, frq(filename) [maf(real 0.05)]                 "
noi di"# for filename, .frq is not needed                                       "
noi di"#########################################################################"
qui { 
	preserve
	!$tabbed `frq'.frq.counts
	import delim using `frq'.frq.counts.tabbed, clear case(lower)
	erase `frq'.frq.counts.tabbed
	for var c1 c2 : destring X, replace force
	for var c1 c2 : drop if  X == .
	gen maf = c1/(c1+c2)
	for var maf : lab var X "minor allele frequency"
	count
	global nSNPs `r(N)'
    count if c1 <= 5
	global nSNPlow `r(N)'
	gen total = c1 + c2
	sum total
	global mac5 = 5/`r(max)'
	sum maf
	noi di"-plotting frequency distribution to tmpFRQ.gph"
	if `r(min)' != `r(max)' {
		tw hist maf,  width(.005) start(0) percent ///
		   xlabel(0(.1)0.5) ///
		   xline($mac5 , lpattern(dash) lwidth(vthin) lcolor(red) ) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with mac < 5 ; N = ${nSNPlow}") ///
		   nodraw saving(tmpFRQ.gph, replace)
		}
	restore
	}
	display "done!"
	end;
	
