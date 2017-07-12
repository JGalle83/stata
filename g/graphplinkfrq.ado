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
# =======================================================================
# Copyright 2017 Richard Anney
Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software")
, to deal in the Software without restriction, including without 
limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to 
whom the Software is furnished to do so, subject to the following 
conditions:
The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#########################################################################
*/
program graphplinkfrq
syntax , frq(string asis) [maf(real 0.05)]
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
	!$tabbed `frq'.frq
	import delim using `frq'.frq.tabbed, clear case(lower)
	erase `frq'.frq.tabbed
	for var maf : destring X, replace force
	drop if  maf == .
	for var maf : lab var X "minor allele frequency"
	count
	global nSNPs `r(N)'
    count if maf < `maf'
	global nSNPlow `r(N)'
	sum maf
	noi di"-plotting frequency distribution to tmpFRQ.gph"
	if `r(min)' != `r(max)' {
		tw hist maf,  width(.0025) start(0) percent ///
		   xline(`maf' , lpattern(dash) lwidth(vthin) lcolor(red) ) ///
		   legend(off) ///
		   caption("SNPs in dataset; N = ${nSNPs}" ///
		           "SNPs with MAF < `maf' ; N = ${nSNPlow}") ///
		   nodraw saving(tmpFRQ.gph, replace)
		}
	restore
	}
	display "done!"
	end;
	
