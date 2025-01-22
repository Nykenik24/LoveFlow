local function getScriptFolder() --* get the path from the root folder in which THIS script is running
	return (debug.getinfo(1, "S").source:sub(2):match("(.*/)"))
end

require(getScriptFolder():gsub("/comps", "") .. "/global")

---@class LoveFlow.Listener.Internal
local listener = {}

---@param event_bus LoveFlow.EventBus
---@return LoveFlow.Listener
function listener.new(event_bus)
	---@class LoveFlow.Listener
	---@field target LoveFlow.EventBus
	local new_listener = {
		target = event_bus,
		_alreadyLogged = false,
		listen = function(self, action)
			if not self._alreadyLogged and SHOW_DEBUG_INFO then
				self._alreadyLogged = true
				LOGGER.info(("%s -> Listening to event bus %s"):format(ToStringPretty(self), ToStringPretty(event_bus)))
			end
			for _, broadcast in ipairs(self.target.pool.broadcasts) do
				if type(broadcast) ~= "function" then
					action(self, broadcast)
				end
			end
			for name, pool in pairs(self.target.pool) do
				if type(pool) == "table" and name ~= "broadcasts" then
					for _, content in pairs(pool) do
						if type(content) ~= "function" then
							action(self, content)
						end
					end
				end
			end
		end,
		update = function(self, updated_bus)
			self.target = updated_bus
		end,
	}
	if SHOW_DEBUG_INFO then
		LOGGER.trace("Created new listener")
	end
	return new_listener
end

return listener
