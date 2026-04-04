local GLOBAL_DATA = {}


MAXIMUM_HIERARCHIES = 32
MAXIMUM_KEYS_ON_HIERARCHY = 64
MAXIMUM_SECONDS_ON_MEMORY = 600


local taskSpawn = task.spawn
local taskDelay = task.delay

local insert = table.insert


local function checkForGlobalData()
	if not GLOBAL_DATA then
		warn("EXTERNAL ERROR: GLOBAL_DATA is nil")
		
		GLOBAL_DATA = {}
		
		return
	end
end


local function checkForHierarchy(hierarchy: number)
	if hierarchy > MAXIMUM_HIERARCHIES then
		error("Given number of hierarchy is higher than the maximum allowed")
		
		return false
	end
	
	if not GLOBAL_DATA[hierarchy] then
		warn("INTERNAL ERROR: GLOBAL_DATA["..hierarchy.."] is nil, rewriting it")
		
		GLOBAL_DATA[hierarchy] = {}
		
		return false
	end
	
	return true
end


local function delayedDeletion(hierarchy: number, key: any)
	if not GLOBAL_DATA[hierarchy] then
		warn("INTERNAL ERROR: GLOBAL_DATA["..hierarchy.."] is nil")
		
		return
	end
	
	GLOBAL_DATA[hierarchy][key] = nil
end


local TempDataBase = {}


function TempDataBase.Init()
	GLOBAL_DATA = {}
	
	local amountOfHierarchies = #GLOBAL_DATA
	
	warn("Loading "..MAXIMUM_HIERARCHIES.." hierarchies")
	
	while amountOfHierarchies < MAXIMUM_HIERARCHIES do
		insert(GLOBAL_DATA, {})
		
		amountOfHierarchies += 1
	end
	
	warn("Successfully loaded "..MAXIMUM_HIERARCHIES.." hierarchies")
	
	warn("Temporary data capacity: "..MAXIMUM_HIERARCHIES * MAXIMUM_KEYS_ON_HIERARCHY)
	
	TempDataBase.Analize()
end


function TempDataBase.Analize()
	checkForGlobalData()
	
	warn("Analizing "..#GLOBAL_DATA.." hierarchies")
	
	if #GLOBAL_DATA > MAXIMUM_HIERARCHIES then
		warn("INTERNAL ERROR: Limit of hierarchies exceeded")
		
		for i = MAXIMUM_HIERARCHIES + 1, #GLOBAL_DATA do
			GLOBAL_DATA[i] = nil
		end
	end
	
	
	for position, hierarchy in GLOBAL_DATA do
		for index, key in hierarchy do
			warn("Key: "..tostring(index).." is still on memory in "..position.." hierarchy")
		end
	end
end


function TempDataBase.Insert(key: any, lifeTime: number?) : number
	checkForGlobalData()
	
	for index = 1, MAXIMUM_HIERARCHIES do
		local hierarchy = GLOBAL_DATA[index]

		local amountOfKeys = #hierarchy
		
		if amountOfKeys < MAXIMUM_KEYS_ON_HIERARCHY then
			hierarchy[key] = true
			
			warn("Successfully inserted key ["..tostring(key).."] in "..index.." hierarchy")
			
			lifeTime = if lifeTime then lifeTime else MAXIMUM_SECONDS_ON_MEMORY
			
			taskDelay(lifeTime, delayedDeletion, index, key)
			
			return index
		end
	end
	
	warn("ERROR: No free space for: "..tostring(key))
end


function TempDataBase.Find(key: any, hierarchy: number?) : boolean
	checkForGlobalData()
	
	local success = checkForHierarchy(hierarchy)
	
	if success then
		if GLOBAL_DATA[hierarchy][key] then
			return true
		else
			return false
		end
	end
end


function TempDataBase.Remove(key: any, position: number?)
	checkForGlobalData()
	
	local success = checkForHierarchy(position)
	
	if success then
		if GLOBAL_DATA[position][key] then
			GLOBAL_DATA[position][key] = nil
			
			warn("Successfully removed key ["..tostring(key).."] from "..position.." hierarchy")
			
			return
		end
		
		warn("Invalid hierarchy: "..tostring(position)..", going through all hierarchies")
	end
	
	for index = 1, MAXIMUM_HIERARCHIES do
		if GLOBAL_DATA[index] and GLOBAL_DATA[index][key] then
			GLOBAL_DATA[index][key] = nil
			
			warn("Removed key in hierarchy "..index)
			
			return
		end
	end
		
	warn("Key ["..tostring(key).."] was not found in Global Data")
end


function TempDataBase.PrintOut()
	warn(GLOBAL_DATA)
end

return table.freeze(TempDataBase)
