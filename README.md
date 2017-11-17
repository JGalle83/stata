# Software - Stata
## Getting started - profile.do
It is important to prepare your ```profile.do``` file with some standard commands and the location of commonly used programs. MY ```profile.do``` links to ```plink```, ```plink2```, ```tabbed.pl``` and a range of windows executables that I have collected over the years that mimic ```linux``` commands. The ```profile.do``` file can be found in ```C:\Program Files (x86)\Stata13```.

```
noi di "Opening Time: $S_DATE $S_TIME"                                         // set time when program is intiated
set maxvar 32767, perm
set more off, perm
set mem 1G,perm
set type double,perm
macro drop _all

// define globals
global init_personal "D:\Software\stata\code\dev-ado"
global init_root     "D:\Software\stata\data" 
global init_unix     "D:\Software\bash\bin"

global tabbed         perl D:\Software\perl\code\tabbed.pl
global plink	         "D:\Software\plink\bin\win\plink.exe"
global plink2	        "D:\Software\plink\bin\win\plink2.exe"
global Rterm_path     `"C:\Program Files\R\R-3.3.1\bin\x64\Rterm.exe"'
global Rterm_options  `"--vanilla"'

set scheme plotplainblind , permanently
sysdir set PERSONAL  ${init_personal}                                          // define PERSONAL DIRECTORY
cd                   ${init_root}                                              // set ROOT to DATA
loadUnixReplicas , folder(${init_unix})                                        // set global for unix replicas from init_unix folder

noi di"CURRENT .. working directory is set to ... ${init_root}"
noi di"PERSONAL ..... ado directory is set to ... ${init_personal}"
noi di"---------------------------------------------------------------------------------------------------"
noi di"Defining universal global files ....... "
noi di"............... PLINK ................. $plink "
noi di"............... PLINK2 ................ $plink2 "
noi di"............... TABBED ................ $tabbed "
noi di"............... UNIX . ................ $init_unix "
noi di"............... R ..................... $Rterm_path "
noi di"............... R (option) ............ $Rterm_options"
noi di"---------------------------------------------------------------------------------------------------"
```
## Background
This is a repository of stata programs that I have written. Most are for use in genomic analysis and were written to work on a windows 10 machine and STATA 13.1 MP.

To install all packages run the following script;
```
 https://github.com/ricanney/stata/blob/master/code/install-all.do
```
This script also includes additional dependencies not written by this author others).

| Programs        | Description | Files
| :-------------- | :----------------------------------------------------------------	| :---------	
| ```bim2dta```         | convert plink \*.bim file to stata \*.dta format                                     | ![info](https://github.com/ricanney/stata/blob/master/documents/bim2dta.md) ![ado](https://github.com/ricanney/stata/blob/master/code/b/bim2dta.ado)	
| ```bim2eigenvec```	   | generate \*.eigenvec and \*.eigenval files from plink \*.bim file                   	| ![info](https://github.com/ricanney/stata/blob/master/documents/bim2eigenvec.md) ![ado](https://github.com/ricanney/stata/blob/master/code/b/bim2eigenvec.ado)	
| ```bim2ldexclude```	  | generate the long-range linkage disequilibrium exclude region from plink \*.bim file	| ![info](https://github.com/ricanney/stata/blob/master/documents/bim2ldexclude.md) ![ado](https://github.com/ricanney/stata/blob/master/code/b/bim2exclude.ado)	
| ```datestamp```	      | create a non-space datestamp in global that can be accessed via $DATA               	| ![info](https://github.com/ricanney/stata/blob/master/documents/datestamp.md) ![ado](https://github.com/ricanney/stata/blob/master/code/d/datestamp.ado)	
| ```ensembl2symbol``` 	| maps gene symbols to ensembl identifiers                                            	| ![info](https://github.com/ricanney/stata/blob/master/documents/ensembl2symbol.md) ![ado](https://github.com/ricanney/stata/blob/master/code/e/ensembl2symbol.ado)	
| ```fam2dta```	        | convert plink \*.fam file to stata \*.dta format                                    	| ![info](https://github.com/ricanney/stata/blob/master/documents/fam2dta.md) ![ado](https://github.com/ricanney/stata/blob/master/code/f/fam2dta.ado)	
| ```genotypeqc```	     | perform qc-pipeline on genotype array data                                          	| ![info](https://github.com/ricanney/stata/blob/master/documents/genotypeqc.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/genotypeqc.ado)	
| ```graphgene```	      | plot exon/gene structure from chromosome location (hg19)                            	| ![info](https://github.com/ricanney/stata/blob/master/documents/graphgene.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphgene.ado)	
| ```graphmanhattan``` 	| plot simple manhattan plot from association data (chr bp p)                         	| ![info](https://github.com/ricanney/stata/blob/master/documents/graphmanhattan.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphmanhattan.ado)	
| ```graphplinkfrq```	  | plot allele frequency distribution from plink generated \*.frq file                 	| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkfrq.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkfrq.ado)	
| ```graphplinkhet```	  | plot heterozygosity distribution from plink generated \*.het file                  		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkhet.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkhet.ado)	
| ```graphplinkhwe```	  | plot hardy-weinberg p-value distribution from plink generated \*.hwe file          		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkhwe.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkhwe.ado)	
| ```graphplinkimiss```	| plot missingness (by individual) from plink generated \*.imiss file                		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkimiss.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkimiss.ado)	
| ```graphplinkkin0```	 | plot kinship distribution from plink generated \*.kin0 file                        		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinkkin0.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkkin0.ado)	
| ```graphplinklmiss```	| plot missingness (by locus) from plink generated \*.lmiss file                     		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphplinklmiss.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinklmiss.ado)	
| ```graphqq```	        | plot simple qq (pp) plot from association data (p)                                 		| ![info](https://github.com/ricanney/stata/blob/master/documents/graphqq.md)	![ado](https://github.com/ricanney/stata/blob/master/code/g/graphqq.ado)	
| ```gwas2prs```	       | prepare association files for profilescore (PRS) analysis                           	| ![info](https://github.com/ricanney/stata/blob/master/documents/gwas2prs.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/gwas2prs.ado)	
| ```loadUnixReplicas```| load windows executables that mimic unix commands                                    | ![info](https://github.com/ricanney/stata/blob/master/documents/loadUnixReplicas.md) ![ado](https://github.com/ricanney/stata/blob/master/code/l/loadUnixReplicas.ado)
| ```profilescore```	   | create profile (polygenic risk score) from ```gwas2prs``` and ```genotypeqc``` processed data	| ![info](https://github.com/ricanney/stata/blob/master/documents/profilescore.md) ![ado](https://github.com/ricanney/stata/blob/master/code/p/profilescore.ado)	
| ```recodegenotype```  | converts ACGT+ID coded alleles to UIPAC genotype codes                              	| ![info](https://github.com/ricanney/stata/blob/master/documents/recodegenotype.md) ![ado](https://github.com/ricanney/stata/blob/master/code/r/recodegenotype.ado)	
| ```recodestrand```	   | flip alleles to a refrence strand including reverse complementary coding            	| ![info](https://github.com/ricanney/stata/blob/master/documents/recodestrand.md) ![ado](https://github.com/ricanney/stata/blob/master/code/r/recodestrand.ado)	
| ```symbol2ensembl```	 | maps ensembl identifiers to gene symbols                                            	| ![info](https://github.com/ricanney/stata/blob/master/documents/symbol2ensembl.md) ![ado](https://github.com/ricanney/stata/blob/master/code/s/symbol2ensembl.ado)	
