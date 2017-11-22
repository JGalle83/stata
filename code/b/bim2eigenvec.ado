/*
#########################################################################
# bim2eigenvec
# a command to generate ancestry informative eigenvectors from plink-format 
# files) 
#
# command: bim2eigenvec, bim(<FILENAME>)
# options: 
# 			pc(num) .....number of pcs to calculate - default = 10
# notes: the filename does not require the .bim to be added
# =======================================================================
# Author:     Richard Anney
# Institute:  Cardiff University
# E-mail:     AnneyR@cardiff.ac.uk
# Date:       10th September 2015
#########################################################################
*/

program bim2eigenvec
syntax , bim(string asis) [pc(real 10)]

di in white"#########################################################################"
di in white"# bim2eigenvec               "
di in white"# version:  1a              "
di in white"# Creation Date: 25may2017            "
di in white"# Author:  Richard Anney (anneyr@cardiff.ac.uk)     "
di in white"#########################################################################"
di in white"# This is a script to derive from a bim file (and matching bed fam) the "
di in white"# ancestry informative eigenvectors. "
di in white"# The script removes long-range LD regions as described in; "
di in white"# Long-Range LD Can Confound Genome Scans in Admixed Populations. Alkes "
di in white"# Price, Mike Weale et al., The American Journal of Human Genetics 83, "
di in white"# 127 - 147, July 2008              "
di in white"# -----------------------------------------------------------------------"
di in white"# Dependencies : plink_v1.9 via ${plink}         "
di in white"# Dependencies : plink_v2   via ${plink2}         "
di in white"# Dependencies : tabbed.pl  via ${tabbed}         "
di in white"# Dependencies : bim2ldexclude       "
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
di in white"# > check path of plink *.bim  and *.bed file is true"
qui { // *.bim
	capture confirm file "`bim'.bim"
	if _rc==0 {
		noi di in green"# >> `bim'.bim found "
		}
	else {
		noi di in red"# >> `bim'.bim not found "
		noi di in red"# >> help: do not include .bim in filename  "
		noi di in red"# >> exiting "
		exit
		}
	}
qui { // *.bed
	capture confirm file "`bim'.bed"
	if _rc==0 {
		noi di in green"# >> `bim'.bed found "
		}
	else {
		noi di in red"# >> `bim'.bed not found "
		noi di in red"# >> help: do not include .bim in filename  "
		noi di in red"# >> exiting "
		exit
		}
	}
di in white"# > check path of dependent software is true                            "
qui { // plink v1.9
	capture confirm file "$plink"
	if _rc==0 {
		noi di in green"# >> plink v1.9+ exists and is correctly assigned as  $plink"
		}
	else {
		noi di in red"# >> plink v1.9 does not exists; download executable from https://www.cog-genomics.org/plink2 "
		noi di in red"# >> set plink v1.9 location using;  "
		noi di in red`"# >> global plink "folder\file"  "'
		exit
		}
	}
qui { // plink v2
	capture confirm file "$plink2"
	if _rc==0 {
		noi di in green"# >> plink v2+  exists and is correctly assigned as  $plink2"
		}
	else {
		noi di in red"# >> plink v2 does not exists; download executable from https://www.cog-genomics.org/plink/2.0/ "
		noi di in red"# >> set plink v2 location using;  "
		noi di in red`"# >> global plink2 "folder\file"  "'
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
		noi di in green"# >> the tabbed.pl script exists and is correctly assigned as  $tabbed"
		noi di in green"# >>> ensuring perl is working on your system and can be called from the command-line"
		clear 
		set obs 10
		gen a = "a b c d"
		outsheet a using test_pl.txt, noq replace
		!$tabbed test_pl.txt
		capture confirm file "test_pl.txt.tabbed"
		if _rc==0 {
			noi di in green"# >>>> the tabbed.pl script is working"
			}
		else {
			noi di in red"# >>>> the tabbed.pl script did not work"
			noi di in red"# >>>> download and install active perl on your computer https://www.activestate.com/activeperl/downloads"
			exit
			}
		!del test_pl.*
		}
	else {
		noi di in red"# >> tabbed.pl does not exists; download executable from https://github.com/ricanney/perl "
		noi di in red"# >> set tabbed.pl location using;  "
		noi di in red`"# >> global tabbed "folder\file"  "'
		exit
		}
	erase _ooo.do
	}
di in white"# > run bim2ldexclude                           "
qui { 
	bim2ldexclude, bim(`bim') 
	}
di in white"# > excluding long-distance-ld-ranges using ${plink}"
qui { 	
	!$plink --bfile `bim' --exclude long-range-ld.exclude --indep-pairwise 1000 5 0.2  --out _00000001
	}
di in white"# > ld-pruning using ${plink}#"
qui {
	!$plink --bfile `bim' --extract _00000001.prune.in --make-bed                      --out _00000002
	}
di in white "# > defining principle component using ${plink2}"
qui {
	!$plink2 --bfile _00000002 --pca `pc' --out _00000003
	}
di in white "# > processing eigenvec file to `bim'_eigenvec.dta"
qui {
	!$tabbed _00000003.eigenvec
	import delim using _00000003.eigenvec.tabbed, clear
	keep fid iid pc1 - pc`pc'
	save `bim'_eigenvec.dta,replace
	}
di in white "# > processing eigenval file to `bim'_eigenval.dta"
qui {	
	!$tabbed _00000003.eigenval
	import delim using _00000003.eigenval.tabbed, clear
	gen pc = _n
	ren v1 eigenval
	save `bim'_eigenval.dta,replace
	}
di in white "# > cleaning temp files"
qui {
	!del *_0000000* long-range-ld.exclude
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;


	
