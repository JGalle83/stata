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
# =======================================================================
# Copyright 2017 Richard Anney

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software")
, to deal in the Software without restriction, including without 
limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to 
whom the Software is furnished to do so, subject to the following 
conditions:
The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#########################################################################
*/

program graphqq
syntax , p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6)]

di"=============================================================="
di"* -    graphQQ - version 0.3a  04Aug2016 richard anney     - *"
di"=============================================================="
di"...The following default thresholds are applied"
di"...maximum -log(10) p-value displayed; P = 1E-`min'"
di"...minimum -log(10) p-value displayed; P = 1E-`max'"
di"=============================================================="
qui{ 
	preserve
	qui { // retaining working variables
		noi di"...retaining working variables and calculating pseudo-chi"
		keep `p'
		}
	qui { // calculating lambda *THIS HAS NOT BEEN IMPLEMENTED FULLY - NEED TO MAKE SURE I AM USING THE CORRECT MATHEMATICS UNDERPINNING THE CALCULATION*
		/*	
		noi di"...calculate lambda"
		gen tmpchi = invchi2tail(1,`p')
		sum tmpchi,detail
		gen lambda = round(r(p50)/0.4549364,0.01)
		sum lambda
		global tmplambda `r(max)'
		noi di"lambda = ${tmplambda}"
		keep tmpp tmpchi
		noi di"...calculate lambda1000"
		keep tmpp tmpchi
		gen tmprandom = uniform()
		sort tmprandom
		egen obs = seq()
		sum tmpchi if obs <1000, detail
		gen lambda1000 = round(r(p50)/0.4549364,0.01)
		sum lambda1000
		global tmplambda1000 `r(max)'
		noi di"lambda1000 = ${tmplambda1000} (10)"
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
			noi di"lambda1000 = ${tmplambda1000} (`i')"
			}
		replace lambda1000 = round(lambda1000,0.01)
		sum lambda1000
		global tmplambda1000 `r(max)'
		noi di"lambda1000 = ${tmplambda1000} (`i')"
		*/
		}
	qui { // calculating expected observations
		noi di"...generate expected observations"
		drop if `p' == .
		qui count
		global rN `r(N)'
		noi di "........A total of `r(N)' unique association signals were uploaded "
		sort `p'
		gen  obs = _n
		gen  tmpE = -log10(_n/${rN})			// define expected P (-log10)
		gen  tmpO = -log10(`p')					// define observed P (-log10)
		replace tmpO = `max' if tmpO > `max'	// apply p-value ceiling"
		}
	qui { // prune data bins (500 per bin) to aid plotting 
		egen bin   = cut(tmpO), at(0(1)`max')
		gen  random  = uniform()
		sort random
		egen instance = seq(),by(bin)
		drop if instance > 500
		}
	qui { // calculate binomal boundaries
		noi di"...calculate binomal boundaries"
		save _tmpData.dta, replace
		use _tmpData.dta, clear
		append using _tmpData.dta
		append using _tmpData.dta
		!rm _tmpData.dta
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
		!rm _tmpScript.do
		gen tmpU = -log10(ub)
		gen tmpL = -log10(lb)
		keep tmpO tmpE tmpU tmpL 
		drop if tmpO < `min' // set floor limits to graph
		drop if tmpE < `min' // set floor limits to graph
		sort tmpE
		}
	qui { // defining plotting options
		global gws red 
		global str midgreen
		colorscheme 8, palette(Reds)
		global level1	"mlc("`r(color4)'") mfc("`r(color4)'")"
		global level2	"mlc("`r(color6)'") mfc("`r(color6)'")"
		global level3	"mlc("`r(color8)'") mfc("`r(color8)'")"
		}
	qui { // plotting graph in memory
		sum tmpO
		gen tmpx =  `r(max)' + 1.1
		replace tmpx = round(tmpx,2)
		sum tmpx
		global tmpmax `r(max)'
		noi di"...plotting graph in memory"
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
	!del _tmpData.dta _tmpScript.do
	
	restore
	}
	noi di"...graph saved in tmpQQ.gph"
	di"done!"
	end;
  
