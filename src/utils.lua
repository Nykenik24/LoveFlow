local function Alphabet()
	return {
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
		"w",
		"x",
		"y",
		"z",
	}
end

---Generates a random 8-character ID
---@return string ID
function GenerateID()
	local chars = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
	for _, letter in ipairs(Alphabet()) do
		table.insert(chars, letter)
		table.insert(chars, letter:upper())
	end

	local id = ""
	for i = 1, 8 do
		local random_char = chars[math.random(1, #chars)]
		id = id .. tostring(random_char)
	end
	return id
end

---Remove and return last element of a table
---@param t table
---@return any
function Pop(t)
	return table.remove(t, #t)
end
