program symbol2ensembl
syntax , name (string asis) symbol(string asis) data(string asis) history(string asis) 
noi di"#########################################################################"
noi di"# symbol2ensembl               "
noi di"# version:  1a              "
noi di"# Creation Date: 02Oct2017            "
noi di"# Author:  Richard Anney (anneyr@cardiff.ac.uk)     "
noi di"#########################################################################"
noi di"# This is a script to derive from a bim file (and matching bed fam) the "
noi di"# a command to convert gene-symbols to ensembl identifiers          "
noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : symbol2ensembl, name(<output-name>) symbol(<varname>) data(<ensembl-database>) history(<gene_history.9606 file>)   "
noi di"#########################################################################"
noi di "Started: $S_DATE $S_TIME"

qui { // clean up gene-names
	rename `symbol' symbol
	count if symbol != ""
	global nonMissSymbol `r(N)'
	noi di in green`"${nonMissSymbol} non-missing gene-symbols observed"'
	count if symbol == ""
	drop  if symbol == ""
	global MissSymbol `r(N)'
	noi di in green`"${MissSymbol} missing gene-symbols dropped"'
	noi di in green`"converting symbols to uppercase"'
	replace symbol = strupper(symbol)
	noi di in green`"correct common excel related issues"'
	qui { // correct common excel related issues
		replace symbol = "FEB1" 		if symbol == "01-Feb"
		replace symbol = "FEB2" 		if symbol == "02-Feb"
		replace symbol = "FEB3" 		if symbol == "03-Feb"
		replace symbol = "FEB4" 		if symbol == "04-Feb"
		replace symbol = "FEB5" 		if symbol == "05-Feb"
		replace symbol = "FEB6" 		if symbol == "06-Feb"
		replace symbol = "FEB7" 		if symbol == "07-Feb"
		replace symbol = "MARCH1" 	if symbol == "01-Mar"
		replace symbol = "MARCH2" 	if symbol == "02-Mar"
		replace symbol = "MARCH3" 	if symbol == "03-Mar"
		replace symbol = "MARCH4" 	if symbol == "04-Mar"
		replace symbol = "MARCH5" 	if symbol == "05-Mar"
		replace symbol = "MARCH6" 	if symbol == "06-Mar"
		replace symbol = "MARCH7" 	if symbol == "07-Mar"
		replace symbol = "MARCH8" 	if symbol == "08-Mar"
		replace symbol = "MARCH8" 	if symbol == "09-Mar"
		replace symbol = "MARCH10" if symbol == "10-Mar"
		replace symbol = "MARCH11" if symbol == "11-Mar"
		replace symbol = "SEPT1" 	if symbol == "01-Sep"
		replace symbol = "SEPT2" 	if symbol == "02-Sep"
		replace symbol = "SEPT3" 	if symbol == "03-Sep"
		replace symbol = "SEPT4" 	if symbol == "04-Sep"
		replace symbol = "SEPT5" 	if symbol == "05-Sep"
		replace symbol = "SEPT6" 	if symbol == "06-Sep"
		replace symbol = "SEPT7" 	if symbol == "07-Sep"
		replace symbol = "SEPT8" 	if symbol == "08-Sep"
		replace symbol = "SEPT9" 	if symbol == "09-Sep"
		replace symbol = "SEPT10"	if symbol == "10-Sep"
		replace symbol = "SEPT11"	if symbol == "11-Sep"
		replace symbol = "SEPT12"	if symbol == "12-Sep"
		replace symbol = "SEPT13"	if symbol == "13-Sep"
		replace symbol = "SEPT14"	if symbol == "14-Sep"
		replace symbol = "SEP15"		if symbol == "15-Sep"
		replace symbol = "DEC1"		if symbol == "01-Dec"
		}
	qui { // standardising non-text/number variables
		replace symbol = subinstr(symbol, "-", "_",.)
		replace symbol = subinstr(symbol, " ", "",.)
		foreach j in . \ / ( ) # ' * + , : ; @ [ ] {
			replace symbol = subinstr(symbol, "`j'", "",.)
			}
		}
	noi di in green`"removing duplicates"'
	duplicates tag, gen(dups)
	duplicates drop
	count
	global uniqueSymbol `r(N)'
	noi di in green`"${uniqueSymbol} unique gene-symbols observed"'
	save tmp-01.dta,replace
	qui { // remove gene symbols which have been discontinued"
		noi di in green`"removing discontinued gene symbols"'
		use `history', clear
		keep if geneid == "-"
		rename discont_symbol symbol
		foreach i in symbol {
			replace `i' = subinstr(`i', "-", "_",.)
			foreach j in . \ / ( ) # ' * + , : ; @ [ ] {
				replace `i' = subinstr(`i', "`j'", "",.)
				}
			replace `i' = subinstr(`i', " ", "",.)
			}
		replace symbol = strupper(symbol)
		keep symbol discont_date
		sort symbol
		merge m:1 symbol using tmp-01.dta
		erase tmp-01.dta
		drop if _m == 1
		count if _m == 3
		global discontinuedSymbol `r(N)'
		noi di in green`"${discontinuedSymbol} gene-symbols have been discontinued"'
		outsheet symbol if _m == 3 using tmp-discontinued.txt, non noq replace
		drop if _m == 3
		keep symbol
		}
	merge 1:m symbol using `data'
	count if _m == 1
	global notmapped `r(N)'
	noi di in green`"${notmapped} gene-symbols not mapped to ensembl identifiers"'
	outsheet symbol if _m == 1 using tmp-notmapped.txt, non noq replace

	count if _m == 3
	global mapped `r(N)'
	noi di in green`"${mapped} gene-symbols mapped to ensembl identifiers"'	
	keep if _m == 3
	order chr sta end sym ens bio
	keep  chr sta end sym ens bio
	sort  chr sta end sym ens bio
	save `name'-ensembl-list.dta, replace
	duplicates tag symbol, gen(tag)
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
	replace a = `"# symbol2ensembl log file"'                                                            in 2                                                             
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
	replace a = `"# Name ................................................... `name'-ensembl-list.dta "' in 14
	replace a = `"# Date ................................................... $S_DATE $S_TIME "'          in 15
	replace a = `"# Number of non-missing symbols imported ................. ${nonMissSymbol}"'          in 16
	replace a = `"# Number of unique symbols ............................... ${uniqueSymbol}"'           in 17
	replace a = `"# Number of discontinued symbols ......................... ${discontinuedSymbol}"'     in 18
	replace a = `"# Number of symbols mapped to ensembl identifiers......... ${mapped}"'                 in 19
	replace a = `"# Number of ensembl identifiers mapped to same symbol .... ${dups}"'                   in 20
	replace a = `"# Number of symbols not-mapped to ensembl identifiers .... ${notmapped}"'              in 21
	replace a =  `"#########################################################################"'           in 22
	outsheet using `name'-ensembl-list.meta-log, non noq replace
	
	!$wc -l tmp-notmapped.txt     > tmp.counts
	!$wc -l tmp-discontinued.txt >> tmp.counts
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
			replace a = `"# symbols not-mapped to ensembl identifiers                              "'            in 3
			replace a = `"# ======================================================================="'            in 4
			replace a = `"#########################################################################"'            in 6
			outsheet a using tmp-notmapped.list, non noq replace
			!type tmp-notmapped.list >> `name'-ensembl-list.meta-log
			}
	import delim using tmp.counts.tabbed, clear
	sum v1 in 2
		if r(sum) != 0 {
			import delim using tmp-discontinued.txt, varnames(noname) clear
			sxpose, clear
			set obs 6
			gen _var0   = "# " in 1
			gen _var999 = ""
			aorder
			egen a = concat(_var0 - _var999), p(" ")
			replace a = a[_n-1] if a == ""
			replace a = ""                                                                                       in 1
			replace a = `"#########################################################################"'            in 2
			replace a = `"# discontinued symbols                             "'            in 3
			replace a = `"# ======================================================================="'            in 4
			replace a = `"#########################################################################"'            in 6
			outsheet a using tmp-discontinued.list, non noq replace
			!type tmp-discontinued.list >> `name'-ensembl-list.meta-log
			}
		}
		
qui { // clean up
	!del tmp.count* tmp-discontin* tmp-notmapp* 
	}
di "Completed: $S_DATE $S_TIME"
di "done!"
end;

	
	

	
		
