local ShinySettings = {
	shinyChance = game.ServerScriptService.shinysettings.shinyChance,
	shinyMultiplier = game.ServerScriptService.shinysettings.shinyMultiplier
}

function ShinySettings:GetCurrentShinyChance()
	return self.shinyChance / self.shinyMultiplier
end

return ShinySettings
