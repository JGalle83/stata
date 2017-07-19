/*
#########################################################################
# _sub_genotypeqc_report
# subroutine for genotypeqc
# command: _sub_genotypeqc_report
# =======================================================================
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 12th July 2017
#########################################################################
*/
program _sub_genotypeqc_report
syntax  
end


		noi di in green"#########################################################################"
		noi di in green"# genotypeqc                                                             "
		noi di in green"# version:       1.0                                                     "
		noi di in green"# Creation Date: 17July2017                                              "
		noi di in green"# Author:        Richard Anney (anneyr@cardiff.ac.uk)                    "
		noi di in green"#########################################################################"
		
		
		
	noi di in green"...creating quality-control-report.docx"
	global toc    "$S_DATE $S_TIME"
	//open document" 
	mata:
	dh = _docx_new()
	// set default document font, size, color, and orientation
	_docx_set_color(dh, "000000")
	_docx_set_font(dh, "Calibri")
	_docx_set_size(dh, 20)

	// TITLE PAGE
	_docx_paragraph_new(dh, "")
	_docx_paragraph_set_textsize(dh, 30)
	_docx_paragraph_add_text(dh, "Genotyping Array Quality Control Report")
	_docx_paragraph_new(dh, "")
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_set_font(dh, "Consolas")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# genotypeqc                                                                        #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# version .................... 1.0                                                  #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Creation Date .............. 17July2017                                           #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Author ..................... Richard Anney (anneyr@cardiff.ac.uk)                 #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Downloaded from ............ https://github.com/ricanney                          #")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Run Date ..................... $S_DATE $S_TIME")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Quality Control Version: ..... version-4")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# Input File: .................. ${data_input}")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Input Array: ................. $arrayType")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Output File ($buildType): ....... ${data_input}-qc-v4")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Input Total Markers: ......... $count_markers_1")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Input Total Individuals: ..... $count_individ_1")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Output Total Markers ......... $count_markers_3")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Output Total Individuals ..... $count_individ_3")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# CEU/ TSI-like Individuals .... $count_European")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# THRESHOLDS: maximum missing by individual ................ $mind")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# THRESHOLDS: maximum missing by marker .................... $geno2")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# THRESHOLDS: minimum minor allele frequency ............... $maf")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# THRESHOLDS: maximum hardy-weinberg deviation (-log10(p)) . 10e-$hwep")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# THRESHOLDS: maximum heterozygosity deviation (std.dev) ... $hetsd" )
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# THRESHOLDS: Rounds of QC ................................. $rounds")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)

	// REPORTING GENOME BUILD 
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# REPORTING GENOME BUILD                                                            #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# This program converts the genome build to hg19+1. Prior to conversion it checks   #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# the current build against a reference file.                                       #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# GENOME BUILD OF ${data_input}")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"${input}.hg_buildmatch.png")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# GENOME BUILD OF ${data_input}-qc-v4")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"${output}.hg_buildmatch.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")

	// REPORTING ARRAY
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)	
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# REPORTING MOST LIKELY ARRAY                                                       #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# This program assesses the genotype-array against a panel of known genotyping      #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# arrays.                                                                           #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# These were derived from data from http://www.well.ox.ac.uk/~wrayner/strand/).     #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# IMPORTANTLY, these are only the best estimates based on overlap co-efficients     #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# The best matched for ${data_input} is ${arrayType} ")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# Jaccard Index for ${arrayType} = ${Jaccard}")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	
	_docx_image_add(dh,"${output}.ArrayMatch.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	
	_docx_paragraph_add_text(dh, "Genome Build of ${data_input}")
	_docx_image_add(dh,"${input}.hg_buildmatch.png")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "Genome Build of ${data_input}-qc-v4")
	_docx_image_add(dh,"${output}.hg_buildmatch.png")

	// REPORTING ALLELE-FREQUENCY DIFFERENCES
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# REPORTING ALLELE_FREQUENCY DISCREPANCIES                                          #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# As part of the quality-control protocol, the imported variant names are converted #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# to rsid. This is achieved by mapping to a 1000-genomes dataset as a reference. A  #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# more sophisticated approach may be implemented in future. The mapping is based on #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# chromosome location and genotype (based on compatable UIPAC genotype codes, for   #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# example R genotypes are compatable with R or Y). The program runs a sanity-check  #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# for the merge using allele-frequencies; after matching to strand/ allele we can   #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# observe some discrepancies between the allele frequencies reported in the test    #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# and reference dataset. As a precaution markers with > 10% allele-frequency        #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# differences are dropped                                                           #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	
	_docx_image_add(dh,"tempfile-module-2-allele-frequency-check.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	

	// REPORTING ALLELE-FREQUENCY DIFFERENCES
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING ANCESTRY                                                               #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# As part of the quality-control protocol, we define a subset of individuals who    #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# are defined as European-like. This is based on similarity of the genotypes to     #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# hapmap reference genotypes. In this instance we flag individuals whose PCs for    #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# the top-3 PCs are no more than 2.5 standard deviations from that reported by the  #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# CEU and TSI hapmap3 populations. Individuals are not removed, but flagged in the  #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# *.keep-ceuLike file. This can be used directly in plink using the --keep flag.    #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# Below we report two panels of PCA plots (PC Scree-Plot; PC1 v PC2; PC1 v PC3;     #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# PC2 v PC3). The top panel includes all indiciduals, whereas the bottom panel      #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# focuses on the European-like regions around the CEU and TSI populations.")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	
	_docx_image_add(dh,"tempfile-module-7-pca.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	
	_docx_image_add(dh,"tempfile-module-7-pca-eur.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	

	// REPORTING CHROMOSOME DIFFERENCES
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "CHROMOSOME DISTRIBUTION: These plots show the distribution of markers by chromosome. They are useful -sanity-checks- for data to make sure all chromosomes were included in a final report download. ")
	_docx_paragraph_new(dh, "")
	_docx_image_add(dh,"tempfile-module-8-final-chromosomes.png")
	//plots # 4	
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "REALTEDNESS: These plots show the relatedness as defined by the kinship matrix. The plots show pre- post- QC and the distribution if the *.related individuals are excluded from the final dataset. By default, duplicates, 2nd and 3rd degree relatives are removed from the dataset. ")
	_docx_paragraph_new(dh, "")
	_docx_image_add(dh,"tempfile-module-8-KIN0_1.png")
	_docx_image_add(dh,"tempfile-module-8-KIN0_2.png")
	// plot # 5
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "HETEROZYGOSITY: These plots are created using the --het flag in plink. The --het flag computes observed and expected autosomal homozygous genotype counts for each sample, and reports method-of-moments F coefficient estimates (i.e. ([observed hom. count] - [expected count]) / ([total observations] - [expected count])). Excessive heterozygosity can be indicative of mixed DNA samples, excessive homozygosity can be indicative of poor DNA quality and allele drop-out. In this pipeline, we flag individuals whose rate of heterozygosity deviates from the population (of genotyping array) mean. Importantly, heterozygosity rates differ (on genotyping arrays) within individuals of differing ancestries. Where there are mixed ancestry samples, we might consider relaxing the threshold to exclude only extreme deviations.")
	_docx_paragraph_new(dh, "")
	_docx_image_add(dh,"tempfile-module-8-HET.png")
	// plot # 6	
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)	
	_docx_paragraph_add_text(dh, "HARDY-WEINBERG-EQUILIBRIUM: These plots are created using the --hardy flag in plink. The --hardy flag writes a list of genotype-counts and Hardy-Weinberg equilibrium exact test statistics to plink.hwe When the samples are case/control, three separate sets of Hardy-Weinberg equilibrium statistics are computed, one considering both cases and controls, one considering only cases, and one considering only controls. These are distinguished by 'ALL', 'AFF', and 'UNAFF' in the TEST column, respectively. By default, only founders are considered when generating this report, so if you are working with e.g. a sibling-only dataset, you won't get any results. Use --nonfounders to include everyone. The implementation of this pipeline flags all SNPs if there is significant HW deviation. Importantly, less stringent thresholds are applied to the case samples as by default they may incur HW bias due to the disease selection.")
	_docx_paragraph_new(dh, "")
	_docx_image_add(dh,"tempfile-module-8-HWE.png")
	// plot # 7	
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "MISSINGNESS (BY-INDIVIDUAL): These plots are created using the --missing flag in plink. The missing --missing produces sample-based and variant-based missing data reports. ")
	_docx_paragraph_new(dh, "")
	_docx_image_add(dh,"tempfile-module-8-IMISS.png")	
	// plot # 8	
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)	
	_docx_paragraph_add_text(dh, "MISSINGNESS (BY-VARIANT): These plots are created using the --missing flag in plink. The --missing flag produces sample-based and variant-based missing data reports. We apply two --geno parameters during the QC pipeline to remove firstly excessive missing then completing the pipeline with a stricter limit.")
	_docx_paragraph_new(dh, "")
	_docx_image_add(dh,"tempfile-module-8-LMISS.png")	
	// plot # 9
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "MINOR ALLELE FREQUENCY: These plots are created using the --freq flag in plink. Nonfounders are normally excluded from these counts/frequencies; use --nonfounders to change this ")
	_docx_image_add(dh,"tempfile-module-8-FRQ.png")
	// export file
	_docx_save(dh, "tempfile-module-8-quality-control-report.docx", 1)
	_docx_close(dh)
	end
	
