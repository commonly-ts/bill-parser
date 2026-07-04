class = {}
class.new = function(t, inheritFrom)
	t.__index = t
	t.new = function()
		return setmetatable({}, t)
	end
	if inheritFrom then
		setmetatable(t, { __index = inheritFrom })
	end
	return t
end

function table.some(t, callback)
	if #t == 0 then return false end
	for i, v in ipairs(t) do
		if callback(v, i, t) then return true end
	end
	return false
end

function table.map(t, func)
	local result = {}
	for i, v in pairs(t) do
		result[i] = func(v, i, t)
	end
	return result
end

function table.find(haystack, needle, init)
	init = init or 1
	for i = init, #haystack + 1 - init do
		if needle == haystack[i] then
			return i
		end
	end
	return nil
end

function table.filter(t, callback)
	local results = {}
	for i, v in pairs(t) do
		if callback(v, i) then table.insert(results, v) end
	end
	return results
end

function table.reverse(t)
	local len = #t
	for i = 1, math.floor(len / 2) do
		local j = len - i + 1
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function table.reduce(t, callback, initValue)
	local result = tonumber(initValue) or 0
	for i, v in (table.isarray(t) and ipairs or pairs)(t) do
		result = callback(result, v, i)
	end
	return result
end

function _G.kpairs(t)
	local keys = table.keys(t)
	table.sort(keys, function(a, b)
		local valA, valB = t[a], t[b]
		local typeA, typeB = type(valA), type(valB)
		-- move largest table downwards
		if typeA == "table" and typeB ~= "table" then
			return false
		elseif typeA ~= "table" and typeB == "table" then
			return true
		elseif typeA == "table" and typeB == "table" then
			local sizeA = table.length(valA)
			local sizeB = table.length(valB)
			if sizeA ~= sizeB then
				return sizeA < sizeB
			end
		end
		local strA, strB = tostring(a), tostring(b)
		return strA < strB
	end)

	local i = 0
	local function iter()
		i = i + 1
		local k = keys[i]
		if k ~= nil then
			return k, t[k]
		end
	end

	return iter, t, nil
end

-- // String

function string.trim(s)
	return string.gsub(s, "%s+$", "")
end

function string.remove(str, s, e)
	return string.sub(str, 1, s - 1) .. string.sub(str, e + 1)
end

function string.split(s, d)
	local result = {}
	for word in s:gmatch("[^%" .. d .. "]+") do
		table.insert(result, word)
	end
	return result
end

function string.indent(n)
	return string.rep(" ", n)
end

function string.startsWith(s, pattern, i)
	return s:sub(tonumber(i) or 1, #pattern) == pattern
end

function string.endsWith(s, pattern, i)
	return s:reverse():sub(tonumber(i) or 1, #pattern) == pattern
end

-- // Table

function table.isarray(t)
	if type(t) ~= "table" then return false end
	local count = 0
	for _ in pairs(t) do
		count = count + 1
		if t[count] == nil then return false end
	end
	return true
end

function table.keys(t)
	local keys = {}
	for k in (table.isarray(t) and ipairs or pairs)(t) do
		table.insert(keys, k)
	end
	return keys
end

function table.values(t)
	local values = {}
	for _, v in (table.isarray(t) and ipairs or pairs)(t) do
		table.insert(values, v)
	end
	return values
end

function table.length(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
	end
	return i
end

function table.tostring(t, maxLevel, level, prev)
	maxLevel = tonumber(maxLevel) or 5
	if not t or type(t) ~= "table" then
		return nil
	end
	if table.length(t) == 0 then return "{}" end
	if t == prev then return t end
	if level and level > maxLevel then return "{ [[EXCESSIVE RECURSION]] }" end
	level = level or 1
	local indentation = string.indent(level * 2)
	local result = { "{" }
	local generator = table.isarray(t) and ipairs or kpairs
	for i, v in generator(t) do
		if type(v) == "table" then
			v = table.length(v) == 0 and "{}" or table.tostring(v, maxLevel, level + 1, t)
		end
		if type(i) == "string" then i = ('"%s"'):format(i) end
		local format = ("%s[%s] = %s,")
		table.insert(result, format:format(indentation, tostring(i), v))
	end
	table.insert(result, ("%s}"):format(string.indent(level * 2 - 2)))
	return table.concat(result, "\n")
end

function table.truthy(t)
	if #t == 0 then return false end
	for _, v in pairs(t) do
		if not v then return false end
	end
	return true
end
