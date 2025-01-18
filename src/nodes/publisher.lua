require("src.utils")

---@class LoveFlow.Publisher.Internal
local pub = {}

---Create a new publisher.
---@param event_bus LoveFlow.EventBus
---@param alias? string Alias assigned
---@return LoveFlow.Publisher
function pub.new(event_bus, alias)
	---@class LoveFlow.Publisher
	local new_pub = {
		alias = alias or nil,
		id = GenerateID(),
		parent_bus = event_bus,
		---Publish an event.
		---@param self LoveFlow.Publisher
		---@param content any
		publish = function(self, content)
			table.insert(self.parent_bus.pool[self.id], content)
		end,
		---Update the parent event bus. Called inside Arch:updateAll()
		---@param self LoveFlow.Publisher
		---@param updated_bus LoveFlow.EventBus
		update = function(self, updated_bus)
			self.parent_bus = updated_bus
		end,
	}
	event_bus.pubs[new_pub.id] = new_pub
	event_bus.pool[new_pub.id] = {} -- create event pool for publisher
	return new_pub
end

return pub
