/*
#########################################################################
# genotypeqc
# a command to perform a full quality-control pipeline in plink binaries
#
# command: genotypeqc, bin(plink-binaries) param(parameter-file) depend(dependency-file)
# options: see parameter file
#########################################################################
#########################################################################
# parameter file
#
# we recommend this as a flat text file called <study-id>.parameters
#
# there are numerous parameters that can be defined for genotyping-array 
# quality control. these will be recorded in the final *.meta-log and 
# *-report.docx. default parameters are included in the 
# template.parameters file. these are based on our needs and may not 
# reflect your needs. please review the parameters to establish whether 
# these are appropriate.
# =======================================================================
#
#
#
#
#
#########################################################################
#########################################################################
# dependencies: 
# there are numerous dependencies that need to be specified in the 
# dependencies file. 
#
# we recommend this as a flat text file called <study-id>.dependencies
# =======================================================================
#
#
#
#
#
#########################################################################
######################################################################### 
# other stata commands
# prior to implementation, run the install-all.do file 
# downloaded from https://github.com/ricanney/stata-genomics-ado
# 
# other non-stata scripts
# tabbed.pl must be set to be called via ${tabbed}
#
# other software
# plink1.9+ from https://www.cog-genomics.org/plink2
# plink2.+  from https://www.cog-genomics.org/plink/2.0/
#
# other associated data
# reference genotypes
#
#########################################################################
# =======================================================================
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 12th July 2017
# =======================================================================
# Copyright 2017 Richard Anney
# Permission is hereby granted, free of charge, to any person obtaining a 
# copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including  
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to  
# permit persons towhom the Software is furnished to do so, subject to 
# the following conditions:
#
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#########################################################################
*/

program genotypeqc
syntax , param(string asis) 

	qui { // introduce program
		noi di"#########################################################################"
		noi di"# genotypeqc                                                             "
		noi di"# version:       1.0                                                     "
		noi di"# Creation Date: 12July2017                                              "
		noi di"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
		noi di"#########################################################################"
		noi di""
		}
	qui { // define sandbox working directory (using ralpha)
		!cd > _000x.tsv
		import delim using _000x.tsv, varname(nonames) clear
		!del _000x.tsv
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
		noi di"#########################################################################"
		noi di "# the current directory is ............. $cd"
		noi di "# the temporary working directory is ... $wd"
		noi di"#########################################################################"
		noi di""
		!mkdir $wd
		cd $wd
		}
	qui { // import parameters
		import delim using ${cd}/template.parameters, stringcols(_all) rowr(21) varname(21) clear
		gen global = "global " + parameter + `" ""' + definition + `"""' 
		outsheet global using _000x.do, non noq replace
		do _000x.do
		erase _000x.do
		global input "${data_folder}\\${data_input}"
		global output "${data_folder}\\${data_input}-qc-v4"
		}
	qui { // report parameters to screen
		noi di"#########################################################################"
		noi di"|- The following dataset will be passed through the quality control pipeline;"
		noi di"| ................................................................ ${input}"
		noi di"|- The dataset will be processed and deposited as; "
		noi di"| ................................................................ ${output}"
		noi di"#########################################################################"
		noi di""
		noi di"#########################################################################"
		noi di"|- The following parameters will be applied"
		noi di"#########################################################################"
		noi di"|-minimum minor-allele-frequency retained ........................ ${maf}"
		noi di"|-maximum genotype-missingness ................................... ${geno2} (preQC = ${geno1})"
		noi di"|-maximum individual-missingness ................................. ${mind}"
		noi di"|-maximum tolerated heterozygosity outliers (by-sd) .............. ${hetsd}"
		noi di"|-maximum tolerated hardy-weinberg deviation ..................... p < 1E-${hwep}"
		noi di"#########################################################################"
		noi di"|-the minimum kinship score for duplicates is set at ............. ${kin_d}"  
		noi di"|-the minimum kinship score for 1st degree relatives is set at ... ${kin_f}"  
		noi di"|-the minimum kinship score for 2nd degree relatives is set at ... ${kin_s}"  
		noi di"|-the minimum kinship score for 3rd degree relatives is set at ... ${kin_t}"  
		noi di"#########################################################################"
		noi di""
		}
	qui { // define-arrays
		qui { // notes
			/*
			#########################################################################
			# this code compares rsid from the test array against a panel of 
			# reference arrays. the input files are plink binaries (specifically the 
			# *.bim) file.
			# 
			# version history
			# =======================================================================
			# - possibly update strand to (+) using the wrayner data (this may limit 
			#   downstream merge issues)?
			# - update tempfile-0* to tempfile-2*
			# - define output of script as tempfile-2
			#########################################################################
			*/
			}
		qui { // import bim file
			noi di"-import bim file"
			bim2dta,bim(${input})
			rename snp rsid
			keep rsid
			sort rsid
			save tempfile-2001.dta, replace
			}
		qui { // check the overlap with references
			noi di"-checking overlap with reference lists and calculating overlaps (this bit can take some time)"
			file open myfile using ${output}.ArrayMatch, write replace
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
			replace a = `"filei + ""' + folder + `":\${ab}:\${all}:\${ji}" \${output}.ArrayMatch"' if obs == 13 
			outsheet a using tempfile-2001.do, non noq replace
			do tempfile-2001.do
			erase tempfile-2001.do
			erase tempfile-2001.dta
			noi di"-finished checking reference lists"
			}
		qui { // create mini-report build
			noi di`"-creating a mini-report: using ${output}.ArrayMatch"'
			import delim using ${output}.ArrayMatch, clear delim(":") varnames(1) case(preserve)
			gsort -J
			gen MostLikely = "+++" in 1
			replace MostLikely = "++" if J > 0.9 & MostLikely == ""
			replace MostLikely = "+" if J > 0.8 & MostLikely == ""
			outsheet using ${input}.ArrayMatch, replace noq
			outsheet using ${output}.ArrayMatch, replace noq
			}		
		qui { // give a brief output to screen
			keep in 1
			gen a = ""
			replace a = "global arrayType "
			outsheet a Array using tempfile-2001.do, non noq replace
			replace a = "global Jaccard "
			outsheet a J using tempfile-2002.do, non noq replace
			do tempfile-2001.do
			do tempfile-2002.do
			noi di"-based on our current estimates the data best matched array:                ${arrayType}"
			noi di"-                                             matched at a Jaccard Index of ${Jaccard}"
			}
		qui { // plot Jaccard Index by Array
			noi di`"-plotting ${output}.ArrayMatch for the output report"'
			import delim using ${output}.ArrayMatch, clear case(preserve)
			keep if _n <10
			graph hbar Jaccard , over(Array,sort(Jaccard) lab(labs(large))) title("Jaccard Index") yline(.9, lcol(red)) fxsize(200) fysize(100) ///
				caption("Based on overlap with our reference data (derived from http://www.well.ox.ac.uk/~wrayner/strand/) the best matched ARRAY is ${arrayType}" ///
								"Jaccard Index of  ${arrayType} = ${Jaccard}")
				graph export ${output}.ArrayMatch.png, height(1000) width(4000) as(png) replace 
				graph export  ${input}.ArrayMatch.png, height(1000) width(4000) as(png) replace 
			window manage close graph
			}
		}
	qui { // update strand information 
		qui { // notes
			/*
			#########################################################################
			# this code performs a simple flip of alleles in strand 
			# i am not convinced that this approach will solve the allele-frequency 
			# issues, but it will not harm the process"
			#########################################################################
			*/
			}
		qui { // prepare genotype file
			noi di"|-prepare genotype file (minor-allele-count = 5)"
			!$plink --bfile ${input} --mac 5 --make-bed --out tempfile-2001
			}
		qui { // update build to hg19+1 using ${array_ref}\\${arrayType}\\${arrayType}.dta
			noi di"|-update build to hg19+1 using ${array_ref}\\${arrayType}\\${arrayType}.dta"
			use ${array_ref}\\${arrayType}\\${arrayType}.dta, clear
			replace chr = "23" if chr == "X"
			replace chr = "24" if chr == "Y"
			replace chr = "26" if chr == "MT"
			outsheet rsid                   using tempfile.extract, non noq replace
			outsheet rsid chr               using tempfile.update-chr, non noq replace
			outsheet rsid bp                using tempfile.update-map, non noq replace
			outsheet rsid if strand == "-"  using tempfile.flip, non noq replace
			!$plink --bfile tempfile-2001 --extract    tempfile.extract    --make-bed --out tempfile-2002
			!$plink --bfile tempfile-2002 --update-chr tempfile.update-chr --make-bed --out tempfile-2003
			!$plink --bfile tempfile-2003 --update-map tempfile.update-map --make-bed --out tempfile-2004 
			!$plink --bfile tempfile-2004 --flip tempfile.flip             --make-bed --out tempfile-2
			}
		qui { // clean-up
			!del tempfile-2001* tempfile-2002* tempfile-2003* tempfile-2004* *.extract *.update-chr *.update-map *.flip
			}
		}
	qui { // convert to rsid
		qui { // notes
			/*
				#########################################################################
				# this code converts the array marker nomenclature to rs# using the 1000-
				# genomes project reference haplotype reference consortium data.
				# - there are a few caveats to using this script
				# 1. we are assuming the hg37 data is a "gold-standard"
				# 2. we are dropping allele mismatches (including indels)
				# 3. we are dropping in allele-freq differ by > 10% (this is probably the
				#    most contentious. it is pragmatic, but depending on population source
				#    this may remove "real-genotypes" - we do this twice; once with unknown 
				#    rs# and a final sweep with known rs# (note, that there are often a 
				#    number of inconsistencies per array design where alleles are miscoded)
				# 4. we are dropping SNPs with <1 and >1 location (all duplicates are 
				#    ommitted)
				# 
				# version history
				# =======================================================================
				# - use 1000-genomes  as reference
				# - correct error where ids1/ids2 does not contain an "rs"
				# - update tempfile-0* to tempfile-3*
				# - define output of script as tempfile-3
				# - modify to accept arrays where all rsid are rs#
				#########################################################################
				*/
				}
		qui { // remove duplicate vars - by identifier
			noi di"-remove duplicate vars - by identifier"
			bim2dta,bim(tempfile-2)
			duplicates tag snp, gen(tag)
			keep if tag !=0
			count
			if `r(N)' != 0 {
					keep snp
					duplicates drop 
					outsheet snp using tempfile-3001.exclude, non noq replace
					}
			else if `r(N)' == 0 {
					noi di"|- no duplicates"
					keep snp
					outsheet snp using tempfile-3001.exclude, non noq replace
					}
			!$plink --bfile tempfile-2 --exclude tempfile-3001.exclude --make-bed --out tempfile-3001
			}
		qui { // remove duplicate vars - by location
				noi di"-removing duplicate SNPs based on chr location - keep rs# SNPs"
				!$plink --bfile tempfile-3001 --list-duplicate-vars --out tempfile-3001
				import delim using tempfile-3001.dupvar, clear
				drop if chr == 0
				count
				if `r(N)' ! = 0 { 
					qui { // define duplicates to keep (priority to rsid)
						noi di"-define duplicates to keep (priority to rsid)"
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
						save tempfile-3001.dta, replace
						}
					qui { // define duplicates to drop
						import delim using tempfile-3001.dupvar, clear
						keep ids
						split ids,p(" ")
						gen obs = _n
						drop ids
						reshape long ids, i(obs) j(x)
						keep ids
						rename ids rsid
						drop if rsid == ""
						merge 1:1 rsid using tempfile-3001.dta
						outsheet rsid if _m == 1 using duplicates.exclude, non noq replace
						}
					qui { //  drop duplicates
						!$plink --bfile tempfile-3001 --exclude duplicates.exclude --make-bed --out tempfile-3002
						}
					}
				else if `r(N)' == 0 {
					!$plink --bfile tempfile-3001 --make-bed --out tempfile-3002
					}
				}

		qui { // convert array names to rs# via kg_ref_frq
				noi di"-convert array names to rs# via kg_ref_frq"
				qui { // 1. convert to rs# where rs noted in name (e.g seq-rs1234 or imm-rs1234)
					noi di"|-convert to rs# where rs noted in name (e.g seq-rs1234 or imm-rs1234)"
					bim2dta, bim(tempfile-3002)
					split snp,p("rs")
					gen renameSNP = "rs" + snp2
					outsheet snp renameSNP if renameSNP != "rs" using tempfile-3002.update-name, non noq replace 
					!$plink --bfile tempfile-3002 --update-name tempfile-3002.update-name --mac 5 --make-bed --out tempfile-3003
					}
				qui { // 2. convert to rs# where markers do not have rs# titles (check MAF and drop if MAF > 10% dif to kg)
					noi di"|-convert to rs# where markers do not have rs# titles"
					qui { // select markers to rename
						noi di"|-select markers to rename"
						bim2dta, bim(tempfile-3003)
						split snp,p("rs")
						gen renameSNP = "rs" + snp2
						keep if renameSNP == "rs"
						}
					count
					if `r(N)' != 0 { 
						outsheet snp using tempfile-3003.extract, non noq replace 
						qui { // merge (by chr bp) against ${kg_ref_frq}
							drop snp1 snp2 renameSNP a1 a2
							for var chr bp: tostring X, replace
							rename gt array_gt
							sort chr bp
							noi di"|-merge (by chr bp against ${kg_ref_frq})"
							merge m:m chr bp using ${kg_ref_frq}
							keep if _m == 3
							drop _m
							save tempfile-3003.dta, replace
							}
						qui { // calculate allele-frequency of array
							noi di"|-calculate allele-frequency"
							!$plink --bfile tempfile-3003 --extract tempfile-3003.extract --freq --out tempfile-3003 		
							!$tabbed tempfile-3003.frq
							import delim using tempfile-3003.frq.tabbed, clear	
							tostring snp,replace
							keep snp a1 maf
							}
						qui { // merge kg and array data
							noi di"|-merge kg and array data"
							merge 1:m snp using tempfile-3003.dta
							}
						qui { // identify snps to drop (#1) - not on kg reference file
							noi di"|-identify snps to drop (#1) - not on kg reference file"
							outsheet snp if _m != 3 using tempfile-3003.exclude, non noq replace
							keep if _m == 3
							}		
						qui { // identify snps to drop (#2) - incompatable genotypes
							noi di"|-identify snps to drop (#2) - incompatable genotypes"
							gen drop = .
							replace drop = 1 if array_gt == "ID"
							replace drop = 1 if array_gt == "M" & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
							replace drop = 1 if array_gt == "K" & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
							replace drop = 1 if array_gt == "R" & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
							replace drop = 1 if array_gt == "Y" & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
							replace drop = 1 if array_gt == "S" & (kg_gt != "S") 
							replace drop = 1 if array_gt == "W" & (kg_gt != "W") 
							outsheet snp if drop == 1 using tempfile-3004.exclude, non noq replace
							drop if drop == 1
							drop drop
							}
						qui { // identify snps to drop (#3) - incompatable allele-frequencies
							noi di"|-identify snps to drop (#3) - incompatable allele-frequencies"
							qui { // normalise strand to kg
								gen flip = .
								replace flip = 1 if array_gt != kg_gt
								gen array_a1 = a1
								replace array_a1 = "A" if (a1 == "T" & flip == 1)
								replace array_a1 = "C" if (a1 == "G" & flip == 1)
								replace array_a1 = "G" if (a1 == "C" & flip == 1)
								replace array_a1 = "T" if (a1 == "A" & flip == 1)
								drop flip a1
								}
							gen array_frq = .
							replace array_frq = maf    if array_a1 == kg_a1
							replace array_frq = 1- maf if array_a1 == kg_a2
							gen drop = .
							replace drop = 1 if array_frq > kg_a1_frq + .1 
							replace drop = 1 if array_frq < kg_a1_frq - .1  
							global format "mlc(black) mfc(blue) mlw(vvthin) m(o)" 
							tw scatter array_frq kg_a1_frq             , $format saving(tempfile-3001,replace) nodraw
							tw scatter array_frq kg_a1_frq if drop == ., $format saving(tempfile-3002,replace) nodraw
							graph combine tempfile-3001.gph tempfile-3002.gph
							graph export  tempfile-allele-frequency-01.png, as(png) height(500) width(2000) replace
							outsheet snp if drop == 1 using tempfile-3005.exclude, non noq replace
							drop if drop == 1
							drop drop			
							}
						qui { // identify snps to drop (#4) - duplicate identifiers (from kg)
							noi di"|-identify snps to drop (#4) - duplicate identifiers"
							duplicates tag rsid , gen(tag)
							egen x = seq(),by(rsid tag) 
							gen drop = .
							replace drop = 1 if x > 1 
							outsheet snp if drop == 1 using tempfile-3006.exclude, non noq replace 
							}
						qui { // create update-name file
							noi di"|-create update-name file"
							drop if drop == 1
							drop drop
							duplicates tag snp, gen(a)
							egen b = seq(),by(snp a)
							drop if b == 2
							keep snp rsid
							outsheet snp rsid using tempfile-3004.update-name, non noq replace 
							}
						qui { // flag duplicates in array
							import delim using tempfile-3003.bim, clear
							egen x = seq(),by(v2)
							tostring x,replace
							replace  v2 = v2 + "_dup" + x if x != "1"
							outsheet v2 if x != "1" using tempfile-3007.exclude, non noq replace 
							drop x
							outsheet using tempfile-3003.bim, non noq replace
							}
						qui { // pre-clean
							clear
							set obs 1
							gen a = ""
							outsheet a using tempfile.exclude, non noq replace
							!type tempfile-3003.exclude >> tempfile.exclude
							!type tempfile-3004.exclude >> tempfile.exclude
							!type tempfile-3005.exclude >> tempfile.exclude
							!type tempfile-3006.exclude >> tempfile.exclude
							!type tempfile-3007.exclude >> tempfile.exclude
							!$plink --bfile tempfile-3003 --exclude tempfile.exclude --make-bed --out tempfile-3004
							}						
						qui { // update-name (round #1)
							noi di"|-updating name (round #1)"			
							!$plink --bfile tempfile-3004 --update-name tempfile-3004.update-name --make-bed --out tempfile-3005
							}
						}
					else if `r(N)' == 0 { 
						!$plink --bfile tempfile-3003 --make-bed --out tempfile-3005
						}
					}
				}

		qui { // remove duplicate vars - by identifier
				noi di"-remove duplicate vars - by identifier"
				import delim using tempfile-3005.bim, clear
				duplicates tag v2, gen(tag)
				egen x = seq(),by(v2 tag)
				for var v1 v4 x: tostring X,replace
				replace v2 = v2 + x if x != "1"
				outsheet v1-v6 using tempfile-3005.bim, non noq replace
				outsheet v2 if x != "1" using tempfile-3005.exclude, non noq replace
				!$plink2 --bfile tempfile-3005 --exclude tempfile-3005.exclude --make-bed --out tempfile-3006
				}
		qui { // remove duplicate vars - by location
				noi di"-remove duplicate vars - by location"
				import delim using tempfile-3006.bim, clear
				duplicates tag v1 v4, gen(tag)
				egen x = seq(),by(v1 v4 tag)
				for var v1 v4 x: tostring X,replace
				outsheet v1-v6 using tempfile-3006.bim, delim(" ") non noq replace
				outsheet v2 if x != "1" using tempfile-3006.exclude, non noq replace
				!$plink --bfile tempfile-3006 --exclude tempfile-3006.exclude --make-bed --out tempfile-3007
				}
				
		qui { // compare allele-frequencies (by rsid)
				noi di"-compare allele-frequencies (by rsid)"
				!$plink --bfile tempfile-3007 --freq --out tempfile-3007
				!$tabbed tempfile-3007.frq
				import delim using tempfile-3007.frq.tabbed, clear
				recodegenotype, a1(a1) a2(a2)
				rename (snp a1 maf _gt) (rsid array_a1 array_maf array_gt)
				keep rsid array_a1 array_maf array_gt
				noi di"|-merge with $kg_ref_frq"
				merge 1:1 rsid using $kg_ref_frq
				qui { // identify snps to drop (#1) - not on kg reference file
					noi di"|-identify snps to drop (#1) - not on kg reference file"
					outsheet rsid if _m == 1 using tempfile-3007.exclude, non noq replace
					keep if _m == 3
					}		
				qui { // identify snps to drop (#2) - incompatable genotypes
					noi di"|-identify snps to drop (#2) - incompatable genotypes"
					gen drop = .
					replace drop = 1 if array_gt == "ID"
					replace drop = 1 if array_gt == "M" & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
					replace drop = 1 if array_gt == "K" & (kg_gt == "R" | kg_gt == "Y" | kg_gt == "S" | kg_gt == "W") 
					replace drop = 1 if array_gt == "R" & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
					replace drop = 1 if array_gt == "Y" & (kg_gt == "M" | kg_gt == "K" | kg_gt == "S" | kg_gt == "W") 
					replace drop = 1 if array_gt == "S" & (kg_gt != "S") 
					replace drop = 1 if array_gt == "W" & (kg_gt != "W") 
					outsheet rsid if drop == 1 using tempfile-3008.exclude, non noq replace
					drop if drop == 1
					drop drop
					}
				qui { // identify snps to drop (#3) - incompatable allele-frequencies
					noi di"|-identify snps to drop (#3) - incompatable allele-frequencies"
					qui { // normalise strand to kg
							gen flip = .
							replace flip = 1 if array_gt != kg_gt
							gen a1 = array_a1
							replace array_a1 = "A" if (a1 == "T" & flip == 1)
							replace array_a1 = "C" if (a1 == "G" & flip == 1)
							replace array_a1 = "G" if (a1 == "C" & flip == 1)
							replace array_a1 = "T" if (a1 == "A" & flip == 1)
							drop flip a1
							}
					gen array_frq = .
					replace array_frq = array_maf    if array_a1 == kg_a1
					replace array_frq = 1- array_maf if array_a1 == kg_a2
					gen drop = .
					replace drop = 1 if array_frq > kg_a1_frq + .1 
					replace drop = 1 if array_frq < kg_a1_frq - .1  
					global format "mlc(black) mfc(blue) mlw(vvthin) m(o) " 
					tw scatter array_frq kg_a1_frq             , $format saving(tempfile-3001,replace) nodraw
					tw scatter array_frq kg_a1_frq if drop == ., $format saving(tempfile-3002,replace) nodraw
					graph combine tempfile-3001.gph tempfile-3002.gph
					graph export  tempfile-allele-frequency-02.png, as(png) height(500) width(2000) replace
					outsheet rsid if drop == 1 using tempfile-3009.exclude, non noq replace
					drop if drop == 1
					drop drop			
					}	
				qui { // final-clean
						clear
						set obs 1
						gen a = ""
						outsheet a using tempfile.exclude, non noq replace
						!type tempfile-3005.exclude >> tempfile.exclude
						!type tempfile-3006.exclude >> tempfile.exclude
						!type tempfile-3007.exclude >> tempfile.exclude
						!type tempfile-3008.exclude >> tempfile.exclude
						!type tempfile-3009.exclude >> tempfile.exclude
						!$plink --bfile tempfile-3007 --exclude tempfile.exclude --make-bed --out tempfile-3
						}	
				}
		qui { // clean-up files
				!del tempfile-2* tempfile-30* *.exclude *bim.dta 
				}


				
				

		}
	qui { // define-build
		qui { // notes
			/*
			#########################################################################
			# this code defines the genome build of the array
			# by defauly this is hg19 +1 after marker name convention
			#########################################################################
			*/
		}
		
		qui { // define input
			noi di"-define build of $input"
			qui { // collect chromosome locations of markers
					noi di"|-collect chromosome locations of markers"
					bim2dta, bim($input)
					rename snp rsid
					keep rsid chr bp
					sort rsid
					}
			qui { // merging dataset with reference co-ordinates
				noi di`"|-merging dataset with reference co-ordinates from ${build_ref}"'
				merge m:m rsid using ${build_ref}
				keep if _m == 3
				tostring bp, replace
				}
			qui { // check overlap with references	
				noi di`"|-comparing co-ordinates"'
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
				}
			qui { // create mini-report build
				noi di`"|-creating a mini-report: using ${input}.hg_buildMatch"'
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
				outsheet using ${input}.hg_buildMatch, replace noq		
				}
			qui { // plot array
				noi di`"-plotting ${input}.hg_buildMatch for the output report"'
				graph hbar percentMatched , over(build,sort(percentMatched) lab(labs(large))) title("Percentage Match Genome Build") yline(.9, lcol(red))  
				graph export ${input}.hg_buildMatch.png, as(png) height(1000) width(4000) replace
				window manage close graph
				}
			qui { // give a brief output to screen	
				keep in 1
				gen a = "global buildType "
				outsheet a build using tmpfile-2-defineBuild_001.do, non noq replace
				do tmpfile-2-defineBuild_001.do
				erase tmpfile-2-defineBuild_001.do
				noi di"|-based on our current estimates the data best matched BUILD: ${buildType}"	
				}	
			}
		qui { // define output
			noi di"-define build of $output"
			qui { // collect chromosome locations of markers
					noi di"|-collect chromosome locations of markers"
					bim2dta, bim(tempfile-3)
					rename snp rsid
					keep rsid chr bp
					sort rsid
					}
			qui { // merging dataset with reference co-ordinates
				noi di`"|-merging dataset with reference co-ordinates from ${build_ref}"'
				merge m:m rsid using ${build_ref}
				keep if _m == 3
				tostring bp, replace
				}
			qui { // check overlap with references	
				noi di`"|-comparing co-ordinates"'
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
				}
			qui { // create mini-report build
				noi di`"|-creating a mini-report: using ${output}.hg_buildMatch"'
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
				outsheet using ${output}.hg_buildMatch, replace noq		
				}
			qui { // plot array
				noi di`"|-plotting ${output}.hg_buildMatch for the output report"'
				graph hbar percentMatched , over(build,sort(percentMatched) lab(labs(large))) title("Percentage Match Genome Build") yline(.9, lcol(red))  
				graph export ${output}.hg_buildMatch.png, as(png) height(1000) width(4000) replace
				window manage close graph
				}
			qui { // give a brief output to screen	
				keep in 1
				gen a = "global buildType "
				outsheet a build using tmpfile-2-defineBuild_001.do, non noq replace
				do tmpfile-2-defineBuild_001.do
				erase tmpfile-2-defineBuild_001.do
				noi di"|-based on our current estimates the data best matched BUILD: ${buildType}"	
				}	
			}
		}
	qui { // run pre-quality controls
		qui { // notes
			/*
			#########################################################################
			# this code runs some basic pre-QC including;
			# - mac 5
			# - limit to chr 1 - 23
			# - make founders
			# - mind 0.99
			# - geno 0.99
			# - impute-sex (if chr 23 is present)
			#########################################################################
			*/
			}
		qui { // performing preQC
			noi di"-restrict to chromosomes 1-23"
			import delim using tempfile-3.bim, clear 
			keep if v1 >=1 & v1 < 24
			outsheet v2 using tempfile-3.extract, non noq replace
			!$plink --bfile tempfile-3 --extract tempfile-3.extract --make-founders --make-bed --out tempfile-5001
			sum v1
			if `r(max)' == 23 {
				!$plink --bfile tempfile-5001 --mac 5 --geno 0.99 --mind 0.99 --impute-sex --make-bed --out tempfile-5
				}
			else if `r(max)' != 23 {
				!$plink --bfile tempfile-5001 --mac 5 --geno 0.99 --mind 0.99  --make-bed --out tempfile-5
				}
				
			!del tempfile-3* tempfile-50*
			}	
		}
	qui { // run round 1 of quality control
		qui { // notes
			/*
			#########################################################################
			# this code runs the first round of QC;
			# - allele-frequency
			# - heterozygosity
			# - missingness (individual / marker)
			# - hardy-weinberg equilibrium
			# - relatedness (no-HLA)
			# 
			# version history
			# =======================================================================
			# - update hla to bim2ldexclude * long-range-ld.exclude
			#########################################################################
			*/
			}
			
		qui { // generate pre-quality-control metrics
			global preqc tempfile-5
			noi di"-generate pre-quality-control metrics on ${preqc}"
			noi di"|-measure allele frequency distribution"
			!$plink --bfile ${preqc} --freq           --out tempfile-round0
			noi di"|-measure heterozygosity in maf > 5%"
			!$plink --bfile ${preqc} --maf 0.05 --het --out tempfile-round0
			noi di"|-measure hardy-weinberg disequilibrium"
			!$plink --bfile ${preqc} --hardy          --out tempfile-round0
			noi di"|-measure missingness"
			!$plink --bfile ${preqc} --missing        --out tempfile-round0
			noi di"|-measure relatedness (create *.kin0)"
			bim2ldexclude, bim(${preqc})
			!$plink2 --bfile ${preqc} --maf 0.05 --exclude long-range-ld.exclude --make-king-table --out tempfile-round0					
			}
		qui { // plot quality-control metrics
			noi di"-plot pre-quality-control metrics on ${preqc}"
			noi di"|-plot allele frequency distribution"
			graphplinkfrq, frq(tempfile-round0) maf(${maf})
			noi di"|-plot heterozygosity distribution (maf > 5%)"
			graphplinkhet, het(tempfile-round0) sd(${hetsd})
			noi di"|-plot hardy-weinberg p-distribution"
			graphplinkhwe, hwe(tempfile-round0) threshold(${hwep}) 			
			noi di"|-plot missingess distribution (by-individual)"
			graphplinkimiss, imiss(tempfile-round0) mind(${mind})
			noi di"|-plot missingess distribution (by-marker)"
			graphplinklmiss, lmiss(tempfile-round0) geno(${geno2})			
			noi di"|-plot relatedness distribution"
			graphplinkkin0, kin0(tempfile-round0) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
			}
		qui { // rename graphs from generic names
			noi di"-rename graphs from generic outputs"
			foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
				!copy "tmp`graph'.gph" "tempfile-round0_`graph'.gph"
				!del "tmp`graph'.gph"
				}
			}	
						
		qui { // run quality-control round # 1
			noi di"-run quality-control round # 1"
			noi di"|-remove heterozygosity outliers (individuals)"
			!$plink --bfile tempfile-5  --remove tempHET.indlist --set-hh-missing --make-bed --out tempfile-6001
			noi di"|-remove hwe outliers (markers)"
			!$plink --bfile tempfile-6001  --exclude  tempHWE.snplist --make-bed --out tempfile-6002 
			noi di"|-remove missingness by snp (pre-quality-control)"
			!$plink --bfile tempfile-6002 --geno ${geno1} --make-bed --out tempfile-6003
			noi di"|-remove missingness by individual"
			!$plink --bfile tempfile-6003 --mind ${mind}  --make-bed --out tempfile-6004
			noi di"|-remove missingness by snp"
			!$plink --bfile tempfile-6004 --geno ${geno2} --make-bed --out tempfile-6005		
			noi di"|-remove snp by minor-allele-frequency"
			!$plink --bfile tempfile-6005 --maf  ${maf}   --make-bed --out tempfile-6006
			erase tempHET.indlist
			erase tempHWE.snplist
			qui { // remove excess cryptic relatedness
				noi di"|-remove excess cryptic relatedness"
				qui { // count number of individuals in data set
					noi di"|-count number of individuals in data set"
					fam2dta, fam(tempfile-6006)
					count
					global sampleSize `r(N)'
					noi di"|-N = $sampleSize"
					}
				qui { // create kinship table
					noi di"|-create kinship table"
					noi di"|-calculate matrix script to create a matrix of $sampleSize x $sampleSize"
					bim2ldexclude, bim(tempfile-6006)
					!$plink2 --bfile tempfile-6006 --maf 0.05 --exclude long-range-ld.exclude --make-king square --out tempfile-6006
					}
				qui { // import kinship table 
					noi di"|-import kinship table "
					!$tabbed tempfile-6006.king
					import delim using tempfile-6006.king.tabbed, clear case(lower)
					count
					global countX `r(N)'
					keep v1-v$countX
					forvalues i=1/ $countX {
							replace v`i' = . in `i'
							}
					gen obs = _n
					aorder
					save tempfile-6006.dta,replace
					}
				qui { // merge kinship table to identifiers
					noi di"|-merge kinship table to identifiers"
					import delim using tempfile-6006.king.id, clear case(lower)
					rename (v1 v2) (fid iid)
					gen obs = _n
					aorder
					merge 1:1 obs using tempfile-6006.dta, update
					drop obs _m
					}
				qui { // calculate by-individual metrics
					noi di"|-calculate by-individual metrics"
					for var v1-v$countX: replace X = 0 if X < 0
					egen rm = rowmean(v1-v$countX)
					egen rx =  rowmax(v1-v$countX)
					keep fid iid rm rx
					}
				qui { // identify individuals with excessive kin
					noi di"|-identify individuals with excessive kin"
				gen excessCryptic = ""
					sum rm
					gen lb = `r(mean)' - 2.5 *`r(sd)'
					gen ub = `r(mean)' + 2.5 *`r(sd)'
				replace excessCryptic = "1" if rm < (lb)
					replace excessCryptic = "1" if rm > (ub)
					count if ex == "1"
					global excessC `r(N)'
					noi di"|-exporting individual if mean kinship is greater than 2.5x standard-deviation from the mean"
					outsheet fid iid if excessC == "1" using excessiveCryptic.remove, replace non noq		
					}
				qui { // plot mean kinship vs maximum kinship
					noi di"|-plot mean kinship vs maximum kinship"
					global format "mlc(black) mlw(vvthin) m(O)"
					tw scatter rx rm if excessCryptic != "1", $format mfc(blue)   ///
					|| scatter rx rm if excessCryptic == "1", $format mfc(red)    ///
						 legend(off) ytitle("maximum KINSHIP") xtitle("average KINSHIP") ///
						 caption("KINSHIP is the Estimated kinship coefficient from the SNP data. All KINSHIP < 0 are reported as 0. " ///
										 "If an individual has excessive KINSHIP it may indicate poor genotyping." ///
										 "In this sample of N = $sampleSize, N = $excessC are +/- 2.5 sd from the KINSHIP mean")
					graph export tempfile-round1_relate.png, as(png) height(1000) width(2000) replace
					window manage close graph
					}
				qui { // remove excessive cryptic relatedness to complete round 1 quality-control
					noi di"|-remove excessive cryptic relatedness to complete round 1 quality-control"
					!$plink --bfile tempfile-6006 --remove excessiveCryptic.remove   --make-bed --out tempfile-round1
					}
				}
			}
		qui { // clean-up files
			!del tempfile-5* tempfile-60* *.exclude *.remove
			}
		}
	qui { // run round N of quality control
		qui { // notes
			/*
			#########################################################################
			# this code runs the first round of QC;
			# - allele-frequency
			# - heterozygosity
			# - missingness (individual / marker)
			# - hardy-weinberg equilibrium
			# - relatedness (no-HLA)
			# 
			# version history
			# =======================================================================
			# - update hla to bim2ldexclude * long-range-ld.exclude
			#########################################################################
			*/
			}
		qui { // run quality-control-rounds 2 to $rounds
			noi di"-run quality-control-rounds 2 to $rounds"
			foreach round of num  2 / $rounds {
				qui { // round `round'
					noi di"-round `round'"
					clear
					set obs 2
					gen obs = _n
					tostring obs, replace
					gen x = `round'
					replace x = x - 1 in 1
					tostring x, replace
					gen round = "global round" + obs + " round" + x
					outsheet round using tempfile-round.do, non noq replace
					do tempfile-round.do,
					erase tempfile-round.do
					qui { // measure post-${round1} files
						noi di"|-measure post-${round1} files"
						noi di"|-measure heterozygosity in maf > 5%"
						!$plink --bfile tempfile-$round1 --maf 0.05 --het --out tempfile-$round1
						graphplinkhet, het(tempfile-$round1) sd(${hetsd})
						noi di"|-measure hardy-weinberg disequilibrium"
						!$plink --bfile tempfile-$round1 --hardy          --out tempfile-$round1
						graphplinkhwe, hwe(tempfile-$round1) threshold(${hwep}) 			
						}	
					qui { // perform qc routines - round-2
						noi di"|-remove heterozygosity outliers (individuals)"
						!$plink --bfile tempfile-$round1   --remove tempHET.indlist --set-hh-missing --make-bed --out tempfile-$round1-0001
						noi di"|-remove hwe outliers (markers)"
						!$plink --bfile tempfile-$round1-0001  --exclude  tempHWE.snplist            --make-bed --out tempfile-$round1-0002 
						noi di"|-remove missingness by individual"
						!$plink --bfile tempfile-$round1-0002  --mind ${mind}  --make-bed --out tempfile-$round1-0003
						noi di"|-remove missingness by snp"
						!$plink --bfile tempfile-$round1-0003  --geno ${geno2} --make-bed --out tempfile-$round1-0004		
						noi di"|-remove snp by minor-allele-frequency"
						!$plink --bfile tempfile-$round1-0004  --maf  ${maf}   --make-bed --out tempfile-$round2
						}		
					qui { // clean-up files
						!del tempfile-$round1-000* *indlist *snplist tmpHWE* tmpHET*
						}
					}
				}
			}
		qui { // measure post-$rounds files
			noi di"-measure post-quality-control metrics on tempfile-round$rounds"
			noi di"|-measure allele frequency distribution"
			!$plink --bfile tempfile-round$rounds --freq           --out tempfile-round$rounds
			noi di"|-measure heterozygosity in maf > 5%"
			!$plink --bfile tempfile-round$rounds --maf 0.05 --het --out tempfile-round$rounds
			noi di"|-measure hardy-weinberg disequilibrium"
			!$plink --bfile tempfile-round$rounds --hardy          --out tempfile-round$rounds
			noi di"|-measure missingness"
			!$plink --bfile tempfile-round$rounds --missing        --out tempfile-round$rounds
			noi di"|-measure relatedness (create *.kin0)"
			bim2ldexclude, bim(tempfile-round$rounds)
			!$plink2 --bfile tempfile-round$rounds --maf 0.05 --exclude long-range-ld.exclude --make-king-table --out tempfile-round$rounds	
			}
		qui { // plot post-round-$rounds files
			noi di"-plot post-$rounds files" 
			qui { // create blank graphs
				noi di"|-create blank graphs"
				tw scatteri 1 1, msymbol(i) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank))     
				foreach i in tmpFRQ tmpHET tmpHWE tmpIMISS tmpLMISS tmpKIN0_1 tmpKIN0_2 {
					graph save `i', replace
					}
				window manage close graph
				}	
			qui { // plot graphs
				noi di"|-plot graphs"
				noi di"|-plot allele frequency distribution"
				graphplinkfrq, frq(tempfile-round$rounds) maf(${maf})
				noi di"|-plot heterozygosity distribution (maf > 5%)"
				graphplinkhet, het(tempfile-round$rounds) sd(${hetsd})
				noi di"|-plot hardy-weinberg p-distribution"
				graphplinkhwe, hwe(tempfile-round$rounds) threshold(${hwep}) 			
				noi di"|-plot missingess distribution (by-individual)"
				graphplinkimiss, imiss(tempfile-round$rounds) mind(${mind})
				noi di"|-plot missingess distribution (by-marker)"
				graphplinklmiss, lmiss(tempfile-round$rounds) geno(${geno2})			
				noi di"|-plot relatedness distribution"
				graphplinkkin0, kin0(tempfile-round$rounds) d(${kin_d}) f(${kin_f}) s(${kin_s}) t(${kin_t})
				}
			qui { // rename graphs from generic names
				noi di"|-rename graphs from generic outputs"
				foreach graph in FRQ HET HWE IMISS LMISS KIN0_1 KIN0_2 { 
					!copy "tmp`graph'.gph" "tempfile-round$rounds_`graph'.gph"
					!del "tmp`graph'.gph"
					}
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
			!del *.snplist *.indlist *.exclude del.do *.dta
			}
		}
	qui { // remove-related-samples
		qui { // notes
			/*
			# =======================================================================
			# this code identifies relatedness using the kinship algorithm (via 
			# plink2) and removes;
			# - duplicates
			# - 2nd-degree relatives
			# - 3rd-degree relatives
			# this script does not remove 1st degree relatives therefore is compatable 
			# with "trio" and "siblings" designs. 
			#
			# this script works in a best-dressed first-removed; it calculates number
			# of shared relatives; then randomly removes individuals with the top-N 
			# related pairs. Then repeats the steps. 
			# 
			# version history
			# =======================================================================
			# - update hla to bim2ldexclude * long-range-ld.exclude
			# -
			#########################################################################
			*/
			}
		qui { // remove-related-samples"
			global makeking "--maf 0.05 --exclude long-range-ld.exclude --make-king-table"
			qui { // identify and exclude duplicates (at random)
				noi di"-identify and exclude duplicates (at random)"
				qui { // re-calculate kinship matrix
					noi di"|-re-calculate kinship matrix"
					bim2ldexclude, bim(tempfile-round${rounds})
					!$plink2 --bfile tempfile-round${rounds} ${makeking} --out tempfile-round${rounds}	
					}
				!$tabbed tempfile-round${rounds}.kin0
				import delim using tempfile-round${rounds}.kin0.tabbed, clear case(lower)
				erase tempfile-round${rounds}.kin0.tabbed
				for var fid1-id2      : tostring X, replace 
				for var hethet-kinship: destring X, replace force
				gen rel = ""
				replace rel = "3rd" if kinship > ${kin_t}
				replace rel = "2nd" if kinship > ${kin_s}
				replace rel = "1st" if kinship > ${kin_f}
				replace rel = "dup" if kinship > ${kin_d}
				replace rel = ""    if kinship == .
				noi di"|-tabulate relatedness prior to removal of duplicates"
				noi ta rel
				keep if rel == "dup"
				keep fid1-id2
				gen obs = _n
				reshape long fid id , i(obs) j(x)
				gen random = uniform()
				sort  obs random
				egen keep = seq(),by(obs)
				keep if keep == 1
				outsheet fid id using duplicates.remove, non noq replace
				!$plink --bfile tempfile-round${rounds} --remove duplicates.remove --make-bed --out tempfile-8001
				}
			qui { // identify and exclude 2nd-degree relatives (at random)
				noi di"-identify and exclude 2nd-degree relatives (at random)"	
				qui { // re-calculate kinship matrix
					noi di"|-re-calculate kinship matrix"
					bim2ldexclude, bim(tempfile-8001)
					!$plink2 --bfile tempfile-8001 ${makeking} --out tempfile-8001	
					!$tabbed tempfile-8001.kin0
					}
				qui { // detemine number of 2nd-degree relatives
					noi di"|-detemine number of 2nd-degree relatives"
					import delim using tempfile-8001.kin0.tabbed, clear case(lower)
					erase tempfile-8001.kin0.tabbed
					for var fid1-id2      : tostring X, replace 
					for var hethet-kinship: destring X, replace force
					gen rel = ""
				replace rel = "3rd" if kinship > ${kin_t}
				replace rel = "2nd" if kinship > ${kin_s}
				replace rel = "1st" if kinship > ${kin_f}
				replace rel = "dup" if kinship > ${kin_d}
					replace rel = ""    if kinship == .
					noi di"|-tabulate relatedness prior to removal of 2nd-degree relatives"
					noi ta rel
					keep if rel == "2nd"
					!type > 2nd-degree.remove
					}
				qui { // run loop routine over 2nd-degree relatives
					noi di"-run loop routine over 2nd-degree relatives"
					count
					if `r(N)' != 0 { 
							noi di"|-2nd-degree relatives exist - run routine"
							keep fid1-id2
							gen obs = _n
							reshape long fid id , i(obs) j(x)
							qui { // remove most-related first
								noi di"|-removing most-related"
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
											outsheet fid id using tempfile-8001.remove, non noq replace
											!type tempfile-8001.remove >> 2nd-degree.remove
											noi di"|-re-calculate kinship matrix"
											!$plink2 --bfile tempfile-8001	--remove 2nd-degree.remove ${makeking} --out tempfile-80XX	
											!$tabbed tempfile-80XX.kin0
											import delim using tempfile-80XX.kin0.tabbed, clear case(lower)
											erase tempfile-80XX.kin0.tabbed
											for var fid1-id2      : tostring X, replace 
											for var hethet-kinship: destring X, replace force
											gen rel = ""
											replace rel = "3rd" if kinship > ${kin_t}
											replace rel = "2nd" if kinship > ${kin_s}
											replace rel = "1st" if kinship > ${kin_f}
											replace rel = "dup" if kinship > ${kin_d}
											replace rel = ""    if kinship == .
											noi di"|-relatedness post removal of 2nd-degree relatives"
											noi ta rel
											keep if rel == "2nd"
											count
											if `r(N)' != 0 { 
												noi di"|-2nd-degree relatives still exist - run routine"
												keep fid1-id2
												gen obs = _n
												reshape long fid id , i(obs) j(x)
												qui { // remove most-related first
													noi di"|-removing most-related setfirst"
													egen y = seq(),by(fid id)
													sum y
													}
												}
											}
										}
									}
								}
							}
					count
					if `r(N)' != 0 { 
							noi di"|-2nd-degree relatives still exist"
							noi di"|-all remaining are unique pairs"
							gen random = uniform()
							sort  obs random
							egen keep = seq(),by(obs)
							keep if keep == 1
							outsheet fid id using tmp.remove, non noq replace
							!type tmp.remove >> 2nd-degree.remove
							}
					!$plink --bfile tempfile-8001 --remove 2nd-degree.remove --make-bed --out tempfile-8002
					}
					}
			qui { // identify and exclude 3rd-degree relatives (at random)
				noi di"-identify and exclude 3rd-degree relatives (at random)"	
				qui { // re-calculate kinship matrix
					noi di"|-re-calculate kinship matrix"
					bim2ldexclude, bim(tempfile-8002)
					!$plink2 --bfile tempfile-8002 ${makeking} --out tempfile-8002	
					!$tabbed tempfile-8002.kin0
					}
				qui { // detemine number of 3rd-degree relatives
					noi di"|-detemine number of 3rd-degree relatives"
					import delim using tempfile-8002.kin0.tabbed, clear case(lower)
					erase tempfile-8002.kin0.tabbed
					for var fid1-id2      : tostring X, replace 
					for var hethet-kinship: destring X, replace force
					gen rel = ""
					replace rel = "3rd" if kinship > ${kin_t}
					replace rel = "2nd" if kinship > ${kin_s}
					replace rel = "1st" if kinship > ${kin_f}
					replace rel = "dup" if kinship > ${kin_d}
					replace rel = ""    if kinship == .
					noi di"|-tabulate relatedness prior to removal of 3rd-degree relatives"
					noi ta rel
					keep if rel == "3rd"
					!type > 3rd-degree.remove
					}
				qui { // run loop routine over 3rd-degree relatives
					noi di"-run loop routine over 3rd-degree relatives"
					count
					if `r(N)' != 0 { 
							noi di"|-3rd-degree relatives exist - run routine"
							keep fid1-id2
							gen obs = _n
							reshape long fid id , i(obs) j(x)
							qui { // remove most-related first
								noi di"|-removing most-related"
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
											outsheet fid id using tempfile-8002.remove, non noq replace
											!type tempfile-8002.remove >> 3rd-degree.remove
											noi di"|-re-calculate kinship matrix"
											!$plink2 --bfile tempfile-8002	--remove 3rd-degree.remove ${makeking} --out tempfile-80XX	
											!$tabbed tempfile-80XX.kin0
											import delim using tempfile-80XX.kin0.tabbed, clear case(lower)
											erase tempfile-80XX.kin0.tabbed
											for var fid1-id2      : tostring X, replace 
											for var hethet-kinship: destring X, replace force
											gen rel = ""
											replace rel = "3rd" if kinship > ${kin_t}
											replace rel = "2nd" if kinship > ${kin_s}
											replace rel = "1st" if kinship > ${kin_f}
											replace rel = "dup" if kinship > ${kin_d}
											replace rel = ""    if kinship == .
											noi di"|-tabulate relatedness post removal of 3rd-degree relatives (`num')"
											noi ta rel
											keep if rel == "3rd"
											count
											if `r(N)' != 0 { 
												noi di"|-3rd-degree relatives still exist - run routine"
												keep fid1-id2
												gen obs = _n
												reshape long fid id , i(obs) j(x)
												qui { // remove most-related first
													noi di"|-removing most-related set"
													egen y = seq(),by(fid id)
													sum y
													}
												}
											}
										}
									}
								}
							}
					count
					if `r(N)' != 0 { 
						noi di"|-3rd-degree relatives still exist"
						noi di"|-all remaining are unique pairs"
						gen random = uniform()
						sort  obs random
						egen keep = seq(),by(obs)
						keep if keep == 1
						outsheet fid id using tmp.remove, non noq replace
						!type tmp.remove >> 3rd-degree.remove
						}
					!$plink --bfile tempfile-8002 --remove 3rd-degree.remove --make-bed --out tempfile-final
					}
				}
			qui { // plot post remove
				noi di"-plot post-removal relatedness"
				!$plink2 --bfile tempfile-final ${makeking} --out tempfile-final
				graphplinkkin0, kin0(tempfile-final)	
				!copy tmpKIN0_2.gph tempfile-final_KIN0_2_noRel.gph
				}
			qui { // clean up files
				!del tempfile-80XX* tempfile-802* *.remove *.exclude tmpK* *.kin0
				}

				
	
			}
		}
	qui { // define and plot ancestry
		qui { // notes
			/*
			#########################################################################
			# this code identifies a subset of individuals who are "European-like". 
			# the script defines this based on similarity to hapmap reference 
			# gentoypes.
			# the reference genotypes are all hg19 + 1
			# ancestry informative markers are used (fst > 0.5)
			# - other versions using fst > 0.1 and fst > 0.8 were examined but did 
			#   not seperate the clusters as "neatly" as the 0.5
			# 
			# version history
			# =======================================================================
			# - prune merged file in reference and limit merge to ld-independent
			# - update to incluse bim2eigenvec program
			#########################################################################
			*/
			}
		qui { // restrict datasets to ancestry-informative-markers
			noi di"-restrict the plink binaries to AIMS (ancestry-informative-markers)"
			global extractaims --extract ${aims} --make-founders --make-bed --out
			!$plink --bfile tempfile-final ${extractaims} tempfile-final-aims-9001
			!$plink --bfile ${hapmap_data} ${extractaims} tempfile-hapmap-aims-9001
			}
		qui { // convert strand to hapmap-ref
			foreach i in final hapmap { 
				bim2dta, bim(tempfile-`i'-aims-9001)
				keep snp a1 a2
				rename (a1 a2) (`i'_a1 `i'_a2)
				save tempfile-`i'-aims.dta,replace
				}
			use tempfile-hapmap-aims.dta, clear
			merge 1:1 snp using tempfile-final-aims.dta
			keep if _m == 3
			outsheet snp using overlap.extract, non noq replace
			recodestrand, ref_a1(hapmap_a1) ref_a2(hapmap_a2) alt_a1(final_a1) alt_a2(final_a2) 
			outsheet snp if _tmpflip == 1 using overlap.flip, non noq replace
			global extractoverlap --make-founders --extract overlap.extract --make-bed --out 
			!$plink --bfile tempfile-final --flip overlap.flip ${extractoverlap} tempfile-final-aims-9002
			!$plink --bfile ${hapmap_data}                     ${extractoverlap} tempfile-hapmap-aims-9002
			}
		qui { // merge hapmap and final
			noi di"-merge hapmap and final genotype"
			!$plink --bfile tempfile-hapmap-aims-9002 --bmerge tempfile-final-aims-9002.bed tempfile-final-aims-9002.bim tempfile-final-aims-9002.fam --allow-no-sex --make-bed --out tempfile-hapmap-final-aims-9002
			}
		qui { // ld-prune reference
			noi di"-ld-prune the hapmap reference "
			bim2eigenvec, bim(tempfile-hapmap-final-aims-9002)
			qui { // plot scree of eigenvalues
				noi di"-plot scree of eigenvalues"
				use tempfile-hapmap-final-aims-9002_eigenval.dta,clear
				twoway scatter eigenval pc, xtitle("Principle Components") connect(l) xlabel(1(1)10) mfc(red) mlc(black) mlw(vthin) ms(O) saving(tempfile-hapmap-final-aims-9003-scree.gph, replace) nodraw
				}
			}
		qui { // define and plot PC legend
			noi di"-plot legend"
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
			global format "msiz(medlarge) msymbol(S) mlc(black) mlabel(POP) mlabposition(3) mlabsize(medium) mlw(vvthin)"
			tw scatter y x if POP == "Test (European)" ,     $format mfcolor("255   0   0")  ///
			|| scatter y x if POP == "Test (non-European)" , $format mfcolor("204 204 204")  ///  
			|| scatter y x if POP == "ASW"                 , $format mfcolor("102 102   0")  ///
			|| scatter y x if POP == "LWK"                 , $format mfcolor("  0 102   0")  ///
			|| scatter y x if POP == "MKK"                 , $format mfcolor(" 51 204   0")  ///
			|| scatter y x if POP == "YRI"                 , $format mfcolor("102 153   0")  ///
			|| scatter y x if POP == "CEU"                 , $format mfcolor("  0   0 255")  ///
			|| scatter y x if POP == "TSI"                 , $format mfcolor(" 51 151 255")  ///
			|| scatter y x if POP == "MEX"                 , $format mfcolor("153 153 255")  ///	
			|| scatter y x if POP == "GIH"                 , $format mfcolor("153   0 153")  ///
			|| scatter y x if POP == "CHB"                 , $format mfcolor("204 153  51")  ///
			|| scatter y x if POP == "CHD"                 , $format mfcolor("255 204 102")  ///
			|| scatter y x if POP == "JPT"                 , $format mfcolor("255 255 102")  ///
			|| scatter y x if POP == " "                   , msymbol(none)                   ///
				 legend(off) ylab("") xlab("") ytitle("") xtitle("") yscale(off) xscale(off) plotregion(lpattern(blank)) 
					graph save legend.gph, replace
			window manage close graph
			}						
		qui { // import eigenvecs and assign population 
			noi di"-import eigenvecs and assign population "
			use tempfile-hapmap-final-aims-9002_eigenvec.dta,clear
			renvars, upper
			save tempfile-hapmap-final-aims-9003.dta, replace
			import delim using ${hapmap_data}.population, clear
			renvars, upper
			merge 1:1 FID IID using tempfile-hapmap-final-aims-9003.dta
			replace POP = "TEST" if POP == ""
			}
		qui { // define "european" according to similarity of CEU /TSI data (w/in 2SD)
			noi di`"-define "european" according to similarity of CEU /TSI data (w/in 2SD) across 3 PCs"'
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
			noi di`"|-individuals described as being similar to "european" exported to ${output}.keep-ceuLike"'
			outsheet FID IID if POP == "nrCEU" using tempfile-hapmap-final-aims-9003.keep-ceuLike, non noq replace
			}
		qui { // plot against all reference ancestries
			noi di"-plot PCs (all ancestries)"
			global format  "msiz(vsmall) msymbol(o) mlc(black) mlw(vvthin)"
			global format2 "msiz(large) msymbol(o) mlc(black) mlw(vvthin)"
			foreach i of num 1/3 { 
				foreach j of num 1/3 { 
					tw scatter PC`j' PC`i' if POP == "ASW" ,  ${format2} mfcolor("102 102   0")  ///
					|| scatter PC`j' PC`i' if POP == "LWK" ,  ${format2} mfcolor("  0 102   0")  ///
					|| scatter PC`j' PC`i' if POP == "MKK" ,  ${format2} mfcolor(" 51 204   0")  ///
					|| scatter PC`j' PC`i' if POP == "YRI" ,  ${format2} mfcolor("102 153   0")  ///
					|| scatter PC`j' PC`i' if POP == "CEU" ,  ${format2} mfcolor("  0   0 255")  ///
					|| scatter PC`j' PC`i' if POP == "TSI" ,  ${format2} mfcolor(" 51 151 255")  ///
					|| scatter PC`j' PC`i' if POP == "MEX" ,  ${format2} mfcolor("153 153 255")  ///	
					|| scatter PC`j' PC`i' if POP == "GIH" ,  ${format2} mfcolor("153   0 153")  ///
					|| scatter PC`j' PC`i' if POP == "CHB" ,  ${format2} mfcolor("204 153  51")  ///
					|| scatter PC`j' PC`i' if POP == "CHD" ,  ${format2} mfcolor("255 204 102")  ///
					|| scatter PC`j' PC`i' if POP == "JPT" ,  ${format2} mfcolor("255 255 102")  ///
					|| scatter PC`j' PC`i' if POP == "TEST",  ${format2} mfcolor("204 204 204")  ///
					|| scatter PC`j' PC`i' if POP == "nrCEU", ${format2} mfcolor("255   0   0")  ///
						 legend(off) saving(_cPC`j'PC`i'.gph, replace) ///
						 yline(${PC`j'max}, lw(.1) lc(black) lp(solid)) ///
						 yline(${PC`j'min}, lw(.1) lc(black) lp(solid)) ///
						 xline(${PC`i'max}, lw(.1) lc(black) lp(solid)) ///
						 xline(${PC`i'min}, lw(.1) lc(black) lp(solid)) nodraw
						}
					}
					
			graph combine tempfile-hapmap-final-aims-9003-scree.gph  _cPC1PC2.gph _cPC1PC3.gph _cPC2PC3.gph legend.gph , col(5) title("All HapMap Ancestries Plotted")
			graph export   tempfile-hapmap-final-aims-9_eigenvec_ALL.png, height(5000) width(16000) replace
			window manage close graph
			}
		qui { // plot against all reference ancestries (european focus)
			noi di"-plot PCs (european focus)"
			foreach i of num 1/3{
				sum PC`i' if POP == "CEU" 
				drop if PC`i' > (r(mean) + 6*r(sd)) 
				drop if PC`i' < (r(mean) - 6*r(sd))
				}
			foreach i of num 1/3 { 
				foreach j of num 1/3 { 
					tw scatter PC`j' PC`i' if POP == "ASW" ,  ${format2} mfcolor("102 102   0")  ///
					|| scatter PC`j' PC`i' if POP == "LWK" ,  ${format2} mfcolor("  0 102   0")  ///
					|| scatter PC`j' PC`i' if POP == "MKK" ,  ${format2} mfcolor(" 51 204   0")  ///
					|| scatter PC`j' PC`i' if POP == "YRI" ,  ${format2} mfcolor("102 153   0")  ///
					|| scatter PC`j' PC`i' if POP == "CEU" ,  ${format2} mfcolor("  0   0 255")  ///
					|| scatter PC`j' PC`i' if POP == "TSI" ,  ${format2} mfcolor(" 51 151 255")  ///
					|| scatter PC`j' PC`i' if POP == "MEX" ,  ${format2} mfcolor("153 153 255")  ///	
					|| scatter PC`j' PC`i' if POP == "GIH" ,  ${format2} mfcolor("153   0 153")  ///
					|| scatter PC`j' PC`i' if POP == "CHB" ,  ${format2} mfcolor("204 153  51")  ///
					|| scatter PC`j' PC`i' if POP == "CHD" ,  ${format2} mfcolor("255 204 102")  ///
					|| scatter PC`j' PC`i' if POP == "JPT" ,  ${format2} mfcolor("255 255 102")  ///
					|| scatter PC`j' PC`i' if POP == "TEST",  ${format2} mfcolor("204 204 204")  ///
					|| scatter PC`j' PC`i' if POP == "nrCEU", ${format2} mfcolor("255   0   0")  ///
						 legend(off) saving(_cPC`j'PC`i'.gph, replace) ///
						 yline(${PC`j'max}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
						 yline(${PC`j'min}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
						 xline(${PC`i'max}, lsty(refline) lw(.1) lc(black) lp(solid)) ///
						 xline(${PC`i'min}, lsty(refline) lw(.1) lc(black) lp(solid)) nodraw
						}
					}
			graph combine tempfile-hapmap-final-aims-9003-scree.gph  _cPC1PC2.gph _cPC1PC3.gph _cPC2PC3.gph legend.gph , col(5)   title("All HapMap Ancestries Plotted (European Focus)")
			graph export tempfile-hapmap-final-aims-9_eigenvec_EUR.png, height(5000) width(15000) replace
			window manage close graph
			}
		qui { // clean up mess!
			noi di"-cleaning up files"
			!del _c*  tempfile-hapmap-a* tempfile-final-a* *.extract *.exclude *.sexcheck *.in *.remove legend* *.flip *scree.gph
			foreach i in bim bed fam log nosex eigenval eigenvec dta{
				!del tempfile-hapmap-final-aims-9003.`i'
				}
			}



				
				
				
			}
	qui { // create report
		qui { // notes
			/*
			#########################################################################
			# this code generates the quality-control-report (docx) from the pipeline
			# 
			# version history
			# =======================================================================
			# -
			# -
			#########################################################################
			*/
			}
		qui { // create final plots as(png)
			noi di"-create final plots as(png)"
			qui { // plot marker by chromosome	
				noi di"|-plotting markers by chromosome by input / output"
				bim2dta,bim(${input})
				hist chr,  xlabel(1(1)25) xtitle("Chromosome") discrete freq ylabel(#4,format(%9.0g))
				graph save input_chrHist.gph, replace
				bim2dta,bim(tempfile-final)
				hist chr,  xlabel(1(1)25) xtitle("Chromosome") discrete freq ylabel(#4,format(%9.0g))
				graph save tempfile-final_chrHist.gph, replace
				graph combine input_chrHist.gph  tempfile-final_chrHist.gph, caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}",	size(tiny)) col(1)
				graph export  tempfile-final_chrHist.png, as(png) replace width(4000) height(2000)
				window manage close graph
				}	
			qui { // combine graphs for report
				noi di"|-consolidate graphs for report"
				foreach i in FRQ HET HWE IMISS LMISS KIN0_1 {
					graph combine tempfile-round0_`i'.gph,       title("pre-quality-control")  nodraw saving(x_`i'.gph, replace) 
					graph combine tempfile-round$rounds_`i'.gph, title("post-quality-control") nodraw saving(y_`i'.gph, replace)
					graph combine x_`i'.gph y_`i'.gph, xcommon caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}", size(tiny)) col(1) 
					graph export tempfile-final-`i'.png, as(png) replace width(4000) height(2000)
					!del x_`i'* y_`i'*
					}
				foreach i in  KIN0_2 {
					graph combine tempfile-round0_`i'.gph,       title("pre-quality-control")  nodraw saving(x_`i'.gph, replace) 
					graph combine tempfile-round$rounds_`i'.gph, title("post-quality-control") nodraw saving(y_`i'.gph, replace) 
					graph combine tempfile-final_`i'_noRel.gph,        title("post-quality-control (no-relatives)") nodraw saving(z_`i'.gph, replace) 
					graph combine x_`i'.gph y_`i'.gph z_`i'.gph, col(3) caption("CREATED: $S_DATE $S_TIME" "INPUT: ${input}" "OUTPUT: ${output}", size(tiny))
					graph export tempfile-final-`i'.png, as(png) replace width(4000) height(2000)
					!del x_`i'* y_`i'* z_`i'*
					}
				}	
			}
		qui { // count metrics 
			noi di"-counting metrics and storing in memory"
			noi di"|-counting numbers of markers in input / output"
			!$wc -l "${input}.bim"                 > "tempfile-final.counts"
			!$wc -l "tempfile-final.bim"          >> "tempfile-final.counts"
			noi di"|-counting individuals in input / output"
			!$wc -l "${input}.fam"                >> "tempfile-final.counts"
			!$wc -l "tempfile-final.fam"          >> "tempfile-final.counts"
			!$wc -l "tempfile-hapmap-final-aims-9003.keep-ceuLike" >> "tempfile-final.counts"
			import delim using tempfile-final.counts, clear varnames(nonames)
			erase tempfile-final.counts
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
		qui { // create *.docx report		
			noi di"-creating quality-control-report.docx"
			global toc    "$S_DATE $S_TIME"
			//open document" 
			mata:
			dh = _docx_new()
			// set default document font, size, color, and orientation
			_docx_set_color(dh, "000000")
			_docx_set_font(dh, "Calibri")
			_docx_set_size(dh, 20)
			//title page
			_docx_paragraph_new(dh, "")
			_docx_paragraph_set_textsize(dh, 30)
			_docx_paragraph_add_text(dh, "Genotyping Array Quality Control Report")
			_docx_paragraph_new(dh, "")
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "This is a genotype-array-quality control report generated automatically using the plink command: ")
			_docx_paragraph_new(dh, "")
			_docx_paragraph_set_font(dh, "Consolas")
			_docx_paragraph_add_text(dh, "genotypeqc, param(<parameter-file>) depend(<dependency-file>)")
			_docx_paragraph_new(dh, "")
			_docx_paragraph_set_font(dh, "Calibri")
			_docx_paragraph_add_text(dh, "available at https://github.com/ricanney")
			_docx_paragraph_add_linebreak(dh)
			//paragraph #1
			_docx_paragraph_new(dh, "")
			_docx_paragraph_set_halign(dh, "left")
			_docx_paragraph_set_font(dh, "Consolas")
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, `"# ======================================================================="')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# Author:     Richard Anney"')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# Institute:  Cardiff University"')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# E-mail:     AnneyR@cardiff.ac.uk"')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# Date:       12th July 2017"')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# Copyright 2017 Richard Anney"')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# ======================================================================="')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# Permission is hereby granted, free of charge, to any person obtaining a "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# copy of this software and associated documentation files (the "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# "Software"), to deal in the Software without restriction, including  "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# without limitation the rights to use, copy, modify, merge, publish, "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# distribute, sublicense, and/or sell copies of the Software, and to  "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# permit persons to whom the Software is furnished to do so, subject to "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# the following conditions:"')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"#"')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# The above copyright notice and this permission notice shall be included "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# in all copies or substantial portions of the Software."')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"#"')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE "')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, `"#########################################################################"')
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_linebreak(dh)
			//table #1 - dataset information
			_docx_paragraph_new(dh, "")
			_docx_paragraph_set_halign(dh, "left")
			_docx_paragraph_set_font(dh, "Consolas")
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "===================================================================")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Date Completed: .............. $S_DATE $S_TIME")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Quality Control Version: ..... version-4")
			_docx_paragraph_add_linebreak(dh) 
			_docx_paragraph_add_text(dh, "Input File: .................. ${data_input}")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Input Array: ................. $arrayType")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Output File ($buildType): ....... ${data_input}-qc-v4")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Input Total Markers: ......... $count_markers_1")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Input Total Individuals: ..... $count_individ_1")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Output Total Markers ......... $count_markers_3")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Output Total Individuals ..... $count_individ_3")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "CEU/ TSI-like Individuals .... $count_European")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "===================================================================")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "THRESHOLDS: maximum missing by individual ................ $mind")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "THRESHOLDS: maximum missing by marker .................... $geno2")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "THRESHOLDS: minimum minor allele frequency ............... $maf")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "THRESHOLDS: maximum hardy-weinberg deviation (-log10(p)) . 10e-$hwep")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "THRESHOLDS: maximum heterozygosity deviation (std.dev) ... $hetsd" )
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "THRESHOLDS: Rounds of QC ................................. $rounds")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "===================================================================")
			_docx_paragraph_add_linebreak(dh)
			// plots # 1
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "GENOME BUILD and ARRAY: By default, the genome-build of the output files are hg19+1. The input array types are based on overlap with our reference data (derived from http://www.well.ox.ac.uk/~wrayner/strand/) ")
			_docx_paragraph_add_text(dh, "The best matched ARRAY is ${arrayType}: Jaccard Index ${Jaccard}")
			_docx_paragraph_new(dh, "")
			_docx_paragraph_add_text(dh, "Array match of ${data_input}-qc-v4")
			_docx_image_add(dh,"${output}.ArrayMatch.png")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Genome Build of ${data_input}")
			_docx_image_add(dh,"${input}.hg_buildMatch.png")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "Genome Build of ${data_input}-qc-v4")
			_docx_image_add(dh,"${output}.hg_buildMatch.png")
			// plots # 1a
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "UPDATING BUILD AND RENAMING SNPs: The HRC reference data is used to update the build and rename markers that do not have rsid. On occasion (more-often-than-we-would-like!) genotypes from a labelled rsid are also incompatible with the HRC reference. ")
			_docx_paragraph_add_text(dh, "The following 2 plots show pre- and post-clean allele-frequency plots for non-rsid and the final rsid match. Markers with > 10% allele-frequency differences are dropped. FUTURE WORK: this is going to be impacted by ancestry of the HRC and we may be excluding high FST markers erroneously.")
			_docx_paragraph_new(dh, "")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "round-1: Allele frequencies for markers mapped by location" )
			_docx_image_add(dh,"tempfile-allele-frequency-01.png")
			_docx_paragraph_add_linebreak(dh)
			_docx_paragraph_add_text(dh, "round-2: Allele frequencies for markers mapped by name" )
			_docx_image_add(dh,"tempfile-allele-frequency-02.png")	
			// plots # 2
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "ANCESTRY: These plots are created using the  --pca flag in plink2. This code identifies a subset of individuals who are European-like, based on similarity to hapmap reference genotypes. Similarity is calculated using ancestry-informative-markers (derived from hapmap markers showing Fst > 0.5 between hapmap ancestries. ")
			_docx_paragraph_new(dh, "")
			_docx_image_add(dh,"tempfile-hapmap-final-aims-9_eigenvec_ALL.png")
			_docx_image_add(dh,"tempfile-hapmap-final-aims-9_eigenvec_EUR.png")
			// plots # 3
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "CHROMOSOME DISTRIBUTION: These plots show the distribution of markers by chromosome. They are useful -sanity-checks- for data to make sure all chromosomes were included in a final report download. ")
			_docx_paragraph_new(dh, "")
			_docx_image_add(dh,"tempfile-final_chrHist.png")
			//plots # 4	
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "REALTEDNESS: These plots show the relatedness as defined by the kinship matrix. The plots show pre- post- QC and the distribution if the *.related individuals are excluded from the final dataset. By default, duplicates, 2nd and 3rd degree relatives are removed from the dataset. ")
			_docx_paragraph_new(dh, "")
			_docx_image_add(dh,"tempfile-final-KIN0_1.png")
			_docx_image_add(dh,"tempfile-final-KIN0_2.png")
			// plot # 5
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "HETEROZYGOSITY: These plots are created using the --het flag in plink. The --het flag computes observed and expected autosomal homozygous genotype counts for each sample, and reports method-of-moments F coefficient estimates (i.e. ([observed hom. count] - [expected count]) / ([total observations] - [expected count])). Excessive heterozygosity can be indicative of mixed DNA samples, excessive homozygosity can be indicative of poor DNA quality and allele drop-out. In this pipeline, we flag individuals whose rate of heterozygosity deviates from the population (of genotyping array) mean. Importantly, heterozygosity rates differ (on genotyping arrays) within individuals of differing ancestries. Where there are mixed ancestry samples, we might consider relaxing the threshold to exclude only extreme deviations.")
			_docx_paragraph_new(dh, "")
			_docx_image_add(dh,"tempfile-final-HET.png")
			// plot # 6				
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)	
			_docx_paragraph_add_text(dh, "HARDY-WEINBERG-EQUILIBRIUM: These plots are created using the --hardy flag in plink. The --hardy flag writes a list of genotype-counts and Hardy-Weinberg equilibrium exact test statistics to plink.hwe When the samples are case/control, three separate sets of Hardy-Weinberg equilibrium statistics are computed, one considering both cases and controls, one considering only cases, and one considering only controls. These are distinguished by 'ALL', 'AFF', and 'UNAFF' in the TEST column, respectively. By default, only founders are considered when generating this report, so if you are working with e.g. a sibling-only dataset, you won't get any results. Use --nonfounders to include everyone. The implementation of this pipeline flags all SNPs if there is significant HW deviation. Importantly, less stringent thresholds are applied to the case samples as by default they may incur HW bias due to the disease selection.")
			_docx_paragraph_new(dh, "")
			_docx_image_add(dh,"tempfile-final-HWE.png")
			// plot # 7				
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "MISSINGNESS (BY-INDIVIDUAL): These plots are created using the --missing flag in plink. The missing --missing produces sample-based and variant-based missing data reports. ")
			_docx_paragraph_new(dh, "")
			_docx_image_add(dh,"tempfile-final-IMISS.png")	
			// plot # 8				
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)	
			_docx_paragraph_add_text(dh, "MISSINGNESS (BY-VARIANT): These plots are created using the --missing flag in plink. The --missing flag produces sample-based and variant-based missing data reports. We apply two --geno parameters during the QC pipeline to remove firstly excessive missing then completing the pipeline with a stricter limit.")
			_docx_paragraph_new(dh, "")
			_docx_image_add(dh,"tempfile-final-LMISS.png")	
			// plot # 9
			_docx_paragraph_new(dh, "")
			_docx_add_pagebreak(dh,)
			_docx_paragraph_set_textsize(dh, 20)
			_docx_paragraph_add_text(dh, "MINOR ALLELE FREQUENCY: These plots are created using the --freq flag in plink. Nonfounders are normally excluded from these counts/frequencies; use --nonfounders to change this ")
			_docx_image_add(dh,"tempfile-final-FRQ.png")
			// export file
			_docx_save(dh, "tempfile-final-quality-control-report.docx", 1)
			_docx_close(dh)
			end
			}	
		}			
	qui { // create meta-log
		qui { // notes
			/*
			#########################################################################
			# this code generates the flat-text meta-log file
			# 
			# version history
			# =======================================================================
			# -
			# -
			#########################################################################
			*/
			}
		qui { // make meta log
			noi di"-make a meta-log file (flat txt file)"
			clear
			input strL v1
			/*1*/		 	 `"#########################################################################"'
			/*2*/				`"# Genotyping Array Quality Control Report from STATA command genotypeqc"'                                                                
			/*3*/				`"# available from https://github.com/ricanney"'                                                                
			/*4*/				`"#########################################################################"'
			/*5*/				`"# Author:     Richard Anney"'
			/*6*/				`"# Institute:  Cardiff University"'
			/*7*/				`"# E-mail:     AnneyR@cardiff.ac.uk"'
			/*8*/				`"# Date:       12th July 2017"'
			/*9*/				`"# Copyright 2017 Richard Anney"'
			/*10*/			`"# ======================================================================="'
			/*11*/			`"# Permission is hereby granted, free of charge, to any person obtaining a "'
			/*12*/			`"# copy of this software and associated documentation files (the "'
			/*13*/			`"# "Software"), to deal in the Software without restriction, including  "'
			/*14*/			`"# without limitation the rights to use, copy, modify, merge, publish, "'
			/*15*/			`"# distribute, sublicense, and/or sell copies of the Software, and to  "'
			/*16*/			`"# permit persons to whom the Software is furnished to do so, subject to "'
			/*17*/			`"# the following conditions:"'
			/*18*/			`"#"'
			/*19*/			`"# The above copyright notice and this permission notice shall be included "'
			/*20*/			`"# in all copies or substantial portions of the Software."'
			/*21*/			`"#"'
			/*22*/			`"# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS "'
			/*23*/			`"# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF "'
			/*24*/			`"# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. "'
			/*25*/			`"# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY "'
			/*26*/			`"# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, "'
			/*27*/			`"# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE "'
			/*28*/			`"# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."'
			/*29*/			`"#########################################################################"'
			/*30*/			`""'
			/*31*/			`"#########################################################################"'
			/*32*/			`"# Run Information"'                                                                
			/*33*/			`"#########################################################################"'
			/*34*/			`"# Date ...................................................... "'
			/*35*/			`"# ======================================================================="'
			/*36*/			`"# Input File ................................................ "'
			/*37*/			`"# Input Array (Approximated) ................................ "'
			/*38*/			`"# Input Total Markers ....................................... "'
			/*39*/			`"# Input Total Individuals ................................... "'
			/*40*/			`"# ======================================================================="'
			/*41*/			`"# Output File ............................................... "'
			/*42*/			`"# Output Genome Build ....................................... "'
			/*43*/			`"# Output Total Markers ...................................... "'
			/*44*/			`"# Output Total Individuals .................................. "'
			/*45*/			`"# ======================================================================="'
			/*46*/			`"# THRESHOLD - maximum missing by individual ................. "'
			/*47*/			`"# THRESHOLD - missing by marker ............................. "'
			/*48*/			`"# THRESHOLD - minimum minor allele frequency ................ "'
			/*49*/			`"# THRESHOLD - maximum hardy-weinberg deviation (-log10(p)) .. "'
			/*50*/			`"# THRESHOLD - maximum heterozygosity deviation (std.dev) .... "'
			/*51*/			`"# THRESHOLD - rounds of QC .................................. "'
			/*52*/			`"# THRESHOLD - europeans ..................................... "'
			/*53*/			`"#########################################################################"'
				end
				gen v2 = ""
				replace v2 = "$S_DATE $S_TIME"     in 34 
				
				replace v2 = "$data_input"         in 36
				replace v2 = "$arrayType"          in 37 
				replace v2 = "$count_markers_1"    in 38
				replace v2 = "$count_individ_1"    in 39
				
				replace v2 = "${data_input}-qc-v4" in 41
				replace v2 = "$buildType"          in 42
				replace v2 = "$count_markers_3"    in 43 
				replace v2 = "$count_individ_3"    in 44 

				replace v2 = "$mind"               in 46
				replace v2 = "$geno2"              in 47 
				replace v2 = "$maf"                in 48 
				replace v2 = "10e-$hwep"           in 49 
				replace v2 = "$hetsd"              in 50 
				replace v2 = "$rounds"             in 51
				replace v2 = "$count_European"     in 52
				outsheet using tempfile-final.meta-log, delim(" ") non noq replace
				}
		}
	qui { // save files
		qui { // notes
			/*
			#########################################################################
			# this code saves and moves the output information and code 
			# 
			# version history
			# =======================================================================
			# - update folder location for archived code
			# -
			#########################################################################	
			*/
			}
		qui { // move files
			noi di"-copying datasets to $folder"
			!copy "tempfile-final-quality-control-report.docx"   "${output}.quality-control-report.docx"
			!copy "tempfile-hapmap-final-aims-9003.keep-ceuLike" "${output}.keep-ceuLike"
			foreach file in meta-log keep-ceuLike bed bim fam {
				!copy "tempfile-final.`file'"                      "${output}.`file'"
				}
			}	
		qui { // clean up
			!del tempfile* *.gph
			}
		}
	di"done!"
	end;
