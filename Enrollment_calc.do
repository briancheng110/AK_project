/*
========================================================
NAME	Enrollment_calc					|
DESCR 	Calculate continuous enrollment before/after tx	|
INPUT	OPTUM_DIR/ses_mbr_detail			|
OUTPUT	ENRL_TIMES					|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"
local ContEnrl_PyScript = "`DO_FILES'/Continuous_enrollment.py"
local CumEnrl_PyScript = "`DO_FILES'/Cumulative_enrollment.py"


* Program options
local SKIP_OPTUM_PULL = 1

* Check if this is set. Set = we got called by another program
if ("`MAX_COVERAGE_GAP'" == "") {
	local MAX_COVERAGE_GAP = 5
}

*---------------------------------------------------------------

if (`SKIP_OPTUM_PULL' == 0) {
	use "`OPTUM_DIR'/ses_mbr_detail", clear
	tostring patid, replace format(%19.0f)

	* This is pre-filter to thin out the files.
	merge m:1 patid using `MPL', keepus(patid)

	* Keep our patients only
	keep if _merge == 3
	drop _merge

	* Generate hybrid key with patid and their planid
	* We wait to do this tostring until after we thin out our dataset
	* dr. b advice: no need to filter by specific plan. Any of them count
	tostring pat_planid, replace format(%19.0g)
	// gen PT_PLN = patid + pat_planid

	* Now we merge in the TX_DATE
	merge m:1 patid using `MPL', keepus(TX_DATE)
	keep if _merge == 3
	drop _merge

	save Intermediates/tmp,replace
}

use Intermediates/tmp,clear

sort patid eligeff
keep patid eligeff eligend TX_DATE

* Pts can enroll 2 different plans that have the same start/end date. We don't care about the plan name, so drop these
duplicates drop patid eligeff eligend, force

* Just gets the number of discrete plan entries for each patient
gen PLAN_COUNT = .
by patid: gen seq = _n
by patid: replace PLAN_COUNT = seq[_N]

gen START = 1 if TX_DATE >= eligeff & TX_DATE <= eligend
replace START = 0 if START == .

reshape wide eligeff eligend  START, i(patid) j(seq)

gen C_START = .
gen C_END = .
gen C_LEAD_IN = .


python
from sfi import Macro
execfile(Macro.getLocal("CumEnrl_PyScript"))
end

/*
* We have a python program to take care of the crazy continuous enrollment logic
python
from sfi import Macro
execfile(Macro.getLocal("ContEnrl_PyScript"))
end

* Once that finishes, we'll have date range for the longest continuous enrollment period for each patid
keep patid C_START C_END TX_DATE


* Calculate lead-in and f/u periods
gen C_LEAD_IN = TX_DATE - C_START
gen C_FOLLOW_UP = C_END - TX_DATE
gen RANGE = LEAD_IN + FOLLOW_UP

* Drop continuous start/end ranges
drop C_START C_END

* And we're done!
save `ENRL_TIMES', replace

/*

keep patid LEAD_IN FOLLOW_UP
