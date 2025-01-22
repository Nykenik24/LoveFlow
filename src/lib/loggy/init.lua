---@class loggy
---@field regular function Regular message
---@field trace function Tracing message
---@field debug function Debugging message
---@field info function Information message
---@field ok function Indicates something works/worked
---@field warn function Warning
---@field error function Error
---@field fatal function Fatal error
local loggy = {}

--* this bit is *--
--* adapted from my library Love2d Tools (https://github.com/Nykenik24/love2d-tools) *--
---@alias log_types
---| `"regular"`
---| `"trace"`
---| `"debug"`
---| `"info"`
---| `"ok"`
---| `"warn"`
---| `"error"`
---| `"fatal"`
local log_types = {
	regular = "\27[37m",
	trace = "\27[34m",
	debug = "\27[36m",
	info = "\27[32m",
	ok = "\27[32m",
	warn = "\27[33m",
	error = "\27[31m",
	fatal = "\27[35m",
}

loggy._chained = {}
loggy.chain_number = 1
local clear_color = "\27[0;0m"
for k, v in pairs(log_types) do
	---@param msg string Log content
	---@return table Chained
	loggy[k] = function(msg)
		print(("%s[%s %s]:%s %s"):format(v, tostring(os.date("%H:%M:%S")), k:upper(), clear_color, msg))
		loggy.chain_number = 1
		return loggy._chained
	end
	---@param msg string Log content
	---@return table Chained
	loggy._chained[k] = function(msg)
		print(
			("%s[%s CHAINED %i %s]:%s %s"):format(
				v,
				tostring(os.date("%H:%M:%S")),
				loggy.chain_number,
				k:upper(),
				clear_color,
				msg
			)
		)

		loggy.chain_number = loggy.chain_number + 1
		return loggy._chained
	end
end

---Print a table in a readable format.
---
---Uses ANSI Colors
---@param t table Table printed
---@param depth? integer Used to make the function recursive
function loggy.PrintTable(t, depth)
	local print = function(msg)
		print(msg)
	end

	local function Tabs(n)
		local tabs = ""
		for _ = 1, n do
			tabs = tabs .. "\t"
		end
		return tabs
	end

	depth = depth or 1
	local tabs = Tabs(depth)
	local start = tabs .. "%s = {"
	local formatted_start = start:format(tostring(t))
	print("\27[1;34m " .. formatted_start:sub(#"table: " + 2, #formatted_start))
	for k, v in pairs(t) do
		if type(k) == "number" and type(v) ~= "table" then
			print("\27[0;32m " .. (tabs .. "[%i] \27[0;0m= "):format(k) .. "\27[0;0m" .. tostring(v))
		elseif type(k) == "string" and type(v) ~= "table" then
			print("\27[0;35m " .. (tabs .. "[%s] \27[0;0m= "):format(k) .. "\27[0;0m" .. tostring(v))
		end

		if type(v) == "table" then
			loggy.PrintTable(v, depth + 1)
		end
	end
	if depth > 1 then
		print(Tabs(depth - 1) .. "\27[1;34m } \27[0;0m")
	else
		print("\27[1;34m } \27[0;0m")
	end
end

--* adapted from my library Love2d Tools (https://github.com/Nykenik24/love2d-tools) *--

function loggy:test()
	self.regular("Regular message")
	self.trace("Tracing message")
	self.debug("Debug message")
	self.info("Information message")
	self.ok("OK message")
	self.warn("Warning")
	self.error("Error")
	self.fatal("Fatal error")
	self.PrintTable({
		a = "a",
		b = "b",
		c = "c",
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = {
			[5] = 5,
			[6] = 6,
			[7] = 7,
		},
		d = "d",
	})
	self.info("Chained example").info("Hello,").info("World!")
end

return loggy
