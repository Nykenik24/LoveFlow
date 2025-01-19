local bus = require("src.comps.bus")

---@class LoveFlow
local loveflow = {}

---Create a new architecture with an EventBus.
---@return LoveFlow.Architecture
function loveflow.newArch()
	---@class LoveFlow.Architecture
	local arch = {
		---@type LoveFlow.EventBus
		bus = bus.new(),
		---Update all that can be updated in the architecture.
		---@param self LoveFlow.Architecture
		updateAll = function(self)
			self.bus:update()
		end,
	}
	return arch
end

return loveflow
