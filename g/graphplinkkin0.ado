/*
#########################################################################
# graphplinkkin0
# a command to plot distribution from *imiss plink file
#
# command: graphplinkkin0, kin0(input-file) 
# options: 
#          d(num) ..... threshold for duplicates
#          f(num) ..... threshold for first degree relatives
#          s(num) ..... threshold for second degree relatives
#          t(num) ..... threshold for third degree relatives
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
program graphplinkkin0
syntax , kin0(string asis) [d(real 0.3540) f(real 0.1770) s(real 0.0884) t(real 0.0442)]

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
noi di"#    3rd-degree if kinship > `t'"
noi di"#    2nd-degree if kinship > `s'"
noi di"#    1st-degree if kinship > `f'"
noi di"#    duplicate  if kinship > `d'"
noi di"#  *** this may not be the case for non-standard arrays e.g. psychchip/ immunochip"
noi di"#########################################################################"

qui { 
	preserve
	!$tabbed `kin0'.kin0
	import delim using `kin0'.kin0.tabbed, clear case(lower)
	erase `kin0'.kin0.tabbed
	for var fid1-id2      : tostring X, replace 
	for var hethet-kinship: destring X, replace force
	replace kin = 0 if kin <0
	noi di"-plotting ibs0 -by- kinship to tmpKIN0_1.gph"
	global format "msiz(medlarge) msymbol(O) mfc(red) mlc(black) mlabsize(small) mlw(vvthin)"
  	global xlabel "0(0.2).4"
	qui { 
	tw scatter kin ibs, $format       ///
			 title("Between-Family Relationships") ///
			 xtitle("Proportioin of Zero IBS") ///
			 ylabel($xlabel)          ///
			 ytitle("Estimated Kinship Coefficient") ///
			 yline(0.354, lpattern(dash) lwidth(vthin) lcolor(red))  ///
			 yline(0.177, lpattern(dash) lwidth(vthin) lcolor(red))  ///
			 yline(0.0884, lpattern(dash) lwidth(vthin) lcolor(red)) ///
			 yline(0.0442, lpattern(dash) lwidth(vthin) lcolor(red)) ///
			 nodraw saving(tmpKIN0_1.gph, replace)
			 }
	gen rel = ""
	replace rel = "3rd" if kinship > `t'
	replace rel = "2nd" if kinship > `s'
	replace rel = "1st" if kinship > `f'
	replace rel = "dup" if kinship > `d'
	replace rel = ""    if kinship == .
	foreach rel in dup 1st 2nd 3rd { 
		count if rel == "`rel'"
		global rel`rel' "`r(N)'"
		di "rel`rel'"
		}
	noi di"-plotting kinship to tmpKIN0_2.gph"
	qui { 
		tw hist kinship , width(0.005) percent                          ///
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
	
