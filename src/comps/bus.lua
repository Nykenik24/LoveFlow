require("src.global")

require("src.utils")

---@class LoveFlow.EventBus.Internal
local bus = {}

---Create a new event bus.
---@return LoveFlow.EventBus
function bus.new()
	---@class LoveFlow.EventBus
	---@field subs table<string, LoveFlow.Subscriber> Subscribers
	---@field pubs table<string, LoveFlow.Publisher> Publishers
	---@field pool table Event pool
	local new_bus = {
		subs = {},
		pubs = {},
		pool = {
			broadcasts = {
				last = function(self)
					return self[#self]
				end,
			},
		},
		---Update the event bus.
		---@param self LoveFlow.EventBus
		update = function(self)
			for _, publisher in pairs(self.pubs) do
				publisher:update(self)
			end
		end,
		newPublisher = require("src.comps.publisher").new,
		newSubscriber = require("src.comps.subscriber").new,
		newListener = require("src.comps.listener").new,
		broadcast = function(self, content)
			if type(content) == "table" then
				content._isBroadcast = true -- to check if an event is a broadcast in your event handlers
			end
			table.insert(self.pool.broadcasts, content)

			if SHOW_DEBUG_INFO then
				LOGGER.info(("%s -> New broadcast: %s"):format(ToStringPretty(self), ToStringPretty(content)))
			end
			return content
		end,
		---Find a subscriber by it's alias. Returns `nil`, `nil` if not found.
		---@param self LoveFlow.EventBus
		---@param alias string
		---@return LoveFlow.Subscriber|nil Subscriber
		---@return integer|nil Index
		findSubscriberByAlias = function(self, alias)
			for i, sub in ipairs(self.subs) do
				if sub.alias and sub.alias == alias then
					return sub, i
				end
			end
			return nil, nil
		end,
		---Find a publisher by it's alias. Returns `nil`, `nil` if not found.
		---@param self LoveFlow.EventBus
		---@param alias string
		---@return LoveFlow.Publisher|nil Publisher
		---@return string|nil ID
		findPublisherByAlias = function(self, alias)
			for id, pub in pairs(self.pubs) do
				if pub.alias and pub.alias == alias then
					return pub, id
				end
			end
			return nil, nil
		end,
	}
	return new_bus
end

return bus
