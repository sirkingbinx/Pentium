local Settings = {}

Settings.AcceptedTypes = {"boolean", "string", "number"}

Settings.BoolColor = {
	[true] = Color3.fromRGB(37, 149, 19),
	[false] = Color3.fromRGB(185, 32, 32)
}

local Log = require(script.Parent.Log)
local Options = {}

-- By default, the settings config thingy will make your setting type the type() of "value"
function Settings.CreateNewSetting(label: string, value: any, callback: (any) -> ())
	if not table.find(Settings.AcceptedTypes, type(value)) then
		Log.DisplayMessage("Error", string.format("A setting was configured without a valid type. [type(value) = %s | value = %s]", type(value), tostring(value) or value))
	else
		table.insert(Options, {
			Label = label,
			Value = value,
			Callback = callback,
			Type = type(value)
		})
	end
end

function Settings.Open()
	local settingsWindow = script.Parent.Parent.Origin.SettingsMenu:Clone()
	local prefBox = settingsWindow.PrefFrame
	
	for _, o: Instance in prefBox:GetChildren() do
		if o:IsA("TextButton") then
			o:Destroy()
		end
	end

	for _, option in Options do
		local valueConfig = nil
		
		if option.Type == "boolean" then
			valueConfig = script.Parent.Parent.Origin.SettingsType.boolean:Clone()
			valueConfig.Label.Text = option.Label
			valueConfig.BackgroundColor3 = Settings.BoolColor[option.Value] or Color3.fromRGB(37, 149, 19)
			
			valueConfig.MouseButton1Click:Connect(function()
				option.Value = not option.Value
				valueConfig.BackgroundColor3 = Settings.BoolColor[option.Value]
				
				option.Callback(option.Value)
			end)
		elseif option.Type == "string" then
			valueConfig = script.Parent.Parent.Origin.SettingsType.string:Clone()
			valueConfig.Label.Text = option.Label
			if valueConfig:IsA("TextBox") then
				valueConfig.FocusLost:Connect(function(isEnter)
					if isEnter then
						option.Value = valueConfig.Text
						option.Callback(option.Value)
					end
				end)
			end
		elseif option.Type == "number" then
			valueConfig = script.Parent.Parent.Origin.SettingsType.number:Clone()
			valueConfig.Label.Text = option.Label
			if valueConfig:IsA("TextBox") then
				valueConfig.FocusLost:Connect(function(isEnter)
					if isEnter and tonumber(valueConfig.Text) ~= nil then
						option.Value = tonumber(valueConfig.Text)
						option.Callback(option.Value)
					elseif not isEnter and tonumber(valueConfig.Text) == nil then
						Log.DisplayMessage("Error", "Please enter a valid number.")
					end
				end)
			end
		end
		
		valueConfig.Parent = prefBox
	end
	
	settingsWindow.Parent = script.Parent.Parent.Parent
	settingsWindow.Topbar.QuitButton.MouseButton1Click:Connect(function()
		settingsWindow:Destroy()
	end)
end

return Settings