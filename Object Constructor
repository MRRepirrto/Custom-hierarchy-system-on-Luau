local EventConstructor = require()
local ProtectedUserdata = require()


local function newIndexObjectFunction(Object, Index, Value)
	ProtectedUserdata.startFunctions.newindex(Object, Index, Value)
	
	local meta: ProtectedUserdata.UserdataStore = getmetatable(Object)
	local properties = meta.Properties
	local property: ProtectedUserdata.UserdataValue = properties[Index]
	
	Object.Changed:Fire(Index)
	
	property.Event:Fire(Value)
end


--//INDEX FUNCTIONS FOR OBJECT ITSELF


local Object = {}


function Object.IsA(self: Object, name: string) : boolean
	return self.ClassName == name
end


function Object.GetPropertyChangedSignal(self: Object, name: string) : EventConstructor.Event
	local changedEvent = self.Changed
	local meta: ProtectedUserdata.UserdataStore = getmetatable(self)
	
	local property = meta.Properties[name]
	
	assert(typeof(self[name]) ~= "function", "Attempt to get a change event for a function with index "..name)
	assert(property, "Attempt to get a change event for a non-existing property with index '"..name.."'")
	assert(property.Restriction.Change ~= "strict", "Attempt to get a change event from unchangable property with name "..name)
	
	return property.Event
end


--//OBJECT FUNCTION


local function setUpMeta(meta)
	meta.__newindex = newIndexObjectFunction
end


local function setUpProperties(meta)
	for index, value in meta.Properties do
		
		if value.Restriction and value.Restriction.Change ~= "strict" then
			value.Event = EventConstructor.new()
		end
		
	end
end


local function createObject<Table>(properties: Table & {[string]: ProtectedUserdata.UserdataValue}, className: string): Object & ProtectedUserdata.returnValues<Table>
	local self = ProtectedUserdata.new({
		ClassName = {
			Value = className,
			Restriction = {
				Index = "nonstrict",
				Change = "strict"
			}
		},
		Changed = {
			Value = EventConstructor.new(),
			Restriction = {
				Index = "nonstrict",
				Change = "strict"
			}
		}
	})
	
	self:Combine(Object)
	self:AddProperties(properties)
	
	local meta = getmetatable(self)
	
	setUpMeta(meta)
	setUpProperties(meta)
	
	return self
end


export type ObjectValue = ProtectedUserdata.UserdataValue & {Event: EventConstructor.Event}


export type Object = {
	ClassName: string,
	Changed: EventConstructor.Event,
	IsA: (self: Object, name: string) -> boolean,
	GetPropertyChangedSignal: (self: Object, name: string) -> EventConstructor.Event
} & ProtectedUserdata.Userdata


return table.freeze({
	new = createObject
})
