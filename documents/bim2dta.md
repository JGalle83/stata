# Title
![bim2dta](https://github.com/ricanney/stata/blob/master/code/b/bim2dta.ado) - a program that imports a plink \*.bim (binary marker) file and converts it to a stata \*.dta file. 
# Installation
```net install bim2dta,                from(https://raw.github.com/ricanney/stata/master/code/b/) replace```
# Syntax
```bim2dta, bim(filename)```
# Description
The plink binary marker file contains information on marker identifiers, chromosome location and allele coding. It is often necessary to import these files into stata. This one line command imports the data, renames the variables, creates a genotype variable ```gt``` using the ```recodegenotype``` program and saves a copy of this coversion in the same directory as filename_bim.dta.

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
