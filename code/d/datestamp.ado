/*
#########################################################################
# datestamp - create a non-space datestamp in global that can be accessed via $DATA 
#
# command: bim2dta, bim(<FILENAME>)
# notes: the filename does not require the .bim to be added
# dependencies: recodeGenotype
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
# #########################################################################
*/

program datestamp
 
qui{ 
	clear
	set obs 1
	gen a = "global DATE "
	gen b = "$S_DATE"
	replace b = subinstr(b, " ", "",.) 
	outsheet using _0000tmp.do, replace non noq
	do  _0000tmp.do
	erase  _0000tmp.do
	}
end
