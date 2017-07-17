/*
#########################################################################
# gtqc_meta
# subroutine for genotypeqc
# command: gtqc_meta
#########################################################################
# =======================================================================
# Author: Richard Anney
# Institute: Cardiff University
# E-mail: AnneyR@cardiff.ac.uk
# Date: 12th July 2017
# =======================================================================
# Copyright 2017 Richard Anney
# Permission is hereby granted, free of charge, to any person obtaining a 
# copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including  
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to  
# permit persons towhom the Software is furnished to do so, subject to 
# the following conditions:
#
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#########################################################################
*/
program gtqc_meta
syntax  
end

	
	noi di in green"...make a meta-log file (flat txt file)"
	clear
	input strL v1
	`"#########################################################################"'
	`"# Genotyping Array Quality Control Report from STATA command genotypeqc"'                                                                
	`"# available from https://github.com/ricanney"'                                                                
	`"#########################################################################"'
	`"# Author:     Richard Anney"'
	`"# Institute:  Cardiff University"'
	`"# E-mail:     AnneyR@cardiff.ac.uk"'
	`"# Date:       12th July 2017"'
	`"# Copyright 2017 Richard Anney"'
	`"# ======================================================================="'
	`"# Permission is hereby granted, free of charge, to any person obtaining a "'
	`"# copy of this software and associated documentation files (the "'
	`"# "Software"), to deal in the Software without restriction, including  "'
	`"# without limitation the rights to use, copy, modify, merge, publish, "'
	`"# distribute, sublicense, and/or sell copies of the Software, and to  "'
	`"# permit persons to whom the Software is furnished to do so, subject to "'
	`"# the following conditions:"'
	`"#"'
	`"# The above copyright notice and this permission notice shall be included "'
	`"# in all copies or substantial portions of the Software."'
	`"#"'
	`"# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS "'
	`"# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF "'
	`"# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. "'
	`"# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY "'
	`"# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, "'
	`"# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE "'
	`"# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."'
	`"#########################################################################"'
	`""'
	`"#########################################################################"'
	`"# Run Information"'                                                                
	`"#########################################################################"'
	`"# Date ...................................................... "'
	`"# ======================================================================="'
	`"# Input File ................................................ "'
	`"# Input Array (Approximated) ................................ "'
	`"# Input Total Markers ....................................... "'
	`"# Input Total Individuals ................................... "'
	`"# ======================================================================="'
	`"# Output File ............................................... "'
	`"# Output Genome Build ....................................... "'
	`"# Output Total Markers ...................................... "'
	`"# Output Total Individuals .................................. "'
	`"# ======================================================================="'
	`"# THRESHOLD - maximum missing by individual ................. "'
	`"# THRESHOLD - missing by marker ............................. "'
	`"# THRESHOLD - minimum minor allele frequency ................ "'
	`"# THRESHOLD - maximum hardy-weinberg deviation (-log10(p)) .. "'
	`"# THRESHOLD - maximum heterozygosity deviation (std.dev) .... "'
	`"# THRESHOLD - rounds of QC .................................. "'
	`"# THRESHOLD - europeans ..................................... "'
	`"#########################################################################"'
	end
	gen v2 = ""
	replace v2 = "$S_DATE $S_TIME"     in 34 
	
	replace v2 = "$data_input"         in 36
	replace v2 = "$arrayType"          in 37 
	replace v2 = "$count_markers_1"    in 38
	replace v2 = "$count_individ_1"    in 39
	
	replace v2 = "${data_input}-qc-v4" in 41
	replace v2 = "$buildType"          in 42
	replace v2 = "$count_markers_3"    in 43 
	replace v2 = "$count_individ_3"    in 44 
	replace v2 = "$mind"               in 46
	replace v2 = "$geno2"              in 47 
	replace v2 = "$maf"                in 48 
	replace v2 = "10e-$hwep"           in 49 
	replace v2 = "$hetsd"              in 50 
	replace v2 = "$rounds"             in 51
	replace v2 = "$count_European"     in 52
	outsheet using tempfile-module-8.meta-log, delim(" ") non noq replace
