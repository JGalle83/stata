/*
#########################################################################
# bim2ldexclude
# a command to identifies long-ld-regions from *.bim files (plink-format 
# marker files) 
#
# command: bim2ldexclude, bim(<FILENAME>)
# notes: the filename does not require the .bim to be added
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
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

program bim2ldexclude
syntax , bim(string asis) 
noi di"#########################################################################"
noi di"# bim2ldexclude               "
noi di"# version:  1a              "
noi di"# Creation Date: 25may2017            "
noi di"# Author:  Richard Anney (anneyr@cardiff.ac.uk)     "
noi di"#########################################################################"
noi di"# This is a script to identify from a bim file the long-range LD regions"
noi di"# as described in; "
noi di"# Long-Range LD Can Confound Genome Scans in Admixed Populations. Alkes "
noi di"# Price, Mike Weale et al., The American Journal of Human Genetics 83, "
noi di"# 127 - 147, July 2008              "
noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : bim2ldexclude, bim(filename)    "
noi di"# for filename, .bim is not needed          "
noi di"#########################################################################"
noi di "Started: $S_DATE $S_TIME"
noi di "-importing bim file: `bim'.bim"
qui { 
	import delim using `bim'.bim, clear 
	gen drop = .
	replace drop = 1 if (v1 == 1  & v4 >= 48000000  & v4 <= 52000000)
	replace drop = 1 if (v1 == 2  & v4 >= 86000000  & v4 <= 100500000)
	replace drop = 1 if (v1 == 2  & v4 >= 134500000 & v4 <= 138000000)
	replace drop = 1 if (v1 == 2  & v4 >= 183000000 & v4 <= 190000000)
	replace drop = 1 if (v1 == 3  & v4 >= 47500000  & v4 <= 50000000)
	replace drop = 1 if (v1 == 3  & v4 >= 83500000  & v4 <= 87000000)
	replace drop = 1 if (v1 == 3  & v4 >= 89000000  & v4 <= 97500000)
	replace drop = 1 if (v1 == 5  & v4 >= 44500000  & v4 <= 50500000)
	replace drop = 1 if (v1 == 5  & v4 >= 98000000  & v4 <= 100500000)
	replace drop = 1 if (v1 == 5  & v4 >= 129000000 & v4 <= 132000000)
	replace drop = 1 if (v1 == 5  & v4 >= 135500000 & v4 <= 138500000)
	replace drop = 1 if (v1 == 6  & v4 >= 24000000  & v4 <= 34000000)
	replace drop = 1 if (v1 == 6  & v4 >= 57000000  & v4 <= 64000000)
	replace drop = 1 if (v1 == 6  & v4 >= 140000000 & v4 <= 142500000)
	replace drop = 1 if (v1 == 7  & v4 >= 55000000  & v4 <= 66000000)
	replace drop = 1 if (v1 == 8  & v4 >= 8000000   & v4 <= 12000000)
	replace drop = 1 if (v1 == 8  & v4 >= 43000000  & v4 <= 50000000)
	replace drop = 1 if (v1 == 8  & v4 >= 112000000 & v4 <= 115000000)
	replace drop = 1 if (v1 == 10 & v4 >= 37000000  & v4 <= 43000000)
	replace drop = 1 if (v1 == 11 & v4 >= 46000000  & v4 <= 57000000)
	replace drop = 1 if (v1 == 11 & v4 >= 87500000  & v4 <= 90500000)
	replace drop = 1 if (v1 == 12 & v4 >= 33000000  & v4 <= 40000000)
	replace drop = 1 if (v1 == 12 & v4 >= 109500000 & v4 <= 112000000)
	replace drop = 1 if (v1 == 20 & v4 >= 32000000  & v4 <= 34500000)	
	outsheet v2 if drop == 1 using "long-range-ld.exclude", replace non noq
	}
di "Completed: $S_DATE $S_TIME"
di "done!"
end;	

	
