local Pentium = script.Parent
local PentiumVersion = "1.1.0"

local ActivateButton: GuiButton = nil

local TextService = game:GetService("TextService")

local ActivateModes = { Startup = 1, Button = 2 }
local ActivateMode = ActivateModes.Startup

local DelModes =  {Destroy = 1, Hide = 2}
local DelMode = DelModes.Destroy

local CreateMessage = require(script.Modules.Log).DisplayMessage
local CreateDraggable = require(script.Modules.DraggableObject).new

local SettingsModule = require(script.Modules.Settings)
local ContextMenuModule = require(script.Modules.ContextMenu)
local AutocompleteModule = require(script.Modules.Autocomplete)

local SyntaxHighlight = require(script.Modules.Highlighting).run

local Settings = {
	SyntaxHighlighting = true,
	Cursor = true,
	Autocomplete = true,
	AutocompleteGameCrawling = true,
	LineNumbers = true,
}

local PentiumLoadCode = function(code: string)
	game.ReplicatedStorage.PentiumDeveloper.Load:FireServer(code)
end

local function CursorBlink()
	while true do
		if Settings.Cursor then
			Pentium.Main.Editor.Cursor.Visible = not Pentium.Main.Editor.Cursor.Visible
		else
			Pentium.Main.Editor.Cursor.Visible = false
		end
		
		task.wait(0.4)
	end
end

local CurrentRunContext = PentiumLoadCode

local newline = function(str: string)
	return string.format("%s\n", str)
end

-- uses \n with string.split to determine the best guess for cursor position
function CursorPosition(content: string)
	local _, lineCount = Pentium.Main.Editor.RawInput.Text:gsub('\n', '\n')
	
	local split = content:split('\n')
	local last = split[#split] or ""
	
	if last == "" then
		return 30, (lineCount * 16)
	else
		local LineWidth = TextService:GetTextSize(last, Pentium.Main.Editor.RawInput.TextSize, 
														Pentium.Main.Editor.RawInput.Font, 
														Pentium.Main.Editor.RawInput.AbsoluteSize)
		
		return LineWidth.X + 30, (lineCount * 16)
	end
end

local function Start()
	Pentium.Splash.Visible = true
	
	CreateDraggable(Pentium.Main, Pentium.Main.Topbar):Enable()

	ContextMenuModule.CreateContextMenu("File")
	ContextMenuModule.CreateContextMenu("Edit")
	ContextMenuModule.CreateContextMenu("Help")
	
	local function Quit()
		if DelMode == DelModes.Hide then
			Pentium.Main.Visible = false
		else
			Pentium:Destroy()
		end
	end
	
	ContextMenuModule.CreateContextMenuButton("File", "Run", function()
		CurrentRunContext(Pentium.Main.Editor.RawInput.Text)
	end)
	
	-- Quit buttons
	ContextMenuModule.CreateContextMenuButton("File", "Quit", Quit)
	Pentium.Main.Topbar.QuitButton.MouseButton1Click:Connect(Quit)
	
	ContextMenuModule.CreateContextMenuButton("Edit", "Settings", SettingsModule.Open)
	
	ContextMenuModule.CreateContextMenuButton("Help", "About Pentium", function()
		CreateMessage("About Pentium"
			, string.format("Pentium v" .. PentiumVersion)
	end)
	
	SettingsModule.CreateNewSetting("Syntax Highlighting", Settings.SyntaxHighlighting, function()
		Settings.SyntaxHighlighting = not Settings.SyntaxHighlighting
	end)
	
	SettingsModule.CreateNewSetting("Cursor", Settings.Cursor, function()
		Settings.Cursor = not Settings.Cursor
	end)
	
	SettingsModule.CreateNewSetting("Line Numbers", Settings.LineNumbers, function()
		Settings.LineNumbers = not Settings.LineNumbers
	end)
	
	SettingsModule.CreateNewSetting("Autocomplete", Settings.Autocomplete, function()
		Settings.Autocomplete = not Settings.Autocomplete
	end)
	
	SettingsModule.CreateNewSetting("Autocomplete Game Crawling", Settings.AutocompleteGameCrawling, function()
		Settings.AutocompleteGameCrawling = not Settings.AutocompleteGameCrawling
	end)
	
	AutocompleteModule.CrawlForDescendents(game)
	
	Pentium.Main.Editor.RawInput.Changed:Connect(function(property: string)
		if property == "Text" then
			if Settings.SyntaxHighlighting then
				Pentium.Main.Editor.StyleInput.Text = SyntaxHighlight(Pentium.Main.Editor.RawInput.Text)
			else
				Pentium.Main.Editor.StyleInput.Text = Pentium.Main.Editor.RawInput.Text
			end
		end

		local CursorX, CursorY = CursorPosition(Pentium.Main.Editor.RawInput.Text)
		
		if Settings.Cursor then
			Pentium.Main.Editor.Cursor.Position = UDim2.fromOffset(CursorX, CursorY)
		end
		
		if Settings.Autocomplete then
			Pentium.Main.Editor.KeywordHint.Position = UDim2.new(
				Pentium.Main.Editor.Cursor.Position.X.Scale, 
				Pentium.Main.Editor.Cursor.Position.X.Offset, 
				Pentium.Main.Editor.Cursor.Position.Y.Scale, 
				Pentium.Main.Editor.Cursor.Position.Y.Offset + 16
			)

			local Last = string.sub(Pentium.Main.Editor.RawInput.Text, -1)
			Last = string.lower(Last):gsub('%%', '%%%%')
				:gsub('^%^', '%%^')
				:gsub('%$$', '%%$')
				:gsub('%(', '%%(')
				:gsub('%)', '%%)')
				:gsub('%.', '%%.')
				:gsub('%[', '%%[')
				:gsub('%]', '%%]')
				:gsub('%*', '%%*')
				:gsub('%+', '%%+')
				:gsub('%-', '%%-')
				:gsub('%?', '%%?')
			
			if Last then
				local Chars = "abcdefghijklmnopqrstuvwxyz1234567890."
				local LastCharIsChar = Last ~= "" and string.find(Chars, Last)
				Pentium.Main.Editor.KeywordHint.Visible = LastCharIsChar or false
			else
				Pentium.Main.Editor.KeywordHint.Visible = false
			end
		end
		
		local _, count = Pentium.Main.Editor.RawInput.Text:gsub('\n', '\n')
		
		if Settings.LineNumbers then
			Pentium.Main.Editor.LineNumbers.Visible = true
			
			Pentium.Main.Editor.LineNumbers.Text = ""
			
			for i = 1, count + 1 do
				Pentium.Main.Editor.LineNumbers.Text = Pentium.Main.Editor.LineNumbers.Text .. newline(tostring(i))
			end
		else
			Pentium.Main.Editor.LineNumbers.Visible = false
		end
		
		if Settings.Autocomplete and Pentium.Main.Editor.KeywordHint.Visible then
			AutocompleteModule.Update(Settings.AutocompleteGameCrawling)
		else
			Pentium.Main.Editor.KeywordHint.Visible = false
		end
		
		if (count * 16) + 30 > Pentium.Main.Size.Height.Offset then
			Pentium.Main.Editor.CanvasSize = UDim2.new(
				Pentium.Main.Editor.CanvasSize.X.Scale, 
				Pentium.Main.Editor.CanvasSize.X.Offset, 
				0, (count * 16) + 30
			)
		end
	end)
	
	coroutine.wrap(CursorBlink)()
	
	task.wait(2)
	
	Pentium.Splash.Visible = false
	
	Pentium.Main.Visible = true
end

if ActivateMode == ActivateModes.Button then
	ActivateButton.MouseButton1Click:Connect(Start)
else
	Start()
end