/*
#########################################################################
# gtqc_report
# subroutine for genotypeqc
# command: gtqc_report
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
program gtqc_report
syntax  
end

	noi di in green"...creating quality-control-report.docx"
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
	_docx_paragraph_add_text(dh, "genotypeqc, param(<parameter-file>)")
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
	_docx_paragraph_add_text(dh, "UPDATING BUILD AND RENAMING SNPs: The 1000-genomes reference data is used to update the build and rename markers that do not have rsid. ")
	_docx_paragraph_add_text(dh, "The following plot show allele-frequency plots for test versus reference. Markers with > 10% allele-frequency differences are dropped. ")
	_docx_paragraph_new(dh, "")
	_docx_paragraph_add_linebreak(dh)
	_docx_paragraph_add_text(dh, "Allele frequencies for markers mapped to reference " )
	_docx_image_add(dh,"tempfile-module-2-allele-frequency-check.png")
	// plots # 2
	_docx_paragraph_new(dh, "")
	_docx_add_pagebreak(dh,)
	_docx_paragraph_set_textsize(dh, 20)
	_docx_paragraph_add_text(dh, "ANCESTRY: These plots are created using the  --pca flag in plink2. This code identifies a subset of individuals who are European-like, based on similarity to hapmap reference genotypes. Similarity is calculated using ancestry-informative-markers (derived from hapmap markers showing Fst > 0.5 between hapmap ancestries. ")
	_docx_paragraph_new(dh, "")
	_docx_image_add(dh,"tempfile-module-7-pca.png")
	_docx_image_add(dh,"tempfile-module-7-pca-eur.png")
	// plots # 3
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
	
