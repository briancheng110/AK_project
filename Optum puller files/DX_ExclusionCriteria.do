/*
========================================================
NAME	DX_ExclusionCriteria				|
DESCR 	Pull pts with our exclusion criteria		|
INPUT	OPTUM_DIR/ses_diag				|
OUTPUT	RAW_DATA/ExclusionPatients			|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"
local OPTUM_FILE_TYPE = "diag"

*------------------------------------------------------------------------------
foreach YEAR of numlist `YR_START'/`YR_END'{
    foreach QUARTER in q1 q2 q3 q4 {
    	* Stata hack. Capture permits the do-file to continue despite error. We catch the error and break the loop when return code != 0
        capture use `OPTUM_DIR'/ses_`OPTUM_FILE_TYPE'`YEAR'`QUARTER', clear
	if (_rc != 0) continue, break
	
	gen ExclReason = ""
	if (icd_flag[1] == "9") {
		replace ExclReason = "Porphyria" if diag == "2771"
		replace ExclReason = "Pregnancy" if regexm(diag, "^V2[23]")		
	} 
	if (icd_flag[1] == "10") {
		replace ExclReason = "Porphyria" if regexm(diag, "^E80[012]*")
		replace ExclReason = "Pregnancy" if regexm(diag, "^O09[0-9aA]") | regexm(diag, "^Z34[089][0123]"
	}
	drop if ExclReason == ""
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

save `RAW_DATA'/ExclusionPatients, replace
