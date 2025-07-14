local Autocomplete = {}

Autocomplete.Keywords = {
	["Luau"] = {
		"and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", "while", "do", "for", "in", "end",
		"local", "return", "function", "export",
	},
	["Roblox"] = {
		"game", "workspace", "script", "math", "string", "table", "task", "wait", "select", "next", "Enum",
		"error", "warn", "tick", "assert", "shared", "loadstring", "tonumber", "tostring", "type",
		"typeof", "unpack", "print", "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
		"OverlapParams", "RaycastParams", "Axes", "Random", "Region3", "Rect", "TweenInfo",
		"collectgarbage", "not", "utf8", "pcall", "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
	},
}

Autocomplete.LookupTable = {}
--[[
lookup table looks like this:
["parent"] = {{objName, objClass}, ...}

["game"] = {{"Workspace", "Workspace"}, {"Players", "Players"}, {"Lighting", "Lighting"}, ...}
["game.Workspace" = {{"Workspace part", "Part"}, {"Workspace folder", "Folder"}}
]]

local function Contains(s: string, t: {}): boolean
	for _, m in t do
		if string.find(s:lower(), m:lower()) then
			return true
		end
	end
	
	return false
end

function Autocomplete.CrawlForDescendents(obj: Instance): {Instance}
	coroutine.wrap(function()
		for idx, inst: Instance in obj:GetDescendants() do
			if Contains(inst:GetFullName(), {"\\", "/", "Service"}) or Contains(inst:GetFullName():split(".")[1], {"game"}) then continue end

			local path = inst:GetFullName():split('.')

			-- each obj in the table is the name of an instance in the heirarchy
			-- loop thru it and add tables for each object

			local propTable = ""

			for idx, obj in path do
				if idx ~= #path then
					propTable = propTable .. obj
				else
					if Autocomplete.LookupTable[propTable] == nil then
						Autocomplete.LookupTable[propTable] = {{obj, inst.ClassName}}
					else
						table.insert(Autocomplete.LookupTable[propTable], {obj, inst.ClassName})
					end
				end
			end
		end
	end)()
end

local function ObjectsInPath(p: string): {}
	if p ~= "____PENTIUM_ROOT" then
		if Autocomplete.LookupTable[p] then
			return Autocomplete.LookupTable[p]
		else
			return {{"no child objects", ""}}
		end
	else
		local allObjects = {}
		
		for _, inst in game:GetChildren() do
			table.insert(allObjects, {inst.Name, inst.ClassName})
		end
		
		return allObjects
	end
end

local function GetAllObjectsWithPattern(search: string): {}
	local all = {}
	
	for parent, lkTabl in Autocomplete.LookupTable do
		for _, obj in lkTabl do
			if string.sub(obj[1], 1, #search):lower() == search:lower() then
				table.insert(all, obj)
			end
		end
	end
	
	return all
end

local function Slct_GetAllObjectsWithPattern(tbl: {}, search: string): {}
	local all = {}

	for parent, lkTabl in tbl do
		for _, obj in lkTabl do
			if string.sub(obj[1], 1, #search):lower() == search:lower() then
				table.insert(all, obj)
			end
		end
	end

	return all
end

local function GetKeyword(name: string)
	for keywordGroup, keywordDefinitions in Autocomplete.Keywords do
		if table.find(keywordDefinitions, name) then
			return {name, keywordGroup}
		end
	end
end

local function LastWordInCode()
	local splitKeyword = script.Parent.Parent.Parent.Main.RawInput.Text:split(" ")
	splitKeyword = splitKeyword[#splitKeyword]:split(".")
	splitKeyword = splitKeyword[#splitKeyword]:split(":")
	
	return splitKeyword[#splitKeyword]
end

local function LastLineInCode()
	local splitKeyword = script.Parent.Parent.Parent.Main.RawInput.Text:split('\n')
	return splitKeyword[#splitKeyword]
end

local function GetAllMatchingKeywords(search: string)
	local all = {}
	
	for group, keywordDefinitions in Autocomplete.Keywords do
		for _, keyword in keywordDefinitions do
			if keyword:sub(1, string.len(search)):lower() == search:lower() then
				table.insert(all, {keyword, group})
			end
		end
	end
	
	return all
end

local function CreateSuggestionLabel(keyword: {})
	local Label = script.Parent.Parent.Templates.KeywordHintLabel:Clone()
	
	local SyntaxHighlight = require(script.Parent.Highlighting).run
	
	Label.Text = SyntaxHighlight(keyword[1])
	Label.Group.Text = keyword[2]
	Label.Parent = script.Parent.Parent.Parent.Main.KeywordHint
end

local StillSearching = false

function Autocomplete.Update()
	if StillSearching then return end
	
	coroutine.wrap(function()
		StillSearching = true
		local lastWord = LastWordInCode()
		
		local allKeywords = {}
		local engineKeywords = GetAllMatchingKeywords(lastWord)
		
		local c = LastLineInCode():split("")
		
		if c[#c] ~= "." then
			allKeywords = GetAllObjectsWithPattern(lastWord)
		else
			local ogPath = LastLineInCode():sub(1, -2)
			local truePath = LastLineInCode():sub(1, -2)
			
			if truePath:sub(1, 4) == "game" then
				truePath = truePath:sub(6, -1)
			end
			
			if truePath ~= "" then
				allKeywords = ObjectsInPath(truePath)
				engineKeywords = {}
			else
				if ogPath == "game" then
					allKeywords = ObjectsInPath("____PENTIUM_ROOT")
					engineKeywords = {}
				else
					GetAllObjectsWithPattern(lastWord)
				end
			end
		end
		
		for _, t in script.Parent.Parent.Parent.Main.KeywordHint:GetChildren() do
			if t:IsA("TextLabel") then t:Destroy() end
		end
		
		--if allPath == {} then
		for _, k in engineKeywords do
			CreateSuggestionLabel(k)
		end
		
		for _, l in allKeywords do
			CreateSuggestionLabel(l)
		end
		
		script.Parent.Parent.Parent.Main.KeywordHint.Size = UDim2.new(0, 250, 0, (#allKeywords + #engineKeywords) * 25)
		--else
		--	for _, k in allPath do
		--		CreateSuggestionLabel(k)
		--	end
		
		--	script.Parent.Parent.Parent.Main.KeywordHint.Size = UDim2.new(0, 250, 0, #allPath * 25)
		--end
		StillSearching = false
	end)()
end

return Autocomplete