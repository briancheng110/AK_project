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
*---------------------------------------------------------------

use "`RAW_DATA'/ExclusionPatients", clear
merge m:1 patid using "`MPL'"
keep if _merge == 3
drop _merge

keep patid ExclReason

save "`EXCLUDE_DIR'/ExclusionPatients", replace
