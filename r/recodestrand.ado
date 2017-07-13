/*
#########################################################################
# recodestrand
# a command to plot distribution from *frq plink file
#
# command: recodestrand, ref_a1(string asis) ref_a2(string asis) alt_a1(string asis) alt_a2(string asis) 
# options: 
#
# dependencies: 
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

program recodestrand
syntax , ref_a1(string asis) ref_a2(string asis) alt_a1(string asis) alt_a2(string asis) 

noi di"#########################################################################"
noi di"recodestrand - version 0.1a - 05May2017 richard anney "
noi di"#########################################################################"
noi di"# allele 1 for the reference strand is     `ref_a1'"
noi di"# allele 2 for the reference strand is     `ref_a2'"
noi di"# allele 1 for the data to be converted is `alt_a1'"
noi di"# allele 2 for the data to be converted is `alt_a2'"
noi di"#########################################################################"
noi di"# - this script flags all indel, ambiguous, missing, monomorphic markers"
noi di"#   in the variable _tmpflag (1 = error)"
noi di"# - this script creates new allele codes for the data (_tmpb1 and _tmpb2)"
noi di"# - this script creates flip code for all markers that were flipped (_tmpflip)"
noi di"#"
noi di"# this is still beta and need to be fully checked - approx 90% satisfied "
noi di" that the code is error-free"
noi di"#########################################################################"
qui { // generating genotypes
	noi di"# - generating genotype variables for reference and data alleles"
	recodegenotype, a1(`ref_a1') a2(`ref_a2')
	rename _gt temp_ref_gt
	recodegenotype, a1(`alt_a1') a2(`alt_a2')
	rename _gt temp_alt_gt
	noi di"#########################################################################"
	}
qui { // display genotypes and dropping incompatible genotypes
	noi di"# - displaying genotypes (pre-clean)"
	noi ta temp_ref_gt temp_alt_gt
	noi di"# - dropping none R Y M K genotypes"
	foreach xx in A C G T ID DI W S {
		drop if temp_ref_gt == "`xx'"
		drop if temp_alt_gt == "`xx'"
		}
	noi di"# - displaying genotypes (post-clean #1)"
	noi ta temp_ref_gt temp_alt_gt
	noi di"# - dropping non-compatible genotypes (K!=M and R!=Y)"
	drop if temp_ref_gt == "K" & ( temp_alt_gt == "R" |  temp_alt_gt == "Y")
	drop if temp_ref_gt == "M" & ( temp_alt_gt == "R" |  temp_alt_gt == "Y")
	drop if temp_ref_gt == "R" & ( temp_alt_gt == "M" |  temp_alt_gt == "K")
	drop if temp_ref_gt == "Y" & ( temp_alt_gt == "M" |  temp_alt_gt == "K")
	noi di"# - displaying genotypes (post-clean #2)"
	noi ta temp_ref_gt temp_alt_gt
	noi di"#########################################################################"
	}		
qui { // determing strand differences	and create alternate alleles
	noi di"# - determining strand differences for reference and data alleles"
	gen _tmpflip = 0
	replace _tmpflip = 1 if temp_ref_gt != temp_alt_gt
	noi di"# - creating alternative allele codes (flipping)"
	gen _tmpb1 = `alt_a1'
	gen _tmpb2 = `alt_a2'
	replace _tmpb1 = "A" if `alt_a1' == "T" & _tmpflip == 1
	replace _tmpb1 = "C" if `alt_a1' == "G" & _tmpflip == 1
	replace _tmpb1 = "G" if `alt_a1' == "C" & _tmpflip == 1
	replace _tmpb1 = "T" if `alt_a1' == "A" & _tmpflip == 1
	replace _tmpb2 = "A" if `alt_a2' == "T" & _tmpflip == 1
	replace _tmpb2 = "C" if `alt_a2' == "G" & _tmpflip == 1
	replace _tmpb2 = "G" if `alt_a2' == "C" & _tmpflip == 1
	replace _tmpb2 = "T" if `alt_a2' == "A" & _tmpflip == 1
	noi di"# - creating alternative genotype from new alleles"
	recodegenotype, a1(_tmpb1) a2(_tmpb2)
	noi di"# - displaying genotypes (post-clean #3)"
	noi ta temp_ref_gt _gt
	drop _gt temp_ref_gt temp_alt_gt
	}
di "done!"
end;

