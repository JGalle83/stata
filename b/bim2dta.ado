/*
#########################################################################
# bim2dta
# a command to convert *.bim files (plink-format marker files) to *.dta (
# stata-format).
#
# command: bim2dta, bim(<FILENAME>)
# notes: the filename does not require the .bim to be added
# dependencies: recodeGenotype
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

program bim2dta
syntax , bim(string asis)

di "***************************************************"
di "bim2dta - version 0.1a 10sept2015 richard anney "
di "***************************************************"
di "Renaming PLINK bim files (addition of genotype codes)"
di "Started: $S_DATE $S_TIME"
qui { 
	noi di ".....importing bim file: `bim'.bim"
	import delim  using `bim'.bim, clear 
	noi di ".....renaming variables"
	rename v1 chr
	rename v2 snp
	rename v4 bp
	rename v5 a1
	rename v6 a2
	noi di ".....recoding genotypes"
	noi recodeGenotype , a1(a1) a2(a2)
	rename _gt_tmp gt
	order chr snp bp a1 a2 gt
	keep  chr snp bp a1 a2 gt
	compress
	sort snp
	save `bim'_bim.dta, replace
	di ".....created new dta file: `bim'_bim.dta"
	}
di "Completed: $S_DATE $S_TIME"
di "done!"
end;	

	
