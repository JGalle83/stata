/*
#########################################################################
# genotypeqc
# a command to perform a full quality-control pipeline in plink binaries
#
# command: genotypeqc, bin(plink-binaries) param(parameter-file) depend(dependency-file)
# options: see parameter file
#########################################################################
#########################################################################
# parameter file
#
# we recommend this as a flat text file called <study-id>.parameters
#
# there are numerous parameters that can be defined for genotyping-array 
# quality control. these will be recorded in the final *.meta-log and 
# *-report.docx. default parameters are included in the 
# template.parameters file. these are based on our needs and may not 
# reflect your needs. please review the parameters to establish whether 
# these are appropriate.
# =======================================================================
#
#
#
#
#
#########################################################################
#########################################################################
# dependencies: 
# there are numerous dependencies that need to be specified in the 
# dependencies file. 
#
# we recommend this as a flat text file called <study-id>.dependencies
# =======================================================================
#
#
#
#
#
#########################################################################
######################################################################### 
# other stata commands
# prior to implementation, run the install-all.do file 
# downloaded from https://github.com/ricanney/stata-genomics-ado
# 
# other non-stata scripts
# tabbed.pl must be set to be called via ${tabbed}
#
# other software
# plink1.9+ from https://www.cog-genomics.org/plink2
# plink2.+  from https://www.cog-genomics.org/plink/2.0/
#
# other associated data
# reference genotypes
#
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
program genotypeqc
syntax , param(string asis) 
di"printing....`param'"
end;
 
