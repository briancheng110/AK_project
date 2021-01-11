/*==============================
Information to collect:		|
- Treatment type 	x	|
- Prior AKs		x	|
- Prior SCCs		x	|
- Exclude prior biospy	x	|
- Enrollment time	x	|
- Demographics			|
- First SCC after TX	x	|
================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"

* Program options
local NO_OPTUM_PULL = 1
local NO_STATS = 1
local MIN_LEAD_IN = 0
local MIN_CUMULATIVE_LEAD_IN = 0
local LEAD_IN_CUTOFF = 1827 // 0 for unlimited look back
local MIN_FOLLOW = 90
local NO_BIOPSY_RANGE = 90
local MAX_COVERAGE_GAP = 32

* Ban inclusion of patients with criteria for some period of time
local PREGNANCY_BAN = 310
local PORPHYRIA_BAN = 0
local BIOPSY_BAN = 93
*---------------------------------------------------------------

* Yes, we can autogen a file list to run (like system.d scripts), but we'll keep it simple for now
* Optum puller for completeness. You really shouldn't run this unless you need to (~8 hours)
if (`NO_OPTUM_PULL' == 0) {
	include "`DO_FILES'/Optum_puller.do"
}

* Generate MPL
include "`DO_FILES'/MPL_preprocessor.do"

* ================================================================
* AK counter code
* Output = AK_COUNT_PROC
include "`DO_FILES'/AK_count.do"

* ================================================================
* Prior SCC counter code
* Output = SCC_COUNT_PROC
include "`DO_FILES'/SCC_count.do"

* ================================================================
* Biopsy excluder
* Output = BX_PROC
*include "`DO_FILES'/Biopsy_excluder.do"

* ================================================================
* Longest continuous enrollment calculator
* Output = ENRL_TIMES
include "`DO_FILES'/Enrollment_calc.do"

* ================================================================
include "`DO_FILES'/First_SCC.do"


* We save the merging for last
* Merge in AK counts
use `MPL', clear
*merge m:1 patid using "`AK_COUNT_PROC'"


* For all files in the append directory, just tack it on verbatim. Really need to figure out why there are stray pts
local FILE_LIST: dir "`APPEND_DIR'" files "*.dta"
foreach FILE of local FILE_LIST {
	merge m:1 patid using "`APPEND_DIR'/`FILE'"
	drop _merge
}

* Same logic for the Exclude directory, except we want to THROW AWAY matches
local FILE_LIST: dir "`EXCLUDE_DIR'" files "*.dta"
foreach FILE of local FILE_LIST {
	merge m:1 patid using "`EXCLUDE_DIR'/`FILE'"
	keep if _merge == 1
	drop _merge
}

* Start excluding patients based on our criteria
drop if PriorEnrl < `MIN_LEAD_IN'
drop if FollowUp_Enrl < `MIN_FOLLOW'
drop if Cml_LeadIn < `MIN_CUMULATIVE_LEAD_IN'

* Stats time
count

