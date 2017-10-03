program ensembl2symbol
syntax , name (string asis) ensembl(string asis) data(string asis) history(string asis) 
noi di"#########################################################################"
noi di"# ensembl2symbol               "
noi di"# version:  1a              "
noi di"# Creation Date: 02Oct2017            "
noi di"# Author:  Richard Anney (anneyr@cardiff.ac.uk)     "
noi di"#########################################################################"
noi di"# This is a script to map gene-symbols from ensembl identifiers          "
noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : ensembl2symbol, name(<output-name>) ensembl(<varname>) data(<ensembl-database>)   "
noi di"#########################################################################"
noi di "Started: $S_DATE $S_TIME"

qui { // clean up gene-names
	keep `ensembl'
	drop if `ensembl' == ""
	count
	global nonMissSymbol `r(N)'
	duplicates drop
	count
	global uniqueSymbol `r(N)'
	rename `ensembl' ensembl_geneID
	merge 1:m ensembl_geneID using `data'
	count if _m == 1
	global notmapped `r(N)'
	noi di in green`"${notmapped} ensembl identifiers not mapped to gene-symbols"'
	outsheet `ensembl' if _m == 1 using tmp-notmapped.txt, non noq replace
	count if _m == 3
	global mapped `r(N)'
	noi di in green`"${mapped} ensembl identifiers mapped to gene-symbols"'	
	keep if _m == 3
	order chr sta end sym ens bio
	keep  chr sta end sym ens bio
	sort  chr sta end sym ens bio
	save `name'-ensembl-list.dta, replace
	duplicates tag `ensembl', gen(tag)
	ta tag
	count if ta != 0
	global dups `r(N)'
	noi di in green`"${dups} observations with non-unique gene-symbols"'	
	}
qui { // create meta-log
	noi di in green"...make a meta-log file (flat txt file)"
	clear
	set obs 22
	gen a = ""
	replace a = `"#########################################################################"'            in 1
	replace a = `"# ensembl2symbol log file"'                                                            in 2                                                             
	replace a = `"# available from https://github.com/ricanney"'                                         in 3                                  
	replace a = `"# ======================================================================="'            in 4
	replace a = `"# Author:     Richard Anney"'                                                          in 5
	replace a = `"# Institute:  Cardiff University"'                                                     in 6
	replace a = `"# E-mail:     AnneyR@cardiff.ac.uk"'                                                   in 7
	replace a = `"# Date:       3rd October 2017"'                                                       in 8
	replace a = `"#########################################################################"'            in 9
	replace a = `""'                                                                                     in 10
	replace a = `"#########################################################################"'            in 11
	replace a = `"# Run Information"'                                                                    in 12      
	replace a = `"# ======================================================================="'            in 13
	replace a = `"# Name ................................................... `name'-ensembl-list.dta "'  in 14
	replace a = `"# Date ................................................... $S_DATE $S_TIME "'          in 15
	replace a = `"# Number of non-missing symbols imported ................. ${nonMissSymbol}"'          in 16
	replace a = `"# Number of unique symbols ............................... ${uniqueSymbol}"'           in 17
	replace a = `"# Number of symbols mapped to ensembl identifiers......... ${mapped}"'                 in 18
	replace a = `"# Number of ensembl identifiers mapped to same symbol .... ${dups}"'                   in 19
	replace a = `"# Number of symbols not-mapped to ensembl identifiers .... ${notmapped}"'              in 20
	replace a =  `"#########################################################################"'           in 21
	outsheet using `name'-ensembl-list.meta-log, non noq replace
	
	!$wc -l tmp-notmapped.txt     > tmp.counts
	!$tabbed tmp.counts
	import delim using tmp.counts.tabbed, clear
	sum v1 in 1
		if r(sum) != 0 {
			import delim using tmp-notmapped.txt, varnames(noname) clear
			sxpose, clear
			set obs 6
			gen _var0   = "# " in 1
			gen _var999 = ""
			aorder
			egen a = concat(_var0 - _var999), p(" ")
			replace a = a[_n-1] if a == ""
			replace a = ""                                                                                       in 1
			replace a = `"#########################################################################"'            in 2
			replace a = `"# ensembl identifiers not-mapped to symbols                              "'            in 3
			replace a = `"# ======================================================================="'            in 4
			replace a = `"#########################################################################"'            in 6
			outsheet a using tmp-notmapped.list, non noq replace
			!type tmp-notmapped.list >> `name'-ensembl-list.meta-log
			}
		}
		
qui { // clean up
	!del tmp.count* tmp-discontin* tmp-notmapp* 
	}
di "Completed: $S_DATE $S_TIME"
di "done!"
end;

	
	

	
		
