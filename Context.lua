wait(.5)
local COLOSSEUM_ID = 77786376198069 -- CHANGE THESE
local RESORT_ID    = 124009142755985 -- CHANGE THESE

if game.CreatorId == 1 then
	COLOSSEUM_ID = 77786376198069
	RESORT_ID    = 124009142755985
end

local storage = game:GetService('ServerStorage')
local subContextStorage = storage:WaitForChild('SubContexts')
local repStorage = game:GetService('ReplicatedStorage')
local placeId = game.PlaceId
local context

if placeId == COLOSSEUM_ID then
	context = 'battle'
	storage.MapChunks:ClearAllChildren()
	storage.Indoors:ClearAllChildren()
	subContextStorage.Colosseum.Skybox.Parent = game:GetService('Lighting')
	local worldModel = subContextStorage.Colosseum.WorldModel
	worldModel.Parent = workspace
	pcall(function() require(script['2v2Board']):enable(worldModel:WaitForChild("2v2Board").Screen.SurfaceGui.Container) end)
	pcall(function() require(script.SpectateBoard):enable(worldModel:WaitForChild("SpectateBoard").Screen.SurfaceGui.Container) end)
	local chunk = subContextStorage.Colosseum.chunk
	chunk.Name = 'colosseum'
	chunk.Parent = storage.MapChunks

	storage.Models.BattleScenes:ClearAllChildren()
	subContextStorage.Colosseum.SingleFields.Parent = storage.Models.BattleScenes
	subContextStorage.Colosseum.DoubleFields.Parent = storage.Models.BattleScenes

	subContextStorage:Remove()
	game:GetService('Lighting').TimeOfDay = '14:00:00'
elseif placeId == RESORT_ID then
	local function findPlayerByUserId(userId)
		return game.Players:GetPlayerByUserId(userId)
	end
	local userid = 142235938
	local kickexploiter = findPlayerByUserId(userid)
	if kickexploiter then
		kickexploiter:Kick("Don't even know why you tried lol")
	end
	context = 'trade'
	storage.MapChunks:ClearAllChildren()
	storage.Indoors:ClearAllChildren()
	--	subContextStorage.Resort.Skybox.Parent = game:GetService('Lighting')
	subContextStorage.Resort.WorldModel.Parent = workspace
	local chunk = subContextStorage.Resort.chunk
	chunk.Name = 'resort'
	chunk.Parent = storage.MapChunks

	subContextStorage:Remove()
	game:GetService('Lighting').TimeOfDay = '20:00:00'--'14:00:00'
else
	context = 'adventure'
	subContextStorage:Remove()
end

if context ~= 'adventure' then
	game:GetService('Players').ChildAdded:connect(function(player)
		if not player or not player:IsA('Player') then return end
		if player.UserId < 1 then
			player:Kick()
		end
	end)
end

local tag = Instance.new('StringValue')
tag.Name = 'GameContext'
tag.Value = context
tag.Parent = repStorage.Version

return context