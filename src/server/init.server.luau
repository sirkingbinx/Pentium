game.ReplicatedStorage.PentiumExecute.OnServerEvent:Connect(function(plr: Player, code: string, password: string)
	if password == "SupaS!CURE!100.253#9ui00we78ht0spdvn540PT" then
		local playerCodePath = "game.Players." .. plr.Name .. ".PlayerGui.Pentium.Pentium.Modules.ScriptingSupport"
		local codeHeader = [[
		-- Pentium-generated code
		function ThrowError(text: string) require(]] .. playerCodePath .. [[).ThrowError(text, game.Players.]].. plr.Name ..[[) end
		function ThrowWarn(text: string) require(]] .. playerCodePath .. [[).ThrowWarn(text, game.Players.]].. plr.Name ..[[) end
		function ThrowInfo(text: string) require(]] .. playerCodePath .. [[).ThrowInfo(text, game.Players.]].. plr.Name ..[[) end
		function DisplayMessage(title: string, text: string, buttons: {}) require(]] .. playerCodePath .. [[).DisplayMessage(title, text, buttons, game.Players.]].. plr.Name ..[[) end
		function rand(tbl: {}) if tbl ~= {} then return tbl[math.random(1, #tbl)] else return nil end end
		
		]]
		
		local output = loadstring(codeHeader .. code)()
		print(output)
	else
		plr:Kick("baited lol")
	end
end)
