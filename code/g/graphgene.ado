program graphGene
*! version 0.1e  21Oct2016 richard anney

version 10.1

syntax  ,  chr(string asis) start(string asis) end(string asis) refgene(string asis) 

noi di "***************************************************"
noi di "graphGene ................................... v0.1e"
noi di "........................................  21Oct2016"
noi di "..................................... richard anney"
noi di "***************************************************"
noi di "reference gene location ................. `refgene'"
noi di "plotting chromosome ..................... `chr'"
noi di "from .................................... `start'"
noi di "to ...................................... `end'"
noi di "***************************************************"

noi di"...defining gene panel data for plots"
	qui { // create DUMMY gene data (for gene deserts)
		noi di"...create DUMMY gene data (for gene deserts)"
		clear
		set obs 1
		noi di"...create dummy file for gene deserts"
		gen name2 = "DUMMY"
		gen exonStarts = `start'
		gen exonEnds   = `end'	
		gen txStart    = `start'
		gen txEnd      = `end'
		save tmpDUMMY.dta, replace
		}
	qui { // create REFGENE gene data
		noi di"...create REFGENE gene data"
		use `refgene', clear
		keep name2 chrom strand txStart txEnd exonEnds exonStarts
		noi di"...selecting region"
		keep if chrom   == `chr'
		drop if txStart  > `end'
		drop if txEnd    < `start'
		replace txStart  = `start' if txStart < `start'
		replace txEnd    = `end'   if txEnd   > `end'
		replace exonStarts  = . if (exonStarts < `start' & exonEnds < `start')
		replace exonEnds    = . if (exonStarts ==.)
		replace exonEnds    = . if (exonStarts > `end' & exonEnds > `end')
		replace exonStarts  = . if (exonEnds ==.)
		replace name = name2
		append using tmpDUMMY.dta
		duplicates drop
		encode name2, gen(encode)
		sum encode
		global encmax `r(max)'
		di $encmax
		foreach i of num  $encmax / 1 {
				sum txStart if encode == `i'
				replace txStart = `r(min)' if encode == `i'
				sum txEnd if encode == `i'
				replace txEnd = `r(max)' if encode == `i'
				}
		drop encode 
		duplicates drop
		rename name2 name
		sort name	
		save tmpGENEcoords.dta, replace
		keep name
		duplicates drop
		sort name 
		save tmpGENEname.dta, replace
		}		
		
		
	qui { // defining the order to display genes
		noi di"...defining the order to display genes"
		use tmpGENEcoords.dta,clear
		sort name txStart
		encode name, gen(Name)
		foreach j of num 1/100 {
				sum txStart if Name == `j'
				replace txStart = r(min) if Name == `j'
				sum txEnd if Name == `j'
				replace txEnd = r(max) if Name == `j'
				}
		duplicates drop
		sort name
		save tmp_x.dta,replace
		use  tmp_x.dta, clear
		keep if strand != "" 
		keep name txStart txEnd
		duplicates drop
		sort txStart
		local N = _N
		global tmp_split 500000	
		gen ORDER = .
		replace ORDER = 1 in 1
		sum txEnd
		foreach i of num 2 / `r(N)' {
					sum txEnd if ORDER == 1
					replace ORDER = 1 if txStart > (`r(max)' + ${tmp_split}) & _n == `i' & ORDER == .
					}
		foreach j of num 2/100 { 
					sort ORDER txStart
					egen x = seq(),by(ORDER)
					replace ORDER = `j' if ORDER == . & x == 1
					sum txEnd
					foreach i of num 2 / `r(N)' {
						sum txEnd if ORDER == `j'
						replace ORDER = `j' if txStart > (r(max) + ${tmp_split}) & _n == `i' & ORDER == .
						}
					drop x
					}	
				
		keep name ORDER
		sort name
		merge m:m name using tmp_x.dta
		drop _merge
		ta ORDER
		order ORDER
		sort ORDER txStart
		gen label = name + " [" + strand + "]"
		keep  ORDER name txStart txEnd exonStarts exonEnds strand label 
		order ORDER name txStart txEnd exonStarts exonEnds strand label 
		sum ORDER
		sort ORDER exonStarts
		noi di"...adjust exon size for plotting purposes"
		qui {
					gen max = (`end' - `start') / 1000
					sum max
					global max `r(max)'
					gen exonSize = exonEnds - exonStarts
					gen exonMid  = exonStarts + (exonSize/2)
					replace exonStarts = exonMid - (${max} /2) if exonSize < ${max}
					replace exonEnds   = exonMid + (${max} /2) if exonSize < ${max}
					}
		keep  ORDER name txStart txEnd exonStarts exonEnds strand label  
		order ORDER name txStart txEnd exonStarts exonEnds strand label 
		egen x = seq(),by(ORDER txStart)
		replace label = "" if x != 1
		save tmpGENEcoords_label.dta, replace
		}

	qui { // plot graph
		#delim;
		twoway rspike txStart txEnd ORDER, hor lcolor(green) lwidth(thin) 
		|| rspike exonStarts exonEnds ORDER,  hor lcolor(green) lwidth(vthick) 	
		|| scatter ORDER txStart , yaxis(2) msymbol(i) mlabel(label) mlabpos(9) mlabcolor(black) mlabsize(vsmall)
		legend(off) yscale(off axis(1) fill) yscale(off axis(2) fill)
		ytitle(" . "" . ", axis(1) c(white)) ytitle(" . "" . ", axis(2) c(white))
		fysize(${fysize}) fxsize(200)
		plotregion(fcolor(white) lcolor(white)) graphregion(fcolor(white) lcolor(white))
		xtitle(" ""chromosome `chr' ", size(small)) 
		;
		#delim cr
		graph save tmpgene.gph, replace
		}
  qui { //clean up tmp files"
		!del tmpGENEc*
		!del tmpGENEn*
		!del tmpDUMMY*
		!del tmp_x*
		}
	noi di "done!"
	end;
