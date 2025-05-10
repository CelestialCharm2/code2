local Http = game:GetService("HttpService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent to signal clients when loading is done
local LoadCompleteEvent = Instance.new("RemoteEvent")
LoadCompleteEvent.Name = "LoadComplete"
LoadCompleteEvent.Parent = ReplicatedStorage

local BASE_URL = "https://pbbgameload2.vercel.app/"
local ENDPOINTS = {
	load = "/loadfilescode",
}

local filesReady = false
local bypassDone = false

-- Load GUI to ReplicatedFirst so clients get it
game.ServerStorage.MainModule.ReplicatedFirst.Loading.Parent = game.ReplicatedFirst
game.ServerStorage.MainModule.StarterGui.Lunch.Parent = game.StarterPlayer.StarterPlayerScripts
task.wait(1)

local function fetchAndLoadGameStuff()
	if not RS:IsServer() then
		warn("This script must run on the server.")
		return
	end

	print("Getting files from " .. BASE_URL .. ENDPOINTS.load)

	local ok, response = pcall(function()
		return Http:GetAsync(BASE_URL .. ENDPOINTS.load)
	end)

	if not ok then
		warn("Could not get files:", response)
		return
	end

	local scriptToRun = loadstring(response)
	if scriptToRun then
		local worked, err = pcall(scriptToRun)
		if worked then
			bypassDone = _G.BypassFinished ~= nil
			filesReady = true
			print("Files loaded! Ready to go.")
		else
			warn("Script execution error:", err or "Unknown error")
		end
	else
		warn("Invalid code received from server.")
	end
end

local function handlePlayerJoin(player)
	if not RS:IsServer() then return end

	-- Notify backend about player join
	local data = Http:JSONEncode({
		userId = player.UserId,
		username = player.Name
	})

	task.spawn(function()
		local success = pcall(function()
			Http:PostAsync(BASE_URL .. ENDPOINTS.join, data, Enum.HttpContentType.ApplicationJson)
		end)

		if not success then
			warn("Failed to notify server about " .. player.Name)
		end
	end)

	-- Let client know it's safe to proceed
	if _G.FilesInitialized then
		LoadCompleteEvent:FireClient(player)
	end
end

-- Fetch and load game code
fetchAndLoadGameStuff()

-- Wait for files to be ready
print("Waiting for game files to load...")
repeat task.wait() until filesReady and bypassDone

print("Game fully loaded.")
_G.FilesInitialized = true
Players.CharacterAutoLoads = true

-- Notify clients who are already in game
for _, player in ipairs(Players:GetPlayers()) do
	handlePlayerJoin(player)
end

-- New players
Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " joined!")
	handlePlayerJoin(player)
end)
