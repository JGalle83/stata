/*
#########################################################################
# genotypeqc
# a command to perform a full quality-control pipeline in plink binaries
#
# command: genotypeqc, param(parameter-file)
#
#########################################################################
# additional files
# download the following archive;
#  https://www.dropbox.com/s/u7s9su44beda710/sandbox.tar.gz?dl=0 - archive
#  https://www.dropbox.com/s/4q1oh1nsxhnoww5/sandbox.tar.gz.md5?dl=0 - md5
#
# this archive contains 
# 1- an example parameter file
#  ** adjust parameter file according to location of unpacked archive **
#  ** adjust parameter file according to quality-control appropriateness **
# 2- the genotype-array archive
# 3- the genome-build file
# 4- reference genotypes from 1000-genomes-phase-1 and hapmap3
# 5- reference frequency data from 1000-genomes-phase-1
# 6- subset of hapmap3 ancestry-informative markers
# 7- population tag for hapmap3
#
# prior to implementation, run the install-all.do file from
# https://github.com/ricanney/stata-genomics-ado
#
#download the following executables from
# plink1.9+ from https://www.cog-genomics.org/plink2
# plink2.+  from https://www.cog-genomics.org/plink/2.0/
#
# download the following perl-script from 
# tabbed.pl from https://github.com/ricanney/perl
# 
# prior to implementation map the following to global tags
#
# global tabbed perl <location of tabbed.pl>
# global plink <location of plink1.9+.exe>
# global plink2 <location of plink2+.exe>
#
#########################################################################

# version 5
# =======================================================================
# change maf to mac5
# remove allele freq check if data is imputed against hrc - mixed ancestry of samples removes non-eur alleles
# retain W/S and ID

#########################################################################
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 12th July 2017
#########################################################################
*/
program genotypeqc
syntax , param(string asis) 
	qui { // introduce program
		noi di in green"#########################################################################"
		noi di in green"# genotypeqc                                                             "
		noi di in green"# version:       1.0                                                     "
		noi di in green"# Creation Date: 17July2017                                              "
		noi di in green"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
		noi di in green"#########################################################################"
		noi di in green""
		}		
	qui { // preamble
		noi di in green"#########################################################################"
		noi di in green"# Preamble                                                              #"
		noi di in green"#########################################################################"
		qui { // create temporary working directory (using ralpha)
			noi di in green"#########################################################################"
			noi di in green"# > create temporary working directory                                  #"
			noi di in green"#########################################################################"
			!cd > _000x.tsv
			import delim using _000x.tsv, varname(nonames) clear
			erase _000x.tsv
			gen a = ""
			ssc install ralpha
			ralpha folderRandom, range(A/z) l(10)
			gen a1 = `"global wd ""' + v1 + "\" + folderRandom + `"""'
			gen a2 = `"global cd ""' + v1 + `"""'
			gen n = _n
			keep n a1-a2
			reshape long a, i(n) 
			outsheet a using _000a.do, non noq replace
			do _000a.do
			erase _000a.do
			noi di in green"# the current directory is ............. $cd"
			noi di in green"# the temporary working directory is ... $wd"
			noi di in green"#########################################################################"
			noi di in green""
			!mkdir $wd
			cd $wd
			}
		qui { // check path of dependent software is true
			noi di in green"#########################################################################"
			noi di in green"# > check path of dependent software is true                            #"
			noi di in green"#########################################################################"
			qui { // plink v1.9
				capture confirm file "$plink"
				if _rc==0 {
					noi di in green"# plink v1.9+ exists and is correctly assigned as  $plink"
					}
				else {
					noi di in red"# plink v1.9 does not exists; download executable from https://www.cog-genomics.org/plink2 "
					noi di in red"# set plink v1.9 location using;  "
					noi di in red`"# global plink "folder\file"  "'
					exit
					}
				}
			qui { // plink v2
				capture confirm file "$plink2"
				if _rc==0 {
					noi di in green"# plink v2+  exists and is correctly assigned as  $plink2"
					}
				else {
					noi di in red"# plink v2 does not exists; download executable from https://www.cog-genomics.org/plink/2.0/ "
					noi di in red"# set plink v2 location using;  "
					noi di in red`"# global plink2 "folder\file"  "'
					exit
					}
				}
			qui { // tabbed
				clear
				set obs 1
				gen a = "$tabbed"
				replace a = subinstr(a,"perl ","capture confirm file ",.)
				outsheet a using _ooo.do, non noq replace
				do _ooo.do
				if _rc==0 {
					noi di in green"# the tabbed.pl script exists and is correctly assigned as  $tabbed"
					noi di in green"# ..... ensuring perl is working on your system and can be called from the command-line"
					clear 
					set obs 10
					gen a = "a b c d"
					outsheet a using test_pl.txt, noq replace
					!$tabbed test_pl.txt
					capture confirm file "test_pl.txt.tabbed"
					if _rc==0 {
						noi di in green"# ..... the tabbed.pl script is working"
						}
					else {
						noi di in red"# ..... the tabbed.pl script did not work"
						noi di in red"# download and install active perl on your computer https://www.activestate.com/activeperl/downloads"
						exit
						}
					!del test_pl.*
					}
				else {
					noi di in red"# tabbed.pl does not exists; download executable from https://github.com/ricanney/perl "
					noi di in red"# set tabbed.pl location using;  "
					noi di in red`"# global tabbed "folder\file"  "'
					exit
					}
				erase _ooo.do
				}
			noi di in green"#########################################################################"
			}
		qui { // run parameters
			noi di in red" *** as of 16th November - the parameter file has become streamlined, removing annotation and becoming in essence a \*.do file"
			noi di in red" *** all globals can be assigned prior to running genotyeqc and a dummy parameter file can be created in lieu"
			noi di in red" *** see https://github.com/ricanney/stata/edit/master/documents/genotypeqc.md for details of new parameter file structure"
			do ${cd}\\`param'
			global input "${data_folder}\\${data_input}"
			global output "${data_folder}\\${data_input}-qc-v5"
			global output_2 "${data_input}-qc-v5"
			}
		qui { // check path of dependent reference data is true
			noi di in green"#########################################################################"
			noi di in green"# > check path of dependent reference data is true                      #"
			noi di in green"#########################################################################"
			foreach i in build_ref kg_ref_frq aims  {
				capture confirm file "${`i'}"
				if _rc==0 {
					noi di in green"# ...................................... ${`i'} found"
					}
				else {
					noi di in red"# ...................................... ${`i'} does not exist"
					exit
					}
				}
			foreach i in bim bed fam {
				capture confirm file "${hapmap_data}.`i'"
				if _rc==0 {
					noi di in green"# ...................................... ${hapmap_data}.`i' found"
					}
				else {
					noi di in red"# ...................................... ${hapmap_data}.`i' does not exist"
					exit
					}
				}
			capture cd "$array_ref"
			if _rc==0 {
				noi di in green"# ...................................... $array_ref directory exists"
				}
			else {
				noi di in red"# ...................................... ${array_ref} directory does not exist"
				exit
				}
			cd $wd	
			}
		qui { // check path of plink binaries to be quality controlled is true
			noi di in green"#########################################################################"
			noi di in green"# > check path of plink binaries to be quality controlled is true       #"
			noi di in green"#########################################################################"
			qui { // ${input}
				foreach i in bim bed fam {
					capture confirm file "${input}.`i'"
					if _rc==0 {
						noi di in green"# ...................................... ${input}.`i' found"
						}
					else {
						noi di in red"# ...................................... ${input}.`i' does not exist"
						exit
						}
					}
				}
			noi di in green"#########################################################################"
			noi di in green""
			noi di in green"#########################################################################"
			noi di in green"# > display output file and thresholds                                  #"
			noi di in green"#########################################################################"
			noi di in green"# The dataset will be processed and deposited as                        #"
			noi di in green"# ...................................... ${output}"
			noi di in green"#########################################################################"
			noi di in green"# The following parameters will be applied"
			noi di in green"# minimum minor-allele-frequency retained ........................ mac5"
			noi di in green"# maximum genotype-missingness ................................... ${geno2} (preQC = ${geno1})"
			noi di in green"# maximum individual-missingness ................................. ${mind}"
			noi di in green"# maximum tolerated heterozygosity outliers (by-sd) .............. ${hetsd}"
			noi di in green"# maximum tolerated hardy-weinberg deviation ..................... p < 1E-${hwep}"
			noi di in green"# the minimum kinship score for duplicates is set at ............. ${kin_d}"  
			noi di in green"# the minimum kinship score for 1st degree relatives is set at ... ${kin_f}"  
			noi di in green"# the minimum kinship score for 2nd degree relatives is set at ... ${kin_s}"  
			noi di in green"# the minimum kinship score for 3rd degree relatives is set at ... ${kin_t}"  
			noi di in green"#########################################################################"
			noi di in green""
			}
			}
	qui { // Module #1 - determining the original genotyping array 
		noi di in green"#########################################################################"
		noi di in green"# Module #1 - define most likely genotyping array of plink binaries from reference data"
		noi di in green"#########################################################################"
		qui { // import bim file
			noi di in green"...importing ............................${input}.bim"
			qui bim2dta,bim(${input})
			rename snp rsid
			keep rsid
			sort rsid
			save tempfile-2001.dta, replace
			}
		qui { // check the overlap with references
			noi di in green"...checking overlap with reference lists and calculating overlaps (this bit can take some time)"
			file open myfile using ${output}.arraymatch, write replace
			file write myfile "Array:Overlap:SNPsinModel:Jaccard Index" _n
			file close myfile
			clear
			set obs 1								
			gen folder = ""							
			save tempfile-2002.dta,replace							
			local myfiles: dir "${array_ref}" dirs "*" 	, respectcase				
			foreach folder of local myfiles {
				clear								
				set obs 1							
				gen folder = "`folder'" 					
				append using tempfile-2002.dta						
				save tempfile-2002.dta,replace						
				}
			drop if folder == ""
			foreach i of num 1/20 {
				append using tempfile-2002.dta
				}
			erase tempfile-2002.dta
			sort folder
			drop if folder == ""
			egen obs = seq(),by(folder)
			gen a = ""
			replace a = `"use tempfile-2001.dta, clear"'     if obs == 1 
			replace a = `"merge m:m rsid using ${array_ref}\"' + folder + "\" + folder + ".dta"  if obs == 2 
			replace a = `"count if _merge == 3"' if obs == 3
			replace a = `"global ab \`r(N)'"' if obs == 4
			replace a = `"gen ab = \${ab}"' if obs == 5
			replace a = `"count "' if obs == 6
			replace a = `"global all \`r(N)'"' if obs == 7
			replace a = `"gen all = \${all}"' if obs == 8
			replace a = `"gen JaccardIndex = ab/all"' if obs == 9 
			replace a = `"sum JaccardIndex"' if obs == 10
			replace a = `"global ji \`r(min)'"' if obs == 11 
			replace a = `"di"... "' + folder + `" overlap = \${ab} of \${all}""' if obs == 12 
			replace a = `"filei + ""' + folder + `":\${ab}:\${all}:\${ji}" \${output}.arraymatch"' if obs == 13 
			outsheet a using tempfile-2001.do, non noq replace
			do tempfile-2001.do
			!del tempfile-2001.do tempfile-2001.dta
			noi di in green"...finished checking reference lists"
			}
		qui { // create mini-report build
			import delim using ${output}.arraymatch, clear delim(":") varnames(1) case(preserve)
			gsort -J
			gen MostLikely = "+++" in 1
			replace MostLikely = "++" if J > 0.9 & MostLikely == ""
			replace MostLikely = "+" if J > 0.8 & MostLikely == ""
			outsheet using ${input}.arraymatch, replace noq
			outsheet using ${output}.arraymatch, replace noq
			keep in 1
			gen a = ""
			replace a = "global arrayType "
			outsheet a Array using tempfile-2001.do, non noq replace
			replace a = "global Jaccard "
			outsheet a J using tempfile-2002.do, non noq replace
			do tempfile-2001.do
			do tempfile-2002.do
			!del tempfile-2001.do tempfile-2002.do
			}		
		qui { // plot Jaccard Index by Array
			import delim using ${output}.arraymatch, clear case(preserve)
			keep if _n <10
			graph hbar Jaccard , over(Array,sort(Jaccard) lab(labs(large))) title("Jaccard Index") yline(.9, lcol(red)) fxsize(200) fysize(100) ///
				caption("Based on overlap with our reference data (derived from http://www.well.ox.ac.uk/~wrayner/strand/) the best matched ARRAY is ${arrayType}" ///
								"Jaccard Index of  ${arrayType} = ${Jaccard}")
			graph export ${output}.arraymatch.png, height(1000) width(4000) as(png) replace 
			graph export  ${input}.arraymatch.png, height(1000) width(4000) as(png) replace 
			window manage close graph
			}
		qui { // give a brief output to screen
			noi di in green"#########################################################################"
			noi di in green"# best array match is ......... ${arrayType}"
			noi di in green"# based on jaccard index of ... 0${Jaccard}"
			noi di in green"# summary plot available in ... ${output}.arraymatch.png"
			noi di in green"# summary data available in ... ${output}.arraymatch"
			noi di in green"#########################################################################"
			noi di in green""
			}
		}
	qui { // Module #2 - update marker identifiers to 1000-genomes compatible rsid
		noi di in green"#########################################################################"
		noi di in green"# Module #2 - update marker identifiers to 1000-genomes compatible rsid #"
		* - prepare genotype files
		* - convert to hg+1 using wrayner data
		* - update names where rsid is in title
		* - remove duplicates by rsid - round #1
		* - remove duplicates by location 
		* - rename snps without rsid using 1000-genomes as a reference
		* - remove duplicates by rsid - round #1
		* - remove variants with divergent allele-frequencies with reference genotypes
		noi di in green"#########################################################################"	
		qui { // prepare genotype file
			noi di in green"...remove low-count genotypes (mac 5)"
			!$plink --bfile ${input} --mac 5 --make-bed --out tempfile-module-2-01
			import delim using tempfile-module-2-01.log, clear
			split v1,p(" variants loaded from .bim file.")
			keep if v1 != v11
			for var v11  : destring X, replace force
			drop if v11 == .
			noi di in green"#########################################################################"	
			sum v11
			noi di in green"# `r(sum)' variants in ${input}.bim"
			import delim using tempfile-module-2-01.log, clear
			split v1,p(" people ("", "") loaded from .fam.")
			keep if v1 != v11
			for var v11  : destring X, replace force
			drop if v11 == .
			sum v11
			noi di in green"# `r(sum)' individuals in ${input}.fam"
			import delim using tempfile-module-2-01.log, clear
			split v1,p(" variants and "" people pass filters and QC.")
			for var v11 v12  : destring X, replace force
			drop if v11 == .
			sum v11
			noi di in green"# `r(sum)' variants remain after --mac 5"
			sum v12
			noi di in green"# `r(sum)' individuals remain after --mac 5"			
			noi di in green"#########################################################################"	
			}
		qui { // convert to hg+1 using wrayner data
			noi di in green"...update build to hg19+1 using ${array_ref}\\${arrayType}\\${arrayType}.dta"
			use ${array_ref}\\${arrayType}\\${arrayType}.dta, clear
			replace chr = "23" if chr == "X"
			replace chr = "24" if chr == "Y"
			replace chr = "26" if chr == "MT"
			outsheet rsid                   using tempfile.extract, non noq replace
			outsheet rsid chr               using tempfile.update-chr, non noq replace
			outsheet rsid bp                using tempfile.update-map, non noq replace
			!$plink --bfile tempfile-module-2-01 --extract    tempfile.extract    --make-bed --out tempfile-module-2-02
			foreach file in bim bed fam { 
				!del tempfile-module-2-01.`file'
				}
			!$plink --bfile tempfile-module-2-02 --update-chr tempfile.update-chr --make-bed --out tempfile-module-2-03
			foreach file in bim bed fam { 
				!del tempfile-module-2-02.`file'
				}
			!$plink --bfile tempfile-module-2-03 --update-map tempfile.update-map --make-bed --out tempfile-module-2-04 
			foreach file in bim bed fam { 
				!del tempfile-module-2-03.`file'
				}
			}	
		qui { // update non-rsid names where rsid is in title
			noi di in green"...update names where rsid is in title"
			import delim using tempfile-module-2-04.bim, clear case(lower)
			rename v2 snp
			keep snp
			split snp,p("rs")
			capture confirm variable snp2
			if !_rc {
				di in green "rs # included in array"
				}
			else {
			 di in red "rs # not included in array"
			 gen snp2 = ""
			 }	
			gen renameSNP = "rs" + snp2
			drop if snp == renameSNP
			drop if renameSNP == "rs"
			outsheet snp renameSNP using  tempfile-module-2-04.update-name, non noq replace 
			!$plink --bfile tempfile-module-2-04 --update-name tempfile-module-2-04.update-name --make-bed --out tempfile-module-2-05
			foreach file in bim bed fam { 
				!del tempfile-module-2-04.`file'
				}
			}
		qui { // remove duplicates by rsid - round #1
			noi di in green"...remove duplicates by rsid"
			import delim using tempfile-module-2-05.bim, clear case(lower)
			rename v2 snp
			keep snp
			duplicates tag snp, gen(tag)
			keep if tag !=0
			count
			if `r(N)' != 0 {
					noi di in green"...`r(N)' duplicates are present"
					keep snp
					duplicates drop 
					outsheet snp using tempfile.exclude, non noq replace
					}
			else if `r(N)' == 0 {
					noi di in green"...`r(N)' duplicates are present"
					keep snp
					outsheet snp using tempfile.exclude, non noq replace
					}
			!$plink --bfile tempfile-module-2-05 --exclude tempfile.exclude --make-bed --out tempfile-module-2-06
			foreach file in bim bed fam { 
				!del tempfile-module-2-05.`file'
				}
			}
		qui { // remove duplicates by location
				noi di in green"...remove duplicates by location"
				!$plink --bfile tempfile-module-2-06 --list-duplicate-vars --out tempfile-module-2-06
				import delim using tempfile-module-2-06.dupvar, clear
				drop if chr == 0
				count
				if `r(N)' != 0 { 
					noi di in green"...`r(N)' locations have >1 variants with common alleles"
					noi di in green"...we will preferentialy keep variants with an rsid"
					split ids,p(" ")
					keep ids1 ids2
					gen ids11 = substr(ids1,1,2)
					gen ids21 = substr(ids2,1,2)
					gen keep = .
					replace keep = 1 if ids11 == "rs"
					replace keep = 2 if ids21 == "rs" & keep == .
					replace keep = 1 if keep  == .
					gen rsid = ""
					replace rsid = ids1 if keep == 1
					replace rsid = ids2 if keep == 2
					keep rsid
					drop if rsid == ""
					save tempfile-module-2-06.dta, replace
					import delim using tempfile-module-2-06.dupvar, clear
					keep ids
					split ids,p(" ")
					gen obs = _n
					drop ids
					reshape long ids, i(obs) j(x)
					keep ids
					rename ids rsid
					drop if rsid == ""
					merge 1:1 rsid using tempfile-module-2-06.dta
					outsheet rsid if _m == 1 using tempfile.exclude, non noq replace
					!$plink --bfile tempfile-module-2-06 --exclude tempfile.exclude --make-bed --out tempfile-module-2-07
					foreach file in bim bed fam { 
						!del tempfile-module-2-06.`file'
						}
					}
				else if `r(N)' == 0 {
					noi di in green"...0 locations have >1 variants with common alleles"
					!$plink --bfile tempfile-module-2-06 --make-bed --out tempfile-module-2-07
					foreach file in bim bed fam { 
						!del tempfile-module-2-06.`file'
						}
					}
				}
		qui { // rename snps without rsid using 1000-genomes as a reference
			noi di in green"...update to latest rsid using 1000-genomes as a reference"
			qui bim2dta, bim(tempfile-module-2-07)
			split snp,p("rs")
			capture confirm variable snp2
			if !_rc {
				di in green "rs # included in array"
				}
			else {
			 di in red "rs # not included in array"
			 gen snp2 = ""
			 }
			gen renameSNP = "rs" + snp2
			keep if renameSNP == "rs"
			count
			if `r(N)' != 0 { 
				noi di in green"...`r(N)' variants do not have an rsid"
				keep chr bp snp gt
				for var chr bp: tostring X, replace
				rename gt array_gt
				merge m:m chr bp using ${kg_ref_frq}
				keep if _m == 3
				count
				if `r(N)' != 0 { 
					noi di in green"...`r(N)' variants (by location) have a matching rsid"
					drop _m
					noi di in green"...checking strand compatibility of UIPAC codes"
					noi ta array_gt kg_gt
					gen drop = .
					replace drop = 1 if array_gt == "M"  & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
					replace drop = 1 if array_gt == "K"  & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
					replace drop = 1 if array_gt == "R"  & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
					replace drop = 1 if array_gt == "Y"  & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
					replace drop = 1 if array_gt == "ID" & (kg_gt != "ID")
					replace drop = 1 if array_gt == "S"  & (kg_gt != "S") 
					replace drop = 1 if array_gt == "W"  & (kg_gt != "W") 
					drop if drop == 1
					drop drop	
					duplicates tag snp, gen(y)
					count if y != 0
					noi di in green"...`r(N)' observations where snp to be renamed has >1 rsid - drop all instances"
					drop if y !=0
					count
					noi di in green"...`r(N)' variants to be renamed"
					outsheet snp rsid using tempfile-module-2-07.update-name, non noq replace 
					!$plink --bfile tempfile-module-2-07 --update-name tempfile-module-2-07.update-name --make-bed --out tempfile-module-2-08
					foreach file in bim bed fam { 
						!del tempfile-module-2-07.`file'
						}
					}
				else if `r(N)' == 0 { 
					noi di in green"...`r(N)' variants (by location) have a matching rsid"
					noi di in green"...`r(N)' variants to be renamed"
					!$plink --bfile tempfile-module-2-07 --make-bed --out tempfile-module-2-08
					foreach file in bim bed fam { 
						!del tempfile-module-2-07.`file'
						}
					}
				}
			else if `r(N)' == 0 {
				noi di in green"...`r(N)' variants do not have an rsid"
				!$plink --bfile tempfile-module-2-07 --make-bed --out tempfile-module-2-08
					foreach file in bim bed fam { 
						!del tempfile-module-2-07.`file'
						}
					}
			}
		qui { // remove duplicates by rsid - round #2
			noi di in green"...remove duplicates by rsid"
			import delim using tempfile-module-2-08.bim, clear case(lower)
			rename v2 snp
			keep snp
			duplicates tag snp, gen(tag)
			keep if tag !=0
			count
			if `r(N)' != 0 {
				noi di in green"...`r(N)' duplicates are present"
				keep snp
				duplicates drop 
				outsheet snp using tempfile.exclude, non noq replace
				}
			else if `r(N)' == 0 {
				noi di in green"...`r(N)' duplicates are present"
				keep snp
				outsheet snp using tempfile.exclude, non noq replace
				}
			!$plink --bfile tempfile-module-2-08 --exclude tempfile.exclude --make-bed --out tempfile-module-2-09
			foreach file in bim bed fam { 
				!del tempfile-module-2-08.`file'
				}
			}
		qui { // remove variants with divergent allele-frequencies with reference genotypes
			clear
			set obs 1
			gen array = "${arrayType}"
			if array != "michigan-imputation-server-v1.0.3-hrc-r1.1-2016" {
				noi di in green"...remove variants with divergent allele-frequencies from that in reference genotypes - keep those without information"
				import delim using tempfile-module-2-09.bim, clear case(lower)
				rename v2 rsid
				keep rsid
				merge 1:m rsid using ${kg_ref_frq}
				keep if _m == 3
				duplicates tag rsid, gen(tag)
				outsheet rsid if tag != 0 using tempfile-module-2-09a.exclude, non noq replace
				keep if tag == 0
				outsheet rsid using tempfile-module-2-09.extract, non noq replace
				!$plink --bfile tempfile-module-2-09 --extract tempfile-module-2-09.extract --freq --out tempfile-module-2-09
				qui bim2dta, bim(tempfile-module-2-09)
				!$tabbed tempfile-module-2-09.frq
				import delim using tempfile-module-2-09.frq.tabbed, clear	
				destring maf, replace force
				tostring snp,replace
				keep snp a1 maf
				merge 1:1 snp a1 using tempfile-module-2-09_bim.dta
				keep if _m == 3
				drop _m chr bp
				for var a1 a2 maf gt: rename X array_X
				rename snp rsid
				merge 1:1 rsid using ${kg_ref_frq}
				count if _m == 1
				noi di in green"...`r(N)' varaints not present in ${kg_ref_frq}"
				count if _m == 3
				noi di in green"...`r(N)' varaints present in ${kg_ref_frq}"
				drop if _m == 2
				noi di in green"...checking allele-frequencies with reference (W/S excluded)"
				gen drop = .
				drop if _m == 1
				replace drop = 1 if array_gt == "M"  & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
				replace drop = 1 if array_gt == "K"  & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
				replace drop = 1 if array_gt == "R"  & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
				replace drop = 1 if array_gt == "Y"  & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
				replace drop = 1 if array_gt == "ID" & (kg_gt != "ID")
				outsheet rsid if drop == 1 using tempfile-module-2-09b.exclude, non noq replace
				replace drop = 2 if array_gt == "W"
				replace drop = 2 if array_gt == "S"
				sum if drop == 1
				noi di in green"...`r(N)' variants to be excluded due to incompatible UIPAC codes"
				gen ref_maf = .
				replace ref_maf = kg_maf if (kg_gt == array_gt & kg_a1 == array_a1)
				replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "A" & array_a1 == "T")
				replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "C" & array_a1 == "G")
				replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "G" & array_a1 == "C")
				replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "T" & array_a1 == "A")
				replace ref_maf = 1-kg_maf if (kg_gt == array_gt & kg_a1 != array_a1)
				replace ref_maf = 1-kg_maf if ref_maf == .
				global format mlc(black) mfc(blue) mlw(vvthin) m(o) xtitle("allele-frequency-array") ytitle("allele-frequency-1000-genomes")
				tw scatter ref_maf array_maf if drop == . , $format saving(tempfile-module-2-09-pre-clean,replace) nodraw
				replace drop = 1 if array_maf > ref_maf + .1 
				replace drop = 1 if array_maf < ref_maf - .1  
				tw scatter ref_maf array_maf if drop == . , $format saving(tempfile-module-2-09-post-clean,replace) nodraw
				graph combine tempfile-module-2-09-pre-clean.gph tempfile-module-2-09-post-clean.gph, ycommon
				graph export  tempfile-module-2-allele-frequency-check.png, as(png) height(500) width(2000) replace
				outsheet rsid if drop == 1 using tempfile-module-2-09c.exclude, non noq replace
				!type tempfile-module-2-09a.exclude > tempfile.exclude
				!type tempfile-module-2-09b.exclude >> tempfile.exclude
				!type tempfile-module-2-09c.exclude >> tempfile.exclude
				!$plink --bfile tempfile-module-2-09 --exclude tempfile.exclude --make-bed --out tempfile-module-2-final
				foreach file in bim bed fam { 
					!del tempfile-module-2-09.`file'
					}
				}
			else if array == "michigan-imputation-server-v1.0.3-hrc-r1.1-2016"{
				noi di in green"...remove variants with divergent allele-codes from that in reference genotypes - keep those without information"
				import delim using tempfile-module-2-09.bim, clear case(lower)
				rename v2 rsid
				keep rsid
				merge 1:m rsid using ${kg_ref_frq}
				keep if _m == 3
				duplicates tag rsid, gen(tag)
				outsheet rsid if tag != 0 using tempfile-module-2-09a.exclude, non noq replace
				keep if tag == 0
				outsheet rsid using tempfile-module-2-09.extract, non noq replace
				!$plink --bfile tempfile-module-2-09 --extract tempfile-module-2-09.extract --freq --out tempfile-module-2-09
				bim2dta, bim(tempfile-module-2-09)
				!$tabbed tempfile-module-2-09.frq
				import delim using tempfile-module-2-09.frq.tabbed, clear	
				destring maf, replace force
				tostring snp,replace
				keep snp a1 maf
				merge 1:1 snp a1 using tempfile-module-2-09_bim.dta
				keep if _m == 3
				drop _m chr bp
				for var a1 a2 maf gt: rename X array_X
				rename snp rsid
				merge 1:1 rsid using ${kg_ref_frq}
				count if _m == 1
				noi di in green"...`r(N)' varaints not present in ${kg_ref_frq}"
				count if _m == 3
				noi di in green"...`r(N)' varaints present in ${kg_ref_frq}"
				drop if _m == 2
				noi di in green"...checking allele-frequencies with reference (W/S excluded)"
				gen drop = .
				drop if _m == 1
				replace drop = 1 if array_gt == "M"  & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
				replace drop = 1 if array_gt == "K"  & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
				replace drop = 1 if array_gt == "R"  & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
				replace drop = 1 if array_gt == "Y"  & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
				replace drop = 1 if array_gt == "ID" & (kg_gt != "ID")
				outsheet rsid if drop == 1 using tempfile-module-2-09b.exclude, non noq replace
				replace drop = 2 if array_gt == "W"
				replace drop = 2 if array_gt == "S"
				sum drop 
				noi di in green"...`r(N)' variants to be excluded due to incompatible UIPAC codes"
				gen ref_maf = .
				replace ref_maf = kg_maf if (kg_gt == array_gt & kg_a1 == array_a1)
				replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "A" & array_a1 == "T")
				replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "C" & array_a1 == "G")
				replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "G" & array_a1 == "C")
				replace ref_maf = kg_maf if (kg_gt != array_gt & kg_a1 == "T" & array_a1 == "A")
				replace ref_maf = 1-kg_maf if (kg_gt == array_gt & kg_a1 != array_a1)
				replace ref_maf = 1-kg_maf if ref_maf == .
				global format mlc(black) mfc(blue) mlw(vvthin) m(o) xtitle("allele-frequency-array") ytitle("allele-frequency-1000-genomes")
				tw scatter ref_maf array_maf if drop == . , $format saving(tempfile-module-2-09-pre-clean,replace) nodraw
				twoway scatteri 1 1,            ///
				msymbol(i)                      ///
				ylab("") xlab("")               ///
				ytitle("") xtitle("")           ///
				yscale(off) xscale(off)         ///
				plotregion(lpattern(blank))     ///
				name(blank, replace)
				
				graph combine tempfile-module-2-09-pre-clean.gph blank, ycommon
				graph export  tempfile-module-2-allele-frequency-check.png, as(png) height(500) width(2000) replace
				outsheet rsid if drop == 1 using tempfile-module-2-09c.exclude, non noq replace
				!type tempfile-module-2-09a.exclude > tempfile.exclude
				!type tempfile-module-2-09b.exclude >> tempfile.exclude
				!type tempfile-module-2-09c.exclude >> tempfile.exclude
				!$plink --bfile tempfile-module-2-09 --exclude tempfile.exclude --make-bed --out tempfile-module-2-final		
				foreach file in bim bed fam { 
					!del tempfile-module-2-09.`file'
					}
				}
			}
		qui { // clean-up files
			!del tempfile-module-2-0* tempfile-module-2-1* *.exclude *update-map *.update-chr 
			}
		qui { // report on status
			import delim using tempfile-module-2-final.log, clear
			split v1,p(" variants and "" people pass filters and QC.")
			for var v11 v12  : destring X, replace force
			drop if v11 == .
			noi di in green"#########################################################################"
			sum v11
			noi di in green"# `r(sum)' variants pass renaming / allele-frequency checking module"
			sum v12
			noi di in green"# `r(sum)' individuals pass renaming / allele-frequency checking module"
			noi di in green"#########################################################################"	
			noi di in green""
			}
		}
	qui { // Module #3 - report the genome build
		noi di in green"#########################################################################"
		noi di in green"# Module #3 - report the genome build                                   #"
		noi di in green"#########################################################################"
		qui { // check build of input binaries
			noi di in green"...checking the build of the input binaries"
			qui bim2dta, bim($input)
			rename snp rsid
			keep rsid chr bp
			duplicates drop rsid, force
			sort rsid
			merge 1:1 rsid using ${build_ref}
			keep if _m == 3
			tostring bp, replace	
			gen hg17_0 = 1 if bp == hg17_chromStart 
			gen hg17_1 = 1 if bp == hg17_chromEnd 
			gen hg18_0 = 1 if bp == hg18_chromStart 
			gen hg18_1 = 1 if bp == hg18_chromEnd 
			gen hg19_0 = 1 if bp == hg19_chromStart 
			gen hg19_1 = 1 if bp == hg19_chromEnd 
			sum chr
			gen all = r(N)
			foreach i in 17_0 17_1 18_0 18_1 19_0 19_1 {
				sum hg`i'
				gen phg`i' = r(N) / all
				}
			keep in 1
			keep phg17_0 - phg19_1
			xpose, clear v
			rename v1 percentMatched
			rename _v build
			replace build = "hg17 +0" if build == "phg17_0"
			replace build = "hg17 +1" if build == "phg17_1"
			replace build = "hg18 +0" if build == "phg18_0"
			replace build = "hg18 +1" if build == "phg18_1"
			replace build = "hg19 +0" if build == "phg19_0"
			replace build = "hg19 +1" if build == "phg19_1"
			gsort -p
			gen MostLikely = "+++" in 1
			replace MostLikely = "++" if p > 0.9 & MostLikely == ""
			replace MostLikely = "+" if p > 0.8 & MostLikely == ""
			outsheet using ${input}.hg-buildmatch, replace noq	
			graph hbar percentMatched , over(build,sort(percentMatched) lab(labs(large))) title("Percentage Match Genome Build") yline(.9, lcol(red))  
			graph export ${input}.hg-buildmatch.png, as(png) height(1000) width(4000) replace
			window manage close graph
			keep in 1
			gen a = "global buildType "
			outsheet a build using tempfile-module-3.do, non noq replace
			do tempfile-module-3.do
			erase tempfile-module-3.do
			}
		qui { // check build of output binaries
			noi di in green"...checking the build of the output binaries"
			qui bim2dta, bim(tempfile-module-2-final)
			rename snp rsid
			keep rsid chr bp
			duplicates drop rsid, force
			sort rsid
			merge 1:1 rsid using ${build_ref}
			keep if _m == 3
			tostring bp, replace	
			gen hg17_0 = 1 if bp == hg17_chromStart 
			gen hg17_1 = 1 if bp == hg17_chromEnd 
			gen hg18_0 = 1 if bp == hg18_chromStart 
			gen hg18_1 = 1 if bp == hg18_chromEnd 
			gen hg19_0 = 1 if bp == hg19_chromStart 
			gen hg19_1 = 1 if bp == hg19_chromEnd 
			sum chr
			gen all = r(N)
			foreach i in 17_0 17_1 18_0 18_1 19_0 19_1 {
				sum hg`i'
				gen phg`i' = r(N) / all
				}
			keep in 1
			keep phg17_0 - phg19_1
			xpose, clear v
			rename v1 percentMatched
			rename _v build
			replace build = "hg17 +0" if build == "phg17_0"
			replace build = "hg17 +1" if build == "phg17_1"
			replace build = "hg18 +0" if build == "phg18_0"
			replace build = "hg18 +1" if build == "phg18_1"
			replace build = "hg19 +0" if build == "phg19_0"
			replace build = "hg19 +1" if build == "phg19_1"
			gsort -p
			gen MostLikely = "+++" in 1
			replace MostLikely = "++" if p > 0.9 & MostLikely == ""
			replace MostLikely = "+" if p > 0.8 & MostLikely == ""
			outsheet using ${output}.hg-buildmatch, replace noq		
			graph hbar percentMatched , over(build,sort(percentMatched) lab(labs(large))) title("Percentage Match Genome Build") yline(.9, lcol(red))  
			graph export ${output}.hg-buildmatch.png, as(png) height(1000) width(4000) replace
			window manage close graph
			noi di in green"#########################################################################"
			noi di in green"# the input binaries are based on build ${buildType}"			
			keep in 1
			gen a = "global buildType "
			outsheet a build using tempfile-module-3.do, non noq replace
			do tempfile-module-3.do
			erase tempfile-module-3.do
			noi di in green"# the output binaries are based on build ${buildType}"			
			}
		noi di in green"#########################################################################"
		noi di in green""
		}
	qui { // Module #4 - prepare the plink binaries for QC
		noi di in green"#########################################################################"
		noi di in green"# Module #4 - prepare the plink binaries for QC                         #"
		noi di in green"#########################################################################"
		qui { // restrict to chromosomes 1 through 23
			noi di in green"...restrict binaries to chromosomes 1 through 23 and make founders"
			import delim using tempfile-module-2-final.bim, clear 
			count 
			noi di in green"...`r(N)' variants loaded"
			keep if v1 >=1 & v1 < 24
			outsheet v2 using tempfile.extract, non noq replace
			!$plink --bfile tempfile-module-2-final --extract tempfile.extract --make-founders --make-bed --out tempfile-module-4-01
			count 
			noi di in green"...`r(N)' variants remain after limiting to chromosomes 1-23"
			}
		qui { // impute sex from genotypes
			noi di in green"...attempt to impute sex from genotypes"
			sum v1
			if `r(max)' == 23 {
				noi di in green"...great! chromosome 23 is present - imputing sex"
				!$plink --bfile tempfile-module-4-01 --mac 5 --geno 0.99 --mind 0.99 --impute-sex --make-bed --out tempfile-module-4-final
				foreach file in bim bed fam { 
					!del tempfile-module-4-01.`file'
					}
				}
			else if `r(max)' != 23 {
				noi di in green"...sorry! chromosome 23 is not present"
				!$plink --bfile tempfile-module-4-01 --mac 5 --geno 0.99 --mind 0.99  --make-bed --out tempfile-module-4-final
				foreach file in bim bed fam { 
					!del tempfile-module-4-01.`file'
					}
				}
			}	
		qui { // clean files
			!del tempfile-module-4-01* 
			noi di in green"#########################################################################"
			noi di in green""
			}	
		}
	qui { // Module #5a - round #1 of quality control pipeline
		noi di in green"#########################################################################"
		noi di in green"# Module #5a - round #1 of quality control pipeline                     #"
		noi di in green"#########################################################################"
		qui { // calculate pre-qc metrics
			noi di in green"...calculating pre-quality-control metrics"
			global preqc tempfile-module-4-final
			global round0 tempfile-module-5-round0
			bim2ldexclude, bim(${preqc})
			!$plink  --bfile ${preqc} --freq counts    --out ${round0}
			!$plink  --bfile ${preqc} --maf 0.05 --het --out ${round0}
			!$plink  --bfile ${preqc} --hardy          --out ${round0}
			!$plink  --bfile ${preqc} --missing        --out ${round0}
			* i expect this threshold to crash if no individuals meet criteria (e.g. post qc)
			* may need to look at how graphplinkkin0 works with a dummy file
			global makeking "--maf 0.05 --exclude long-range-ld.exclude --make-king-table --king-table-filter ${kin_t}"
			!$plink  --bfile ${preqc} --maf 0.05 --exclude long-range-ld.exclude --make-bed --out tmp_x				
			/*
			the thin-count routine is problematic
			- ld-prune the major dataset
			- define a common set of SNPs (50K)
			- keep these for each iteration
			*/
			!$plink  --bfile tmp_x --indep-pairwise 1000 5 0.2  --out tmp_x
			import delim using tmp_x.prune.in, clear
			gen x = uniform()
			sort x
			drop if _n > 50000
			outsheet v1 using common50k.extract, non noq replace
			!$plink  --bfile tmp_x  --extract common50k.extract --make-bed --out tmp_y	
			!$plink2 --bfile tmp_y ${makeking} --out ${round0}	
			!del tmp_x.* tmp_y.*
			}
		qui { // plot quality-control metrics
			noi di in green"...plotting pre-quality-control metrics"
			graphplinkfrq, frq(${round0}) 
			graphplinkhet, het(${round0}) sd(${hetsd})
			graphplinkhwe, hwe(${round0}) threshold(${hwep}) 			
			graphplinkimiss, imiss(${round0}) mind(${mind})
			graphplinklmiss, lmiss(${round0}) geno(${geno2})			
			graphplinkkin0, kin0(${round0}) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
			}
		qui { // rename plots
			noi di in green"...rename plots"	
			foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
				!copy "tmp`graph'.gph" "${round0}_`graph'.gph"
				!del "tmp`graph'.gph"
				}
			}	
		qui { // apply quality-control to binaries
			noi di in green"...apply quality-control to binaries"	
			!$plink --bfile ${preqc}  --remove tempHET.indlist --set-hh-missing --make-bed --out tempfile-module-5-01
			!$plink --bfile tempfile-module-5-01 --exclude  tempHWE.snplist --make-bed --out tempfile-module-5-02
			foreach file in bim bed fam { 
				!del tempfile-module-5-01.`file'
				}
			!$plink --bfile tempfile-module-5-02 --geno ${geno1} --make-bed --out tempfile-module-5-03
			foreach file in bim bed fam { 
				!del tempfile-module-5-02.`file'
				}
			!$plink --bfile tempfile-module-5-03 --mind ${mind}  --make-bed --out tempfile-module-5-04
			foreach file in bim bed fam { 
				!del tempfile-module-5-03.`file'
				}
			!$plink --bfile tempfile-module-5-04 --geno ${geno2} --make-bed --out tempfile-module-5-05		
			foreach file in bim bed fam { 
				!del tempfile-module-5-04.`file'
				}
			!$plink --bfile tempfile-module-5-05 --mac 5  --make-bed --out tempfile-module-5-06
			foreach file in bim bed fam { 
				!del tempfile-module-5-05.`file'
				}
			}
		qui { // remove excessive cryptic relatedness
			noi di in green"...remove excess cryptic relatedness"
			qui fam2dta, fam(tempfile-module-5-06)
			count
			global sampleSize `r(N)'
			noi di in green"...$sampleSize individuals are retained following preliminary quality-control"
			noi di in green"...creating a $sampleSize x $sampleSize kinship matrix"
			bim2ldexclude, bim(tempfile-module-5-06)
			!$plink  --bfile tempfile-module-5-06 --maf 0.05 --exclude long-range-ld.exclude --make-bed --out tmp_x				
			!$plink  --bfile tmp_x --extract common50k.extract --make-bed --out tmp_y	
			!$plink2 --bfile tmp_y --make-king square --out tempfile-module-5-06	
			!del tmp_x.* tmp_y.*					
			!$tabbed tempfile-module-5-06.king
			import delim using tempfile-module-5-06.king.tabbed, clear case(lower)
			count
			global countX `r(N)'
			keep v1-v$countX
			forvalues i=1/ $countX {
					replace v`i' = . in `i'
					}
			gen obs = _n
			aorder
			save tempfile-module-5-06.dta,replace
			noi di in green"...merge kinship table to identifiers"
			import delim using tempfile-module-5-06.king.id, clear case(lower)
			rename (v1 v2) (fid iid)
			gen obs = _n
			aorder
			merge 1:1 obs using tempfile-module-5-06.dta, update
			drop obs _m
			noi di in green"...calculate by-individual metrics"
			for var v1-v$countX: replace X = 0 if X < 0
			egen rm = rowmean(v1-v$countX)
			egen rx =  rowmax(v1-v$countX)
			keep fid iid rm rx
			noi di in green"...identify individuals with excessive kinship coefficients"
			gen excessCryptic = ""
			sum rm
			gen lb = `r(mean)' - 2.5 *`r(sd)'
			gen ub = `r(mean)' + 2.5 *`r(sd)'
			replace excessCryptic = "1" if rm < (lb)
			replace excessCryptic = "1" if rm > (ub)
			count if ex == "1"
			global excessC `r(N)'
			noi di in green"...${excessC} individuals to be dropeed due to showing excessive kinship coefficients (greater than 2.5x standard-deviation from the mean)"
			outsheet fid iid if excessC == "1" using excessiveCryptic.remove, replace non noq
			!$plink --bfile tempfile-module-5-06 --remove excessiveCryptic.remove   --make-bed --out tempfile-module-5-round1
			foreach file in bim bed fam { 
				!del tempfile-module-5-06.`file'
				}			
			}
		qui { // plot mean kinship vs maximum kinship
			noi di in green"...plot mean kinship vs maximum kinship"
			global format "mlc(black) mlw(vvthin) m(O)"
			tw scatter rx rm if excessCryptic != "1", $format mfc(blue)   ///
			|| scatter rx rm if excessCryptic == "1", $format mfc(red)    ///
				 legend(off) ytitle("maximum kinship") xtitle("average kinship") ///
				 caption("kinship is the estimated kinship coefficient from the SNP data. All kinship < 0 are reported as 0. " ///
								 "If an individual has excessive kinship it may indicate poor genotyping." ///
								 "In this sample of N = $sampleSize, N = $excessC are +/- 2.5 sd from the kinship mean")
				graph export tempfile-module-5-relate.png, as(png) height(1000) width(2000) replace
				window manage close graph
				}
		qui { // clean-up files
			!del tempfile-module-5-0* *.exclude *.remove *.relPairs *.snplist *.indlist
			noi di in green"#########################################################################"
			noi di in green""
			}
		}
	qui { // Module #5b - round #2 to N of quality control pipeline
		noi di in green"#########################################################################"
		noi di in green"# Module #5b - round #2 to #${rounds} of quality control pipeline               #"
		noi di in green"#########################################################################"
		foreach round of num  2 / $rounds {
			noi di in green"...initiating round #`round'"
			clear
			set obs 2
			gen obs = _n
			tostring obs, replace
			gen x = `round'
			replace x = x - 1 in 1
			tostring x, replace
			gen round = "global round" + obs + " round" + x
			outsheet round using tempfile-round.do, non noq replace
			do tempfile-round.do
			erase tempfile-round.do
			qui { // calculate pre-qc metrics
				noi di in green"...calculating quality-control metrics"
				bim2ldexclude, bim(tempfile-module-5-${round1})
				!$plink  --bfile tempfile-module-5-${round1} --maf 0.05 --het --out tempfile-module-5-${round1}
				!$plink  --bfile tempfile-module-5-${round1} --hardy          --out tempfile-module-5-${round1}
				}
			qui { // plot quality-control metrics
				noi di in green"...plotting quality-control metrics"
				graphplinkhet, het(tempfile-module-5-${round1}) sd(${hetsd})
				graphplinkhwe, hwe(tempfile-module-5-${round1}) threshold(${hwep}) 			
				}
			qui { // apply quality-control to binaries
				noi di in green"...apply quality-control to binaries"	
				!$plink --bfile tempfile-module-5-${round1}  --remove tempHET.indlist --set-hh-missing --make-bed --out tempfile-module-5-01
				foreach file in bim bed fam { 
					!del tempfile-module-5-${round1}.`file'
					}
				!$plink --bfile tempfile-module-5-01 --exclude  tempHWE.snplist --make-bed --out tempfile-module-5-02
				foreach file in bim bed fam { 
					!del tempfile-module-5-01.`file'
					}				
				!$plink --bfile tempfile-module-5-02 --mind ${mind}  --make-bed --out tempfile-module-5-03
				foreach file in bim bed fam { 
					!del tempfile-module-5-02.`file'
					}
				!$plink --bfile tempfile-module-5-03 --geno ${geno2} --make-bed --out tempfile-module-5-04		
				foreach file in bim bed fam { 
					!del tempfile-module-5-03.`file'
					}				
				!$plink --bfile tempfile-module-5-04 --mac 5  --make-bed --out tempfile-module-5-${round2}
				foreach file in bim bed fam { 
					!del tempfile-module-5-04.`file'
					}
				}
			}
		qui { // calculate post-qc metrics
			bim2ldexclude, bim(tempfile-module-5-round${rounds})
			!$plink  --bfile tempfile-module-5-round${rounds} --freq counts    --out tempfile-module-5-round${rounds}
			!$plink  --bfile tempfile-module-5-round${rounds} --maf 0.05 --het --out tempfile-module-5-round${rounds}
			!$plink  --bfile tempfile-module-5-round${rounds} --hardy          --out tempfile-module-5-round${rounds}
			!$plink  --bfile tempfile-module-5-round${rounds} --missing        --out tempfile-module-5-round${rounds}
			!$plink  --bfile tempfile-module-5-round${rounds} --maf 0.05 --exclude long-range-ld.exclude --make-bed --out tmp_x				
			!$plink  --bfile tmp_x  --extract common50k.extract --make-bed --out tmp_y	
			!$plink2 --bfile tmp_y ${makeking} --out tempfile-module-5-round${rounds}	
			!del tmp_x.* tmp_y.*
			}
		qui { // plotting post-quality-control metrics"
			noi di in green"...plotting post-quality-control metrics"
			qui { // create blank graphs
				tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))     
				foreach i in tmpFRQ tmpHET tmpHWE tmpIMISS tmpLMISS tmpKIN0_1 tmpKIN0_2 {
					graph save `i', replace
					}
				window manage close graph
				}	
			graphplinkfrq, frq(tempfile-module-5-round${rounds}) 
			graphplinkhet, het(tempfile-module-5-round${rounds}) sd(${hetsd})
			graphplinkhwe, hwe(tempfile-module-5-round${rounds}) threshold(${hwep}) 			
			graphplinkimiss, imiss(tempfile-module-5-round${rounds}) mind(${mind})
			graphplinklmiss, lmiss(tempfile-module-5-round${rounds}) geno(${geno2})			
			graphplinkkin0, kin0(tempfile-module-5-round${rounds}) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
			}
		qui { // rename plots
			noi di in green"...rename plots"	
			foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
				!copy "tmp`graph'.gph" "tempfile-module-5-round${rounds}_`graph'.gph"
				!del "tmp`graph'.gph"
				}
			}	
		qui { // clean-up files
			clear
			set obs $rounds
			gen obs = _n
			drop in $rounds
			drop in 1
			tostring obs,replace
			gen a = "!del tempfile-round" + obs + ".*"
			outsheet a using del.do, non noq replace
			do del.do
			!del tempfile-module-5-0* *.exclude *.remove *.relPairs *.snplist *.indlist del.do
			}
		noi di in green"#########################################################################"
		noi di in green""
		}	
	qui { // Module #6 - remove duplicates; 2nd and 3rd degree relatives 
		noi di in green"#########################################################################"
		noi di in green"# Module #6 - remove duplicates; 2nd and 3rd degree relatives           #"
		noi di in green"#########################################################################"
		qui { // remove-related-samples (duplicated)
			noi di in green"...identifying duplicates"
			noi di in green"...calculating kinship matrix"
			bim2ldexclude, bim(tempfile-module-5-round${rounds})
			!$plink  --bfile tempfile-module-5-round${rounds} --maf 0.05 --exclude long-range-ld.exclude --make-bed --out tmp_x		
			outsheet v1 using common50k.keep, non noq replace
			!$plink  --bfile tmp_x  --extract common50k.extract --make-bed --out tmp_y				
			!$plink2 --bfile tmp_y ${makeking} --out tempfile-module-5-round${rounds}
			!del tmp_x.* tmp_y.*	
			!$tabbed tempfile-module-5-round${rounds}.kin0
			import delim using tempfile-module-5-round${rounds}.kin0.tabbed, clear case(lower)
			erase tempfile-module-5-round${rounds}.kin0.tabbed
			for var fid1-id2      : tostring X, replace 
			for var hethet-kinship: destring X, replace force
			gen rel = ""
			replace rel = "3rd" if kinship > ${kin_t}
			replace rel = "2nd" if kinship > ${kin_s}
			replace rel = "1st" if kinship > ${kin_f}
			replace rel = "dup" if kinship > ${kin_d}
			replace rel = ""    if kinship == .
			noi di in green"...tabulate relatedness prior to removal of duplicates"
			noi ta rel
			keep if rel == "dup"
			keep fid1-id2
			gen obs = _n
			reshape long fid id , i(obs) j(x)
			gen random = uniform()
			sort  obs random
			egen keep = seq(),by(obs)
			keep if keep == 1
			count
			noi di in green"...`r(N)' genetic duplicates observed"
			outsheet fid id using duplicates.remove, non noq replace
			!$plink --bfile tempfile-module-5-round${rounds} --remove duplicates.remove --make-bed --out tempfile-module-6-01
			foreach file in bim bed fam { 
				!del tempfile-module-5-${rounds}.`file'
				}
			}
		qui { // remove-related-samples (2nd-degree)
			noi di in green"...identifying 2nd-degree relatives"
			noi di in green"...calculating kinship matrix"
			bim2ldexclude, bim(tempfile-module-6-01)	
			!$plink  --bfile tempfile-module-6-01 --maf 0.05 --exclude long-range-ld.exclude --make-bed --out tmp_x			
			!$plink  --bfile tmp_x  --extract common50k.extract --make-bed --out tmp_y				
			!$plink2 --bfile tmp_y ${makeking} --out tempfile-module-6-01
			!del tmp_x.* tmp_y.*			
			!$tabbed tempfile-module-6-01.kin0
			import delim using tempfile-module-6-01.kin0.tabbed, clear case(lower)
			erase tempfile-module-6-01.kin0.tabbed
			for var fid1-id2      : tostring X, replace 
			for var hethet-kinship: destring X, replace force
			gen rel = ""
			replace rel = "3rd" if kinship > ${kin_t}
			replace rel = "2nd" if kinship > ${kin_s}
			replace rel = "1st" if kinship > ${kin_f}
			replace rel = "dup" if kinship > ${kin_d}
			replace rel = ""    if kinship == .
			noi di in green"...tabulate relatedness prior to removal of 2nd-degree relatives"
			noi ta rel
			keep if rel == "2nd"
			!type > 2nd-degree.remove
			count
			if `r(N)' != 0 { 
				noi di in green"...`r(N)' genetic 2nd-degree relatives observed"
				keep fid1-id2
				gen obs = _n
				reshape long fid id , i(obs) j(x)
				noi di in green"...removing most-related"
				egen y = seq(),by(fid id)
				sum y
				foreach num of num 1/1000 { 
					if `r(N)' ! = 0 {
						if `r(max)' > 0 {
							keep if y == `r(max)'
							gen random = uniform()
							sort  obs random
							egen keep = seq(),by(obs)
							keep if keep == 1
							outsheet fid id using tempfile-module-6-01.remove, non noq replace
							!type tempfile-module-6-01.remove >> 2nd-degree.remove
							noi di in green"...re-calculate kinship matrix"		
							!$plink  --bfile tempfile-module-6-01 --maf 0.05 --exclude long-range-ld.exclude --make-bed --out tmp_x				
							!$plink  --bfile tmp_x  --extract common50k.extract --make-bed --out tmp_y				
							!$plink2 --bfile tmp_y --remove 2nd-degree.remove ${makeking} --out tempfile-module-6-0x
							!del tmp_x.* tmp_y.*	
							!$tabbed tempfile-module-6-0x.kin0
							import delim using tempfile-module-6-0x.kin0.tabbed, clear case(lower)
							erase tempfile-module-6-0x.kin0.tabbed
							for var fid1-id2      : tostring X, replace 
							for var hethet-kinship: destring X, replace force
							gen rel = ""
							replace rel = "3rd" if kinship > ${kin_t}
							replace rel = "2nd" if kinship > ${kin_s}
							replace rel = "1st" if kinship > ${kin_f}
							replace rel = "dup" if kinship > ${kin_d}
							replace rel = ""    if kinship == .
							noi di in green"...tabulate relatedness post removal of 2nd-degree relatives"
							noi ta rel
							keep if rel == "2nd"
							count
							if `r(N)' != 0 { 
								noi di in green"...2nd-degree relatives still exist - continue routine"
								keep fid1-id2
								gen obs = _n
								reshape long fid id , i(obs) j(x)
								noi di in green"...removing most-related"
								egen y = seq(),by(fid id)
								sum y
								}
							}
						}
					}
				}
			count
			if `r(N)' != 0 { 
				noi di in green"...all remaining 2nd degree relatives are unique pairs"
				gen random = uniform()
				sort  obs random
				egen keep = seq(),by(obs)
				keep if keep == 1
				outsheet fid id using tmp.remove, non noq replace
				!type tmp.remove >> 2nd-degree.remove
				}
			!$plink --bfile tempfile-module-6-01 --remove 2nd-degree.remove --make-bed --out tempfile-module-6-02
			foreach file in bim bed fam { 
				!del tempfile-module-6-01.`file'
				}
			}
		qui { // remove-related-samples (3rd-degree)
			noi di in green"...identifying 3rd-degree relatives"
			noi di in green"...calculating kinship matrix"
			bim2ldexclude, bim(tempfile-module-6-02)
			!$plink  --bfile tempfile-module-6-02 --maf 0.05 --exclude long-range-ld.exclude --make-bed --out tmp_x				
			!$plink  --bfile tmp_x  --extract common50k.extract --make-bed --out tmp_y				
			!$plink2 --bfile tmp_y ${makeking} --out tempfile-module-6-02
			!del tmp_x.* tmp_y.*								
			!$tabbed tempfile-module-6-02.kin0
			import delim using tempfile-module-6-02.kin0.tabbed, clear case(lower)
			erase tempfile-module-6-02.kin0.tabbed
			for var fid1-id2      : tostring X, replace 
			for var hethet-kinship: destring X, replace force
			gen rel = ""
			replace rel = "3rd" if kinship > ${kin_t}
			replace rel = "2nd" if kinship > ${kin_s}
			replace rel = "1st" if kinship > ${kin_f}
			replace rel = "dup" if kinship > ${kin_d}
			replace rel = ""    if kinship == .
			noi di in green"...tabulate relatedness prior to removal of 3rd-degree relatives"
			noi ta rel
			keep if rel == "3rd"
			!type > 3rd-degree.remove
			count
			if `r(N)' != 0 { 
				noi di in green"...`r(N)' genetic 3rd-degree relatives observed"
				keep fid1-id2
				gen obs = _n
				reshape long fid id , i(obs) j(x)
				noi di in green"...removing most-related"
				egen y = seq(),by(fid id)
				sum y
				foreach num of num 1/1000 { 
					if `r(N)' ! = 0 {
						if `r(max)' > 0 {
							keep if y == `r(max)'
							gen random = uniform()
							sort  obs random
							egen keep = seq(),by(obs)
							keep if keep == 1
							outsheet fid id using tempfile-module-6-02.remove, non noq replace
							!type tempfile-module-6-02.remove >> 3rd-degree.remove
							noi di in green"...re-calculate kinship matrix"						
							!$plink  --bfile tempfile-module-6-02 --maf 0.05 --exclude long-range-ld.exclude --make-bed --out tmp_x				
							!$plink  --bfile tmp_x  --extract common50k.extract --make-bed --out tmp_y				
							!$plink2 --bfile tmp_y --remove 3rd-degree.remove ${makeking} --out tempfile-module-6-0x
							!del tmp_x.* tmp_y.*								
							!$tabbed tempfile-module-6-0x.kin0
							import delim using tempfile-module-6-0x.kin0.tabbed, clear case(lower)
							erase tempfile-module-6-0x.kin0.tabbed
							for var fid1-id2      : tostring X, replace 
							for var hethet-kinship: destring X, replace force
							gen rel = ""
							replace rel = "3rd" if kinship > ${kin_t}
							replace rel = "2nd" if kinship > ${kin_s}
							replace rel = "1st" if kinship > ${kin_f}
							replace rel = "dup" if kinship > ${kin_d}
							replace rel = ""    if kinship == .
							noi di in green"...tabulate relatedness post removal of 3rd-degree relatives"
							noi ta rel
							keep if rel == "3rd"
							count
							if `r(N)' != 0 { 
								noi di in green"...3rd-degree relatives still exist - continue routine"
								keep fid1-id2
								gen obs = _n
								reshape long fid id , i(obs) j(x)
								noi di in green"...removing most-related"
								egen y = seq(),by(fid id)
								sum y
								}
							}
						}
					}
				}
			count
			if `r(N)' != 0 { 
				noi di in green"...all remaining 3rd degree relatives are unique pairs"
				gen random = uniform()
				sort  obs random
				egen keep = seq(),by(obs)
				keep if keep == 1
				outsheet fid id using tmp.remove, non noq replace
				!type tmp.remove >> 3rd-degree.remove
				}
			!$plink --bfile tempfile-module-6-02 --remove 3rd-degree.remove --make-bed --out tempfile-module-6-final
			foreach file in bim bed fam { 
				!del tempfile-module-6-02.`file'
				}
			}
		qui { // plot post remove
			noi di in green"...plot post-removal relatedness"
			!$plink  --bfile tempfile-module-6-final --maf 0.05 --exclude long-range-ld.exclude --make-bed --out tmp_x				
			!$plink  --bfile tmp_x  --extract common50k.extract --make-bed --out tmp_y				
			!$plink2 --bfile tmp_y  ${makeking} --out tempfile-module-6-final
			!del tmp_x.* tmp_y.*								
			graphplinkkin0, kin0(tempfile-module-6-final)	
			!copy tmpKIN0_2.gph tempfile-module-6-final_KIN0_2_noRel.gph
			}
		qui { // clean up files
			!del tempfile-module-6-0x* tempfile-module-6-0* *.remove *.exclude tmpK* *.kin0
			noi di in green"#########################################################################"
			noi di in green""
			}
		}
	qui { // Module #7 - define european (ceu-tsi-like) subset 
		noi di in green"#########################################################################"
		noi di in green"# Module #7 - define european (ceu-tsi-like) subset                     #"
		noi di in green"#########################################################################"
		qui { // extract ancestry-informative-markers from test and reference set
			noi di in green"...extract ancestry-informative-markers from test and reference set"
			global extractaims --extract ${aims} --make-founders --make-bed --out
			!$plink --bfile tempfile-module-6-final ${extractaims} tempfile-module-7-test-01
			!$plink --bfile ${hapmap_data}          ${extractaims} tempfile-module-7-hapmap-01
			}
		qui { // merge hapmap-ref
			foreach i in test hapmap { 
				qui bim2dta, bim(tempfile-module-7-`i'-01)
				keep snp a1 a2
				rename (a1 a2) (`i'_a1 `i'_a2)
				save tempfile-module-7-`i'.dta,replace
				}
			use tempfile-module-7-hapmap.dta, clear
			merge 1:1 snp using tempfile-module-7-test.dta
			keep if _m == 3
			drop _m
			recodegenotype, a1(hapmap_a1) a2(hapmap_a2)
			rename _gt hapmap_gt
			recodegenotype, a1(test_a1) a2(test_a2)
			rename _gt test_gt
			gen drop = .
			replace drop = 1 if hapmap_gt == "S"
			replace drop = 1 if hapmap_gt == "W"
			replace drop = 1 if test_gt == "S"
			replace drop = 1 if test_gt == "W"
			replace drop = 1 if hapmap_gt == "K" & test_gt =="R"
			replace drop = 1 if hapmap_gt == "K" & test_gt =="Y"
			replace drop = 1 if hapmap_gt == "M" & test_gt =="R"
			replace drop = 1 if hapmap_gt == "M" & test_gt =="Y"
			replace drop = 1 if hapmap_gt == "R" & test_gt =="K"
			replace drop = 1 if hapmap_gt == "R" & test_gt =="M"
			replace drop = 1 if hapmap_gt == "Y" & test_gt =="K"
			replace drop = 1 if hapmap_gt == "Y" & test_gt =="M"	
			drop if drop == 1
			outsheet snp using overlap.extract, non noq replace
			recodestrand, ref_a1(hapmap_a1) ref_a2(hapmap_a2) alt_a1(test_a1) alt_a2(test_a2) 
			outsheet snp if _tmpflip == 1 using overlap.flip, non noq replace
			global extractoverlap --make-founders --extract overlap.extract --make-bed --out 
			!$plink --bfile tempfile-module-6-final --flip overlap.flip ${extractoverlap} tempfile-module-7-test-02
			!$plink --bfile ${hapmap_data}                              ${extractoverlap} tempfile-module-7-hapmap-02
			noi di in green"...merge hapmap and final genotype"
			!$plink --bfile tempfile-module-7-hapmap-02 --bmerge tempfile-module-7-test-02.bed tempfile-module-7-test-02.bim tempfile-module-7-test-02.fam --allow-no-sex --make-bed --out tempfile-module-7-01
			noi di in green"...ld-prune overlap "
			bim2eigenvec, bim(tempfile-module-7-01)
			noi di in green"...plot scree of eigenvalues"
			use tempfile-module-7-01_eigenval.dta,clear
			twoway scatter eigenval pc, xtitle("Principle Components") connect(l) xlabel(1(1)10) mfc(red) mlc(black) mlw(vthin) ms(O) saving(tempfile-module-7-scree.gph, replace) nodraw
			}
		qui { // define and plot PC legend
			noi di in green"...define and plot legend for pca"
			qui { // define plot location
				clear
				set obs 25
				egen x = seq(),block(5)	
				egen y = seq(),by(x)
				gen POPULATION = ""
				replace POPULATION = "Test (European)"     if x == 1 & y == 5
				replace POPULATION = "Test (non-European)" if x == 3 & y == 5
				replace POPULATION = "ASW"                 if x == 1 & y == 4
				replace POPULATION = "LWK"                 if x == 2 & y == 4
				replace POPULATION = "MKK"                 if x == 3 & y == 4
				replace POPULATION = "YRI"                 if x == 4 & y == 4
				replace POPULATION = "CEU"                 if x == 1 & y == 3
				replace POPULATION = "TSI"                 if x == 2 & y == 3
				replace POPULATION = "MEX"                 if x == 1 & y == 2
				replace POPULATION = "GIH"                 if x == 2 & y == 2
				replace POPULATION = "CHB"                 if x == 1 & y == 1
				replace POPULATION = "CHD"                 if x == 2 & y == 1
				replace POPULATION = "JPT"                 if x == 3 & y == 1
				replace POPULATION = " "                   if x == 5 & y == 5
				}
			qui { // define plot colors
				global format msiz(medlarge) msymbol(S) mlc(black) mlabel(POP) mlabposition(3) mlabsize(medium) mlw(vvthin)
				colorscheme 8, palette(Blues) 
				global ceu mfcolor("`=r(color8)'")
				global tsi mfcolor("`=r(color4)'")
				colorscheme 8, palette(Oranges) 
				global chb mfcolor("`=r(color8)'")
				global chd mfcolor("`=r(color6)'")
				global jpt mfcolor("`=r(color4)'")
				colorscheme 8, palette(Purples) 
				global mex mfcolor("`=r(color8)'")
				global gih mfcolor("`=r(color6)'")			
				colorscheme 8, palette(Greens) 
				global yri mfcolor("`=r(color8)'")
				global lwk mfcolor("`=r(color7)'")
				global mkk mfcolor("`=r(color6)'")			
				global asw mfcolor("`=r(color5)'")
				global test1 mfcolor(red)
				global test2 mfcolor(gs8)	
				}
			qui { // plot legend
				tw scatter y x if POP == "Test (European)" ,     $format $test1  ///
				|| scatter y x if POP == "Test (non-European)" , $format $test2  ///  
				|| scatter y x if POP == "ASW"                 , $format $asw  ///
				|| scatter y x if POP == "LWK"                 , $format $lwk  ///
				|| scatter y x if POP == "MKK"                 , $format $mkk  ///
				|| scatter y x if POP == "YRI"                 , $format $yri  ///
				|| scatter y x if POP == "CEU"                 , $format $ceu  ///
				|| scatter y x if POP == "TSI"                 , $format $tsi  ///
				|| scatter y x if POP == "MEX"                 , $format $mex  ///	
				|| scatter y x if POP == "GIH"                 , $format $gih  ///
				|| scatter y x if POP == "CHB"                 , $format $chb  ///
				|| scatter y x if POP == "CHD"                 , $format $chd  ///
				|| scatter y x if POP == "JPT"                 , $format $jpt  ///
				|| scatter y x if POP == " "                   , msymbol(none)                   ///
					 legend(off) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank)) 
					 graph save legend.gph, replace
				window manage close graph
				}	
			}
		qui { // import eigenvecs and define european (ceu-tsi-like) subset
			noi di in green"...import eigenvecs and define a subset of european (ceu-tsi-like) individuals "
			use tempfile-module-7-01_eigenvec.dta,clear
			renvars, upper
			save tempfile-module-7-02.dta, replace
			import delim using ${hapmap_data}.population, clear
			renvars, upper
			merge 1:1 FID IID using tempfile-module-7-02.dta
			replace POP = "TEST" if POP == ""
			foreach i of num 1/3{
				gen nr`i' = .
				sum PC`i' if (POP == "CEU" | POP == "TSI")
				gen min = r(mean) - 2*r(sd)
				gen max = r(mean) + 2*r(sd)
				foreach j in min max {
					sum `j'
					global PC`i'`j' `r(mean)'
					di" `j' bounds of PC`i' == ${PC`i'`j'}"
					drop `j'
					}
				replace nr`i' = 1 if  PC`i' < ${PC`i'max} & PC`i' > ${PC`i'min}
				}
			replace POP = "nrCEU" if POP == "TEST" & nr1 == 1 & nr2 == 1 & nr3 == 1
			noi di in green`"...individuals described as being similar to "european" (+/- 2*sd from ceu-tis on top-3 pca) exported to;"'
			noi di in green`"...${output}.keep-ceuLike"'
			outsheet FID IID if POP == "nrCEU" using ${output}.keep-ceuLike, non noq replace
			}
		qui { // plot eigenvecs against all reference ancestries
			noi di in green"...plot pca against all ancestries"
			global format "msiz(large) msymbol(o) mlc(black) mlw(vvthin)"
			foreach i of num 1/3 { 
				foreach j of num 1/3 { 
					tw scatter PC`j' PC`i' if POP == "ASW" ,  $format $asw ///
					|| scatter PC`j' PC`i' if POP == "LWK" ,  $format $lwk ///
					|| scatter PC`j' PC`i' if POP == "MKK" ,  $format $mkk ///
					|| scatter PC`j' PC`i' if POP == "YRI" ,  $format $yri ///
					|| scatter PC`j' PC`i' if POP == "CEU" ,  $format $ceu ///
					|| scatter PC`j' PC`i' if POP == "TSI" ,  $format $tsi ///
					|| scatter PC`j' PC`i' if POP == "MEX" ,  $format $mex ///	
					|| scatter PC`j' PC`i' if POP == "GIH" ,  $format $gih ///
					|| scatter PC`j' PC`i' if POP == "CHB" ,  $format $chb ///
					|| scatter PC`j' PC`i' if POP == "CHD" ,  $format $chd ///
					|| scatter PC`j' PC`i' if POP == "JPT" ,  $format $jpt ///
					|| scatter PC`j' PC`i' if POP == "TEST",  $format $test2 ///
					|| scatter PC`j' PC`i' if POP == "nrCEU", $format $test1 ///
						 legend(off) saving(_cPC`j'PC`i'.gph, replace) ///
						 yline(${PC`j'max}, lw(.1) lc(black) lp(solid)) ///
						 yline(${PC`j'min}, lw(.1) lc(black) lp(solid)) ///
						 xline(${PC`i'max}, lw(.1) lc(black) lp(solid)) ///
						 xline(${PC`i'min}, lw(.1) lc(black) lp(solid)) nodraw
						}
					}
			graph combine tempfile-module-7-scree.gph  _cPC1PC2.gph _cPC1PC3.gph _cPC2PC3.gph legend.gph , col(5) title("All HapMap Ancestries Plotted")
			graph export  tempfile-module-7-pca.png, height(2500) width(8000) replace
			window manage close graph
			}
		qui { // plot eigenvecs against all reference ancestries (european focus)
			noi di in green"...plot pca against all ancestries (european focus)"
			foreach i of num 1/3{
				sum PC`i' if POP == "CEU" 
				drop if PC`i' > (r(mean) + 6*r(sd)) 
				drop if PC`i' < (r(mean) - 6*r(sd))
				}
			foreach i of num 1/3 { 
				foreach j of num 1/3 { 
					tw scatter PC`j' PC`i' if POP == "ASW" ,  $format $asw ///
					|| scatter PC`j' PC`i' if POP == "LWK" ,  $format $lwk ///
					|| scatter PC`j' PC`i' if POP == "MKK" ,  $format $mkk ///
					|| scatter PC`j' PC`i' if POP == "YRI" ,  $format $yri ///
					|| scatter PC`j' PC`i' if POP == "CEU" ,  $format $ceu ///
					|| scatter PC`j' PC`i' if POP == "TSI" ,  $format $tsi ///
					|| scatter PC`j' PC`i' if POP == "MEX" ,  $format $mex ///	
					|| scatter PC`j' PC`i' if POP == "GIH" ,  $format $gih ///
					|| scatter PC`j' PC`i' if POP == "CHB" ,  $format $chb ///
					|| scatter PC`j' PC`i' if POP == "CHD" ,  $format $chd ///
					|| scatter PC`j' PC`i' if POP == "JPT" ,  $format $jpt ///
					|| scatter PC`j' PC`i' if POP == "TEST",  $format $test2 ///
					|| scatter PC`j' PC`i' if POP == "nrCEU", $format $test1 ///
						 legend(off) saving(_cPC`j'PC`i'.gph, replace) ///
						 yline(${PC`j'max}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
						 yline(${PC`j'min}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
						 xline(${PC`i'max}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
						 xline(${PC`i'min}, lsty(refline) lw(.1) lc(black) lp(solid)) nodraw
						}
					}
			graph combine tempfile-module-7-scree.gph  _cPC1PC2.gph _cPC1PC3.gph _cPC2PC3.gph legend.gph , col(5) title("All HapMap Ancestries Plotted")
			graph export  tempfile-module-7-pca-eur.png, height(2500) width(8000) replace
			window manage close graph
			}
		qui { // clean up files
			noi di in green"...cleaning up files"
			!del _c*  tempfile-module-7-hapmap* tempfile-module-7-test* tempfile-module-7-0* *.extract *.exclude *.sexcheck *.in *.remove legend* *.flip *scree.gph
			noi di in green"#########################################################################"
			noi di in green""
			}
		}
	qui { // Module #8 - create quality-control mini-log and docx-report
		noi di in green"#########################################################################"
		noi di in green"# Module #8 - create quality-control mini-log and docx-report           #"
		noi di in green"#########################################################################"
		qui { // create final plots as(png)
			noi di in green"...create final plots as(png) for reports"
			qui { // plot marker by chromosome	
				noi di in green"...plotting markers by chromosome by input / output"
				qui bim2dta,bim(${input})
				hist chr,  xlabel(1(1)25) xtitle("Chromosome") discrete freq ylabel(#4,format(%9.0g))
				graph save input_chrHist.gph, replace
				qui bim2dta,bim(tempfile-module-6-final)
				hist chr,  xlabel(1(1)25) xtitle("Chromosome") discrete freq ylabel(#4,format(%9.0g))
				graph save tempfile-final_chrHist.gph, replace
				graph combine input_chrHist.gph  tempfile-final_chrHist.gph, caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}",	size(tiny)) col(1) ycommon
				graph export  tempfile-module-8-final-chromosomes.png, as(png) replace width(4000) height(2000)
				window manage close graph
				}	
			qui { // combine pre- and post-quality-control graphs for report
				noi di in green"...combine pre- and post-quality-control graphs for report"
				foreach i in FRQ HET HWE IMISS LMISS KIN0_1 {
					graph combine tempfile-module-5-round0_`i'.gph,       title("pre-quality-control")  nodraw saving(x_`i'.gph, replace) 
					graph combine tempfile-module-5-round${rounds}_`i'.gph, title("post-quality-control") nodraw saving(y_`i'.gph, replace)
					graph combine x_`i'.gph y_`i'.gph, xcommon caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}", size(tiny)) col(1) 
					graph export tempfile-module-8-`i'.png, as(png) replace width(4000) height(2000)
					!del x_`i'* y_`i'*
					}
				foreach i in  KIN0_2 {
					graph combine tempfile-module-5-round0_`i'.gph,         title("pre-quality-control")  nodraw saving(x_`i'.gph, replace) 
					graph combine tempfile-module-5-round${rounds}_`i'.gph, title("post-quality-control") nodraw saving(y_`i'.gph, replace) 
					graph combine tempfile-module-6-final_`i'_noRel.gph,    title("post-quality-control (no-relatives)") nodraw saving(z_`i'.gph, replace) 
					graph combine x_`i'.gph y_`i'.gph z_`i'.gph, col(3) caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}", size(tiny))
					graph export tempfile-module-8-`i'.png, as(png) replace width(4000) height(2000)
					!del x_`i'* y_`i'* z_`i'*
					window manage close graph
					}
				}	
			}
		qui { // count metrics 
			noi di in green"...counting metrics and storing in memory"
			noi di in green"...counting numbers of markers in input / output"
			!$wc -l "${input}.bim"                   > "tempfile-module-8-final.counts"
			!$wc -l "tempfile-module-6-final.bim"   >> "tempfile-module-8-final.counts"
			noi di in green"...counting individuals in input / output"
			!$wc -l "${input}.fam"                  >> "tempfile-module-8-final.counts"
			!$wc -l "tempfile-module-6-final.fam"   >> "tempfile-module-8-final.counts"
			!$wc -l "${output}.keep-ceuLike"        >> "tempfile-module-8-final.counts"
			import delim using tempfile-module-8-final.counts, clear varnames(nonames)
			erase tempfile-module-8-final.counts
			split v1,p(" ")
			replace v1 = "global count_markers_1" in 1 
			replace v1 = "global count_markers_3" in 2
			replace v1 = "global count_individ_1" in 3 
			replace v1 = "global count_individ_3" in 4
			replace v1 = "global count_European " in 5
			outsheet v1 v11 using tempfile.do, non noq replace
			do tempfile.do
			erase tempfile.do
			}	
		qui { // create *.docx report and meta-log		
			_sub_genotypeqc_report
			_sub_genotypeqc_meta
			}		
		qui { // move files
			noi di in green"...copying datasets to $data_folder"
			!copy "tempfile-module-8-quality-control-report.docx"   "${output}.quality-control-report.docx"
			!copy "tempfile-module-8.meta-log"                      "${output}.meta-log"
			foreach file in bed bim fam {
				!copy "tempfile-module-6-final.`file'"                "${output}.`file'"
				}
			noi di in green"#########################################################################"
			noi di in green""
			}
		}				
	qui { // Module #9 - clean-up temp files
		noi di in green"#########################################################################"
		noi di in green"# Module #9 - remove temporary files and folder                         #"
		noi di in green"#########################################################################"
		cd ${cd}
		!rmdir  $wd /S /Q
		cd ..
		!del ${output}.hg-buildmatc* ${output}.arraymatc*
		!mkdir "${output_2}"
		cd "${output_2}"
		!copy "${output}.bed"                           "${output_2}.bed"
		!copy "${output}.bim"                           "${output_2}.bim"
		!copy "${output}_bim.dta"                       "${output_2}_bim.dta"
		!copy "${output}.fam"                           "${output_2}.fam"
		!copy "${output}.keep-ceuLike"                  "${output_2}.keep-ceuLike"
		!copy "${output}.meta-log"                      "${output_2}.meta-log"
		!copy "${output}.quality-control-report.docx"   "${output_2}.quality-control-report.docx"
		!del  ${output}*
		}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;
