from sfi import Data
from sfi import Macro

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
	TX_DATE = Data.get("TX_DATE", OBS, "", False, 0)[0][0]

	# If the start period is the first, we can calcluate days from the eligeff, and skip the loop
	if START_INDEX == 1:
		CURRENT_EFF = Data.get("eligeff1", OBS, "", False, 0)[0][0]
		ENRL_DAYS = TX_DATE - CURRENT_EFF
		
		Data.storeAt("CM_LEAD_IN", OBS, ENRL_DAYS)
		continue
		
	# Work backwards
	for ENRL_PERIOD in range(START_INDEX, 0, -1):
		# We care about the gap, because we want to detect overlapping enrollment periods and compensate
		#Need to do this, since will error out trying to access ENRL_PERIOD = 0
		if (ENRL_PERIOD == 1):
			CURRENT_EFF = Data.get("eligeff"+str(ENRL_PERIOD), OBS, "", False, 0)[0][0]
			CURRENT_END = Data.get("eligend"+str(ENRL_PERIOD), OBS, "", False, 0)[0][0]
		else:
			CURRENT_EFF = Data.get("eligeff"+str(ENRL_PERIOD), OBS, "", False, 0)[0][0]
			CURRENT_END = Data.get("eligend"+str(ENRL_PERIOD), OBS, "", False, 0)[0][0]
			PREV_START = Data.get("eligeff"+str(ENRL_PERIOD-1), OBS, "", False, 0)[0][0]
			PREV_END = Data.get("eligend"+str(ENRL_PERIOD-1), OBS, "", False, 0)[0][0]
			ENRL_GAP = CURRENT_EFF - PREV_END

		# This means the previous period is overlapping. We want to use the earliest start date (biggest range)
		if ENRL_GAP < 0:
			START_GAP = CURRENT_EFF - PREV_START
			if START_GAP > 0:
				CURRENT_EFF = PREV_START

		# Means we're on the starting period 
		if (ENRL_PERIOD == START_INDEX):
			Data.storeAt("CM_LEAD_IN", OBS, TX_DATE - CURRENT_EFF)
			continue

		current_lead_in = Data.get("CM_LEAD_IN", OBS, "", False, 0)[0][0]
		Data.storeAt("CM_LEAD_IN", OBS, current_lead_in + (CURRENT_END - CURRENT_EFF))
	
	# We want the number of enrollment periods each patient had
	PLAN_COUNT = int(Data.get("PLAN_COUNT", OBS, "", False, 0)[0][0])

