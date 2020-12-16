/*
========================================================
NAME	ENV_HEADER					|
DESCR 	Just an environment header for all programs	|
OUTPUT	None						|
========================================================
*/

local DIR = "/project/etzkorn_MMSutilization/brian/AK_files"
local DO_FILES = "`DIR'/Do files/"
local RAW_DATA = "`DIR'/Masters/Raw"
local PROC_DATA = "`DIR'/Masters"
local OPTUM_DIR = "/origdata/Optum2019"
local MPL = "`PROC_DATA'/MPL.dta"
local INCLUDE_DIR = "`PROC_DATA'/Include"
local EXCLUDE_DIR = "`PROC_DATA'/Exclude"
local APPEND_DIR = "`PROC_DATA'/Append"
local YR_START = 2014
local YR_END = 2019

local AK_DESTR_RAW = "`RAW_DATA'/PROC_AKDESTR"
local AKDX_RAW = "`RAW_DATA'/DX_AK"
local AK_COUNT_PROC = "`APPEND_DIR'/AK_counts"
local BX_RAW = "`RAW_DATA'/PROC_BIOPSY"
local BX_PROC = "`EXCLUDE_DIR'/BXPATIENTS"
local SCCEXC_RAW = "`RAW_DATA'/PROC_SCCEXC"
local SCCDX_RAW = "`RAW_DATA'/DX_SCC"
local SCC_COUNT_PROC = "`APPEND_DIR'/SCC_counts"
local ENRL_TIMES = "`APPEND_DIR'/Enrollment_times"
local FIRST_SCC = "`APPEND_DIR'/First_SCC"


local PROC_FIELDS = "patid pat_planid clmid std_cost std_cost_yr charge proc_cd provcat prov_par fst_dt copay deduct prov provcat"
local DX_FIELDS = "patid pat_planid clmid diag fst_dt"

* Keep all RX fields.
*local RX_FIELDS = "patid pat_planid clmid fst_dt"


cd "`DIR'/Autoprocess/Proc"
