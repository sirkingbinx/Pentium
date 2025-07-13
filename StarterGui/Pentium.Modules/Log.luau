local Log = {}

Log.Script = script.Parent.Parent

function Log.DisplayMessage(title: string, content: string, buttons: {string}, plr: Player): string
	if plr == nil then
		plr = game.Players.LocalPlayer
	end
	
	local newUI = Instance.new("ScreenGui", plr.PlayerGui)
	newUI.Name = title
	
	local newUserMessage = Log.Script.Origin.UserMessage:Clone()
	newUserMessage.Topbar.Title.Text = title
	newUserMessage.Message.Text = content
	newUserMessage.Parent = newUI
	
	newUserMessage.Visible = true
	
	local CreateDraggable = require(script.Parent.DraggableObject).new
	CreateDraggable(newUserMessage, newUserMessage.Topbar):Enable()
	
	if buttons == nil or #buttons == 0 then
		print("Log.DisplayMessage[warn]: no buttons provided, defaulting to OK")
		
		local newUserMessageButton = Log.Script.Origin.UserMessageButton:Clone()
		newUserMessageButton.Name = "OK"
		newUserMessageButton.Text = "OK"
		newUserMessageButton.Visible = true
		newUserMessageButton.Parent = newUserMessage.Buttons

		newUserMessageButton.MouseButton1Click:Connect(function()
			newUserMessage.Parent:Destroy()

			return "OK"
		end)
	else
		for _, button: string in buttons do
			local newUserMessageButton = Log.Script.Origin.UserMessageButton:Clone()
			newUserMessageButton.Name = button
			newUserMessageButton.Text = button
			newUserMessageButton.Visible = true
			newUserMessageButton.Parent = newUserMessage.Buttons
			
			newUserMessageButton.MouseButton1Click:Connect(function()
				newUserMessage.Parent:Destroy()
				
				return button
			end)
		end
	end
end

return Log