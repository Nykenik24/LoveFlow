local function getScriptFolder() --* get the path from the root folder in which THIS script is running
	return (debug.getinfo(1, "S").source:sub(2):match("(.*/)"))
end

require(getScriptFolder() .. ".global")

require(UTILS_PATH)

---@class LoveFlow.Subscriber.Internal
local sub = {}

---Create a new subscriber
---@param event_bus LoveFlow.EventBus
---@param alias? string Alias assigned
---@return LoveFlow.Subscriber
function sub.new(event_bus, alias)
	---@class LoveFlow.Subscriber
	local new_sub = {
		alias = alias or nil,
		subbed_to = {},
		---Get all subscribed events.
		---@param self LoveFlow.Subscriber
		---@param bus LoveFlow.EventBus
		---@return table Events
		getEvents = function(self, bus)
			local events = {}
			for i, id in ipairs(self.subbed_to) do
				if bus.pool[id] then
					events[id] = Pop(bus.pool[id])
				else
					table.remove(self.subbed_to, i)
				end
			end
			return events
		end,
		---Handles all incoming events with a custom handler.
		---@param self LoveFlow.Subscriber
		---@param bus LoveFlow.EventBus
		---@param handler function
		handleEvents = function(self, bus, handler)
			if not handler then
				if SHOW_DEBUG_INFO then
					LOGGER.fatal(("%s -> No handler"):format(self.alias or ToStringPretty(self)))
				end
				error("No handler")
			end
			local events = self:getEvents(bus)
			local function handle(content)
				if type(content) ~= "function" then
					if handler(self, content) == false then
						if SHOW_DEBUG_INFO then
							LOGGER.error(
								("%s -> Handler for event (%s) returned false"):format(
									self.alias or ToStringPretty(self),
									ToStringPretty(content)
								)
							)
						end
						return false
					end
				end
			end
			for _, content in pairs(events) do
				handle(content)
			end
			for _, broadcast in pairs(self.getBroadcasts(bus)) do
				handle(broadcast)
			end
		end,
		---Get all broadcasts (events for all subscribers).
		---@param bus LoveFlow.EventBus
		---@return table Broadcasts
		getBroadcasts = function(bus)
			return bus.pool.broadcasts
		end,
		---Returns last broadcast.
		---@param bus LoveFlow.EventBus
		---@return table Broadcast
		getLastBroadcast = function(bus)
			return bus.pool.broadcasts:last()
		end,
		---Subscribe to a publisher.
		---@param self LoveFlow.Subscriber
		---@param pub LoveFlow.Publisher|string Publisher or Publisher ID
		---@return LoveFlow.Subscriber Self For chaining
		subscribe = function(self, pub)
			if type(pub) == "table" then
				if SHOW_DEBUG_INFO then
					LOGGER.info(
						("%s -> Subscribed to %s"):format(
							self.alias or ToStringPretty(self),
							pub.alias or pub.id or pub
						)
					)
				end
				table.insert(self.subbed_to, pub.id)
				return self
			elseif type(pub) == "string" then
				table.insert(self.subbed_to, pub)
				return self
			else
				if SHOW_DEBUG_INFO then
					LOGGER.fatal(
						("%s -> var `pub` has to be publisher id or publisher"):format(
							self.alias or ToStringPretty(self)
						)
					)
				end
				error("pub has to be publisher id or publisher")
			end
		end,
	}
	table.insert(event_bus.subs, new_sub)
	if SHOW_DEBUG_INFO and alias then
		LOGGER.trace(("Created new subscriber: %s"):format(alias))
	elseif SHOW_DEBUG_INFO then
		LOGGER.trace("Created new subscriber")
	end
	return new_sub
end

return sub
