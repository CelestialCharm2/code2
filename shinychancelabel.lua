local ShinyModule = require(game.ServerScriptService:WaitForChild("ShinyModule"))

local function onPlayerAdded(player)
	local playerGui = player:WaitForChild("PlayerGui")
	local shinyLabel = playerGui:WaitForChild("shinylabel")
	local textLabel = shinyLabel:WaitForChild("TextLabel2") 

	local function updateTextLabel()
		local shinyMultiplier, shinyChance = ShinyModule.GetShinyStats() 
		textLabel.Text = "Shiny Chance: 1 in " .. shinyChance
	end

	updateTextLabel()

	task.spawn(function()
		while true do
			updateTextLabel() 
			wait()  
		end
	end)
end

-- Connect the function to player added event
game.Players.PlayerAdded:Connect(onPlayerAdded)
