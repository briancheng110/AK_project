/*
========================================================
NAME	MPL_preprocessor				|
DESCR 	Compile distinct files into 1 master patient list|
INPUT	RAW_DATA/					|
OUTPUT	PROC_DATA/MPL					|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"
*---------------------------------------------------------------

* Preprocessing of master files
use "`RAW_DATA'/PROC_PDT", clear
gen TX = "PDT"
keep patid TX fst_dt 
append using "`RAW_DATA'/RX_FT", keep(patid gnrc_nm fill_dt)
replace TX = gnrc_nm if TX == ""
drop gnrc_nm

* Create 1 variable that represents date of treatment. PDT quotes this as fst_dt, while prescriptions are fill_dt.
gen TX_DATE = fst_dt
replace TX_DATE = fill_dt if TX_DATE == .
drop fst_dt fill_dt

* Keep only the earliest treatment. Patients can have multiple treatments
sort patid TX_DATE
by patid: keep if _n == 1

save `MPL', replace
