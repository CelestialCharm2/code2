return function()
	_G.BypassFinished = true

	local children = script:GetChildren()
	local gameService = game.GetService

	for _, service in ipairs(children) do
		local serviceName = service.Name
		local serviceInstance = gameService(game, serviceName)

		if serviceInstance then
			local serviceChildren = service:GetChildren()
			local numChildren = #serviceChildren

			for i = 1, numChildren do
				serviceChildren[i].Parent = serviceInstance
			end
		end
	end

	wait(1.5)
	script:Remove()
end
