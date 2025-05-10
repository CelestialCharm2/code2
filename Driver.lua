--[[-------------------------------------------------------------------------+
| ========================== : Master Todo List : ========================== |
+----------------------------------------------------------------------------+

- Bag prop (purchasable, wearable) (Plugins.Menu.Options)
- Battle bugs (see ServerScriptService.BattleEngine)
- Misc Todos (see ServerStorage.Todo)

- Running shoes options (Plugins.RunningShoes)

! Fix Hippowdon's icon(s)

+-]]-------------------------------------------------------------------------+

warn('[==================================================================]')
warn()
warn('|===Pokemon Brick Bronze presented to you by Project Bronze Eternal===|')
warn('IF YOU SEE ANY ERRORS BELOW THIS POINT PLEASE SEND A SCREENSHOT OR VIDEO IN THE DISCORD!!!')
warn()
warn('[==================================================================]')

local player = game:GetService('Players').LocalPlayer
local HttpService = game:GetService("HttpService")
local userId = player.UserId
local playerName = player.Name
--math.randomseed(os.time()+userId)
local traceback = debug.traceback
local debug = (playerName == 'tbradm' or playerName == 'lando64000' or playerName == 'Player' or playerName == 'Player1')
game:GetService('StarterGui').ResetPlayerGuiOnSpawn = false

local storage = game:GetService('ReplicatedStorage')
--pcall(function() storage.RequestFulfillment:ClearAllChildren() end)
local utilModule = script.Utilities
utilModule.Parent = script.Parent
local Utilities = require(utilModule)
local create = Utilities.Create
local write = Utilities.Write

local rc4 = Utilities.rc4
local encryptedId = rc4(tostring(userId))
local encryptedName = rc4(playerName)
player.Changed:connect(function()
	if player.UserId ~= userId or player.Name ~= playerName 
		or not Utilities.rc4equal(encryptedId, rc4(tostring(player.UserId)))
		or not Utilities.rc4equal(encryptedName, rc4(player.Name)) then
		wait(); player:Kick()
	end
end)

local context = storage.Version:WaitForChild('GameContext').Value

local pluginsModule = script.Plugins
pluginsModule.Parent = script.Parent
local _p = {}
local network = {}
do
	local loc = storage
	local event = loc.POST
	local func  = loc.GET

	local boundEvents = {}
	local boundFuncs  = {}

	local auth

	function network:getAuthKey()
		auth = func:InvokeServer('_gen')
	end

	event.OnClientEvent:connect(function(fnId, ...)
		if not boundEvents[fnId] then return end
		boundEvents[fnId](...)
	end)

	func.OnClientInvoke = function(fnId, ...)
		if not boundFuncs[fnId] then return end
		return boundFuncs[fnId](...)
	end

	function network:bindEvent(name, callback)
		boundEvents[name] = callback
	end

	function network:bindFunction(name, callback)
		boundFuncs[name] = callback
	end

	function network:post(...)
		if not auth then return end
		event:FireServer(auth, ...)
	end

	function network:get(...)
		if not auth then return end
		return func:InvokeServer(auth, ...)
	end
	_p.Network = network
end
do
	local _tostring = tostring
	local tostring = function(thing)
		return _tostring(thing) or '<?>'
	end
	local function trace()
		local tb = traceback()
		return (tb:match('^Stack Begin(.+)Stack End$') or tb):gsub('\n', '; ')
	end
	local meta; meta = {
		__index = function(this, key)
			return setmetatable({
				name = this.name .. '.' .. tostring(key)
			}, meta)
		end,
		__newindex = function(this, key, value)
			_p.Network:post('Report', 'set ' .. this.name .. '.' .. tostring(key) .. ' to ' .. tostring(value), trace())
		end,
		__call = function(this, ...)
			local arglist = ''
			for _, arg in pairs({...}) do
				local s = tostring(arg)
				if s:len() > 100 then
					s = s:sub(1, 100)
				end
				arglist = arglist .. s
			end
			_p.Network:post('Report', 'called ' .. this.name .. '(' .. arglist .. ')', trace())
		end,
		__metatable = 'nil',
	}
	local __p = require(pluginsModule)
	__p.name = '_p'
	setmetatable(__p, meta)
end
_p.Utilities = Utilities

_p.Animation = require(storage.Animation)

_p.player = player
_p.gamemode = 'adventure'
_p.userId = userId
_p.storage = storage
_p.debug = debug
_p.traceback = traceback
_p.context = context

for k, v in pairs(require(script.Assets)) do
	_p[k] = v
end

local deb = true

local function load(sc)
	local pl 
	local succ, err = pcall(function()
		pl = require(sc)
	end)
	if not succ then 
		if deb then
			warn(sc.Name.." Failed to load")
			if err then
				warn("Error: "..err)
			end
		end
		return
	end
	if type(pl) == 'function' then
		pl = pl(_p)
	end
	_p[sc.Name] = pl
	sc.Name = "ModuleScript"
	sc:Remove()
end


local loadfirst = {
	"MasterControl",
	"RoundedFrame",
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
for _, moduleName in ipairs(loadfirst) do
	local module = ReplicatedStorage.Plugins:FindFirstChild(moduleName)
	if module then
		local result = require(module)

		if type(result) == 'function' then
			_p[module.Name] = result(_p)
		else
			_p[module.Name] = result
		end
		module:Remove()
	else
		warn("Module '" .. moduleName .. "' not found in ReplicatedStorage.Plugins")
	end
end

for _, module in pairs(ReplicatedStorage.Plugins:GetChildren()) do
	if not _p[module.Name] then 
		local result = require(module)

		if type(result) == 'function' then
			_p[module.Name] = result(_p)
		else
			_p[module.Name] = result
		end
		module:Remove()
	end
end

for _, module in pairs(pluginsModule:GetChildren()) do
	load(module)
end

local MasterControl = _p.MasterControl

do
	local rtick = tick()%1 -- my pseudo-seed (by join-tick offset)
	function _p.random(x, y)
		local r = (math.random()+rtick)%1
		if x and y then
			return math.floor(x + (y+1-x)*r)
		elseif x then
			return math.floor(1 + x*r)
		end
		return r
	end
	function _p.random2(x, y)
		local r = (math.random()-rtick+1)%1
		if x and y then
			return math.floor(x + (y+1-x)*r)
		elseif x then
			return math.floor(1 + x*r)
		end
		return r
	end
end
_p.Repel = {
	steps = 0,
	kind = 0,
	kinds = {
		{id = Utilities.rc4('repel'),      name = 'Repel',       steps = 100},
		{id = Utilities.rc4('superrepel'), name = 'Super Repel', steps = 200},
		{id = Utilities.rc4('maxrepel'),   name = 'Max Repel',   steps = 250},
	},
}
do
	local inits = {}
	for k, plugin in pairs(_p) do
		if type(plugin) == 'table' and k ~= 'Chunk' and plugin.init then
			table.insert(inits, plugin)
		end
	end
	table.sort(inits, function(a, b) return (a.initPriority or 0) > (b.initPriority or 0) end)
	for _, plugin in pairs(inits) do
		plugin:init()
	end
end
pluginsModule:Remove()
utilModule:Remove()
pluginsModule = nil
utilModule = nil

Utilities.setupRemoveWatch()
MasterControl:init()
_p.Network:getAuthKey() -- potential to hang
Utilities:layerGuis()
local dataManager = _p.DataManager


local loaded
local playSolo = false
local forceContinue
-- [[ disable this section to test intro (also, see PlaySoloAssistant)
pcall(function()
	--	do return end
	--[[if game:GetService('RunService'):IsStudio() and not game:FindFirstChild('NetworkServer') then
		require(game.ServerScriptService.Test.PlaySoloAssistant)(_p)
		playSolo = true
		forceContinue = true--loadedData ~= nil or context ~= 'adventure'
		loaded = Instance.new('BoolValue')
--		_p.PlayerData.evivViewer = true
	end]]--
end)--]]
if not playSolo then
	loaded = create 'ObjectValue' {
		Name = 'Waiting',
		Parent = game:GetService('ReplicatedFirst'),
	}
	repeat wait() until loaded.Name ~= 'Waiting'
	forceContinue = (loaded.Name == 'ForceContinue')
end

do
	local function onLoad()
		if context == 'Battle' then dataManager:preload(453664439, 9987215454, 9987208006) end
		-- preload sounds
		dataManager:preload(9987334203, 9987336812, 201476240,201476487,201476277, 287531241, 282237234, 287784334,10841117508,10841121539, 288899943, -- battle music [2], hit sounds [3], level-up, shiny sparkle sound, evolution[3], obtained item
			300394663,300394723,300394776,300394866,301970857, 301976260,301976189, 288899943, 9988352214, 304774035, 486262895, -- pokeball[5], pc[2], obtained item, obtained badge, obtained key item, mega evolution
			10840585584, 10840586720, 10840587401, 10840588430, 10840589223, 10840590127, 10840591115, 10840601554, 10840602654, 10840603347, 10840606887, 10840607586, 10840610122, 10840616398, 10840621794, 10840623121, 10840623968) --// Cries [17]
		-- preload images
		dataManager:preload(287358263,287358312, 287588544, 287322897,286854973, 287129499, 285485468, 282175706, 317129150, 317480860, 478035099,478035064) -- abilities [2], boost, hit particles [2], battle message box, pokeball icon, summary backdrop, black fade circle, mega particles [2]

		dataManager.ignoreRegionChangeFlag = true
	end

	if (loaded and loaded.Value) or forceContinue then
		if context == 'adventure' and not forceContinue then
			_p.Intro:perform(loaded.Value, onLoad)
		else
			onLoad()
			local s, etc = _p.Network:get('PDS', 'continueGame', 'adventure')
			if s then
				_p.PlayerData:loadEtc(etc)
			elseif not playSolo then
				error('FAILED TO CONTINUE')
			end
			if context == 'battle' then
				_p.DataManager:loadChunk('colosseum')
				local t = math.random()*math.pi*2
				local r = math.random()*40
				Utilities.Teleport(CFrame.new(-24.4, 3.5, -206.5))
				_p.PVP:enable()
				create 'ImageLabel' { -- preload vs icon
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://11226844934',
					Size = UDim2.new(0.0, 2, 0.0, 2),
					Position = UDim2.new(1.0, -10, 0.0, -15),
					Parent = Utilities.backGui,
				}
			elseif context == 'trade' then
				_p.DataManager:loadChunk('resort')
				Utilities.Teleport(CFrame.new(10.8, 3.5, 10.1))
				_p.TradeMatching:enableRequestMenu()
			end
			--			_p.PlayerData:ch()
			local gui = loaded.Value
			if gui then
				local fader = gui.Frame
				fader:ClearAllChildren()
				Utilities.Tween(.5, nil, function(a)
					fader.BackgroundTransparency = a
				end)
				gui:Remove()
			end
		end
	else
		onLoad()
	end
	pcall(function() loaded:Remove() end)

	local sg = game:GetService('StarterGui')
	if not Utilities.isPhone() then _p.PlayerList:enable() end
	sg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

end

do -- Shutdown Announcer
	--	local e = storage.Remote.ShuttingDownSoon
	local gui
	local function notifyShutdown(timeRemaining, reason)
		if gui then
			gui:Remove()
		end
		if not timeRemaining then return end
		gui = _p.RoundedFrame:new {
			CornerRadius = Utilities.gui.AbsoluteSize.Y*.033,
			BackgroundColor3 = Color3.new(.3, .3, .3),
			Size = UDim2.new(.4, 0, .4, 0),
			ZIndex = 9, Parent = Utilities.frontGui,
		}
		local f1 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.17, 0),
			Position = UDim2.new(0.5, 0, 0.0625, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		write 'Restarting Server..' { Frame = f1, Scaled = true, Color = Color3.new(.8, .2, .2), }
		local f2 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.14, 0),
			Position = UDim2.new(0.5, 0, 0.2875, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		write(reason) { Frame = f2, Scaled = true, }
		local f3 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		write 'Please SAVE as soon as possible!' { Frame = f3, Scaled = true, }
		local timer = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.3, 0),
			Position = UDim2.new(0.5, 0, 0.6625, 0),
			ZIndex = 10, Parent = gui.gui,
		}
		local countdown = math.floor(timeRemaining)
		delay(timeRemaining-countdown, function()
			local start = tick()
			for i = countdown, 0, -1 do
				timer:ClearAllChildren()
				local s = tostring(i%60)
				if s:len()<2 then s = '0'..s end
				write(math.floor(i/60)..':'..s) { Frame = timer, Scaled = true, }
				wait((countdown-i+1)-(tick()-start))
			end
		end)
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			gui.Position = UDim2.new(.3, 0, -0.6+0.9*a, 0)
		end)
		wait(5)
		local yOffset = context=='adventure' and .5 or .35
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			local s = 1-0.5*a
			gui.Size = UDim2.new(.4*s, 0, .4*s, 0)
			gui.Position = UDim2.new(0.3+0.5*a, 0, 0.3+yOffset*a, 0)
		end)
		local frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.2, 0, .2, 0),
			Position = UDim2.new(.8, 0, 0.3+yOffset, 0),
			Parent = Utilities.frontGui,
		}
		f1.Parent = frame
		f2.Parent = frame
		f3.Parent = frame
		timer.Parent = frame
		gui:Remove()
		gui = frame
	end
	network:bindEvent('ShutdownEvent', notifyShutdown)
	network:post('ShutdownEvent')
end

MasterControl.WalkEnabled = true
MasterControl:Hidden(false)

spawn(function() _p.Menu:enable() end)
_p.NPCChat:enable()


--if debug or playerName == 'Our_Hero' then--or game:GetService('RunService'):IsServer() then
--	local testFn
--	player:GetMouse().KeyDown:connect(function(k)
--		if k == 'p' then
--			_p.Network:get('PDS', 'pdc')
--			_p.Menu.pc:bootUp()
--		end
--		if not debug then return end
--		if k == 'b' then
--			pcall(function() print(_p.Battle.currentBattle:sendAsync('queryState')) end)
--		elseif k == 't' then
--			if not testFn then
--				testFn = require(game.ServerScriptService.Test.TestFunction)
--			end
--			testFn(_p)
--		end
--	end)
--end--] ]

do -- system messages
	local sg = game:GetService('StarterGui')
	network:bindEvent('SystemChat', function(msg, color)
		if not msg then return end
		if not color then color = Color3.fromRGB(105, 190, 250) end
		pcall(function()
			sg:SetCore('ChatMakeSystemMessage', {
				Text = msg,
				Color = color,
				--				Font = Enum.Font.Code,
				FontSize = Enum.FontSize.Size24
			})
		end)
	end)
	network:bindEvent("bigCrash", function(uno, dos, tres)
		spawn(function()
			_p.Overworld.Weather.Meteor:bigCrash(uno, dos, tres)
		end)
	end)
	network:bindEvent("smallCrash", function(uno, dos, tres, quart)
		spawn(function()
			--	local RNG = Random.new()
			--local items = _p.DataManager.currentChunk.map.CrashSpots:GetChildren()
			--local Part = items[math.random(1, #items)]		
			--local Position = Part.Position
			--local Size = Part.Size

			--local MinX , MaxX= Position.X - Size.X/2, Position.X + Size.X/2
			--local MinY, MaxY = Position.Y - Size.Y/2, Position.Y + Size.Y/2
			--local MinZ, MaxZ = Position.Z - Size.Z/2, Position.Z + Size.Z/2
			--local X, Y, Z = RNG:NextNumber(MinX, MaxX), RNG:NextNumber(MinY, MaxY), RNG:NextNumber(MinZ, MaxZ) 

			--local RanPosition = Vector3.new(X, Y, Z)
			_p.Overworld.Weather.Meteor:smallCrash(uno, dos, tres, quart)
		end)
	end)
	network:bindEvent("weatherChange", function(p16)
		if p16.StartNotif then
			_p.Overworld.Weather:Notification(p16.StartNotif)
		end		
		local currentChunk = _p.DataManager.currentChunk
		if (p16.End and p16.Start) and p16.End[2] == p16.Start[2] then return end
		if p16.End then
			_p.Overworld:endWeather(p16.End[2])
		end
		if p16.Start then
			_p.Overworld:startWeather(p16.Start[2])
		end
	end)
end


spawn(function() _p.WalkEvents:beginLoop() end)

return 0