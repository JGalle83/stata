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
di in white"#########################################################################"
di in white"# fam2dta - version 0.1a 10sept2015 richard anney "
di in white"#########################################################################"
di in white"# A command to convert *.fam files (plink-format fam files) to *.dta     "
di in white"# (stata-format).                                                        " 
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
di in white"# > check path of plink *.fam file is true"
qui {
	capture confirm file "`fam'.fam"
	if _rc==0 {
		noi di in green"# >> `fam'.fam found and will be imported"
		}
	else {
		noi di in red"# >> `fam'.fam not found "
		noi di in red"# >> help: do not include .fam in filename  "
		noi di in red"# >> exiting "
		exit
		}
	}
di in white " > importing fam file: `fam'.fam"
qui {
	import delim  using `fam'.fam, clear delim(" ")
	}
di in white"# > naming variables"
qui { 
	rename (v1-v6) (fid iid fatid motid sex pheno)
	for var fid iid fatid motid: tostring X, replace
	}
di in white"# > cleaning file"
qui { 
	order fid iid fatid motid sex pheno
	keep  fid iid fatid motid sex pheno
	sort fid iid
	compress
	}
di in white"# > saving file as `fam'_fam.dta"
qui {
	save `fam'_fam.dta, replace
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;		
