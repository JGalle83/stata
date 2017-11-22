program gwas2prs

syntax , name(string asis) reference(string asis) 
di in white"#########################################################################"
di in white"# gwas2prs               "
di in white"# version:  1a              "
di in white"# Creation Date: 5Oct2017            "
di in white"# Author:  Richard Anney (anneyr@cardiff.ac.uk)     "
di in white"#########################################################################"
di in white"# This is a script to standardise the prePRS files from gwas summary statistics     "
di in white"# -----------------------------------------------------------------------"
di in white"# syntax , name(string asis) reference(string asis) "
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
di in white"# > count observations in the dataset"
qui { 
	count
	global inputSNP `r(N)'
	di in white"# >> ${inputSNP} SNPs in the dataset"
	di in white"#########################################################################"
	}
di in white"# > checking if variables exist and are in correct format"
di in white"# >> chromosome variable: chr "
qui { 
	capture confirm var chr 
	if _rc==0 {
		di in green"# >> chr is present"
		}
	else {
		di in red"# >> the var chr is absent ... exiting"
		exit
		}
	di in white"# >>> processing chr"
	qui {
		destring chr, replace
		count if chr > 22
		global nonautosomeSNP `r(N)'
		drop if chr > 22
		drop if chr == .
		tostring chr, replace
		}
	}
di in white"# >> chromosome location variable: bp "
qui { 
	capture confirm var bp 
	if _rc==0 {
		di in green"# >> bp is present"
		}
	else {
		di in red"# >> the var bp is absent ... exiting"
		exit
		}
	di in white"# >>> processing bp"
	qui {
		tostring bp, replace
		}
	}
di in white"# >> allele variable: a1 a2 "
qui { 
	foreach var in a1 a2  {
		capture confirm string var `var' 
		if _rc==0 {
			di in green"# >>> the allele variable `var' is present"
			}
		else {
			di in red"# >>> the allele variable `var' is absent ... exiting"
			exit
			}
		}
	di in white"# >>> processing alleles - removing ID, W and S genotype codes"
	noi recodegenotype, a1(a1) a2(a2)
	count if _gt == "ID" | _gt == "W" | _gt == "S"	
	global problemSNP `r(N)'	
	drop if _gt == "ID" | _gt == "W" | _gt == "S"	
	drop _gt
	}
di in white"# >> info-score variable: info "		
qui { 
	capture confirm numeric var info
	if !_rc {
		di in green"# >> the info score variable info is present and numeric ... continue"
		di in white"# >>> processing info score"
		count if info < .8
		global infoSNP `r(N)'
		drop if info < .8
		drop info
		}
	else {
		di in red"# >> the info score variable info is not present or not numeric ... continue"
		global infoSNP "the info score variable info is not present or not numeric"
		}
	}
di in white"# >> meta-analysis direction variable: direction "		
qui {
	capture confirm string var direction
	if !_rc {
		di in green"# >> the direction variable direction is present and string ... continue"
		di in white"# >>> processing direction"
		replace direction = subinstr(direction, "-", "",.)
		replace direction = subinstr(direction, "+", "",.)
		gen count = length(direction)
		count if count > 1
		global directionSNP `r(N)'
		drop if count > 1
		drop direction count
		}
	else {
		di in red"# >> the direction variable direction is not present or not string ... continue"
		global directionSNP "the direction variable direction is not present"
		}
	}
di in white"# >> marker name variable: rsid"
qui {
	capture confirm string var rsid
	if !_rc {
		di in green"# >> the marker variable rsid is present and string ... continue"
		di in white"# >>> processing rsid - removing duplicates"	
		qui {
			duplicates tag rsid, gen(tag)
			count if tag != 0
			global dupsSNP `r(N)'
			drop  if tag != 0
			drop tag
			}
		}
	else {
		di in red"# >> the marker variable rsid is absent ... exiting"
		exit
		}
	}
di in white"# >> allele frequency variable a1_frq"
qui { 
	capture confirm variable a1_frq
	if !_rc {
		di in green"# >> a1_frq present"
		global a1_frq "a1_frq present in input and used in output"
		}
	else {
		di in red">> a1_frq not present - check for reference frequencies"
		global ref_temp "`reference'"
		capture confirm file "${ref_temp}_frq.dta"
		if !_rc {
			di in green"# >>> ${ref_temp}_frq.dta located"
			global a1_frq "a1_frq not present in input : mapped from ${ref_temp}"
			di in white"# >>> merging with reference"
			qui {
				rename (a1 a2 rsid) (b1 b2 snp) 
				merge 1:1 snp using "${ref_temp}_frq.dta"
				keep if _m == 3
				drop _m
				compress
				}
			di in white"# >>> identifying strand flips"
			qui { 
				noi recodestrand, ref_a1(b1) ref_a2(b2) alt_a1(a1) alt_a2(a2) 
				gen a1_frq = .
				replace a1_frq = maf if b1 == _tmpb1
				replace a1_frq = 1-maf if b1 == _tmpb2
				}
			di in white"# >>> keep aligned allele codes"
			qui {
				keep chr bp snp b1 b2 or p a1_frq
				rename (snp b1 b2) (rsid a1 a2)
				}
			}
		else {
			di in red"# >>> ${ref_temp}_frq.dta not located ... exiting"
			exit
			}
		}
	}
di in white"# > exporting processed data"
qui { 
	count
	global outputSNP `r(N)'
	order chr bp rsid a1 a2 a1_f or p
	keep  chr bp rsid a1 a2 a1_f or p
	outsheet using "`name'-prePRS.tsv", noq replace
	!$gzip  -f "`name'-prePRS.tsv"
	}
di in white"# > make meta-log file (flat txt file)"
qui {
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
	di in white`"# Output.................................................. `name'-prePRS.tsv.gz "'
	di in white"# Number of snps imported ................................ ${inputSNP}"
	di in white"# Number of snps in output................................ ${outputSNP}"
	di in white"# Number of snps dropped due to (ID/W/S) genotype code.... ${problemSNP}"
	di in white"# Number of snps dropped due to non-autosomal chromosome.. ${nonautosomeSNP}"
	di in white"# Number of snps dropped due to info score < 0.8 ......... ${infoSNP}"
	di in white"# Number of snps dropped due missing in >1 study (meta) .. ${directionSNP}"
	di in white"# Number of snps dropped due to duplicated identifier..... ${dupsSNP}"
	di in white"# Origin of a1_frq ....................................... ${a1_frq}"
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;

	
	

	
		
