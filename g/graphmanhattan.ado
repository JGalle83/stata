/*
#########################################################################
# graphmanhattan
# a command to create a publication quality manhattan plot from gwas 
# summary data
#
# command: graphmanhattan, chr(chromosome-variable) bp(base-location-variable) p(p-value-variable)
# options: 
# 			max(num) .....maximum -log10P to plot - default = 10
# 			min(num) .....minimum -log10P to plot - default = 2
# 			gwas(num) ....where to plot gws line - default = 7.3 (5e-8)
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

program graphmanhattan
syntax , chr(string asis) bp(string asis) p(string asis) [max(real 10) min(real 2) gws(real 7.3) str(real 6)]

di"=============================================================="
di"* - graphmanhattan - version 1.0 04Aug2016 richard anney - *"
di"=============================================================="
di"...All chromosomes must be numeric 1-22, X = 23 (XY and Y are not plotted)"
di"...All positions must numeric and in bp"
di"...The following default thresholds are applied"
di"...maximum -log(10) p-value displayed; P = 1E-`min'"
di"...minimum -log(10) p-value displayed; P = 1E-`max'"
di"...Genomewide Significance Reported as P = 5E-8"
di"...strong Associations (Highlighted) are P < 1E-`str'"
di"=============================================================="

qui{ 
	preserve
	qui { // retaining working variables
		noi di"...retaining working variables"
		keep `chr' `bp' `p'			// keep chr bp p variables
		drop if `chr' > 23			// drop chromosomes > X (X- XY and other)
		duplicates drop			 	// drop any duplicate observations
		}
	qui { // retaining signals for plotting
		noi di"...retaining signals for plotting"
		qui count
		noi di"........A total of `r(N)' unique associateion signals were uploaded "
		sum `p'
		noi di"........the minimum P-value observed in this dataset is P = `r(min)' "
		gen tmpp = -log10(`p')
		drop if tmpp == .
		noi di"........after pruning SNPs based on P-value"
		drop if tmpp < `min'
		replace tmpp = `max' if tmpp > `max'
		qui count
		noi di"........a total of `r(N)' SNPs are retained for plotting"
		}
	qui { // define spacer between chromosomes
		noi di"...define spacer between chromosomes"
		foreach i of num 1 / 22 {
			sum `bp' if `chr' == `i'
			replace `bp' = (`bp' + `r(max)' + 20000000) if `chr' == `i' + 1
			}
		sum `chr'
		global maxchr `r(max)'
		gen tmpbp = round(`bp'/1000000,0.01)
		foreach i of num 1 / $maxchr {
			sum tmpbp if `chr' == `i'
			global mtick`i' `r(mean)'
			di ${mtick`i'}
			}
		}
	qui { // defining plotting options
		global gws red 
		global str midgreen
		colorscheme 8, palette(Blues)
		global color3	"mlc("`r(color7)'") mfc("`r(color7)'")"
		global color4	"mlc("`r(color8)'") mfc("`r(color8)'")"
		}
	qui { // plotting graph in memory
		sum tmpp
		gen tmpx = `r(max)' + 1.1
		replace tmpx = round(tmpx,2)
		sum tmpx
		global tmpmax `r(max)'
		gen tmpmin = `min'
		global tmp_symbol "msymbol(o) msize(small)"
		noi di"...plotting graph to memory"	
		#delimit;
		tw scatter tmpp tmpbp if (`chr' == 1 & tmpp < `str'),  ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 2 & tmpp < `str'),  ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 3 & tmpp < `str'),  ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 4 & tmpp < `str'),  ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 5 & tmpp < `str'),  ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 6 & tmpp < `str'),  ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 7 & tmpp < `str'),  ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 8 & tmpp < `str'),  ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 9 & tmpp < `str'),  ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 10 & tmpp < `str'), ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 11 & tmpp < `str'), ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 12 & tmpp < `str'), ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 13 & tmpp < `str'), ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 14 & tmpp < `str'), ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 15 & tmpp < `str'), ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 16 & tmpp < `str'), ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 17 & tmpp < `str'), ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 18 & tmpp < `str'), ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 19 & tmpp < `str'), ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 20 & tmpp < `str'), ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 21 & tmpp < `str'), ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (`chr' == 22 & tmpp < `str'), ${tmp_symbol} ${color4}
		|| scatter tmpp tmpbp if (`chr' == 23 & tmpp < `str'), ${tmp_symbol} ${color3}
		|| scatter tmpp tmpbp if (tmpp >= `str' & tmpp < `gws'), ${tmp_symbol} mlcolor(${str}) mfcolor(${str})
		|| scatter tmpp tmpbp if (tmpp >= `gws'), ${tmp_symbol} mlcolor(${gws}) mfcolor(${gws})
		ytitle("-log10(p)"" ")
		ylabel(`min'(2)${tmpmax})
		xmlabel(${mtick1} "1" ${mtick2} "2" ${mtick3} "3" ${mtick4} "4" ${mtick5} "5" ${mtick6} "6" ${mtick7} "7" ${mtick8} "8" ${mtick9} "9" ${mtick10} "10" ${mtick11} "11" ${mtick12} "12" ${mtick13} "13" ${mtick14} "14" ${mtick15} "15" ${mtick16} "16" ${mtick17} "17" ${mtick18} "18" ${mtick19} "19" ${mtick20} "20" ${mtick21} "21" ${mtick22} "22" , nogrid)
		xlabel(none)
		xtitle(" ""Chromosome") 
		fysize(100) fxsize(500)
		legend(off)
		nodraw saving(tmpManhattan.gph, replace)
		;
		#delimit cr
		}
	restore
	}
noi di"...graph saved in tmpManhattan.gph"
di"done!"
end;
	
 
