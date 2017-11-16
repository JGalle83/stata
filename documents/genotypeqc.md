# Title
![genotypeqc](https://github.com/ricanney/stata/blob/master/code/g/genotypeqc.ado) - a program that imports a plink binary file and performs a genotype quality control, creating cleaned plink binaries, ceu-like classifiers and meta-log / docx output reports. 
# Installation
```net install genotypeqc,                from(https://raw.github.com/ricanney/stata/master/code/g/) replace```
# Syntax
```genotypeqc, param(<parameter_file>)```
# Description
This program runs a 'single-line-code' quality control of genotype array data utilising ```plink``` and ```plink2``` within ```stata```. Due to the complexity of the analysis the program utilises numerous reference file requires and other dependencies; these need to be noted in a parameters file. 
## Create a parameters file
The pipeline requires a number of dependencies and thresholds to be defined within a parameters file. The parameter file is basically a set of globals that ```stata``` stores in memory and applies during the qc program
### Definitions
* ```array_ref``` the path to the folder containing the genotype array folders;
* ```build_ref``` the path to the file ```rsid-hapmap-genome-location.dta```
* ```kg_ref_frq``` the path to the file ```eur-1000g-phase1integrated-v3-chrall-impute-macgt5-frq.dta```
* ```hapmap_data``` the path to the plink binaries files for hapmap3-all-hg19-1
* ```aims``` the path to the file ```hapmap3-all-hg19-1-aims.snp-list```
* ```data_folder``` the path to the folder containing the plink binaries to be qc'd
* ```data_input``` the name of the plink binaries to be qc'd
* ```rounds``` the number of rounds of quality contro to be applied (4)
* ```hwep``` the max. hwe deviation in control samples to be tolerated (-log10(p)) (10)
* ```hetsd```  the max. heterozygosity standard deviation from the mean (4)
* ```mind``` the max. missingness per individual to be tolerate (0.02)
* ```geno1``` the max. missingness per SNP to be tolerated (first round) (0.05)
* ```geno2 ``` the max. max. missingness per SNP to be tolerated (final) (0.02)
* ```kin_d``` the min. kinship releationship for duplicates (0.354)
* ```kin_f``` the min. kinship releationship for 1st degree relatives (0.1770)
* ```kin_s``` the min. kinship releationship for 2nd degree relatives (0.0884)
* ```kin_t``` the min. kinship releationship for 3rd degree relatives (0.0442)
### An example parameter file
```
*an example parameter file
global array_ref   "E:\sandbox\example-data\genotyping-arrays\data"
global build_ref   "E:\sandbox\example-data\genome-builds\data\rsid-hapmap-genome-location.dta" 
global kg_ref_frq  "E:\sandbox\example-data\genotypes\1000-genomes\phase1\data\hg19\eur-1000g-phase1integrated-v3-chrall-impute-macgt5-frq.dta"
global hapmap_data "E:\sandbox\example-data\genotypes\hapmap\data\all\hg19-1\hapmap3-all-hg19-1"
global aims        "E:\sandbox\example-data\genotypes\hapmap\data\all\hg19-1\hapmap3-all-hg19-1-aims.snp-list"
global data_folder "E:\sandbox\example-data\genotypes\example" 
global data_input  "example" 
global rounds      4
global hwep        10
global hetsd       4
global maf         0.01
global mind        0.02
global geno1       0.05
global geno2       0.02
global kin_d       0.354
global kin_f       0.177
global kin_s       0.0884
global kin_t       0.0442
*the end of the example parameter file
```
## What is happening under the bonnet?
Although this is a single line of code, it is important to understand what is happening under the bonnet of the code. The code is split into mini modules each performing an important role in the qc.
### 1. the preamble - checking if everything is where it is supposed to be
This part of the code runs a number of checks to make sure everything is in its place and ready for the script. 
> as of 16th November - the parameter file has become streamlined, removing annotation and becoming in essence a \*.do file

| 1. check dependencies including ```plink``` ```plink2``` ```tabbed.pl```
2. create a temp folder using ```ralpha``` -  if the script crashes this is where the temp files and \*.log files will be found
3. check location of all dependent files\folders including;
 1. ```rsid-hapmap-genome-location.dta``` - an rsid list and chromosome location file to determine genome build.
 2. ```eur-1000g-phase1integrated-v3-chrall-impute-macgt5-frq.dta``` - a reference allele frequency file generated from the european 1000-genomes project phase 1-vers3 genotype files.
 3. ```hapmap3-all-hg19-1.bed``` ```hapmap3-all-hg19-1.bim``` ```hapmap3-all-hg19-1.fam``` - reference genotypes from the hapmap3 project.
 4. ```hapmap3-all-hg19-1-aims.snp-list``` - a set of ancestry informative markers derived from the ```hapmap3-all-hg19``` genotypes.
 5. ```genotype-array\data``` - a folder containing reference markers for a range of known genotype arrays enabling assignment of most-likely array to genotype data.
4. check location and presence of plink binaries to be qc'd



plink binary marker file contains information on marker identifiers, chromosome location and allele coding. It is often necessary to import these files into stata. This one line command imports the data, renames the variables, creates a genotype variable ```gt``` using the ```recodegenotype``` program and saves a copy of this coversion in the same directory as filename_bim.dta.

The plink \*.bim file is tab-delimited text file with no header line, one line per variant with the following six fields:
1. Chromosome code (either an integer, or 'X'/'Y'/'XY'/'MT'; '0' indicates unknown) or name
2. Variant identifier
3. Position in morgans or centimorgans (safe to use dummy value of '0')
4. Base-pair coordinate (normally 1-based, but 0 ok; limited to 231-2)
5. Allele 1 (corresponding to clear bits in .bed; usually minor)
6. Allele 2 (corresponding to set bits in .bed; usually major)
Allele codes can contain more than one character.

```
1	rs12354060	0	10004	A	G
1	rs4477212	0	72017	T	A
1	rs6650104	0	554340	G	A
1	rs2185539	0	556738	C	G
1	rs6681105	0	581938	G	A
```

The plink \*_bim.dta file contains 

# Examples
The program does not need the .bim to be included in the command. For example, the plink file example.bim can be converted to example_bim.dta as follows;
```bim2dta, bim(example)```

```
chr	snp	bp	a1	a2	gt
5	rs335163	122483920	G	A	R
5	rs335166	122555741	C	A	M
5	rs335168	122554718	A	C	M
5	rs335170	122510142	A	C	M
5	rs335178	122542019	G	A	R
3	rs33518	42423300	A	G	R
```

# Dependencies
| Program | Installation Command
| :----- | :------
|```recodegenotype``` | ```net install recodegenotype, from(https://raw.github.com/ricanney/stata/master/code/r/) replace```

Note that ```recodegenotype``` is automatically installed alongside ```bim2dta``` 

|```program``` | ```ssc install program```


# data-repositories
to run genotypeqc download the following archive;
* https://www.dropbox.com/s/u7s9su44beda710/sandbox.tar.gz?dl=0 - archive
* https://www.dropbox.com/s/4q1oh1nsxhnoww5/sandbox.tar.gz.md5?dl=0 - md5
