/*
========================================================
NAME	SCC_count					|
DESCR 	Calculate number of SCCs prior to treatment	|
INPUT	RAW_DATA/PROC_SCCEXC, DX_SCC			|
OUTPUT	SCC_COUNT_PROC					|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"

if ("`LEAD_IN_CUTOFF'" == "") {
	local LEAD_IN_CUTOFF = 0 // Use unlimited look back by default
}
*---------------------------------------------------------------

* We use claim IDs to match the SCC code with a surgery event. Must be on the same clmid to count
* Looks like claim IDs are not unique. Need to use a patid + clmid fusion key
use pt_clm using `SCCEXC_RAW', clear
duplicates drop
save Intermediates/SCC_SURG_clmids, replace

* Next, merge in the pt_clms, and keep only the matches
use `SCCDX_RAW', clear
merge m:1 pt_clm using Intermediates/SCC_SURG_clmids
keep if _merge == 3
drop _merge pt_clm
save Masters/SCC-TXONLY, replace

*Pull in TX_DATE from the patient list. We want to drop AK diagnoses that are after the TX_DATE
merge m:1 patid using `MPL', keepus(TX_DATE)

*Have to keep the code 2 patients. These are pts with no prior AKs, so we set to 0
* We don't generate the count until later. Don't drop _merge until we do this.
keep if _merge == 3 | _merge == 2

* Because _merge 2 records are incomplete. This will cause all 2 records to drop
* Want to only look at data in the lead in period
* Generate time range to count SCCs
drop if fst_dt > TX_DATE & _merge == 3

* Only do this if a cutoff is specified
if (`LEAD_IN_CUTOFF' > 0) {
	gen LEAD_IN_START = TX_DATE - `LEAD_IN_CUTOFF'
	drop if fst_dt < LEAD_IN_START & _merge == 3
}

* Count instances of AK, after we drop AKs occuring after TX_DATE
sort patid TX_DATE
by patid: gen SCC_count = _n
by patid: keep if _n == _N
drop clmid fst_dt

* _merge 2 represents pts with no SCC data. Set SCC_count = 0
replace SCC_count = 0 if _merge == 2
drop _merge

* Merge in the MPL again. If a pt has only 1 SCC after TX_DATE, they are entirely lost. This restores them into the dataset
merge m:1 patid using `MPL', keepus(patid)
replace SCC_count = 0 if _merge == 2
drop _merge


keep patid SCC_count
save `SCC_COUNT_PROC', replace

tabstat SCC_count, by(SCC_count) statistic(count)
