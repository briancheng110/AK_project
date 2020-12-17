/*
========================================================
NAME	Biopsy_excluder					|
DESCR 	Generate list of pts that had biopsies prior to	|
treatment date						|
INPUT	BX_RAW						|
OUTPUT	BX_PROC						|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"

* Check if this is set already. If set, this means we were called from a higher program
if ("`NO_BIOSPY_RANGE'" == "") {
	local NO_BIOPSY_RANGE = 90
}
*---------------------------------------------------------------


* Original file has 1 entry per claim ID
* Need to only include AKs that are _prior_ to the TX_DATE

* We start with a list of all biopsies in the time range
use `BX_RAW', clear
merge m:1 patid using Masters/All_patients, keepus(TX_DATE)

* Only interested in pts from our study
keep if _merge == 3

* If they had a biopsy after the TX_DATE, that's ok
* Calculate cutoff date range
gen CUTOFF_DATE = TX_DATE - `NO_BIOPSY_RANGE'
keep if fst_dt >= CUTOFF_DATE & fst_dt <= TX_DATE

* Clean up and save
keep patid
duplicates drop
save "`BX_PROC'", replace
