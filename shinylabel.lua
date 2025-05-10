local ShinyModule = require(game.ServerScriptService:WaitForChild("ShinyModule")) 

local function onPlayerAdded(player)
	-- Wait for PlayerGui to be available
	local playerGui = player:WaitForChild("PlayerGui")
	local shinyLabel = playerGui:WaitForChild("shinylabel")
	local textLabel = shinyLabel:WaitForChild("TextLabel") 

	local function updateTextLabel()
		local shinyMultiplier, _ = ShinyModule.GetShinyStats() 
		textLabel.Text = "Shiny Multiplier: x" .. shinyMultiplier
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
