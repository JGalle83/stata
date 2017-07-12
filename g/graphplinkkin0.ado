/*
#########################################################################
# graphplinkkin0
# a command to plot distribution from *imiss plink file
#
# command: graphplinkkin0, kin0(input-file) 
# options: 
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
program graphplinkkin0
syntax , kin0(string asis) 

noi di"#########################################################################"
noi di"# graphPLINKkin0                                                         "
noi di"# version:       1a                                                      "
noi di"# Creation Date: 21April2017                                             "
noi di"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
noi di"#########################################################################"
noi di"# This is a script to plot the output from the  --make-king-table routine"
noi di"# in plink2.                                                             " 
noi di"# The input data comes in standard format from the kin0 output.          "
noi di"# -----------------------------------------------------------------------"
noi di"# Dependencies : tabbed.pl via ${tabbed}                                 "
noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : graphplinkkin0, kin0(filename)                                "
noi di"# for filename, .kin0 is not needed                                      "
noi di"#                                                                        "
noi di"# We are assuming relationships/ kinship scores are as follows;          "
noi di"#    3rd-degree if kinship > .0442"
noi di"#    2nd-degree if kinship > .0884"
noi di"#    1st-degree if kinship > .1770"
noi di"#    duplicate  if kinship > .3540"
noi di"#  *** this may not be the case for non-standard arrays e.g. psychchip/ immunochip"
noi di"#########################################################################"

qui { 
	preserve
	!$tabbed `kin0'.kin0
	import delim using `kin0'.kin0.tabbed, clear case(lower)
	erase `kin0'.kin0.tabbed
	for var fid1-id2      : tostring X, replace 
	for var hethet-kinship: destring X, replace force
	noi di"-plotting ibs0 -by- kinship to tmpKIN0_1.gph"
	global format "msiz(medlarge) msymbol(O) mfc(red) mlc(black) mlabsize(small) mlw(vvthin)"
  global xlabel "-.2(0.2).4"
	qui { 
	tw scatter ibs kin, $format  ///
			 xlabel($xlabel)          ///
			 xline(0.354, lpattern(dash) lwidth(vthin) lcolor(red))  ///
			 xline(0.177, lpattern(dash) lwidth(vthin) lcolor(red))  ///
			 xline(0.0884, lpattern(dash) lwidth(vthin) lcolor(red)) ///
			 xline(0.0442, lpattern(dash) lwidth(vthin) lcolor(red)) ///
			 nodraw saving(tmpKIN0_1.gph, replace)
			 }
	gen rel = ""
	replace rel = "3rd" if kinship > .0442
	replace rel = "2nd" if kinship > .0884
	replace rel = "1st" if kinship > .177
	replace rel = "dup" if kinship > .354
	replace rel = ""    if kinship == .
	foreach rel in dup 1st 2nd 3rd { 
		count if rel == "`rel'"
		global rel`rel' "`r(N)'"
		di "rel`rel'"
		}
	noi di"-plotting kinship to tmpKIN0_2.gph"
	qui { 
		tw hist kinship , width(0.005) percent                     ///
			 xline(0.3540, lpattern(dash) lwidth(vthin) lcolor(red)) ///
			 xline(0.1707, lpattern(dash) lwidth(vthin) lcolor(red)) ///
			 xline(0.0884, lpattern(dash) lwidth(vthin) lcolor(red)) ///
			 xline(0.0442, lpattern(dash) lwidth(vthin) lcolor(red)) ///
			 xlabel($xlabel) legend(off)                             ///
			 caption("Twin/Duplicate Pairs; N = ${reldup}"           ///
							 "1st Degree Relative Pairs ; N = ${rel1st}"     ///
							 "2nd Degree Relative Pairs ; N = ${rel2nd}"     ///
							 "3rd Degree Relative Pairs ; N = ${rel3rd}") nodraw saving(tmpKIN0_2.gph, replace)
			}
	noi di"-exporting related paris to tmpKIN0.relPairs"
	outsheet if rel != "" using tmpKIN0.relPairs, noq replace 
	restore
	}
noi di "done!"
end;
	
