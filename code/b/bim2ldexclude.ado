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
#########################################################################
*/

program bim2ldexclude
syntax , bim(string asis) 

di in white"#########################################################################"
di in white"# bim2ldexclude                                                          "
di in white"# version:  1a                                                           "
di in white"# Creation Date: 25may2017                                               "
di in white"# Author:  Richard Anney (anneyr@cardiff.ac.uk)                          "
di in white"#########################################################################"
di in white"# A command to identifies long-ld-regions from *.bim files (plink-format "
di in white"# marker files). The regions excluded are identified in; "
di in white"# Long-Range LD Can Confound Genome Scans in Admixed Populations. Alkes "
di in white"# Price, Mike Weale et al., The American Journal of Human Genetics 83, "
di in white"# 127 - 147, July 2008              "
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
	import delim using `bim'.bim, clear 
	}
di in white"# > identifying regions to exclude"
qui { 
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
	}
di in white`"# > exporting snp-list to file "long-range-ld.exclude""'
qui { 
	outsheet v2 if drop == 1 using "long-range-ld.exclude", replace non noq
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;	
	

	
