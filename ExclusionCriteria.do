/*
========================================================
NAME	ExclusionCriteria				|
DESCR 	Compiles list of patients who meet exclusion	|
INPUT	RAW_DATA/ExclusionPatients			|
OUTPUT	EXCLUDE_DIR/ExclusionPatients			|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"

local LEAD_IN_CUTOFF = 365.25 * 5
* 10 months by default, unless overridden
if ("`PREGNANCY_BAN'" == "") {
	local PREGNANCY_BAN = 310
}

* Check if this is set. Set = we got called by another program
if ("`PORPHYRIA_BAN'" == "") {
	local PORPHYRIA_BAN = 0
}

* Check if this is set. Set = we got called by another program
if ("`BIOPSY_BAN'" == "") {
	local BIOPSY_BAN = 93
}

if ("`LEAD_IN_CUTOFF'" == "") {
	local LEAD_IN_CUTOFF = 0 // Use unlimited look back by default
}
*---------------------------------------------------------------

* Combine exclusion diagnoses and biopsy patients together. Process using a common pathway
use "`RAW_DATA'/ExclusionPatients", clear
append using "`BX_RAW'"

* Indicative of a biopsy patient
replace ExclReason = "Biopsy" if ExclReason == ""

* Merge in MPL to keep the list restricted to our patients
merge m:1 patid using "`MPL'", keepus(patid TX_DATE)
keep if _merge == 3
drop _merge

*Only use data that is prior to TX_DATE. Look forward is not allowed
drop if fst_dt > TX_DATE


* Looking back further than our cutoff is also not allowed
if (`LEAD_IN_CUTOFF' != 0) {
	drop if fst_dt < (TX_DATE - `LEAD_IN_CUTOFF')
}

* Keep only the latest entry
gsort patid -fst_dt
by patid: keep if _n == 1

keep patid ExclReason fst_dt TX_DATE
ren fst_dt EventDate

* Pregnancy prevents inclusion for 10 months only. Porphyria is forever
if (`PORPHYRIA_BAN' != 0) {
	drop if EventDate + `PORPHYRIA_BAN' < TX_DATE
}

if (`PREGNANCY_BAN' != 0) {
	drop if EventDate + `PREGNANCY_BAN' < TX_DATE
}

if (`BIOPSY_BAN' != 0) {
	drop if EventDate + `BIOPSY_BAN' < TX_DATE
}


save "`EXCLUDE_DIR'/ExclusionPatients", replace
