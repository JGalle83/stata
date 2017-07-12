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

program bim2eigenvec
syntax , bim(string asis) [pc(real 10)]
noi di"#########################################################################"
noi di"# bim2eigenvec               "
noi di"# version:  1a              "
noi di"# Creation Date: 25may2017            "
noi di"# Author:  Richard Anney (anneyr@cardiff.ac.uk)     "
noi di"#########################################################################"
noi di"# This is a script to derive from a bim file (and matching bed fam) the "
noi di"# ancestry informative eigenvectors. "
noi di"# The script removes long-range LD regions as described in; "
noi di"# Long-Range LD Can Confound Genome Scans in Admixed Populations. Alkes "
noi di"# Price, Mike Weale et al., The American Journal of Human Genetics 83, "
noi di"# 127 - 147, July 2008              "
noi di"# -----------------------------------------------------------------------"
noi di"# Dependencies : plink_v1.9 via ${plink}         "
noi di"# Dependencies : plink_v2   via ${plink2}         "
noi di"# Dependencies : tabbed.pl  via ${tabbed}         "
noi di"# Dependencies : bim2ldexclude       "
noi di"# -----------------------------------------------------------------------"
noi di"# Syntax : bim2eigenvec, bim(filename) [pc(real 10)]     "
noi di"# for filename, .bim is not needed          "
noi di"#########################################################################"
noi di "Started: $S_DATE $S_TIME"
noi di "-importing bim file: `bim'.bim"
qui { 
	bim2ldexclude, bim(`bim') 
	noi di "-excluding long-distance-ld-ranges and ld-pruning using ${plink}"
	!$plink --bfile `bim' --exclude long-range-ld.exclude --indep-pairwise 1000 5 0.2  --out _00000001
	!$plink --bfile `bim' --extract _00000001.prune.in --make-bed                      --out _00000002
	noi di "-defining `pc' pca using ${plink2}"
	!$plink2 --bfile _00000002 --pca `pc' --out _00000003
	!$tabbed _00000003.eigenvec
	!$tabbed _00000003.eigenval
	import delim using _00000003.eigenvec.tabbed, clear
	keep fid iid pc1 - pc`pc'
	noi di "-saving as `bim'_eigenvec.dta"
	save `bim'_eigenvec.dta,replace
	import delim using _00000003.eigenval.tabbed, clear
	gen pc = _n
	ren v1 eigenval
	save `bim'_eigenval.dta,replace
	!del *_0000000* long-range-ld.exclude

	}
di "Completed: $S_DATE $S_TIME"
di "done!"
end;	

	
