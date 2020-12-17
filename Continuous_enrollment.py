from sfi import Data
from sfi import Macro

# First we get pull in the coverage gap variable from stata
MAX_ENRL_GAP = int(Macro.getLocal("MAX_COVERAGE_GAP"))

# We want to run the entire observation space
for OBS in range(Data.getObsTotal()):

	# Stata provides data called from Data.get as a list. [0][0] is to remove the list part

	# Loop through enrollment periods until we find the one with START_FLAG = 1
	# This is the period that contains the TX_DATE (eligeff < TX_DATE < eligend)
	for ENRL_PERIOD in range(1, 49):
		START_FLAG = int(Data.get("START"+str(ENRL_PERIOD), OBS, "", False, 0)[0][0])
		if START_FLAG == 1:
			START_INDEX = ENRL_PERIOD
			break
	

	# If the start period is the first, we can shortcut and set C_START to our current eligeff
	if START_INDEX == 1:
		CURRENT_EFF = Data.get("eligeff1", OBS, "", False, 0)[0][0]
		Data.storeAt("C_START", OBS, CURRENT_EFF)
	
	# Basic model:
	# 2 loops - 1 working backwards and 1 working forwards
	# Compare the enrollment gap to our MAX_ENRL_GAP variable
	# If within threshold, overwrite the start date to the previous eligeff
	CURRENT_EFF = Data.get("eligeff"+str(START_INDEX), OBS, "", False, 0)[0][0]
	for ENRL_PERIOD in range(START_INDEX, 1, -1):
		PREV_START = Data.get("eligeff"+str(ENRL_PERIOD-1), OBS, "", False, 0)[0][0]
		PREV_END = Data.get("eligend"+str(ENRL_PERIOD-1), OBS, "", False, 0)[0][0]
		ENRL_GAP = CURRENT_EFF - PREV_END

		if ENRL_GAP > MAX_ENRL_GAP:
			Data.storeAt("C_START", OBS, CURRENT_EFF)
			break
		
		# This means the previous period is overlapping. We want to use the earliest start date (biggest range)
		if ENRL_GAP < 0:
			START_GAP = CURRENT_EFF - PREV_START
			if START_GAP > 0:
				Data.storeAt("C_START", OBS, PREV_START)
			else:
				Data.storeAt("C_START", OBS, CURRENT_EFF)
		
		else:
			Data.storeAt("C_START", OBS, PREV_START)
		
		# We want to calculate the gap based on the the longest continuous period we know of already, then extend it
		CURRENT_EFF = Data.get("C_START", OBS, "", False, 0)[0][0]
	
	# We want the number of enrollment periods each patient had
	PLAN_COUNT = int(Data.get("PLAN_COUNT", OBS, "", False, 0)[0][0])
	
	# This means the plan containing the TX_DATE is the last enrollment period
	# Just set C_END to our current eligend
	if START_INDEX == PLAN_COUNT:
		CURRENT_END = Data.get("eligend"+str(START_INDEX), OBS, "", False, 0)[0][0]
		Data.storeAt("C_END", OBS, CURRENT_END)
	

	CURRENT_END = Data.get("eligend"+str(START_INDEX), OBS, "", False, 0)[0][0]	
	for ENRL_PERIOD in range(START_INDEX, PLAN_COUNT, 1):
		NEXT_START = Data.get("eligeff"+str(ENRL_PERIOD+1), OBS, "", False, 0)[0][0]
		NEXT_END = Data.get("eligend"+str(ENRL_PERIOD+1), OBS, "", False, 0)[0][0]
		ENRL_GAP = NEXT_START - CURRENT_END

		if ENRL_GAP > MAX_ENRL_GAP:
			Data.storeAt("C_END", OBS, CURRENT_END)
			break
		
		# This means the previous period is overlapping. We want to use the earliest start date (biggest range)
		if ENRL_GAP < 0:
			END_GAP =  NEXT_END - CURRENT_END
			if END_GAP > 0:
				Data.storeAt("C_END", OBS, NEXT_END)
			else:
				Data.storeAt("C_END", OBS, CURRENT_END)
		
		else:
			Data.storeAt("C_END", OBS, NEXT_END)
			
		CURRENT_END = Data.get("C_END", OBS, "", False, 0)[0][0]
