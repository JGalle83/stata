program loadUnixReplicas
*! version 0.1a 02oct2015 richard anney
version 10.1
syntax , folder(string asis) 

di in white"#########################################################################"
di in white"# loadUnixReplicas - version 0.1a 02oct2015 richard anney "
di in white"#########################################################################"
di in white"# Load global definitions for unixreplicas"
di in red `"# as an alternative use !bash -c "<unix code>""'
di in white"#########################################################################"
di in white"# Started: $S_DATE $S_TIME"
di in white"#########################################################################"
di in white"# > scan `folder' for *.exe "
qui {
	clear
	set obs 1
	gen unixreplicas = ""
	save _tmpunixreplicas.dta,replace
	local myfiles: dir "`folder'" files "*.exe" 
	foreach file of local myfiles { 
		clear
		set obs 1
		gen unixreplicas = "`file'" 
		append using _tmpunixreplicas.dta
		save _tmpunixreplicas.dta,replace
		} 
	}
di in white"# > creating globals for individual *.exe "
qui {
	drop if unixreplicas == ""
	split unixreplicas,p(".exe")
	gen a1 = "global "
	gen a2 = " `folder'\"
	egen a = concat(a1 unixreplicas1 a2 unixreplicas)
	outsheet a using _tmpunixreplicas.do, non noq replace
	do _tmpunixreplicas.do
	erase _tmpunixreplicas.dta
	erase _tmpunixreplicas.do
	clear
	}
di in white"#########################################################################"
di in white"# Completed: $S_DATE $S_TIME"
di in white"#########################################################################"
end;
