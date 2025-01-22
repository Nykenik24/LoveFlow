local function getScriptFolder() --* get the path from the root folder in which THIS script is running
	return (debug.getinfo(1, "S").source:sub(2):match("(.*/)"))
end

require(getScriptFolder() .. "/global")

require(UTILS_PATH)

---@class LoveFlow.Publisher.Internal
local pub = {}

---Create a new publisher.
---@param event_bus LoveFlow.EventBus
---@param alias? string Alias assigned
---@return LoveFlow.Publisher
function pub.new(event_bus, alias)
	---@class LoveFlow.Publisher
	---@field id string
	local new_pub = {
		alias = alias or nil,
		id = GenerateID(),
		parent_bus = event_bus,
		---Publish an event.
		---@param self LoveFlow.Publisher
		---@param content any
		---@return LoveFlow.Publisher Self For chaining
		publish = function(self, content)
			if SHOW_DEBUG_INFO then
				LOGGER.info(("%s -> Published %s"):format(self.alias or self.id, ToStringPretty(content)))
			end
			table.insert(self.parent_bus.pool[self.id], 1, content)
			return self
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
	if SHOW_DEBUG_INFO and alias then
		LOGGER.trace(("Created new publisher: %s"):format(alias))
	elseif SHOW_DEBUG_INFO then
		LOGGER.trace("Created new publisher")
	end
	return new_pub
end

return pub
