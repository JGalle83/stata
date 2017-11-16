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
# #########################################################################
*/

program bim2dta
syntax , bim(string asis)

di in white"***************************************************"
di in white"bim2dta - version 0.1a 10sept2015 richard anney "
di in white"***************************************************"
di in white"Renaming PLINK bim files (addition of genotype codes)"
di in white"Started: $S_DATE $S_TIME"
qui { 
	capture confirm file "`bim'.bim"
	if _rc==0 {
		noi di in green"# `bim'.bim found and will be imported"
		}
	else {
		noi di in red"# `bim'.bim not found "
		noi di in red"# help: do not include .bim in filename  "
		noi di in red"# exiting "
		exit
		}
	noi di in white".....importing bim file: `bim'.bim"
	import delim  using `bim'.bim, clear 
	noi di in white".....renaming variables"
	rename v1 chr
	rename v2 snp
	rename v4 bp
	rename v5 a1
	rename v6 a2
	noi di in white".....recoding genotypes"
	noi recodegenotype , a1(a1) a2(a2)
	rename _gt_tmp gt
	order chr snp bp a1 a2 gt
	keep  chr snp bp a1 a2 gt
	compress
	sort snp
	save `bim'_bim.dta, replace
	di in white".....created new dta file: `bim'_bim.dta"
	}
di in white"Completed: $S_DATE $S_TIME"
di in white"done!"
end;	

	
