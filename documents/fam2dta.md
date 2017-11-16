# Title
![fam2dta](https://github.com/ricanney/stata/blob/master/code/f/fam2dta.ado) - a program that imports a plink \*.fam (family) file and converts it to a stata \*.dta file. 
# Installation
```net install fam2dta,                from(https://raw.github.com/ricanney/stata/master/code/f/) replace```
# Syntax
```fam2dta, fam(filename)```
# Description
The plink fam file contains information on family identifiers (ped format). It is often necessary to import these files into stata. This one line command imports the data, renames the variables, converts observations to string and saves a copy of this in the same directory as filename_fam.dta.

The plink \*.fam file is space-delimited text file with no header line, one line per variant with the following six fields:
```
1. Family ID ('FID')
2. Within-family ID ('IID'; cannot be '0')
3. Within-family ID of father ('0' if father isn't in dataset)
4. Within-family ID of mother ('0' if mother isn't in dataset)
5. Sex code ('1' = male, '2' = female, '0' = unknown)
6. Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)
```

The plink \*_fam.dta file contains 

# Examples
The program does not need the .fam to be included in the command. For example, the plink file example.fam can be converted to example_fam.dta as follows;
```fam2dta, fam(example)```

```
fid	iid	fatid	motid	sex	pheno
1020	4	2	1	1	-9
1030	1	0	0	2	-9
1030	2	0	0	1	-9
1030	3	2	1	1	-9
1033	1	0	0	2	-9
1033	2	0	0	1	-9
```

# Dependencies
| Program | Installation Command
| :----- | :------
|||
