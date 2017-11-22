/*
#########################################################################
# datestamp - create a non-space datestamp in global that can be accessed via $DATA 
#
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
# #########################################################################
*/

program datestamp
 
di in white"#########################################################################"
di in white"# datestamp                                                              "
di in white"# version:       1                                                       "
di in white"# Creation Date: 10Sep2015                                               "
di in white"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
di in white"# > creating \$DATE"
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
di in green"# > the global \$DATE will report $DATE"
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;
