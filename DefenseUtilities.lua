local kickMessage = "Your account has flagged our security systems. If this is a mistake, please report it in the bug-reports channel in our Discord! discord.gg/odysseys"
local grouplock = false
local protection = false
local player = game:GetService("Players")

local groups = {
	1200769, --// Roblox Admin Group
	4199740, --// Roblox Star Creator Group
	107778, --// Roblox Moderation
	15153029, --// BU Audio Group
}

--// Script Toggle
pcall(function()
	if protection == false then
		script:Remove()
	end
end)

--[[ --// Group Lock System
pcall(function()
	if grouplock == true then
		game.Players.PlayerAdded:Connect(function(plr)
			if not plr:IsInGroup(33485439 or 32429031) then
				plr:Kick("Please join the community group listed below in the description to access the game!")
			end
		end)
	end
end) ]]

--// Standard Kick System
pcall(function()
	game.Players.PlayerAdded:Connect(function(plr)
		for i=1, #groups do
			if plr:IsInGroup(groups[i]) then
				plr:Kick(kickMessage)
			end
		end
	end)	
end)

--// Group Poisoner - (BU Community Group)
pcall(function()
	game.Players.PlayerAdded:Connect(function(plr)
		if plr:GetRankInGroup(14742819) >= 2 then
			plr:Kick(kickMessage)
		end			
	end)
end)

if player ~= player then
	player:kick("you a bot or sum my bro?")
end
