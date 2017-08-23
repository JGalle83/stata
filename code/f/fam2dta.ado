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
