SHOW_DEBUG_INFO = false

local function getScriptFolder() --* get the path from the root folder in which THIS script is running
	return (debug.getinfo(1, "S").source:sub(2):match("(.*/)"))
end
PATH = getScriptFolder()
COMP_PATH = getScriptFolder() .. "comps."
UTILS_PATH = getScriptFolder() .. "utils"

LOGGER = require(getScriptFolder() .. "lib.logger")
