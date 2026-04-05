local ProtectedUserdata = require(<PLACE WHERE YOU HAVE PUT PROTECTED USERDATA>)
local EventConnectionConsturctor = require(<PLACE WHERE YOU HAVE PUT Event Connection>)
local TempDataBase = require(<PLACE WHERE YOU HAVE PUT TemporaryDataBase>)

local pack = table.pack
local insert = table.insert
local remove = table.remove
local clear = table.clear

local taskWait = task.wait


local Event = {}
local connectionsMeta = {__mode = "v", __metatable = "Protected"}


function Event.Connect(self: Event, func: () -> ())
	local connection = EventConnectionConsturctor.new("serial", true, func)
	TempDataBase.Insert(connection)

	insert(self._connections, connection)

	return connection
end


function Event.Wait(self: Event, Timeout: number?) : ()
	local start = if Timeout then time() else nil

	local fired = false
	local packedTable = {}

	local function onFire(...)
		fired = true

		packedTable = pack(...)
	end

	local connection = self:Once(onFire)

	repeat
		if Timeout and (time() - start) >= Timeout then
			warn("Waited for "..Timeout.." seconds, breaking")
			break
		end

		if fired then
			break
		end
	until taskWait()

	connection:Disconnect()

	return unpack(packedTable)
end


function Event.Once(self: Event, func: () -> ())
	local connection = EventConnectionConsturctor.new("serial", false, func)
	TempDataBase.Insert(connection)

	insert(self._connections, connection)

	return connection
end


function Event.ConnectParallel(self: Event, func: () -> ())
	local connection = EventConnectionConsturctor.new("parallel", true, func)
	TempDataBase.Insert(connection)

	insert(self._connections, connection)

	return connection
end


function Event.Fire(self: Event, ...: any)
	local connections = self._connections
	
	for i, connection in connections do
		connection:Fire(...)
	end
end


function Event.DisconnectAll(self: Event)
	for i, v in self._connections do
		v:Disconnect()
	end
end


function createEvent(): Event
	local self = ProtectedUserdata.new({
		_connections = {
			Value = setmetatable({}, connectionsMeta),
			Restriction = {
				Index = "nonstrict",
				Change = "strict"
			}
		}
	})
	
	self:Combine(Event)

	return self
end


export type Event = typeof(Event)


return table.freeze({
	new = createEvent
})
