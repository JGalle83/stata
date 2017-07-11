program datestamp
version 10.1
  
qui{ 
	clear
	set obs 1
	gen a = "global DATE "
	gen b = "$S_DATE"
	replace b = subinstr(b, " ", "",.) 
	outsheet using _0000tmp.do, replace non noq
	do  _0000tmp.do
	erase  _0000tmp.do
	}
end
