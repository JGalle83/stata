# software - stata
## Background
This is a repository of stata programs that I have written. Most are for use in genomic analysis and were written to work on a windows 10 machine and STATA 13.1 MP.

To install all packages run the following script;
```
 https://github.com/ricanney/stata/blob/master/code/install-all.do
```
This script also includes additional dependencies not written by this author others).

| Programs        | Description | Help Files
| :-------------- | :----------------------------------------------------------------	| :---------	
| ```bim2dta```         | convert plink \*.bim file to stata \*.dta format                                     | ![info](https://github.com/ricanney/stata/blob/master/bim2dta.md)	
| ```bim2eigenvec```	   | generate \*.eigenvec and \*.eigenval files from plink \*.bim file                   	| ![bim2eigenvec](https://github.com/ricanney/stata/blob/master/bim2eigenvec.md)
| ```bim2ldexclude```	  | generate the long-range linkage disequilibrium exclude region from plink \*.bim file	| ![bim2ldexclude](https://github.com/ricanney/stata/blob/master/bim2ldexclude.md)
| ```datestamp```	      | create a non-space datestamp in global that can be accessed via $DATA               	| ![datestamp](https://github.com/ricanney/stata/blob/master/datestamp.md)
| ```ensembl2symbol``` 	| maps gene symbols to ensembl identifiers                                            	| ![ensembl2symbol](https://github.com/ricanney/stata/blob/master/ensembl2symbol.md)
| ```fam2dta```	        | convert plink \*.fam file to stata \*.dta format                                    	| ![fam2dta](https://github.com/ricanney/stata/blob/master/fam2dta.md)
| ```genotypeqc```	     | perform qc-pipeline on genotype array data                                          	| ![genotypeqc](https://github.com/ricanney/stata/blob/master/genotypeqc.md)	|
| ```graphgene```	      | plot exon/gene structure from chromosome location (hg19)                            	| ![graphgene](https://github.com/ricanney/stata/blob/master/graphgene.md)	|
| ```graphmanhattan``` 	| plot simple manhattan plot from association data (chr bp p)                         	| ![graphmanhattan](https://github.com/ricanney/stata/blob/master/graphmanhattan.md)	|
| ```graphplinkfrq```	  | plot allele frequency distribution from plink generated \*.frq file                 	| ![graphplinkfrq](https://github.com/ricanney/stata/blob/master/graphplinkfrq.md)	|
| ```graphplinkhet```	  | plot heterozygosity distribution from plink generated \*.het file                  		| ![graphplinkhet](https://github.com/ricanney/stata/blob/master/graphplinkhet.md)	|
| ```graphplinkhwe```	  | plot hardy-weinberg p-value distribution from plink generated \*.hwe file          		| ![graphplinkhwe](https://github.com/ricanney/stata/blob/master/graphplinkhwe.md)	|
| ```graphplinkimiss```	| plot missingness (by individual) from plink generated \*.imiss file                		| ![graphplinkimiss](https://github.com/ricanney/stata/blob/master/graphplinkimiss.md)	|
| ```graphplinkkin0```	 | plot kinship distribution from plink generated \*.kin0 file                        		| ![graphplinkkin0](https://github.com/ricanney/stata/blob/master/graphplinkkin0.md)	|
| ```graphplinklmiss```	| plot missingness (by locus) from plink generated \*.lmiss file                     		| ![graphplinklmiss](https://github.com/ricanney/stata/blob/master/graphplinklmiss.md)	|
| ```graphqq```	        | plot simple qq (pp) plot from association data (p)                                 		| ![graphqq](https://github.com/ricanney/stata/blob/master/graphqq.md)	|
| ```gwas2prs```	       | prepare association files for profilescore (PRS) analysis                           	| ![gwas2prs](https://github.com/ricanney/stata/blob/master/gwas2prs.md)	|
| ```profilescore```	   | create profile (polygenic risk score) from ```gwas2prs``` and ```genotypeqc``` processed data	| ![profilescore](https://github.com/ricanney/stata/blob/master/profilescore.md)	|
| ```recodegenotype```  | converts ACGT+ID coded alleles to UIPAC genotype codes                              	| ![recodegenotype](https://github.com/ricanney/stata/blob/master/recodegenotyp.md)	|
| ```recodestrand```	   | flip alleles to a refrence strand including reverse complementary coding            	| ![recodestrand](https://github.com/ricanney/stata/blob/master/recodestrand.md)	|
| ```symbol2ensembl```	 | maps ensembl identifiers to gene symbols                                            	| ![symbol2ensembl](https://github.com/ricanney/stata/blob/master/symbol2ensembl.md)	|


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
