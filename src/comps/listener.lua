---@class LoveFlow.Listener.Internal
local listener = {}

function listener.new(event_bus)
	---@class LoveFlow.Listener
	---@field target LoveFlow.EventBus
	local new_listener = {
		target = event_bus,
		listen = function(self, action)
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
	return new_listener
end

return listener
