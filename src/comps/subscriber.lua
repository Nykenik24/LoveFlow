require("src.utils")

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
				error("No handler")
			end
			local events = self:getEvents(bus)
			local function handle(content)
				if type(content) ~= "function" then
					if handler(self, content) == false then
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
				table.insert(self.subbed_to, pub.id)
				return self
			elseif type(pub) == "string" then
				table.insert(self.subbed_to, pub)
				return self
			else
				error("pub has to be publisher id or publisher")
			end
		end,
	}
	table.insert(event_bus.subs, new_sub)
	return new_sub
end

return sub
