-- For when teleporting to game
local text1, text2 = 'NOW', 'LOADING'
local forceContinue = false
local teleportGui
game:GetService('TeleportService').LocalPlayerArrivedFromTeleport:connect(function(gui, data)
	local player = game:GetService('Players').LocalPlayer
	local userId = player.UserId
	teleportGui = gui
	if not data or type(data) ~= 'table' or data.passcode ~= 'PBB_RTD_1214CD-14dW4289' then return end -- OVH  change passcode?
	if data.userId ~= userId then wait(); player:Kick('Teleport error: player ID mismatch') end
	forceContinue = true
end)
--

local player = game:GetService('Players').LocalPlayer
local userId = player.UserId
local gui = Instance.new('ScreenGui')

-- We need local copies of some Utilities
local Timing = {
	easeOutCubic = function(d)
		return function(t)
			t = t / d - 1
			return t^3 + 1
		end
	end
}
local stepped = game:GetService('RunService').RenderStepped
function Tween(duration, timing, fn)
	if type(timing) == 'string' then
		timing = Timing[timing](duration)
	end
	local st = tick()
	fn(0)
	while true do
		stepped:wait()
		local et = tick()-st
		if et >= duration then
			fn(1)
			return
		end
		local a = et/duration
		if timing then
			a = timing(et)
		end
		if fn(a) == false then return end
	end
end
function create(instanceType)
	return function(data)
		local obj = Instance.new(instanceType)
		for k, v in pairs(data) do
			local s, e = pcall(function()
				if type(k) == 'number' then
					v.Parent = obj
				elseif type(v) == 'function' then
					obj[k]:connect(v)
				else
					obj[k] = v
				end
			end)
			if not s then
				error('Create: could not set property '..k..' of '..instanceType..' ('..e..')', 2)
			end
		end
		return obj
	end
end


local PlayerGui = player:FindFirstChild('PlayerGui')
repeat wait() until PlayerGui
gui.Name = 'LoadingGui'
gui.Parent = PlayerGui
for _, id in pairs({288621494,288621623,288621744,288621878, 191836102,191836129,191836172,191836194,191836210, 288652352, 288686590, 270154756, 313110711,313609630}) do
	create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://'..id,
		ImageColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(0.0, 1, 0.0, 1),
		Parent = gui,
	}
end
local container = create 'Frame' {
	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
	Size = UDim2.new(1.0, 0, 1.0, 70),
	Position = UDim2.new(0.0, 0, 0.0, -70),
	Parent = gui
}
local top = create 'Frame' {
	BackgroundTransparency = 1.0,
	Size = UDim2.new(1.0, 0, 0.5, 0),-- 36),
	Position = UDim2.new(0.0, 0, 0.0, 0),-- -36),
	ClipsDescendants = true,
	Parent = container,
}
local bottom = create 'Frame' {
	BackgroundTransparency = 1.0,
	Size = UDim2.new(1.0, 0, 0.5, 0),
	Position = UDim2.new(0.0, 0, 0.5, 0),
	ClipsDescendants = true,
	Parent = container,

	create 'Frame' {
		Name = 'div',
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 2.0, 0),-- 36),
		Position = UDim2.new(0.0, 0, -1.0, 0),-- -36),
	}
}
function tileBackgroundTexture(frameToFill)
	frameToFill:ClearAllChildren()
	local backgroundTextureSize = Vector2.new(512, 512)
	for i = 0, math.ceil(frameToFill.AbsoluteSize.X/backgroundTextureSize.X) do
		for j = 0, math.ceil(frameToFill.AbsoluteSize.Y/backgroundTextureSize.Y) do
			create 'ImageLabel' {
				BackgroundTransparency = 1,
				Image = 'rbxasset://textures/loading/darkLoadingTexture.png',
				Position = UDim2.new(0, i*backgroundTextureSize.X, 0, j*backgroundTextureSize.Y),
				Size = UDim2.new(0, backgroundTextureSize.X, 0, backgroundTextureSize.Y),
				ZIndex = 2,
				Parent = frameToFill,
			}
		end
	end
end
local sq = create 'Frame' {
	BackgroundTransparency = 1.0,
	SizeConstraint = Enum.SizeConstraint.RelativeYY,
	Size = UDim2.new(1.0, 0, 1.0, 0),
	Parent = container,
}
local function onScreenSizeChanged(prop)
	if prop ~= 'AbsoluteSize' then return end
	tileBackgroundTexture(top)
	tileBackgroundTexture(bottom.div)
	sq.Position = UDim2.new(0.5, -sq.AbsoluteSize.X/2, 0.0, 0)
end

local circle = create 'ImageLabel' {
	BackgroundTransparency = 1.0,
	Image = 'rbxassetid://6299613262',
	ImageColor3 = Color3.new(0, 0, 0),
	Size = UDim2.new(0.0, 1, 0.0, 1),
	Position = UDim2.new(0.1, 0, 0.5, 0),
	ZIndex = 3,
	Parent = sq,
}
local ball = create 'ImageLabel' {
	BackgroundTransparency = 1.0,
	Image = 'rbxassetid://5685510578',-- 5685510578
	Size = UDim2.new(0.0, 1, 0.0, 1),
	Position = UDim2.new(0.1, 0, 0.5, 0),
	ZIndex = 4,
	Parent = sq,
}
spawn(function()
	local s = tick()
	while ball.Parent do
		stepped:wait()
		ball.Rotation = (tick()-s)*250
	end
end)
local s = 0.1
local nowcontainer = create 'Frame' {
	BackgroundTransparency = 1.0,
	ClipsDescendants = true,
	Size = UDim2.new(1.0, 0, s, 0),
	Position = UDim2.new(-0.5-s*2.5/2, 0, 0.5-s/2, 0),
	Parent = sq,
}
local now = create 'TextLabel' {
	BackgroundTransparency = 1.0,
	Size = UDim2.new(1.0, 0, 1.0, 0),
	Position = UDim2.new(1.0, 0, 0.0, 0),
	Text = text1,
	TextXAlignment = Enum.TextXAlignment.Right,
	Font = Enum.Font.SourceSansBold,
	TextScaled = true,
	TextColor3 = Color3.new(.3, .3, .3),
	ZIndex = 5,
	Parent = nowcontainer,
}
local loadingcontainer = create 'Frame' {
	BackgroundTransparency = 1.0,
	ClipsDescendants = true,
	Size = UDim2.new(1.0, 0, s, 0),
	Position = UDim2.new(0.5+s*2.5/2, 0, 0.5-s/2, 0),
	Parent = sq,
}
local loading = create 'TextLabel' {
	BackgroundTransparency = 1.0,
	Size = UDim2.new(1.0, 0, 1.0, 0),
	Position = UDim2.new(-1.0, 0, 0.0, 0),
	Text = text2,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.SourceSansBold,
	TextScaled = true,
	TextColor3 = Color3.new(.3, .3, .3),
	ZIndex = 5,
	Parent = loadingcontainer,
}

wait(.1)
local ch = gui.Changed:connect(onScreenSizeChanged)
onScreenSizeChanged('AbsoluteSize')
game:GetService('ReplicatedFirst'):RemoveDefaultLoadingScreen()
wait(.1)
if teleportGui then
	teleportGui:Remove()
end

local b = s*2.25
delay(.5, function()
	Tween(.7, 'easeOutCubic', function(a)
		ball.Size = UDim2.new(b*a, 0, b*a, 0)
		ball.Position = UDim2.new(0.5-b*a/2, 0, 0.5-b*a/2, 0)
	end)
end)
Tween(1, 'easeOutCubic', function(a)
	top.Position = UDim2.new(0.0, 0, -s/2*a, 0)-- -36)
	bottom.Position = UDim2.new(0.0, 0, 0.5+s/2*a, 0)
	circle.Size = UDim2.new(s*2.5*a, 0, s*2.5*a, 0)
	circle.Position = UDim2.new(0.5-s*2.5*a/2, 0, 0.5-s*2.5*a/2, 0)
end)
Tween(.5, 'easeOutCubic', function(a)
	now.Position = UDim2.new(1-a, 0, -0.01, 0)
	loading.Position = UDim2.new(-1+a, 0, -0.01, 0)
end)


wait(.5)
while true do
	wait(.5)
	if game:IsLoaded() then break end
	wait(.5)
end
game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local removeBan = {
}
for _, idOrName in pairs(removeBan) do
	if player.Name == idOrName or userId == idOrName then
		pcall(function() game:GetService('ReplicatedStorage'):ClearAllChildren() end)
		player:Kick()
		player:Remove()
		error()
	end
end
local ban = {
}
for _, idOrName in pairs(ban) do
	if player.Name == idOrName or userId == idOrName then
		game:GetService('ReplicatedStorage'):ClearAllChildren()
		Instance.new('BindableEvent').Event:wait()
	end
end

local comTag = script.Parent:WaitForChild('Waiting')

if not teleportGui then
	game:GetService('ContentProvider'):PreloadAsync{'rbxassetid://18721678491'}
	create('Sound')({SoundId = 'rbxassetid://18721678491', Looped = true, Parent = gui}):Play()
end

local fader = create 'Frame' {
	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
	Size = UDim2.new(1.0, 0, 1.0, 0),
	ZIndex = 10,
	Parent = container,
}
Tween(1.6, 'easeOutCubic', function(a)
	local o = 1-a
	top.Position = UDim2.new(0.0, 0, -s/2*o, 0)-- -36)
	bottom.Position = UDim2.new(0.0, 0, 0.5+s/2*o, 0)
	circle.Size = UDim2.new(s*2.5*o, 0, s*2.5*o, 0)
	circle.Position = UDim2.new(0.5-s*2.5*o/2, 0, 0.5-s*2.5*o/2, 0)
	now.Position = UDim2.new(a, 0, -0.01, 0)
	loading.Position = UDim2.new(-a, 0, -0.01, 0)

	ball.ImageColor3 = Color3.new(o, o, o)
	ball.Size = UDim2.new(b+3*a, 0, b+3*a, 0)
	ball.Position = UDim2.new(0.5-b/2-3*a/2, 0, 0.5-b/2-3*a/2, 0)
	fader.BackgroundTransparency = o
end)

ch:disconnect()
if gui then
	comTag.Value = gui
end
if forceContinue then
	comTag.Name = 'ForceContinue'
else
	comTag.Name = 'Ready'
end
script:Remove()
