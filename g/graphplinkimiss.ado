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
	
