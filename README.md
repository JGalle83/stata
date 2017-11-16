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
| bim2dta         | convert plink \*.bim file to stata \*.dta format                                     | ![bim2dta](https://github.com/ricanney/stata/blob/master/bim2dta.md)	
| bim2eigenvec	   | generate \*.eigenvec and \*.eigenval files from plink \*.bim file                   	| ![bim2eigenvec](https://github.com/ricanney/stata/blob/master/bim2eigenvec.md)
| bim2ldexclude	  | generate the long-range linkage disequilibrium exclude region from plink \*.bim file	| ![bim2ldexclude](https://github.com/ricanney/stata/blob/master/bim2ldexclude.md)
| datestamp	      | create a non-space datestamp in global that can be accessed via $DATA               	| ![datestamp](https://github.com/ricanney/stata/blob/master/datestamp.md)
| ensembl2symbol 	| convert plink *.bim file to stata *.dta format	| ![ensembl2symbol](https://github.com/ricanney/stata/blob/master/ensembl2symbol.md)
| fam2dta	        | convert plink *.bim file to stata *.dta format	| ![fam2dta](https://github.com/ricanney/stata/blob/master/fam2dta.md)
| genotypeqc	     | convert plink *.bim file to stata *.dta format	| ![genotypeqc](https://github.com/ricanney/stata/blob/master/genotypeqc.md)	|
| graphgene	      | convert plink *.bim file to stata *.dta format	| ![graphgene](https://github.com/ricanney/stata/blob/master/graphgene.md)	|
| graphmanhattan 	| convert plink *.bim file to stata *.dta format	| ![graphmanhattan](https://github.com/ricanney/stata/blob/master/graphmanhattan.md)	|
| graphplinkfrq	  | convert plink *.bim file to stata *.dta format	| ![graphplinkfrq](https://github.com/ricanney/stata/blob/master/graphplinkfrq.md)	|
| graphplinkhet	  | convert plink *.bim file to stata *.dta format	| ![graphplinkhet](https://github.com/ricanney/stata/blob/master/graphplinkhet.md)	|
| graphplinkhwe	  | convert plink *.bim file to stata *.dta format	| ![graphplinkhwe](https://github.com/ricanney/stata/blob/master/graphplinkhwe.md)	|
| graphplinkimiss	| convert plink *.bim file to stata *.dta format	| ![graphplinkimiss](https://github.com/ricanney/stata/blob/master/graphplinkimiss.md)	|
| graphplinkkin0	 | convert plink *.bim file to stata *.dta format	| ![graphplinkkin0](https://github.com/ricanney/stata/blob/master/graphplinkkin0.md)	|
| graphplinklmiss	| convert plink *.bim file to stata *.dta format	| ![graphplinklmiss](https://github.com/ricanney/stata/blob/master/graphplinklmiss.md)	|
| graphqq	        | convert plink *.bim file to stata *.dta format	| ![graphqq](https://github.com/ricanney/stata/blob/master/graphqq.md)	|
| gwas2prs	       | convert plink *.bim file to stata *.dta format	| ![gwas2prs](https://github.com/ricanney/stata/blob/master/gwas2prs.md)	|
| profilescore	   | convert plink *.bim file to stata *.dta format	| ![profilescore](https://github.com/ricanney/stata/blob/master/profilescore.md)	|
| recodegenotyp	  | convert plink *.bim file to stata *.dta format	| ![recodegenotyp](https://github.com/ricanney/stata/blob/master/recodegenotyp.md)	|
| recodestrand	   | convert plink *.bim file to stata *.dta format	| ![recodestrand](https://github.com/ricanney/stata/blob/master/recodestrand.md)	|
| symbol2ensembl	 | convert plink *.bim file to stata *.dta format	| ![symbol2ensembl](https://github.com/ricanney/stata/blob/master/symbol2ensembl.md)	|


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
