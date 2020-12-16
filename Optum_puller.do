/*
========================================================
NAME	Optum_puller					|
DESCR 	Pulls data files from Optum *VERY SLOW*		|
INPUT	OPTUM_DIR/					|
OUTPUT	RAW_DATA/					|
========================================================
*/

* Environment header
include "/project/etzkorn_MMSutilization/brian/AK_files/Do files/ENV_HEADER.doh"
local OPTUM_PULLER_FILES = "`DO_FILES'/Optum puller files"
set output error
*-----------------------------------------------------------------------------------------------


*========================================================
* AK information pullers
noisily: disp "Now working on AK diagnoses..."
*include "`OPTUM_PULLER_FILES'/DX_AK.do"

noisily: disp "Now working on AK destruction codes..."
include "`OPTUM_PULLER_FILES'/PROC_AKDESTR.do"


*========================================================
* PDT procedures puller
noisily: disp "Now working on PDT procedures..."
include "`OPTUM_PULLER_FILES'/PROC_PDT.do"


*========================================================
* Field therapy prescription drugs puller
noisily: disp "Now working on field therapy drugs..."
include "`OPTUM_PULLER_FILES'/RX_FIELD_THERAPY.do"


*========================================================
* Biopsy procedures puller
noisily: disp "Now working on biopsies..."
include "`OPTUM_PULLER_FILES'/PROC_BIOPSY.do"


*========================================================
* SCC information pullers
noisily: disp "Now working on SCC diagnoses..."
include "`OPTUM_PULLER_FILES'/DX_SCC.do"

noisily: disp "Now working on SCC excisions..."
include "`OPTUM_PULLER_FILES'/PROC_SCCEXC.do"


