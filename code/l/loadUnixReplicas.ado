program loadUnixReplicas
*! version 0.1a 02oct2015 richard anney
version 10.1
syntax , folder(string asis) 

di "***************************************************"
di "loadUnixReplicas - version 0.1a 02oct2015 richard anney "
di "***************************************************"
di "Load global definitions for unixreplicas"
di "***************************************************"
di "Started: $S_DATE $S_TIME"

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
	end
	