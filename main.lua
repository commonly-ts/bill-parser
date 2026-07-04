require("extensions")

local lines = {}
local document = {
	code = "N/A",
	sections = {}
}

local currentSection = nil
local lastProvision = nil
while true do
	io.write("Enter text: ")
	local text = io.read()
	if text == "" or text == nil then break end

	if text:startsWith("SECTION ") then
		table.insert(document.sections, {
			content = text,
			provisions = {}
		})
		currentSection = document.sections[#document.sections]
	elseif string.match(text, "%([%a%d]%)%s%d%s(M%.S%.C%.)") and not string.endsWith(text, ")") then
		-- if its the start of a provision
		if currentSection then
			table.insert(currentSection.provisions, {
				lines = { text }
			})
			lastProvision = currentSection.provisions[#currentSection.provisions]
		else
			print("No section to insert provision into")
		end
	elseif string.match(text, '(.?)([%".]?)([.%"]?)') then
		-- if its a partial provision
		if lastProvision then
			local lastLine = lastProvision.lines[#lastProvision.lines]
			if not string.endsWith(lastLine, '"') and not string.startsWith(text, "S.B.") then
				table.insert(lastProvision.lines, text)
			end
		else
			print("No provision to insert partial into")
		end
	end

	if not document.code and string.startsWith(text, "S.B.") then
		document.code = "SB" .. text:match("%d+$")
	end

	table.insert(lines, text)
end

if document.code == "N/A" then
	document.code = "SB" .. lines[#lines]:match("%d+$")
end

local results = {}
for _, section in ipairs(document.sections) do
	table.insert(results, {
		name = section.content,
		provisions = {}
	})
	currentSection = results[#results]
	for _, provision in ipairs(section.provisions) do
		local content = table.concat(provision.lines, " ")
		local position = content:match('%(.%)')

		content = content:gsub("M.S.C. ", "", 1)
		content = content:gsub('%(.%) ', "", 1)

		local title = string.match(content, '%d')
		content = content:gsub('%d', "", 1)

		local subtitle = string.match(content, '%d')
		content = content:gsub('%d', "", 1)

		local law = string.match(content, '%d+')
		content = content:gsub('%d+', "", 1)

		local subProvisions = ""
		for p in string.gmatch(content, "%(.%)") do
			subProvisions = subProvisions .. p
		end
		content = content:gsub("%(.%)", "", 1)

		local action = content:find("be added") and "Insert" or content:find("be amended") and "Amend" or "N/A"
		local text = content:match('"([^"]+)"')
		if text then
			if #subProvisions > 1 then
				content = subProvisions:match('%([%a%d]%)$') .. " " .. text
			else
				content = text
			end
			table.insert(currentSection.provisions, {
				title = title,
				subtitle = subtitle,
				law = tostring(law) .. subProvisions,
				subProvisions = subProvisions,
				content = content,
				action = action,
				position = position
			})
		end
	end
end

local outputFile, err = io.open("output.txt", "w")
if not outputFile then
	print("Could not create file: " .. err)
	return
end

for sI, section in ipairs(results) do
	local numeral = section.name:gsub("SECTION ", "")
	numeral = numeral:gsub("%. ([%a%d%s]+).", "")
	if #section.provisions > 0 then
		outputFile:write(section.name .. "\n")
		for pI, provision in ipairs(section.provisions) do
			outputFile:write(("---\n%s\n%s at\n%s M.S.C. %s § %s\n%s\n%s Sec. %s%s, %s; \n---"):format(provision.position,
				provision.action, provision.title, provision.subtitle, provision.law, provision.content:gsub("", "§"),
				os.date("%b. %d %Y"), numeral, provision.position,
				document.code))
			if pI ~= #section.provisions then
				outputFile:write("\n\n")
			end
		end
		if sI ~= #results then
			outputFile:write("\n\n")
		end
	end
end

print("Success!")
