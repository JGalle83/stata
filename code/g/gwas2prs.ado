program gwas2prs
syntax , name(string asis) reference(string asis) 
noi di"#########################################################################"
noi di"# gwas2prs               "
noi di"# version:  1a              "
noi di"# Creation Date: 5Oct2017            "
noi di"# Author:  Richard Anney (anneyr@cardiff.ac.uk)     "
noi di"#########################################################################"
noi di"# This is a script to standardise the prePRS files from gwas summary statistics     "
noi di"# -----------------------------------------------------------------------"
noi di"# syntax , name(string asis) reference(string asis) "
noi di"#########################################################################"
noi di "Started: $S_DATE $S_TIME"

qui { // count input
	count
	global inputSNP `r(N)'
	}
qui { // drop problematic genotypes
	noi di in green"removing ID, W and S genotype codes"
	recodegenotype, a1(a1) a2(a2)
	count if _gt == "ID" | _gt == "W" | _gt == "S"	
	global problemSNP `r(N)'	
	drop if _gt == "ID" | _gt == "W" | _gt == "S"	
	drop _gt
	}
qui { // update chromosome codes and limit to autosomes
	noi di in green"updating chromosomes (assuming coded 1-22)"
	destring chr, replace
	count if chr > 22
	global nonautosomeSNP `r(N)'
	drop if chr > 22
	drop if chr == .
	for var chr bp: tostring X, replace
	}
qui { // cleaning based on info score
	noi di in green"cleaning based on info score"
	capture confirm variable info
	if !_rc {
		count if info < .8
		global infoSNP `r(N)'
		drop if info < .8
		drop info
		}
	else {
		global infoSNP "info variable not present"
		}
	}
qui { // cleaning based on direction variable
	noi di in green"cleaning based on direction variable"
	capture confirm variable direction
	if !_rc {
		replace direction = subinstr(direction, "-", "",.)
		replace direction = subinstr(direction, "+", "",.)
		gen count = length(direction)
		noi ta count
		count if count > 1
		global directionSNP `r(N)'
		drop if count > 1
		drop direction count
		}
	else {
		global directionSNP "direction variable not present"
		}
	}
qui { // removing duplicated SNPs by rsid
	noi di"removing duplicated SNPs by rsid"
	duplicates tag rsid, gen(tag)
	count if tag != 0
	global dupsSNP `r(N)'
	drop  if tag != 0
	drop tag
	}
qui { // create a1_frq if not present
	capture confirm variable a1_frq
	if !_rc {
		noi di"a1_frq present"
		global a1_frq "a1_frq present in input and used in output"
	}
	else {
		noi di"a1_frq not present"
		global a1_frq "a1_frq not present in input and matched frq from ${hg19_maf} used in output"
		rename (a1 a2 rsid) (b1 b2 snp) 
		merge 1:1 snp using `reference'_frq.dta
		keep if _m == 3
		drop _m
		compress
		recodestrand, ref_a1(b1) ref_a2(b2) alt_a1(a1) alt_a2(a2) 
		gen a1_frq = .
		replace a1_frq = maf if b1 == _tmpb1
		replace a1_frq = 1-maf if b1 == _tmpb2
		keep chr bp snp b1 b2 or p a1_frq
		rename (snp b1 b2) (rsid a1 a2)
		}
	}
qui { // outsheet data
	count
	global outputSNP `r(N)'
	order chr bp rsid a1 a2 a1_f or p
	keep  chr bp rsid a1 a2 a1_f or p
	outsheet using "`name'-prePRS.tsv", noq replace
	!$gzip   "`name'-prePRS.tsv"
	}
qui { // make meta log
	noi di in green"...make a meta-log file (flat txt file)"
	clear
	set obs 25
	gen a = ""
	replace a = `"#########################################################################"'            in 1
	replace a = `"# gwas2prs log file"'                                                                  in 2                                                             
	replace a = `"# available from https://github.com/ricanney"'                                         in 3                                  
	replace a = `"# ======================================================================="'            in 4
	replace a = `"# Author:     Richard Anney"'                                                          in 5
	replace a = `"# Institute:  Cardiff University"'                                                     in 6
	replace a = `"# E-mail:     AnneyR@cardiff.ac.uk"'                                                   in 7
	replace a = `"# Date:       5th October 2017"'                                                       in 8
	replace a = `"#########################################################################"'            in 9
	replace a = `""'                                                                                     in 10
	replace a = `"#########################################################################"'            in 11
	replace a = `"# Run Information"'                                                                    in 12      
	replace a = `"# ======================================================================="'            in 13
	replace a = `"# Output.................................................. `name'-prePRS.tsv.gz "'     in 14
	replace a = `"# Date ................................................... $S_DATE $S_TIME "'          in 15
	replace a = `"# Number of snps imported ................................ ${inputSNP}"'               in 16
	replace a = `"# Number of snps in output................................ ${outputSNP}"'              in 17
	replace a = `"# Number of snps dropped due to (ID/W/S) genotype code.... ${problemSNP}"'             in 18
	replace a = `"# Number of snps dropped due to non-autosomal chromosome.. ${nonautosomeSNP}"'         in 19
	replace a = `"# Number of snps dropped due to info score < 0.8 ......... ${infoSNP}"'                in 20
	replace a = `"# Number of snps dropped due missing in >1 study (meta) .. ${directionSNP}"'           in 21
	replace a = `"# Number of snps dropped due to duplicated identifier..... ${dupsSNP}"'                in 22
	replace a = `"# Origin of a1_frq ....................................... ${a1_frq}"'                 in 23
	replace a =  `"#########################################################################"'           in 24
	outsheet using `name'-prePRS.meta-log, non noq replace
	}

di "Completed: $S_DATE $S_TIME"
di "done!"
end;

	
	

	
		
