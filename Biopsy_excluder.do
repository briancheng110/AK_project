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

* Original file has 1 entry per claim ID
* Need to only include AKs that are _prior_ to the TX_DATE

* We start with a list of all biopsies in the time range
use `BX_RAW', clear
merge m:1 patid using Masters/All_patients, keepus(TX_DATE)

* Only interested in pts from our study
keep if _merge == 3

* If they had a biopsy after the TX_DATE, that's ok
drop if fst_dt > TX_DATE
keep patid
duplicates drop
save `BX_PROC', replace
