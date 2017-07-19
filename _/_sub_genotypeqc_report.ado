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

	noi di in green"...creating quality-control-report.docx"
	global toc    "$S_DATE $S_TIME"
	//open document" 
	mata:
	dh = _docx_new()
	// set default document font, size, color, and orientation
	_docx_set_color(dh, "000000")
	_docx_set_font(dh, "Consolas")
	_docx_set_size(dh, 20)

	// TITLE PAGE
	_docx_paragraph_new(dh, "")
	_docx_paragraph_set_textsize(dh, 30)
	_docx_paragraph_add_text(dh, "Genotyping Array Quality Control Report")
	_docx_paragraph_new(dh, "")
	_docx_paragraph_set_textsize(dh, 20)
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
	_docx_paragraph_add_linebreak(dh)
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
	_docx_image_add(dh,"${input}.hg-buildmatch.png")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# GENOME BUILD OF ${data_input}-qc-v4")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"${output}.hg-buildmatch.png")
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
	_docx_image_add(dh,"${input}.hg-buildmatch.png")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	
	_docx_paragraph_add_text(dh, "Genome Build of ${data_input}-qc-v4")
	_docx_image_add(dh,"${output}.hg-buildmatch.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	


	// REPORTING ALLELE-FREQUENCY DIFFERENCES
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING ALLELE_FREQUENCY DISCREPANCIES                                          #")
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

	// DISPLAYING ANCESTRY DISTRIBUTIONS   
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING ANCESTRY DISTRIBUTIONS                                                 #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# These plots are created from the *.eigenval files created using the --pca flag in #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# plink. As part of the quality-control protocol, we define a subset of individuals #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# who are defined as European-like. This is based on similarity of the genotypes to #")
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
	_docx_paragraph_add_text(dh, "# focuses on the European-like regions around the CEU and TSI populations.          #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	
	_docx_image_add(dh,"tempfile-module-7-pca.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	
	_docx_image_add(dh,"tempfile-module-7-pca-eur.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")	

	// DISPLAYING CHROMOSOME DISTRIBUTION  
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING CHROMOSOME DISTRIBUTION                                                #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# The following plots show the distribution of markers by chromosome. This is a     #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# useful -sanity-check- for data to make sure all chromosomes were included in a    #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# final report download.                                                            #")	
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")		
	_docx_image_add(dh,"tempfile-module-8-final-chromosomes.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")		

	// REPORTING RELATEDNESS
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING RELATEDNESS                                                            #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# These plots are created from the *.kin0 files created using the --make-king-table #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# flag in plink2. The following plots show relatedness as defined by this kinship   #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# matrix. Approximation of kinship thresholds (duplicates, 2nd and 3rd degree       #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# relatives) are given by horizontal red lines. By default, duplicates, 2nd and 3rd #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# degree relatives are removed from the dataset. First-degree relatives (parent-    #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# child and sibling-pairs) are retained.                                            #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"tempfile-module-8-KIN0_1.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"tempfile-module-8-KIN0_2.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")


	// REPORTING HETEROZYGOSITY
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING HETEROZYGOSITY                                                         #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# These plots are created from the *.het files created using the --het flag in      #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# plink. The --het flag computes observed and expected autosomal homozygous         #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# genotype counts for each sample, and reports method-of-moments F coefficient      #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# estimates i.e.                                                                    #")
	_docx_paragraph_add_linebreak(dh)	 
	_docx_paragraph_add_text(dh, "#              ([observed hom. count] - [expected count])                           #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "#              ----------------------------------------                             #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "#               ([total observations] - [expected count])                           #")
	_docx_paragraph_add_linebreak(dh)	 
	_docx_paragraph_add_text(dh, "#. Excessive heterozygosity can be indicative of mixed DNA samples, excessive       #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# homozygosity can be indicative of poor DNA quality and allele drop-out. In this   #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# pipeline, we flag individuals whose rate of heterozygosity deviates from the      #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# population (of genotyping array) mean. Importantly, heterozygosity rates differ   #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# (on genotyping arrays) within individuals of differing ancestries. Where there    #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# are mixed ancestry samples, we might consider relaxing the threshold to exclude   #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# only extreme deviations.                                                          #")
	_docx_paragraph_new(dh, "")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"tempfile-module-8-HET.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")

	// REPORTING HARDY-WEINBERG EQUILIBRIUM
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING HARDY-WEINBERG-EQUILIBRIUM                                             #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# These plots are created using the --hardy flag in plink. The --hardy flag writes  #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# a list of genotype-counts and Hardy-Weinberg equilibrium exact test statistics to #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# plink.hwe. Importantly, we apply less stringent thresholds than in other routines #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# as case samples, by design, may incur HW bias due to disease selection.           #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"tempfile-module-8-HWE.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
		
	// REPORTING MISSINGNESS (BY-INDIVIDUAL)
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING MISSINGNESS (BY-INDIVIDUAL)                                            #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# These plots are created using the --missing flag in plink. The missing --missing  #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# produces sample-based and variant-based missing data reports.                     #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"tempfile-module-8-IMISS.png")	
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	
	// REPORTING MISSINGNESS (BY-VARIANT)
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING MISSINGNESS (BY-VARIANT)                                               #")
	_docx_paragraph_add_linebreak(dh)  
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# These plots are created using the --missing flag in plink. The missing --missing  #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# produces sample-based and variant-based missing data reports. We apply two --geno #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# parameters during the QC pipeline to remove firstly excessive missing then        #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# completing the pipeline with a stricter limit                                     #")
	_docx_paragraph_add_linebreak(dh) 
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"tempfile-module-8-LMISS.png")	
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	
	// REPORTING MISSINGNESS (BY-VARIANT)
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "# DISPLAYING MINOR ALLELE FREQUENCY                                                 #")
	_docx_paragraph_add_linebreak(dh)  
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# These plots are created using the --freq flag in plink. Nonfounders are normally  #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# excluded from these counts/frequencies; we use --nonfounders to change this.      #")
	_docx_paragraph_add_linebreak(dh)	
	_docx_paragraph_add_text(dh, "# ================================================================================= #")
	_docx_image_add(dh,"tempfile-module-8-FRQ.png")
	_docx_paragraph_add_text(dh, "# ================================================================================= #")

	// SAVING DOCX
	_docx_save(dh, "tempfile-module-8-quality-control-report.docx", 1)
	_docx_close(dh)
	end
	
