/*
========================================================
NAME	PROC_AKDESTR					|
DESCR 	Pull AK destruction procedures from Optum	|
INPUT	OPTUM_DIR/ses_m					|
OUTPUT	PROC_DATA/PROC_AKDESTR				|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"
local OPTUM_FILE_TYPE = "m"

*------------------------------------------------------------------------------
foreach YEAR of numlist `YR_START'/`YR_END'{
    foreach QUARTER in q1 q2 q3 q4 {
    	* Stata hack. Capture permits the do-file to continue despite error. We catch the error and break the loop when return code != 0
        capture use `OPTUM_DIR'/ses_`OPTUM_FILE_TYPE'`YEAR'`QUARTER', clear
	if (_rc != 0) continue, break
	
	keep if regexm(proc_cd, "1700[04]")
        keep `PROC_FIELDS'
	tostring patid, replace format(%19.0f)
	gen pt_clm = patid + clmid
        save Intermediates/`OPTUM_FILE_TYPE'`YEAR'`QUARTER'.dta, replace
    }
}

* Combine into 1 file
* Create a dummy variable, then append all files together.

clear
gen t = .

foreach YEAR of numlist `YR_START'/`YR_END' {
    foreach QUARTER in q1 q2 q3 q4 {
        capture append using Intermediates/`OPTUM_FILE_TYPE'`YEAR'`QUARTER'.dta
	if (_rc != 0) continue, break
    }
}
drop t

save `RAW_DATA'/PROC_AKDESTR, replace
