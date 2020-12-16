/*
========================================================
NAME	FIRST_SCC					|
DESCR 	Finds first SCC after treatment			|
INPUT	Masters/SCC-TXONLY				|
OUTPUT	FIRST_SCC					|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"
*---------------------------------------------------------------

* We use claim IDs to match the SCC code with a surgery event. Must be on the same clmid to count
use Masters/SCC-TXONLY, clear

*Pull in TX_DATE from the patient list. DRop all from before TX
merge m:1 patid using `MPL', keepus(TX_DATE)
keep if _merge == 3
drop _merge
drop if fst_dt < TX_DATE

* Keep the earliest instance (first after field therapy)
sort patid fst_dt
by patid: keep if _n == 1

* Cleanup
keep patid fst_dt
ren fst_dt FIRST_SCC


save "`FIRST_SCC'", replace
