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
#########################################################################
*/

program fam2dta
syntax , fam(string asis)

di in white "***************************************************"
di in white "fam2dta - version 0.1a 10sept2015 richard anney "
di in white "***************************************************"
di in white "Renaming PLINK fam files"
di in white "Started: $S_DATE $S_TIME"
qui{
	capture confirm file "`fam'.fam"
	if _rc==0 {
		noi di in green"# `fam'.fam found and will be imported"
		}
	else {
		noi di in red"# `fam'.fam not found "
		noi di in red"# help: do not include .fam in filename  "
		noi di in red"# exiting "
		exit
		}
	di in white ".....importing fam file: `fam'.fam"
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
	di in white ".....created new dta file: `fam'_fam.dta"
	}
di in white "Completed: $S_DATE $S_TIME"
di in white "done!"
end;	
