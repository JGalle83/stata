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

di in white"#########################################################################"
di in white"# graphplinkkin0                                                         "
di in white"# version:       1a                                                      "
di in white"# Creation Date: 21April2017                                             "
di in white"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di in white"#########################################################################"
di in white"# This is a script to plot the output from the  --make-king-table routine"
di in white"# in plink2.                                                             " 
di in white"# The input data comes in standard format from the kin0 output.          "
di in white"# -----------------------------------------------------------------------"
di in white"# Dependencies : tabbed.pl via ${tabbed}                                 "
di in white"# -----------------------------------------------------------------------"
di in white"# Syntax : graphplinkkin0, kin0(filename)                                "
di in white"# for filename, .kin0 is not needed                                      "
di in white"#                                                                        "
di in white"# We are assuming relationships/ kinship scores are as follows;          "
di in white"#    3rd-degree if kinship > `t'"
di in white"#    2nd-degree if kinship > `s'"
di in white"#    1st-degree if kinship > `f'"
di in white"#    duplicate  if kinship > `d'"
di in white"#  WARNING : this may not be the case for non-standard arrays e.g. psychchip/ immunochip"
di in white"#########################################################################"
preserve
di in white"# > check path of plink *.kin0 file is true"
qui { // *.kin0
	capture confirm file "`kin0'.kin0"
	if _rc==0 {
		noi di in green"# >> `kin0'.kin0 found"
		}
	else {
		noi di in red"# >> `kin0'.kin0 not found "
		noi di in red"# >> help: do not include .kin0 in filename  "
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
di in white"# > processing *.kin0"
qui { 
	
	!$tabbed `kin0'.kin0
	import delim using `kin0'.kin0.tabbed, clear case(lower)
	erase `kin0'.kin0.tabbed
	count
	if `r(N)' > 0 {
		di in white"# > non-zero individuals with kinship co-efficients imported - plotting ibs0 by kinship to tmpKIN0_1.gph"
		for var fid1-id2      : tostring X, replace 
		for var hethet-kinship: destring X, replace force
		replace kin = 0 if kin <0
		global format "msiz(medlarge) msymbol(O) mfc(red) mlc(black) mlabsize(small) mlw(vvthin)"
		global xlabel "0(0.2).4"
		qui { 
			tw scatter kin ibs, $format       ///
				 title("Between-Family Relationships") ///
				 xtitle("Proportion of Zero IBS") ///
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
			}
		di in white"# > non-zero individuals with kinship co-efficients imported - plotting kinship histogram to tmpKIN0_2.gph"
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
		di in white"# > exporting related pairs to tmpKIN0.relPairs"
		outsheet if rel != "" using tmpKIN0.relPairs, noq replace 
		}
	else {
		di in white"# > zero individuals with kinship co-efficients imported - generating blank plot to tmpKIN0_1.gph and tmpKIN0_2.gph"
		twoway scatteri 1 1,            ///
		msymbol(i)                      ///
		ylab("") xlab("")               ///
		yscale(off) xscale(off)         ///
		plotregion(lpattern(blank))     ///
		nodraw saving(tmpKIN0_1.gph, replace)
		twoway scatteri 1 1,            ///
		msymbol(i)                      ///
		ylab("") xlab("")               ///
		yscale(off) xscale(off)         ///
		plotregion(lpattern(blank))     ///
		nodraw saving(tmpKIN0_2.gph, replace)
		}
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
restore
end;
	
