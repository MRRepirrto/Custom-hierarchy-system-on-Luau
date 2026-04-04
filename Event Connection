local ProtectedUserdata = require(<PROTECTED USERDATA FILE>)

local taskWait = task.wait
local spawnFn = task.spawn
local cancel = task.cancel
local desync = task.desynchronize
local sync = task.synchronize


local EventConnection = {}


function EventConnection.Fire(self: EventConnection, ...: any?): boolean?
	local _mode = self._mode
	
	if not self.Connected then
		warn("Attempt to fire disconnected connection, connection was not fired")
		
		return
	end

	if _mode == "serial" then
		
		spawnFn(self._fn, ...)
		
	elseif _mode == "parallel" then
		
		desync()
		spawnFn(self._fn, ...)
		sync()
		
	else
		
		error("Unknown mode: ".._mode)
		
	end
	
	if not self._repeat then
		self:Disconnect()
	end
end


function EventConnection.Disconnect(self: EventConnection)
	self.Connected = false
end


function createConnection(mode: "serial" | "parallel", repeating: boolean, func: (...any) -> ...any) : EventConnection
	local self: EventConnection = ProtectedUserdata.new({
		Connected = {
			Value = true,
			Restriction = {
				Index = "nonstrict",
				Change = "safe"
			}
		},
		_fn = {
			Value = func,
			Restriction = {
				Index = "nonstrict",
				Change = "strict"
			}
		},
		_mode = {
			Value = mode,
			Restriction = {
				Index = "nonstrict",
				Change = "strict"
			}
		},
		_repeat = {
			Value = repeating,
			Restriction = {
				Index = "nonstrict",
				Change = "strict"
			}
		},
		_hierarchy = {
			Value = 0,
			Restriction = {
				Index = "nonstrict",
				Change = "safe"
			}
		}
	})
	
	self.Hierarchy = TempDataBase.Insert(self)
	self:Combine(EventConnection)

	return self
end


export type EventConnection = {
	Connected: boolean,
	_fn: (...any) -> ...any?,
	_repeat: boolean,
	_mode: "serial" | "parallel",
	_hierarchy: number
} & typeof(EventConnection)


return table.freeze({
	new = createConnection
})
