/*
#########################################################################
# recodeGenotype
# a command to convert allele codes into genotype codes
#
# command: recodeGenotype, a1(<A1>) a2(<A2>)
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

program recodeGenotype
syntax , a1(string asis)  a2(string asis) 

di "***************************************************"
di "recodeGenotype - version 0.1a - 28may2014 richard anney "
di "***************************************************"
di "...allele 1 is `a1'"
di "...allele 2 is `a2'"
di "...genotype varname is _gt_tmp"
di "...allele codes must be A C G T I or D "

qui{
	noi di"...converting complex indels to ID"
	gen counta1 = length(`a1')
	gen counta2 = length(`a2')
	replace `a1' = "I" if counta1 > counta2
	replace `a2' = "I" if counta2 > counta1
	replace `a1' = "D" if `a2' == "I"
	replace `a2' = "D" if `a1' == "I"
	replace `a1' = substr(`a1',1,1)
	replace `a2' = substr(`a2',1,1)
	drop counta1 counta2
	replace `a1' = "" if `a1' == "-"
	replace `a2' = "" if `a2' == "-"
	replace `a1' = "" if `a1' == "0"
	replace `a2' = "" if `a2' == "0"
	compress
	
	noi di"...creating genotype variable _gt_tmp"
	gen _gt_tmp = ""
	replace _gt_tmp = "A" if  (`a1' ==""  & `a2' =="A")
	replace _gt_tmp = "A" if  (`a1' ==""  & `a2' =="A")
	replace _gt_tmp = "A" if  (`a1' =="A" & `a2' =="A")
	replace _gt_tmp = "C" if  (`a1' ==""  & `a2' =="C")
	replace _gt_tmp = "C" if  (`a1' ==""  & `a2' =="C")
	replace _gt_tmp = "C" if  (`a1' =="C" & `a2' =="C")
	replace _gt_tmp = "C" if  (`a1' =="C" & `a2' =="C")
	replace _gt_tmp = "D" if  (`a1' ==""  & `a2' =="D")
	replace _gt_tmp = "D" if  (`a1' ==""  & `a2' =="D")
	replace _gt_tmp = "D" if  (`a1' =="D" & `a2' =="D")
	replace _gt_tmp = "G" if  (`a1' ==""  & `a2' =="G")
	replace _gt_tmp = "G" if  (`a1' ==""  & `a2' =="G")
	replace _gt_tmp = "G" if  (`a1' =="G" & `a2' =="G")
	replace _gt_tmp = "G" if  (`a1' =="G" & `a2' =="G")
	replace _gt_tmp = "I" if  (`a1' ==""  & `a2' =="I")
	replace _gt_tmp = "I" if  (`a1' ==""  & `a2' =="I")
	replace _gt_tmp = "I" if  (`a1' =="I" & `a2' =="I")
	replace _gt_tmp = "ID" if (`a1' =="D" & `a2' =="I")
	replace _gt_tmp = "ID" if (`a1' =="I" & `a2' =="D")
	replace _gt_tmp = "K" if  (`a1' =="G" & `a2' =="T")
	replace _gt_tmp = "K" if  (`a1' =="T" & `a2' =="G")
	replace _gt_tmp = "M" if  (`a1' =="A" & `a2' =="C")
	replace _gt_tmp = "M" if  (`a1' =="C" & `a2' =="A")
	replace _gt_tmp = "R" if  (`a1' =="A" & `a2' =="G")
	replace _gt_tmp = "R" if  (`a1' =="G" & `a2' =="A")
	replace _gt_tmp = "S" if  (`a1' =="C" & `a2' =="G")
	replace _gt_tmp = "S" if  (`a1' =="G" & `a2' =="C")
	replace _gt_tmp = "T" if  (`a1' ==""  & `a2' =="T")
	replace _gt_tmp = "T" if  (`a1' ==""  & `a2' =="T")
	replace _gt_tmp = "T" if  (`a1' =="T" & `a2' =="T")
	replace _gt_tmp = "T" if  (`a1' =="T" & `a2' =="T")
	replace _gt_tmp = "W" if  (`a1' =="A" & `a2' =="T")
	replace _gt_tmp = "W" if  (`a1' =="T" & `a2' =="A")
	replace _gt_tmp = "Y" if  (`a1' =="C" & `a2' =="T")
	replace _gt_tmp = "Y" if  (`a1' =="T" & `a2' =="C")
	}

di "done!"
end;
