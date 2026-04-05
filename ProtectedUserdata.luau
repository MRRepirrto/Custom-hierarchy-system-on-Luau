local taskSpawn = task.spawn
local taskDefer = task.defer


local function indexFunction(Userdata, Index): any
	local Meta: UserdataStore = getmetatable(Userdata)

	local properties = Meta.Properties
	local property: UserdataValue = properties[Index]

	assert(typeof(Index) == "string", "Index name must be a string")

	if property and typeof(property) == "table" then
		local valueRestriction = property.Restriction.Index

		if valueRestriction == "strict" then

			error("Attempt to index with nil: "..Index)

		elseif valueRestriction == "nonstrict" then

			return property.Value

		else

			error("Unknown index restriction: "..property)

		end
	else

		return Meta.IndexTable[Index]

	end
end


local function newIndexFunction(Userdata, IndexTo, ValueTo)
	local Meta: UserdataStore = getmetatable(Userdata)

	local properties = Meta.Properties
	local property: UserdataValue = properties[IndexTo]

	if property and typeof(property) == "table" then
		local valueRestriction = property.Restriction.Change

		if valueRestriction == "strict" then

			error("Attempt to change userdata value: "..IndexTo)

		elseif valueRestriction == "safe" then

			assert(property ~= nil, "Attempt to change value to nil with index: "..IndexTo)

			local typeBefore = typeof(property.Value)
			local typeNow = typeof(ValueTo)

			assert(typeBefore == typeNow, "Attempt to change userdata value type from "..typeBefore.." to "..typeNow.." with index '"..IndexTo.."' and value '"..tostring(ValueTo).."'")

			property.Value = ValueTo

		elseif valueRestriction == "nonstrict" then

			property.Value = ValueTo

		else

			error("Unknown change restriction: "..property)

		end
	else

		error("Attempt to set new property with index: "..IndexTo.." and value: "..tostring(ValueTo))

	end
end


local function setUpMeta(Meta: UserdataStore)
	Meta.__index = indexFunction
	
	Meta.__newindex = newIndexFunction
end


local function setProperties(Meta, values: {[string]: UserdataValue})
	if not Meta.Properties then
		Meta.Properties = {}
	end
	
	for index, value in values do
		local IndexType = typeof(index)
		local ValueType = typeof(value)
		
		local restiction = value.Restriction
		local changeType = restiction.Change
		local indexType = restiction.Index
		
		assert(changeType == "nonstrict" or changeType == "strict" or changeType == "safe", "Unknown change restriction mode: "..changeType)
		assert(indexType == "nonstrict" or indexType == "strict", "Unknown index restriction mode: "..indexType)
		assert(ValueType == "table", "Property value must be a table, got: "..ValueType)
		assert(IndexType == "string", "You can't use numbers as index keys in properties table, got: "..IndexType)
		assert(value.Restriction and value.Restriction.Index ~= nil and value.Restriction.Change ~= nil, "One of the restrictions is not specified")
		assert(Meta.Properties[index] == nil, "Property with index: "..index.." already exists")
		
		Meta.Properties[index] = value
	end
end


local function checkIndexTable(IndexTable: {(...any) -> (...any)})
	assert(typeof(IndexTable) == "table", "Index table must be a table, got "..typeof(IndexTable))
	for index, value in IndexTable do
		assert(typeof(index) ~= "number", "Index must be a string, got "..typeof(index))
		assert(typeof(value) == "function", "Value must be a function, got "..typeof(value))
	end
end


local function combineTables(To: {any}, From: {any})
	for index, value in From do
		To[index] = value
	end
	
	return To
end


--//NEWPROXY FUNCTIONS


local Proxy = {}


function Proxy.Combine(self: Userdata, indexTable: {(...any) -> (...any)})
	checkIndexTable(indexTable)
	
	local Meta: UserdataStore = getmetatable(self)
	
	combineTables(Meta.IndexTable, indexTable)
end


function Proxy.AddProperties(self: Userdata, properties: {[string]: UserdataValue})
	local Meta: UserdataStore = getmetatable(self)
	
	setProperties(Meta, properties)
end


--//NEWPROXY


local function createNewproxy<Table>(properties: Table & UserdataValue) : Userdata & returnValues<Table>
	local self = newproxy(true)
	local meta: UserdataStore = getmetatable(self)
	
	meta.IndexTable = {}
	
	combineTables(meta.IndexTable, Proxy)
	setUpMeta(meta)
	setProperties(meta, properties)
	
	return self
end


export type UserdataRestriction = {
	Index: "strict" | "nonstrict",
	Change: "strict" | "safe" | "nonstrict"
}


export type UserdataValue = {
	Value: any,
	Restriction: UserdataRestriction
}


export type UserdataStore = {
	Properties: {[string]: UserdataValue},
	IndexTable: {(...any) -> (...any)},
	__index: typeof(indexFunction),
	__newindex: typeof(newIndexFunction)
}


export type Userdata = typeof(Proxy)


export type function returnValues(values: type): type
	if values and not values:is("table") then
		error("An argument must be a table, got "..typeof(values), 2)
	end
	
	local name = types.singleton("Value")
	
	local out = types.newtable()
	
	for index, value in values:properties() do
		if not value.read:is("table") then
			error("A value must be a table, got "..typeof(value.read), 2)
		end
		
		for i, v in value.read:properties() do
			if i == name then
				out:setproperty(index, v.read)
			end
		end
	end
	
	return out
end


return table.freeze({
	new = createNewproxy,
	startFunctions = {
		index = indexFunction,
		newindex = newIndexFunction
	}
})
