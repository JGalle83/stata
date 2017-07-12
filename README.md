# stata-genomics-ado
This is a repository of stata codes that I have written.
Most are for use in genomic analysis and all were written to work on a windows 10 machine and STATA 13.1 MP


To install all packages run the install_all.do script on your local compute
To install a specific module (and its dependencies) run the following;

*installing the bim2dta package*
```
net install bim2dta, from(https://raw.github.com/ricanney/stata-genomics/master/b/) replace
```
For the above code to work, two additional files are required in the destination folder
* stata.toc
* *package*.pkg

