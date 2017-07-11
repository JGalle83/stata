/*
#########################################################################
# fam2dta
# a command to convert *.fam file (plink-format) into *.dta files
#
# command: fam2dta, fam(<filename>)
# notes: the filename does not require the .fam to be added
#
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

program fam2dta
syntax , fam(string asis)

di "***************************************************"
di "fam2dta - version 0.1a 10sept2015 richard anney "
di "***************************************************"
di "Renaming PLINK fam files"
di "Started: $S_DATE $S_TIME"
qui{
	di ".....importing fam file: `fam'.fam"
	import delim  using `fam'.fam, clear delim(" ")
	rename v1 fid 
	rename v2 iid
	rename v3 fatid
	rename v4 motid
	rename v5 sex
	rename v6 pheno
	for var fid iid fatid motid: tostring X, replace
	order fid iid fatid motid sex pheno
	sort fid iid
	save `fam'_fam.dta, replace
	di ".....created new dta file: `fam'_fam.dta"
	}
di "Completed: $S_DATE $S_TIME"
di "done!"
end;	
