program graphManhattan
*! version 0.2a  08Sept2015 richard anney
   version 10.1
   
	syntax , chr(string asis) bp(string asis) p(string asis) [max(real 10) min(real 2) gws(real 7.3) strong(real 6) c1(string asis) c2(string asis)]

di"***************************************************"
di"graphManhattan - version 0.2b  04Oct2015 richard anney "
di"***************************************************"
di"...The following default thresholds are applied"
di"...maximum -log(10) p-value displayed; P = 1E-`min'"
di"...minimum -log(10) p-value displayed; P = 1E-`max'"
di"...Genomewide Significance Reported as P = 5E-8"
di"...Strong Associations (Highlighted) are P < 1E-`strong'"
di"***************************************************"

qui{ 
	noi di"...saving current dataset in temporary file"
	preserve
	duplicates drop
	noi di"...create working variables"
		keep `chr' `bp' `p'
	noi di"...rename chromosomes and define max chromosome (display up to X-only)"
		tostring 	`chr', replace
		replace 	`chr' = strupper(`chr')
		replace 	`chr' = "23" if `chr' == "X"
		replace 	`chr' = "24" if `chr' == "Y"
		replace 	`chr' = "25" if `chr' == "XY"
		replace 	`chr' = "26" if `chr' == "MT"
		destring 	`chr', replace
		sum 		`chr'
		global  maxchr `r(max)'
		gen tmpchr = `chr'
	noi di"...define bp"
		destring `bp', replace
		foreach i of num 1 / 22 {
			sum `bp' if `chr' == `i'
			replace `bp' = `bp' + `r(max)' + 30000000 if `chr' == `i' + 1
			}
		gen tmpbp = round(`bp'/1000000,0.01)
		drop if `chr' > 23
		foreach i of num 1 / $maxchr {
			sum tmpbp if `chr' == `i'
			global mtick`i' `r(mean)'
			di ${mtick`i'}
			}
	noi di"...define p vales"
		sum `p'
		noi di"...the minimum P-value observed in this dataset is P = `r(min)'"
		gen tmpp   = -log10(`p')
		drop if tmpp == .

	noi di"...define optional globals"
	global tmpmax `max'
	global tmpmin `min'
	global tmpgws `gws'
	global tmpstr `strong'
		gen global = ""
		replace global = "global tmpc1  `c1'"  in 1
		replace global = "global tmpc2  `c2'"  in 2
		replace global = "global tmpc1 emerald" if global == "global tmpc1  "
		replace global = "global tmpc2 dknavy"  if global == "global tmpc2  "
		outsheet global if global != ""  using _tmpglobal.do, non noq replace
		do _tmpglobal.do
		erase _tmpglobal.do
		drop global

	noi di"...identify highlighted regions"
	keep tmpchr tmpbp tmpp
	gsort -tmpp
	gen tmphlight = 0
	replace tmphlight = 2 in 1
	replace tmphlight = 2 if tmpp > ${tmpstr}
	gen ur = tmpbp + 0.2
	gen lr = tmpbp - 0.2
	gen _c = tmpchr
	for var ur lr _c : tostring X, replace force
	
	gen a 		= "replace tmphlight = 1 if ((inrange(tmpbp," + lr + "," + ur + ")) & tmpchr == " + _c + ")"
	egen obs 	= seq(),by(tmphlight a)
	replace a 	= "" if obs != 1
	outsheet a if (tmphlight == 2  & a ! = "") using tmphlight.do, non noq replace
	keep tmpchr tmpbp tmpp tmphlight
	do tmphlight.do
	erase tmphlight.do
	drop if tmpp < $tmpmin
	replace tmpp = $tmpmax if tmpp > $tmpmax
	
	
	noi di"...drawing graph to memory"	
	#delimit;
	twoway 	scatter tmpp tmpbp if tmpchr == 1,  msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 2,  msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 3,  msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 4,  msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 5,  msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 6,  msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 7,  msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 8,  msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 9,  msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 10, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 11, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 12, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 13, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 14, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 15, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 16, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 17, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 18, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 19, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 20, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 21, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmpchr == 22, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc2}) msize(vsmall) mfcolor(${tmpc2})
	 ||		scatter tmpp tmpbp if tmpchr == 23, msymbol(o) mlwidth(vvthin) mlcolor(${tmpc1}) msize(vsmall) mfcolor(${tmpc1})
	 ||		scatter tmpp tmpbp if tmphlight==1, msymbol(o) mlwidth(vvthin) mlcolor(red) 	   msize(vsmall) mfcolor(red)
	 ||		scatter tmpp tmpbp if tmphlight==2, msymbol(o) mlwidth(vvthin) mlcolor(black) 	 msize(vsmall) mfcolor(orange)
	ytitle("-log10(p)"" ")
	yline(${tmpgws}, lpattern(dash) lwidth(vthin) lcolor(red)) 
	yline(${tmpstr}, lpattern(dash) lwidth(vthin) lcolor(orange))
	ylabel(${tmpmin}(2)${tmpmax})
	ylabel(${tmpmin}(2)${tmpmax})
	xmlabel(${mtick1} "1" ${mtick2} "2" ${mtick3} "3" ${mtick4} "4" ${mtick5} "5" ${mtick6} "6" ${mtick7} "7" ${mtick8} "8" ${mtick9} "9" ${mtick10} "10" ${mtick11} "11" ${mtick12} "12" ${mtick13} "13" ${mtick14} "14" ${mtick15} "15" ${mtick16} "16" ${mtick17} "17" ${mtick18} "18" ${mtick19} "19" ${mtick20} "20" ${mtick21} "21" ${mtick22} "22" , nogrid)
	xtitle(" ""Chromosome") xlabel(none)
	fysize(100) fxsize(500)
	legend(off)
	nodraw saving(tmpmanhattan.gph, replace)
	;
	#delimit cr
	noi di"...graph saved in tmpmanhattan.gph"
	noi di"...re-opening current dataset from temporary file"
	restore
	}

		
di"done!"
end;
