from sfi import Data
from sfi import Macro

MAX_ENRL_GAP = int(Macro.getLocal("MAX_COVERAGE_GAP"))

TOTAL_OBS = Data.getObsTotal()
for OBS in range(TOTAL_OBS):
	PLAN_COUNT = int(Data.get("PLAN_COUNT", OBS, "", False, 0)[0][0])
	for ENRL_PERIOD in range(1, 49):
		START_FLAG = int(Data.get("START"+str(ENRL_PERIOD), OBS, "", False, 0)[0][0])
		if START_FLAG == 1:
			START_INDEX = ENRL_PERIOD
			break
	

	
	if START_INDEX == 1:
		CURRENT_EFF = Data.get("eligeff1", OBS, "", False, 0)[0][0]
		Data.storeAt("C_START", OBS, CURRENT_EFF)
		
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
			
		CURRENT_EFF = Data.get("C_START", OBS, "", False, 0)[0][0]
	
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
