local bus = require("src.comps.bus")
require("src.global")

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
		---Show debug logs.
		---@param show? boolean Don't set if you want to toggle debug logs.
		showDebugInfo = function(show)
			SHOW_DEBUG_INFO = show or not SHOW_DEBUG_INFO
		end,
	}
	return arch
end

return loveflow
