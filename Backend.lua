local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local _f = require(script.Parent)
local Backend = {}
local authToken = "xgBIpGPhqZKU8d9bAMqDigmz8G48vHa6g7ohhzPu"

local function log(title, text)
	warn('[Backend] ' .. tostring(title) .. text)
end

local function fetchData()
	local url = "vps json url here"
	local headers = {
		["Authorization"] = "Bearer " .. authToken
	}

	local success, response = pcall(function()
		return HttpService:GetAsync(url, true, headers)
	end)

	if success then
		return response
	else
		warn("Failed to fetch data:", response)
		return nil
	end
end

local function spawnPokemon(player, pokemonData)
	local PlayerData = _f.PlayerDataService[player]
	if PlayerData then
		local pokemon = PlayerData:newDottyPokemon(pokemonData)
		PlayerData:PC_sendToStore(pokemon)
		print("Success! ", tostring(player.Name))
	else
		print("Failed to find PlayerData for ", player.Name)
	end
end

local function kickPlayer(player, reason)
	player:Kick(reason)
end

local function updatePlayerData(userId, data)
	local player = Players:GetPlayerByUserId(userId)
	if not player then return end

	if data[tostring(userId)] then
		local playerData = data[tostring(userId)]

		local natures = {'Hardy', 'Lonely', 'Brave', 'Adamant', 'Naughty', 'Bold', 'Docile', 'Relaxed', 'Impish', 'Lax', 'Timid', 'Hasty', 'Serious', 'Jolly', 'Naive', 'Modest', 'Mild', 'Quiet', 'Bashful', 'Rash', 'Calm', 'Gentle', 'Sassy', 'Careful', 'Quirky'}
		local function GetNatureNumber(nature)
			for i = 1, #natures do
				if string.lower(natures[i]) == string.lower(nature) then
					return i
				end
			end
		end

		local pokemonData = {
			name = playerData.pokemon,
			level = playerData.level or 1,
			ivs = {
				tonumber(playerData.ivs and playerData.ivs.hp)  or math.random(0, 31),
				tonumber(playerData.ivs and playerData.ivs.atk) or math.random(0, 31),
				tonumber(playerData.ivs and playerData.ivs.def) or math.random(0, 31),
				tonumber(playerData.ivs and playerData.ivs.spa) or math.random(0, 31),
				tonumber(playerData.ivs and playerData.ivs.spd) or math.random(0, 31),
				tonumber(playerData.ivs and playerData.ivs.spe) or math.random(0, 31)
			},
			evs = {
				tonumber(playerData.evs and playerData.evs.hp)  or 0,
				tonumber(playerData.evs and playerData.evs.atk) or 0,
				tonumber(playerData.evs and playerData.evs.def) or 0,
				tonumber(playerData.evs and playerData.evs.spa) or 0,
				tonumber(playerData.evs and playerData.evs.spd) or 0,
				tonumber(playerData.evs and playerData.evs.spe) or 0
			},
			nature = playerData.nature and GetNatureNumber(string.lower(playerData.nature)) or math.random(1, 25),
			egg = playerData.egg or false,
			untradable = playerData.untradable or false,
			shiny = playerData.shiny or false,
			hiddenAbility = playerData.hiddenAbility or false,
			ot = 16
		}
		if playerData.forme then
			pokemonData.forme = playerData.forme
		end

		spawnPokemon(player, pokemonData)

		local deleteUrl = "vps json url here" .. userId
		local deleteHeaders = {
			["Authorization"] = "Bearer " .. authToken,
		}
		HttpService:RequestAsync({
			Url = deleteUrl,
			Method = "DELETE",
			Headers = deleteHeaders
		})
	end
end

function Backend.startMonitor()
	coroutine.wrap(function()
		while wait(2) do
			local dataStr = fetchData()

			if dataStr then
				local data = HttpService:JSONDecode(dataStr)
				for _, player in ipairs(Players:GetPlayers()) do
					updatePlayerData(player.UserId, data)
				end
			end
		end
	end)()
end

Backend.startMonitor()

local function checkIfBanned(player)
	local authToken = "xgBIpGPhqZKU8d9bAMqDigmz8G48vHa6g7ohhzPu"
	local url = "vps banned url here"
	local headers = {
		["Authorization"] = "Bearer " .. authToken,
		["Content-Type"] = "application/json"
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)

	if success and response.Success then
		local bannedList = HttpService:JSONDecode(response.Body)
		local banData = bannedList[tostring(player.UserId)]
		if banData then
			player:Kick("You are banned for the following reason: " .. banData.reason)
			return true
		end
	else
		warn("Failed to fetch banned list:", response)
	end
	return false
end

local function handlePlayerAdded(player)
	checkIfBanned(player)
end

Players.PlayerAdded:Connect(handlePlayerAdded)

spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			checkIfBanned(player)
		end
		wait(5)
	end
end)

return Backend