/*
#########################################################################
# graphmiami
# a command to create a publication quality miami plot from overlapping regions of a gwas 
# assumes both input files have rsid and p as outcome variable
# 
# command: graphmiami, gwas1() gwas2() title1() title2() hg19()
# options: 
#
# dependencies: colorscheme
# net install colorscheme, from(https://github.com/matthieugomez/stata-colorscheme/raw/master/)
# =======================================================================
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 10th September 2015
#########################################################################
*/

program graphmiami
syntax , gwas1(string asis) gwas2(string asis) title1(string asis) title2(string asis) region(string asis) exons(string asis) ref(string asis)

di in white"#########################################################################"
di in white"# graphmiami - version 1.0 04Aug2016 richard anney                      #"
di in white"#########################################################################"
di in white"# A command to create a publication quality miami plot from overlapping #"
di in white"# regions of a gwas.                                                    #"
di in white"# The program assumes both input files have rsid and p as outcome       #"
di in white"# variable.                                                             #"
di in white"#                                                                       #"
di in white"# titles for each gwas can be added                                     #"
di in white"# exon locations are derived from Homo_sapiens.GRCh37.87.gtf_exon.dta   #"
di in white"# Homo_sapiens.GRCh37.87.gtf_exon.dta created using                     #"
di in blue "# https://github.com/ricanney/stata/blob/master/code/get-ensembl-gtf.do #"
di in white"#                                                                       #"
di in white"# region to plot format is bed format: chr#:start-end                 #"
di in white"#                                                                       #"
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"

di in white"# > checking location of files"
qui { 
	capture confirm file "`gwas1'"
	if _rc==0 {
		noi di in green"# >> located `gwas1'"
		noi di in green"# >> title:  `title1'"
		}
	else {
		noi di in red"# >> cannot locate `gwas1' ... exiting"
		exit
		}
	capture confirm file "`gwas2'"
	if _rc==0 {
		noi di in green"# >> located `gwas2'"
		noi di in green"# >> title:  `title2'"
		}
	else {
		noi di in red"# >> cannot locate `gwas1' ... exiting"
		exit
		}
	capture confirm file "`exons'"
	if _rc==0 {
		noi di in green"# >> located `exons'"
		}
	else {
		noi di in red"# >> cannot locate `exons' ... exiting"
		exit
		}
	capture confirm file "`ref'"
	if _rc==0 {
		noi di in green"# >> located `ref'"
		}
	else {
		noi di in red"# >> cannot locate `ref' ... exiting"
		exit
		}
	}
di in white"# > setting region to plot"
qui { 
	clear
	set obs 1
	gen a = "`region'"
	split a,p("chr"":""-")
	keep a2-a4
	sxpose, clear
	gen a = ""
	replace a = "global chr " + _v in 1
	replace a = "global start " + _v in 2
	replace a = "global stop " + _v in 3
	outsheet a using tmp.do, non noq replace
	do tmp.do
	di in white"# >> the plot region will be;"
	di in white"# >> chromosome ${chr}"
	di in white"# >> from ${start}"
	di in white"# >> to ${stop}"
	}
di in white"# > plot genes in region"
qui { 
	graphgene, chr(${chr}) start(${start}) end(${stop}) gene_file(`exons')
	}
di in white"# > loading rsid and p from `gwas1'"
qui { 
	global tmp1 "`gwas1'"
	global tmp2 "`gwas2'"
	global tmp3 "`ref'"
	use rsid p using ${tmp1}, clear
	gen gwas1_log10p = -log10(p)
	keep rsid gwas1_log10p
	save tmp1.dta,replace
	}
di in white"# > merging with `gwas2'"
qui {
	use rsid p using ${tmp2}, clear
	gen gwas2_log10p = log10(p)
	keep rsid gwas2_log10p
	merge 1:1 rsid using tmp1.dta
	keep if _m == 3
	keep rsid gwas1_log10p gwas2_log10p
	}
di in white"# > merging with `ref'"
qui {
	rename rsid snp
	merge 1:1 snp using ${tmp3}
	keep if _m == 3
	}
di in white"# > plot regions to tmpMiami.gph"
qui { 
	keep if chr == ${chr}
	drop if bp < ${start}
	drop if bp > ${stop}
	append using temp-graphgene-data.dta
	for var gwas1_log10p : replace X = 15  if X > 15
	for var gwas2_log10p : replace X = -15 if X < -15
	for var gwas2_log10p : replace X = X -20
	sum order
	gen _x = 15/(`r(max)'+1)
	replace order = (order * _x) - _x
	sum order
	replace order = order -4 -`r(max)'
	sort bp
	gen dx_1 = "`title1'" in 1 
	gen dx_2 = "`title2'" in 1 
	gen dx_1p = 15
	gen dx_2p = -35
	tw scatter gwas1_log10p bp, mfc("107 174 214") mlc("107 174 214") m(O)  ///
	|| scatter gwas2_log10p bp, mfc("203 024 029") mlc("0203 024 029")  m(O) ///
	|| scatter dx_1p bp, m(none) mlabel(dx_1) mlabpos(3) mlabcolor(black)   ///
	|| scatter dx_2p bp, m(none) mlabel(dx_2) mlabpos(3) mlabcolor(black)   ///
	|| rspike start end order , hor lcolor("035 139 069") lwidth(vvthin) ///
	|| rspike _txs _txe order , hor lcolor("035 139 069") lwidth(*10) ///
	|| scatter order start if pos == 11  , msymbol(i) mlabel(symbol) mlabpos(11) mlabcolor(black) mlabsize(vsmall) 			///
	|| scatter order end   if pos == 1   , msymbol(i) mlabel(symbol) mlabpos(1 ) mlabcolor(black) mlabsize(vsmall)      ///
	ylab(-35"15" -30"10" -25"5" -20"0" 0"0" 5"5" 10"10" 15"15" ) legend(off) ytitle("-log10(P)") xtitle("Chromosome ${chr}") yline(7.2) yline(-27.2) nodraw saving(tmpMiami.gph, replace)
	}
di in white"# > cleaning"
qui {
	erase temp-graphgene.gph
	erase temp-graphgene-data.dta
	erase tmp.do
	erase tmp1.dta
	}
clear 
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;
	
