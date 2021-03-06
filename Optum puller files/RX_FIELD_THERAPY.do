/*
========================================================
NAME	RX_FIELD_THERAPY				|
DESCR 	Pull all pts with field therapy from Optum	|
INPUT	OPTUM_DIR/ses_r					|
OUTPUT	PROC_DATA/RX_FT					|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"
local OPTUM_FILE_TYPE = "r"

*------------------------------------------------------------------------------
foreach YEAR of numlist `YR_START'/`YR_END'{
    foreach QUARTER in q1 q2 q3 q4 {
    	* Stata hack. Capture permits the do-file to continue despite error. We catch the error and break the loop when return code != 0
        capture use `OPTUM_DIR'/ses_`OPTUM_FILE_TYPE'`YEAR'`QUARTER', clear
	if (_rc != 0) continue, break
	
	* Compound if statements with regex is VERY slow. Just pre-check the ICD version using the first record
	keep if gnrc_nm=="FLUOROURACIL" | gnrc_nm=="IMIQUIMOD" | gnrc_nm=="INGENOL MEBUTATE"
        *keep patid planid clmid fst_dt
	* keep all the fields
	
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

save `RAW_DATA'/RX_FT, replace
