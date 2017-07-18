# stata-genomics-ado
This is a repository of stata codes that I have written.

Most are for use in genomic analysis and all were written to work on a windows 10 machine and STATA 13.1 MP.

Some packages, like the genotypeqc command use v13+ to create docx files.


To install all packages run the install_all.do script on your local computer

To install a specific module (and its dependencies) run the following;

*installing the bim2dta package*
```
net install bim2dta, from(https://raw.github.com/ricanney/stata-genomics/master/b/) replace
```

For the above code to work, two additional files are required in the destination folder
* stata.toc
* *package*.pkg

# data-repositories
to run genotypeqc download the following archive;
* https://www.dropbox.com/s/u7s9su44beda710/sandbox.tar.gz?dl=0 - archive
* https://www.dropbox.com/s/4q1oh1nsxhnoww5/sandbox.tar.gz.md5?dl=0 - md5
