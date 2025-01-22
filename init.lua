local function getScriptFolder() --* get the path from the root folder in which THIS script is running
	return (debug.getinfo(1, "S").source:sub(2):match("(.*/)"))
end

---@type LoveFlow
return require(getScriptFolder() .. "src.loveflow")
