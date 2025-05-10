local ShinyModule = {}

local shinyMultiplier = 1
local shinyChance = 2048
local multiplierChanged = Instance.new("BindableEvent") 

local function getRandomShinyMultiplier()
	local multipliers = {}
	for i = 2, 25 do
		local weight = 1 / i^3
		table.insert(multipliers, {value = i, weight = weight})
	end

	local totalWeight = 0
	for _, entry in ipairs(multipliers) do
		totalWeight += entry.weight
	end

	local randomWeight = math.random() * totalWeight
	local currentWeight = 0
	for _, entry in ipairs(multipliers) do
		currentWeight += entry.weight
		if currentWeight >= randomWeight then
			return entry.value
		end
	end

	return 2
end

function ShinyModule.UpdateShiny()
	shinyMultiplier = getRandomShinyMultiplier()
	shinyChance = 2048 / shinyMultiplier

	multiplierChanged:Fire(shinyMultiplier)

end

-- Function to get the current shiny stats
function ShinyModule.GetShinyStats()
	return shinyMultiplier, shinyChance
end

function ShinyModule.OnMultiplierChanged()
	return multiplierChanged.Event
end

task.spawn(function()
	while true do
		ShinyModule.UpdateShiny()
		wait(420) 
	end
end)

return ShinyModule
