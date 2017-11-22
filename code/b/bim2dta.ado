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

di in white"#########################################################################"
di in white"# bim2dta - version 0.1a 10sept2015 richard anney "
di in white"#########################################################################"
di in white"# A command to convert *.bim files (plink-format marker files) to *.dta  "
di in white"# (stata-format).                                                        " 
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
di in white"# > check path of plink *.bim file is true"
qui { 
	capture confirm file "`bim'.bim"
	if _rc==0 {
		noi di in green"# >> `bim'.bim found and will be imported"
		}
	else {
		noi di in red"# >> `bim'.bim not found "
		noi di in red"# >> help: do not include .bim in filename  "
		noi di in red"# >> exiting "
		exit
		}
	}
di in white"# > importing *.bim file"
qui { 
	import delim  using `bim'.bim, clear
	}
di in white"# > naming variables"
qui { 
	rename (v1 v2 v4 v5 v6) (chr snp bp a1 a2)
	}
di in white"# > creating a genotype variable"
qui { 
	recodegenotype , a1(a1) a2(a2)
	rename _gt_tmp gt
	}
di in white"# > cleaning file"
qui { 
	order chr snp bp a1 a2 gt
	keep  chr snp bp a1 a2 gt
	compress
	}
di in white"# > saving file as `bim'_bim.dta"
qui {
	save `bim'_bim.dta, replace
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;	
