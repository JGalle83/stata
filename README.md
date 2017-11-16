# software - stata
## Background
This is a repository of stata programs that I have written. Most are for use in genomic analysis and were written to work on a windows 10 machine and STATA 13.1 MP.

To install all packages run the following script;
```
 https://github.com/ricanney/stata/blob/master/code/install-all.do
```
This script also includes additional dependencies not written by this author others).

| Programs        | Description | Files
| :-------------- | :----------------------------------------------------------------	| :---------	
| ```bim2dta```         | convert plink \*.bim file to stata \*.dta format                                     | ![info](https://github.com/ricanney/stata/blob/master/bim2dta.md) ![ado](https://github.com/ricanney/stata/blob/master/code/b/bim2dta.ado)	
| ```bim2eigenvec```	   | generate \*.eigenvec and \*.eigenval files from plink \*.bim file                   	| ![info](https://github.com/ricanney/stata/blob/master/bim2eigenvec.md) ![ado](https://github.com/ricanney/stata/blob/master/code/b/bim2eigenvec.ado)	
| ```bim2ldexclude```	  | generate the long-range linkage disequilibrium exclude region from plink \*.bim file	| ![info](https://github.com/ricanney/stata/blob/master/bim2ldexclude.md) ![ado](https://github.com/ricanney/stata/blob/master/code/b/bim2exclude.ado)	
| ```datestamp```	      | create a non-space datestamp in global that can be accessed via $DATA               	| ![info](https://github.com/ricanney/stata/blob/master/datestamp.md) ![ado](https://github.com/ricanney/stata/blob/master/code/d/datestamp.ado)	
| ```ensembl2symbol``` 	| maps gene symbols to ensembl identifiers                                            	| ![info](https://github.com/ricanney/stata/blob/master/ensembl2symbol.md) ![ado](https://github.com/ricanney/stata/blob/master/code/e/ensembl2symbol.ado)	
| ```fam2dta```	        | convert plink \*.fam file to stata \*.dta format                                    	| ![info](https://github.com/ricanney/stata/blob/master/fam2dta.md) ![ado](https://github.com/ricanney/stata/blob/master/code/f/fam2dta.ado)	
| ```genotypeqc```	     | perform qc-pipeline on genotype array data                                          	| ![info](https://github.com/ricanney/stata/blob/master/genotypeqc.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/genotypeqc.ado)	
| ```graphgene```	      | plot exon/gene structure from chromosome location (hg19)                            	| ![info](https://github.com/ricanney/stata/blob/master/graphgene.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphgene.ado)	
| ```graphmanhattan``` 	| plot simple manhattan plot from association data (chr bp p)                         	| ![info](https://github.com/ricanney/stata/blob/master/graphmanhattan.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphmanhattan.ado)	
| ```graphplinkfrq```	  | plot allele frequency distribution from plink generated \*.frq file                 	| ![info](https://github.com/ricanney/stata/blob/master/graphplinkfrq.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkfrq.ado)	
| ```graphplinkhet```	  | plot heterozygosity distribution from plink generated \*.het file                  		| ![info](https://github.com/ricanney/stata/blob/master/graphplinkhet.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkhet.ado)	
| ```graphplinkhwe```	  | plot hardy-weinberg p-value distribution from plink generated \*.hwe file          		| ![info](https://github.com/ricanney/stata/blob/master/graphplinkhwe.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkhwe.ado)	
| ```graphplinkimiss```	| plot missingness (by individual) from plink generated \*.imiss file                		| ![info](https://github.com/ricanney/stata/blob/master/graphplinkimiss.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkimiss.ado)	
| ```graphplinkkin0```	 | plot kinship distribution from plink generated \*.kin0 file                        		| ![info](https://github.com/ricanney/stata/blob/master/graphplinkkin0.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinkkin0.ado)	
| ```graphplinklmiss```	| plot missingness (by locus) from plink generated \*.lmiss file                     		| ![info](https://github.com/ricanney/stata/blob/master/graphplinklmiss.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/graphplinklmiss.ado)	
| ```graphqq```	        | plot simple qq (pp) plot from association data (p)                                 		| ![info](https://github.com/ricanney/stata/blob/master/graphqq.md)	![ado](https://github.com/ricanney/stata/blob/master/code/g/graphqq.ado)	
| ```gwas2prs```	       | prepare association files for profilescore (PRS) analysis                           	| ![info](https://github.com/ricanney/stata/blob/master/gwas2prs.md) ![ado](https://github.com/ricanney/stata/blob/master/code/g/gwas2prs.ado)	
| ```profilescore```	   | create profile (polygenic risk score) from ```gwas2prs``` and ```genotypeqc``` processed data	| ![info](https://github.com/ricanney/stata/blob/master/profilescore.md) ![ado](https://github.com/ricanney/stata/blob/master/code/p/profilescore.ado)	
| ```recodegenotype```  | converts ACGT+ID coded alleles to UIPAC genotype codes                              	| ![info](https://github.com/ricanney/stata/blob/master/recodegenotype.md) ![ado](https://github.com/ricanney/stata/blob/master/code/r/recodegenotype.ado)	
| ```recodestrand```	   | flip alleles to a refrence strand including reverse complementary coding            	| ![info](https://github.com/ricanney/stata/blob/master/recodestrand.md) ![ado](https://github.com/ricanney/stata/blob/master/code/r/recodestrand.ado)	
| ```symbol2ensembl```	 | maps ensembl identifiers to gene symbols                                            	| ![info](https://github.com/ricanney/stata/blob/master/symbol2ensembl.md) ![ado](https://github.com/ricanney/stata/blob/master/code/s/symbol2ensembl.ado)	

#### Syntax
'''
bim2dta, bim(filename)
'''
#### Description



### bim2eigenvec
### bim2ldexclude
### datestamp
### ensembl2symbol
### fam2dta
### genotypeqc
### graphgene
### graphmanhattan
### graphplinkfrq
### graphplinkhet
### graphplinkhwe
### graphplinkimiss
### graphplinkkin0
### graphplinklmiss
### graphqq
### gwas2prs
### profilescore
### recodegenotyp
### recodestrand
### symbol2ensembl



'''
## Programs
### bim2dta
#### Syntax
'''
bim2dta, bim(filename)
'''
#### Description



### bim2eigenvec
### bim2ldexclude
### datestamp
### ensembl2symbol
### fam2dta
### genotypeqc
### graphgene
### graphmanhattan
### graphplinkfrq
### graphplinkhet
### graphplinkhwe
### graphplinkimiss
### graphplinkkin0
### graphplinklmiss
### graphqq
### gwas2prs
### profilescore
### recodegenotyp
### recodestrand
### symbol2ensembl


# data-repositories
to run genotypeqc download the following archive;
* https://www.dropbox.com/s/u7s9su44beda710/sandbox.tar.gz?dl=0 - archive
* https://www.dropbox.com/s/4q1oh1nsxhnoww5/sandbox.tar.gz.md5?dl=0 - md5
