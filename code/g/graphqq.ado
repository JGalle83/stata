/*
#########################################################################
# graphqq
# a command to create a publication quality qq-plots from gwas 
# summary data
#
# command: graphqq,  p(p-value-variable)
# options: 
# 			max(num) .....maximum -log10P to plot - default = 10
# 			min(num) .....minimum -log10P to plot - default = 2
# 			gws(num) .....where to plot gws line - default = 7.3 (5e-8)
# 			str(num) .....what to consider as a strong association - default = 6
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

program graphqq
syntax , p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6)]

di in white"#########################################################################"
di in white"# graphqq - version 0.3a  04Aug2016 richard anney                       #"
di in white"#########################################################################"
di in white"# A command to create a publication quality qq-plots from gwas          #"
di in white"# The following thresholds are applied to the plot;                     #"
di in white"# maximum plotted -log(10) p-value ; P = 1E-`min'              #"
di in white"# minimum plotted -log(10) p-value ; P = 1E-`max'              #"
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
net install colorscheme, from(https://github.com/matthieugomez/stata-colorscheme/raw/master/)
preserve
di in white"# > retaining working variables"
qui { 
	keep `p'
	}
di in white"# > checking variable in correct format"
qui { // p
	capture confirm numeric var `p' 
	if _rc==0 {
		noi di in green"# >> the p-value variable `p' is numeric ... continue"
		}
	else {
		noi di in red"# >> the p-value variable `p' is not numeric ... exiting"
		exit
		}
	}
*di in white"# > calculate lambda"
qui { // *THIS HAS NOT BEEN IMPLEMENTED FULLY - NEED TO MAKE SURE I AM USING THE CORRECT MATHEMATICS UNDERPINNING THE CALCULATION*
	/*	
	noi di in white"...calculate lambda"
	gen tmpchi = invchi2tail(1,`p')
	sum tmpchi,detail
	gen lambda = round(r(p50)/0.4549364,0.01)
	sum lambda
	global tmplambda `r(max)'
	noi di in white"lambda = ${tmplambda}"
	keep tmpp tmpchi
	noi di in white"...calculate lambda1000"
	keep tmpp tmpchi
	gen tmprandom = uniform()
	sort tmprandom
	egen obs = seq()
	sum tmpchi if obs <1000, detail
	gen lambda1000 = round(r(p50)/0.4549364,0.01)
	sum lambda1000
	global tmplambda1000 `r(max)'
	noi di in white"lambda1000 = ${tmplambda1000} (10)"
	foreach i of num 9/1 {
		keep tmpp tmpchi
		gen tmprandom = uniform()
		sort tmprandom
		egen obs = seq()
		sum tmpchi if obs <1000, detail
		gen     lambda1000 = round(r(p50)/0.4549364,0.001)
		replace lambda1000 = round(((lambda1000 + ${tmplambda1000}) / 2),0.001)
		sum lambda1000
		global tmplambda1000 `r(max)'
		noi di in white"lambda1000 = ${tmplambda1000} (`i')"
		}
	replace lambda1000 = round(lambda1000,0.01)
	sum lambda1000
	global tmplambda1000 `r(max)'
	noi di in white"lambda1000 = ${tmplambda1000} (`i')"
	*/
	}
di in white"# > calculating expected observations"
qui { 
	drop if `p' == .
	qui count
	global rN `r(N)'
	noi di in white"# >> A total of `r(N)' unique association signals were uploaded "
	sort `p'
	gen  obs = _n
	gen  tmpE = -log10(_n/${rN})			// define expected P (-log10)
	gen  tmpO = -log10(`p')					// define observed P (-log10)
	replace tmpO = `max' if tmpO > `max'	// apply p-value ceiling"
	}
di in white"# > pruning data bins to speed up plotting"
qui {
	egen bin   = cut(tmpO), at(0(1)`max')
	gen  random  = uniform()
	sort random
	egen instance = seq(),by(bin)
	drop if instance > 500
	}
di in white"# > calculate binomal boundaries"
qui {
	save _tmpData.dta, replace
	use _tmpData.dta, clear
	append using _tmpData.dta
	append using _tmpData.dta
	erase _tmpData.dta
	keep tmpO tmpE obs
	tostring obs, replace 
	egen x  = seq(),by(obs)
	gen script = ""
	replace script = "qui cii $rN " + obs if x == 1
	replace script = `"qui replace ub = r(ub) if obs == ""' + obs + `"""' if x == 2
	replace script = `"qui replace lb = r(lb) if obs == ""' + obs + `"""' if x == 3
	sort obs x
	outsheet script using _tmpScript.do, non noq replace
	gen ub = .
	gen lb = .
	do _tmpScript.do
	erase _tmpScript.do
	gen tmpU = -log10(ub)
	gen tmpL = -log10(lb)
	keep tmpO tmpE tmpU tmpL 
	drop if tmpO < `min' // set floor limits to graph
	drop if tmpE < `min' // set floor limits to graph
	sort tmpE
	}
di in white"# > plotting to tmpQQ.gph"
qui {
	global gws red 
	global str midgreen
	colorscheme 8, palette(Reds)
	global level1	"mlc("`r(color4)'") mfc("`r(color4)'")"
	global level2	"mlc("`r(color6)'") mfc("`r(color6)'")"
	global level3	"mlc("`r(color8)'") mfc("`r(color8)'")"
	sum tmpO
	gen tmpx =  `r(max)' + 1.1
	replace tmpx = round(tmpx,2)
	sum tmpx
	global tmpmax `r(max)'
	noi di in white"...plotting graph in memory"
	global tmp_symbol "msymbol(o) msize(small)"
	#delimit;
	tw line tmpE  tmpE , lwidth(vthin) lcolor(black)
	|| line tmpU tmpE , lpattern(dash) lwidth(vthin) lcolor(black)
	|| line tmpL tmpE , lpattern(dash) lwidth(vthin) lcolor(black)
	|| scatter tmpO tmpE if (tmpO < `str') ,  		${tmp_symbol} ${level1}
	|| scatter tmpO tmpE if (tmpO >= `str' & tmpO < `gws'), ${tmp_symbol} ${level2}
	|| scatter tmpO tmpE if (tmpO >= `gws'), 		${tmp_symbol} ${level3}
	legend(off) 
	xtitle(" " "Expected (-log10(P))") 
	ytitle("-log10(p)"" ")
	xmlabel(2 "2" 4 "4" 6"6")
	xlabel(none)
	ylabel(`min'(2)${tmpmax})
	fysize(100) fxsize(100)
	nodraw saving(tmpQQ.gph, replace)
	;
	#delimit cr
	}
di in white"# > cleaning up temporary files"
qui{
	erase _tmpData.dta
	erase _tmpScript.do
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
restore
end;
  
