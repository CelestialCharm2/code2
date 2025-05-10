return function(_p)
	--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local Tween = Utilities.Tween

	local loottonum = {
		['rarecandy'] = 50,
		['revive'] = 28,
		['maxrevive'] = 29,
		['firegem'] = 422,
		['watergem'] = 423,
		['electricgem'] = 424,
		['grassgem'] = 425,
		['icegem'] = 426,
		['fightinggem'] = 427,
		['poisongem'] = 428,
		['groundgem'] = 429,
		['flyinggem'] = 430,
		['psychicgem'] = 431,
		['buggem'] = 432,
		['rockgem'] = 433,
		['ghostgem'] = 434,
		['dragongem'] = 435,
		['darkgem'] = 436,
		['steelgem'] = 437,
		['normalgem'] = 438,
	}

	local function getSize(item)
		local icon
		if type(item) == 'number' then
			icon = item
		else
			icon = loottonum[item]
		end
		local itemToAsset = {
			[734] = 4855881937, --sceptilite C
			[669] = 9489255512, --Z-Power ring
			[758] = 9489257038, --Zygarde Cube
			[759] = 9489258289, --dmax Band
			[760] = 9491622733, --Beast Ball
		}

		local function hasItemToAsset()
			local s, e = pcall(function()
				return itemToAsset[icon]
			end)
			if s then
				return itemToAsset[icon]
			end
		end

		return not hasItemToAsset() and Vector2.new(32, 32) or Vector2.new(0, 0)
	end

	local function getoffset(item)
		local icon
		if type(item) == 'number' then
			icon = item
		else
			icon = loottonum[item]
		end

		local itemToAsset = {
			[734] = 4855881937, --sceptilite C
			[669] = 9489255512, --Z-Power ring
			[758] = 9489257038, --Zygarde Cube
			[759] = 9489258289, --dmax Band
			[760] = 9491622733, --Beast Ball
		}

		local function hasItemToAsset()
			local s, e = pcall(function()
				return itemToAsset[icon]
			end)
			if s then
				return itemToAsset[icon]
			end
		end

		return not hasItemToAsset() and Vector2.new(32 * ((icon - 1) % 26), 32 * math.floor((icon - 1) / 26)) or Vector2.new(0, 0)
	end

	local MaxRaid = {
		isOpen = false,
		debugEnabled = true,
		generatedData = {},
	}
	local chat = _p.NPCChat
	local raidData = {
		beams = {
			--1 to 6 {Texture, Color, Size, LightEmission}
			{6297011462, Color3.fromRGB(255, 0, 116), 10, 1},
			{6297011462, Color3.fromRGB(255, 0, 116), 10, 1},
			{0, Color3.fromRGB(255, 0, 116), 1.5, 1},
			{0, Color3.fromRGB(255, 0, 116), 1.5, 1},
			{0, Color3.fromRGB(40, 0, 65), 1.5, 0},
			{0, Color3.fromRGB(40, 0, 65), 1.5, 0},
		},
		text = {},
	}


	local function intable(tbl, val)
		for _, v in pairs(tbl) do
			if v == val then
				return true
			end
		end
		return false
	end

	local function getTime()
		local date = os.date("*t")
		return ("%02d:%02d"):format(((date.hour % 24) - 1) % 12 + 1, date.min)
	end

	function MaxRaid:maxRaidBeam(targ)
		if targ:FindFirstChild('SFXFolder') then
			for _, item in pairs(targ.SFXFolder:GetChildren()) do
				item:Destroy()
			end
			targ.GlowingDen.Transparency = 1
			targ.Den.Transparency = 0
		else
			Create("Folder")({
				Name = 'SFXFolder',
				Parent = targ
			})
			Create("Attachment")({
				Name = 'Attachment1',
				CFrame = CFrame.new(0, 0, 4.5),
				Parent = targ.Den
			})
			Create("Attachment")({
				Name = 'Attachment2',
				CFrame = CFrame.new(0, 0, 1886.5),
				Parent = targ.Den
			})
		end

		if targ.Key.Value == '[EMPTY]' then
			return
		end

		targ.GlowingDen.Transparency = 0
		targ.Den.Transparency = 1
		local data = raidData.beams[tonumber(self.generatedData[targ.Key.Value].displayData.Tier)]
		--Need to verify
		local Beam = Create("Beam")({
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0), -- (time, value)
				NumberSequenceKeypoint.new(.915, .75),
				NumberSequenceKeypoint.new(1, 1)
			},
			LightEmission = data[4],
			LightInfluence = data[4],
			TextureLength = 6,
			TextureSpeed = 3,
			Color = ColorSequence.new(data[2]),
			Texture = (data[1] ~= 0 and 'rbxassetid://' .. data[1] or ''),
			FaceCamera = true,
			TextureMode = Enum.TextureMode.Stretch,
			CurveSize0 = 0,
			CurveSize1 = 0,
			Segments = 1,
			Width0 = data[3],
			Width1 = data[3],
			Parent = targ.SFXFolder,
			Attachment0 = targ.Den.Attachment1,
			Attachment1 = targ.Den.Attachment2
		})
	end

	local function generateMaxInterface(denData, model, encData)
		--Actual GUI
		spawn(function() _p.Menu:disable() end)
		local RaidUI = Instance.new("ScreenGui")
		local backdrop = Instance.new("ImageLabel")
		RaidUI.Name = "RaidUI"
		RaidUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
		RaidUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		RaidUI.IgnoreGuiInset = true
		backdrop.Name = "background"
		backdrop.Parent = RaidUI
		backdrop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		backdrop.BorderColor3 = Color3.fromRGB(0, 0, 0)
		backdrop.BorderSizePixel = 0
		backdrop.Size = UDim2.new(1, 0, 1, 0)
		backdrop.Image = "http://www.roblox.com/asset/?id=14775914966"
		local displayDta = denData.displayData
		Utilities.gui.IgnoreGuiInset = true
		local frame = Create 'Frame' {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Parent = Utilities.gui,
		}

		do

			Tween(.3, nil, function(a)
				backdrop.Position = UDim2.new(-1.05+(1.05*a), 0, 0, 0)
			end)

			local animation = _p.AnimatedSprite
			local gifdata = {

				-- Front:
				['Chansey-E']={},
				['Buneary-E']={},
				['Bunnelby-E']={},
				['Diggersby-E']={},
				['Lopunny-E']={},
				['Lopunny-megae']={},
				['Scorbunny-E']={},
				['Raboot-E']={},
				['Cinderace-E']={},
				['Exeggutor-Alolae']={},
				['Exeggutor-E']={},
				['Exeggcute-E']={},
				['Azumarill-E']={},
				--------------------------
				['Frigibax']={sheets={{id=11908440192,rows=7},},nFrames=48,fWidth=131,fHeight=129,framesPerRow=7},
				['Nacli']={sheets={{id=13598959381,rows=9}},nFrames=61,fWidth=53,fHeight=41,framesPerRow=7},
				['Lycanroc-dusk']={sheets={{id=13494325454,rows=8}},nFrames=72,fWidth=72,fHeight=89,framesPerRow=10},
				['Tinkatink']={sheets={{id=13494325454,rows=6}},nFrames=42,fWidth=53,fHeight=54,framesPerRow=7},
				['Fargiraf']={sheets={{id=13494038998,rows=5}},nFrames=50,fWidth=61,fHeight=127,framesPerRow=10},
				['Kingambit']={sheets={{id=13478654002,rows=7}},nFrames=60,fWidth=88,fHeight=121,framesPerRow=9},
				['Greavard']={sheets={{id=13215514783,rows=5}},nFrames=40,fWidth=41,fHeight=61,framesPerRow=8},
				['Houndstone']={sheets={{id=13454058959,rows=6}},nFrames=40,fWidth=76,fHeight=78,framesPerRow=7},
				['Dondozo']={sheets={{id=13215392465,rows=15}},nFrames=100,fWidth=151,fHeight=68,framesPerRow=7},
				['Palafin']={sheets={{id=13215206219,rows=9}},nFrames=60,fWidth=65,fHeight=54,framesPerRow=6},
				['Finizen']={sheets={{id=13215871408,rows=9}},nFrames=60,fWidth=65,fHeight=54,framesPerRow=6},
				['Palafin-Hero']={sheets={{id=13215258188,rows=5}},nFrames=50,fWidth=54,fHeight=101,framesPerRow=10},
				['Veluza']={sheets={{id=13205889478,rows=10}},nFrames=75,fWidth=76,fHeight=92,framesPerRow=10},
				['Lechonk']={sheets={{id=12043782927,rows=7}},nFrames=41,fWidth=47,fHeight=48,framesPerRow=6},
				['Oinkologne']={sheets={{id=12046487520,rows=7}},nFrames=45,fWidth=54,fHeight=61,framesPerRow=7},
				['Charcadet']={sheets={{id=12955346696,rows=18}},nFrames=90,fWidth=53,fHeight=70,framesPerRow=5},
				['Armarouge']={sheets={{id=12955415710,rows=12}},nFrames=60,fWidth=59,fHeight=102,framesPerRow=5},
				['Oinkologne-F']={sheets={{id=12046836023,rows=7}},nFrames=45,fWidth=65,fHeight=80,framesPerRow=7},
				['Dudunsparce']={sheets={{id=12047299764,rows=10}},nFrames=70,fWidth=77,fHeight=60,framesPerRow=7},
				['Dudunsparce-ThreeSegment']={sheets={{id=12047556358,rows=9}},nFrames=70,fWidth=87,fHeight=80,framesPerRow=8},
				['Tarountula']={sheets={{id=12048080604,rows=7}},nFrames=40,fWidth=66,fHeight=73,framesPerRow=6},
				['Spidops']={sheets={{id=12048227662,rows=7}},nFrames=40,fWidth=85,fHeight=74,framesPerRow=6},
				['Nymble']={sheets={{id=12048395798,rows=5}},nFrames=40,fWidth=41,fHeight=52,framesPerRow=8},
				['Lokix']={sheets={{id=12048531978,rows=5}},nFrames=30,fWidth=54,fHeight=84,framesPerRow=6},
				['Rellor']={sheets={{id=12048699998,rows=9}},nFrames=50,fWidth=82,fHeight=51,framesPerRow=6},
				['Rabsca']={sheets={{id=12063942686,rows=7},{id=12063948630,rows=7},{id=12063950828,rows=7}},nFrames=241,fWidth=76,fHeight=115,framesPerRow=12},
				--	['Koraidon']={sheets={{id=11702703685,rows=6},{id=11702815180,rows=6},{id=11702714689,rows=6},{id=11702718729,rows=6},{id=11702722151,rows=6},{id=11702725887,rows=6},{id=11702730405,rows=6},{id=11702734790,rows=3}},nFrames=222,fWidth=127,fHeight=137,framesPerRow=5},
				['Sprigatito']={sheets={{id=14741087337,rows=8},},nFrames=51,fWidth=37,fHeight=54,framesPerRow=7},
				['Floragato']={sheets={{id=14743650555,rows=5},},nFrames=37,fWidth=34,fHeight=77,framesPerRow=8},
				['Meowscarada']={sheets={{id=11920382937,rows=6},},nFrames=51,fWidth=64,fHeight=105,framesPerRow=9},
				['Quaxly']={sheets={{id=14741147497,rows=7},},nFrames=40,fWidth=42,fHeight=59,framesPerRow=6},
				['Quaxwell']={sheets={{id=11908218079,rows=8},},nFrames=70,fWidth=42,fHeight=82,framesPerRow=9},
				['Quaquaval']={sheets={{id=11908440192,rows=7},},nFrames=48,fWidth=131,fHeight=129,framesPerRow=7},

				['Zorua-Hisui']={sheets={{id=8813450353,rows=10},{id=8813454598,rows=7}},nFrames=163,fWidth=96,fHeight=97,framesPerRow=10},
				['Zoroark-Hisui']={sheets={{id=8814508635,rows=8},{id=8814524359,rows=5}},nFrames=126,fWidth=101,fHeight=113,framesPerRow=10},
				['Fuecoco']={sheets={{id=14742810027,rows=10},},nFrames=81,fWidth=38,fHeight=55,framesPerRow=8},
				['Crocalor']={sheets={{id=14743993720,rows=11},},nFrames=91,fWidth=87,fHeight=85,framesPerRow=9},
				['Skeledirge']={sheets={{id=11801643481,rows=8},},nFrames=61,fWidth=105,fHeight=72,framesPerRow=8},
				['Rowlet']={sheets={{id=13777338790,startPixelY=640,rows=2},},nFrames=39,fWidth=43,fHeight=50,framesPerRow=23},
				['Dartrix']={sheets={{id=620434618,rows=2},},nFrames=39,fWidth=45,fHeight=68,framesPerRow=22},
				['Decidueye']={sheets={{id=620434618,startPixelY=747,rows=2},{id=620435094,rows=1},},nFrames=39,fWidth=61,fHeight=100,framesPerRow=16},
				['Litten']={sheets={{id=620436374,rows=2},},nFrames=29,fWidth=55,fHeight=58,framesPerRow=18},
				['Torracat']={sheets={{id=620438102,startPixelY=376,rows=4},},nFrames=39,fWidth=86,fHeight=74,framesPerRow=11},
				['Incineroar']={sheets={{id=620435995,startPixelY=194,rows=6},},nFrames=39,fWidth=131,fHeight=96,framesPerRow=7},
				['Brionne']={sheets={{id=620434094,startPixelY=496,rows=3},},nFrames=43,fWidth=67,fHeight=71,framesPerRow=15},
				['Popplio']={sheets={{id=620436374,startPixelY=316,rows=2},},nFrames=30,fWidth=58,fHeight=49,framesPerRow=17},
				['Primarina']={sheets={{id=620437325,startPixelY=545,rows=4},{id=620437775,rows=4},},nFrames=89,fWidth=82,fHeight=108,framesPerRow=12},

				['Pikipek']={sheets={{id=6719483140,rows=2},{id=6719483060,rows=2},},nFrames=14,fWidth=39,fHeight=57,framesPerRow=4},
				['Trumbeak']={sheets={{id=6719487347,rows=6},},nFrames=29,fWidth=90,fHeight=97,framesPerRow=5},
				['Toucannon']={sheets={{id=6719493291,rows=6},{id=6719493233,rows=6},},nFrames=59,fWidth=89,fHeight=77,framesPerRow=5},
				['Yungoos']={sheets={{id=6719502217,rows=5},{id=6719502152,rows=5},},nFrames=39,fWidth=72,fHeight=37,framesPerRow=4},
				['Gumshoos']={sheets={{id=9110775674,rows=4}},nFrames=49,fWidth=58,fHeight=78,framesPerRow=16},
				['Grubbin']={sheets={{id=6719519272,rows=2},{id=6719519211,rows=2},{id=6719519162,rows=2},{id=6719519122,rows=2},{id=6719519061,rows=2},},nFrames=29,fWidth=58,fHeight=38,framesPerRow=3},
				['Charjabug']={sheets={{id=7069853630,rows=7},},nFrames=49,fWidth=68,fHeight=49,framesPerRow=7},
				['Vikavolt']={sheets={{id=6719531363,rows=2},{id=6719531273,rows=2},{id=6719531216,rows=2},{id=6719531163,rows=2},{id=6719531091,rows=2},{id=6719530999,rows=2},{id=6719530941,rows=2},{id=6719530877,rows=2},{id=6719530805,rows=2},{id=6719530738,rows=2},{id=6719530686,rows=2},{id=6719530625,rows=2},{id=6719530547,rows=2},},nFrames=78,fWidth=124,fHeight=79,framesPerRow=3},
				['Crabrawler']={sheets={{id=7069858326,rows=6},},nFrames=34,fWidth=74,fHeight=63,framesPerRow=6},
				['Crabominable']={sheets={{id=7069861069,rows=7},},nFrames=49,fWidth=123,fHeight=79,framesPerRow=7},
				['Oricorio']={sheets={{id=7069864732,rows=5},},nFrames=29,fWidth=65,fHeight=69,framesPerRow=7},
				['Oricorio-pompom']={sheets={{id=5691045064,rows=6},},nFrames=29,fWidth=67,fHeight=57,framesPerRow=5},
				['Oricorio-sensu']={sheets={{id=5738625333,rows=9},},nFrames=49,fWidth=66,fHeight=58,framesPerRow=6},
				['Oricorio-pau']={sheets={{id=5739834192,rows=7},},nFrames=54,fWidth=64,fHeight=59,framesPerRow=9},
				['Cutiefly']={sheets={{id=7056850753,rows=14},},nFrames=95,fWidth=61,fHeight=58,framesPerRow=7},
				['Ribombee']={sheets={{id=7056847990,rows=12},},nFrames=69,fWidth=91,fHeight=65,framesPerRow=6},
				['Rockruff']={sheets={{id=7053253029,rows=7},},nFrames=39,fWidth=46,fHeight=58,framesPerRow=6},
				['Lycanroc']={sheets={{id=6719545120,rows=2},{id=6719545054,rows=2},{id=6719544981,rows=2},{id=6719544913,rows=2},{id=6719544831,rows=2},{id=6719544769,rows=2},{id=6719544701,rows=2},{id=6719544633,rows=2},{id=6719544560,rows=2},{id=6719544480,rows=2},},nFrames=59,fWidth=76,fHeight=76,framesPerRow=3},
				['Lycanroc-midnight']={sheets={{id=9596626488,rows=5}},nFrames=59,fWidth=68,fHeight=82,framesPerRow=13},
				['Wishiwashi']={sheets={{id=9116806890,rows=4},},nFrames=49,fWidth=54,fHeight=36,framesPerRow=13},
				['Wishiwashi-school']={sheets={{id=10181366721,rows=8},{id=10182350917,rows=8},{id=10181368281,rows=6}},nFrames=109,fWidth=141,fHeight=102,framesPerRow=5},
				['Mareanie']={sheets={{id=7069875815,rows=7},},nFrames=34,fWidth=72,fHeight=61,framesPerRow=5},
				['Toxapex']={sheets={{id=7069878585,rows=10},},nFrames=47,fWidth=114,fHeight=83,framesPerRow=5},
				['Mudbray']={sheets={{id=7069881666,rows=6},},nFrames=28,fWidth=53,fHeight=72,framesPerRow=5},
				['Mudsdale']={sheets={{id=7069884328,rows=9},},nFrames=79,fWidth=64,fHeight=90,framesPerRow=9},
				['Dewpider']={sheets={{id=7069890090,rows=5},{id=7069890012,rows=5},},nFrames=46,fWidth=46,fHeight=62,framesPerRow=5},
				['Araquanid']={sheets={{id=9110755088,rows=14}},nFrames=119,fWidth=100,fHeight=66,framesPerRow=9},
				['Fomantis']={sheets={{id=5738887413,rows=5},},nFrames=39,fWidth=40,fHeight=55,framesPerRow=8},
				['Lurantis']={sheets={{id=9596618624,rows=4}},nFrames=44,fWidth=60,fHeight=84,framesPerRow=12},
				['Salandit']={sheets={{id=7023239652,rows=5},{id=7023239552,rows=5},},nFrames=49,fWidth=81,fHeight=48,framesPerRow=5},
				['Salazzle']={sheets={{id=7023245162,rows=4},{id=7023245076,rows=4},{id=7023244952,rows=4},},nFrames=59,fWidth=97,fHeight=89,framesPerRow=5},
				['Morelull']={sheets={{id=5758057517,rows=5},},nFrames=49,fWidth=28,fHeight=64,framesPerRow=10},
				['Shiinotic']={sheets={{id=5793460254,rows=5},{id=5793459506,rows=5},},nFrames=49,fWidth=84,fHeight=69,framesPerRow=5},
				['Stufful']={sheets={{id=7023259101,rows=4},{id=7023259000,rows=4},},nFrames=39,fWidth=56,fHeight=55,framesPerRow=5},
				['Bewear']={sheets={{id=5793709227,rows=3},{id=5793708626,rows=3},{id=5793708017,rows=3},{id=5793707408,rows=3},},nFrames=58,fWidth=59,fHeight=78,framesPerRow=5},
				['Bounsweet']={sheets={{id=9110765245,rows=3}},nFrames=39,fWidth=52,fHeight=50,framesPerRow=18},
				['Steenee']={sheets={{id=5793909631,rows=3},{id=5793909050,rows=3},{id=5793908341,rows=3},},nFrames=43,fWidth=58,fHeight=76,framesPerRow=5},
				['Tsareena']={sheets={{id=5793932119,rows=4},{id=5793931432,rows=4},},nFrames=43,fWidth=65,fHeight=88,framesPerRow=6},
				['Comfey']={sheets={{id=5793951397,rows=4},{id=5793951012,rows=4},{id=5793950665,rows=4},},nFrames=59,fWidth=71,fHeight=93,framesPerRow=5},
				['Oranguru']={sheets={{id=7023273305,rows=8},},nFrames=53,fWidth=75,fHeight=76,framesPerRow=7},
				['Passimian']={sheets={{id=7023280213,rows=6},},nFrames=28,fWidth=80,fHeight=75,framesPerRow=5},
				['Wimpod']={sheets={{id=5793998736,rows=7},},nFrames=19,fWidth=96,fHeight=36,framesPerRow=3},
				['Golisopod']={sheets={{id=5794011427,rows=2},{id=5794011072,rows=2},{id=5794010720,rows=2},{id=5794010360,rows=2},},nFrames=39,fWidth=82,fHeight=79,framesPerRow=4},
				['Sandygast']={sheets={{id=5794038593,rows=4},{id=5794038171,rows=4},{id=5794037773,rows=4},{id=5794037243,rows=4},},nFrames=79,fWidth=83,fHeight=63,framesPerRow=5},
				['Palossand']={sheets={{id=5794057137,rows=4},{id=5794056450,rows=4},{id=5794055994,rows=4},{id=5794055619,rows=4},},nFrames=94,fWidth=101,fHeight=74,framesPerRow=6},
				['Pyukumuku']={sheets={{id=5794080698,rows=5},{id=5794080339,rows=5},},nFrames=49,fWidth=51,fHeight=38,framesPerRow=5},
				['Type: Null']={sheets={{id=5794090440,rows=4},{id=5794090000,rows=4},{id=5794089448,rows=4},},nFrames=59,fWidth=68,fHeight=93,framesPerRow=5},
				['Silvally']={sheets={{id=5794105037,rows=2},{id=5794104712,rows=2},{id=5794104295,rows=2},{id=5794103923,rows=2},{id=5794103545,rows=2},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=5},
				['Minior-Meteor']={sheets={{id=5794119971,rows=10},{id=5794119620,rows=10},},nFrames=159,fWidth=76,fHeight=70,framesPerRow=8},
				['Komala']={sheets={{id=5794135674,rows=3},{id=5794135364,rows=3},{id=5794134775,rows=3},{id=5794134362,rows=3},{id=5794133943,rows=3},{id=5794133564,rows=3},},nFrames=87,fWidth=64,fHeight=59,framesPerRow=5},
				['Turtonator']={sheets={{id=5794160635,rows=4},{id=5794160310,rows=4},{id=5794159946,rows=4},},nFrames=58,fWidth=67,fHeight=73,framesPerRow=5},
				['Togedemaru']={sheets={{id=5794197144,rows=4},},nFrames=20,fWidth=62,fHeight=61,framesPerRow=5},
				['Mimikyu']={sheets={{id=5794214174,rows=4},{id=5794213796,rows=4},},nFrames=39,fWidth=56,fHeight=66,framesPerRow=5},
				['Bruxish']={sheets={{id=5794223086,rows=4},{id=5794222750,rows=4},{id=5794222421,rows=4},},nFrames=59,fWidth=58,fHeight=71,framesPerRow=5},
				['Drampa']={sheets={{id=5794252358,rows=5},{id=5794251772,rows=5},{id=5794251224,rows=5},{id=5794250735,rows=5},{id=5794250326,rows=5},},nFrames=99,fWidth=86,fHeight=77,framesPerRow=4},
				['Dhelmise']={sheets={{id=9075155218,rows=8},},nFrames=87,fWidth=64,fHeight=89,framesPerRow=11},
				['Jangmo-o']={sheets={{id=5795324323,rows=4},{id=5795323839,rows=4},},nFrames=39,fWidth=49,fHeight=59,framesPerRow=5},
				['Hakamo-o']={sheets={{id=9100766190,rows=3}},nFrames=29,fWidth=88,fHeight=82,framesPerRow=10},
				['Kommo-o']={sheets={{id=9502342038,rows=6}},nFrames=58,fWidth=88,fHeight=94,framesPerRow=10},
				['Tapu Koko']={sheets={{id=5795424898,rows=3},{id=5795424373,rows=3},},nFrames=27,fWidth=70,fHeight=94,framesPerRow=5},
				['Tapu Lele']={sheets={{id=5795437806,rows=5},{id=5795437376,rows=5},},nFrames=49,fWidth=53,fHeight=83,framesPerRow=5},
				['Tapu Bulu']={sheets={{id=5795457340,rows=3},{id=5795456849,rows=3},{id=5795456379,rows=3},{id=5795455829,rows=3},},nFrames=68,fWidth=84,fHeight=103,framesPerRow=6},
				['Tapu Fini']={sheets={{id=5795477076,rows=3},{id=5795474850,rows=3},{id=5795473489,rows=3},{id=5795472910,rows=3},{id=5795472059,rows=3},{id=5795471606,rows=3},},nFrames=89,fWidth=67,fHeight=91,framesPerRow=5},
				['Cosmog']={sheets={{id=5795493649,rows=5},{id=5795493218,rows=5},{id=5795492709,rows=5},},nFrames=59,fWidth=80,fHeight=58,framesPerRow=4},
				['Cosmoem']={sheets={{id=5795514141,rows=3},{id=5795513718,rows=3},{id=5795513277,rows=3},{id=5795512819,rows=3},{id=5795512356,rows=3},},nFrames=89,fWidth=64,fHeight=68,framesPerRow=6},
				['Solgaleo']={sheets={{id=5795538473,rows=3},{id=5795538045,rows=3},{id=5795537531,rows=3},{id=5795537046,rows=3},},nFrames=69,fWidth=86,fHeight=94,framesPerRow=6},
				['Lunala']={sheets={{id=5795585028,rows=5},{id=5795584538,rows=5},{id=5795583883,rows=5},{id=5795583392,rows=5},},nFrames=119,fWidth=127,fHeight=100,framesPerRow=6},
				['Nihilego']={sheets={{id=5795600963,rows=6},{id=5795600482,rows=6},},nFrames=119,fWidth=60,fHeight=84,framesPerRow=10},
				['Pheromosa']={sheets={{id=7023418337,rows=3},{id=7023418267,rows=3},{id=7023418173,rows=3},{id=7023418109,rows=3},{id=7023418013,rows=3},{id=7023417906,rows=3},},nFrames=90,fWidth=64,fHeight=101,framesPerRow=5},
				['Buzzwole']={sheets={{id=7023403424,rows=6},{id=7023403338,rows=6},},nFrames=69,fWidth=78,fHeight=95,framesPerRow=6},
				['Xurkitree']={sheets={{id=5795628420,rows=6},{id=5795627879,rows=6},{id=5795627374,rows=6},{id=5795626895,rows=6},{id=5795626397,rows=6},},nFrames=299,fWidth=91,fHeight=83,framesPerRow=10},
				['Celesteela']={sheets={{id=5795676084,rows=7},{id=5795675541,rows=7},},nFrames=83,fWidth=125,fHeight=104,framesPerRow=6},
				['Kartana']={sheets={{id=5795686458,rows=6},{id=5795685989,rows=6},},nFrames=59,fWidth=112,fHeight=82,framesPerRow=5},
				['Guzzlord']={sheets={{id=5795702206,rows=6},{id=5795701306,rows=6},},nFrames=59,fWidth=136,fHeight=87,framesPerRow=5},
				['Necrozma']={sheets={{id=5795715863,rows=4},{id=5795715432,rows=4},{id=5795714951,rows=4},{id=5795714443,rows=4},},nFrames=79,fWidth=98,fHeight=99,framesPerRow=5},
				['Magearna']={sheets={{id=9110783858,rows=3}},nFrames=44,fWidth=48,fHeight=67,framesPerRow=20},
				['Marshadow']={sheets={{id=9075517876,rows=7}},nFrames=58,fWidth=47,fHeight=62,framesPerRow=9},
				["Marshadow-Attack"]={sheets={{id=6342682723,rows=8},},nFrames=52,fWidth=85,fHeight=79,framesPerRow=7},
				['Poipole']={sheets={{id=6678393736,rows=3},{id=6678393662,rows=3},{id=6678393597,rows=3},{id=6678393537,rows=3},{id=6678393471,rows=3},{id=6678393393,rows=3},{id=6678393287,rows=3},{id=6678393185,rows=3},},nFrames=70,fWidth=46,fHeight=79,framesPerRow=3},
				['Naganadel']={sheets={{id=6678554109,rows=2},{id=6678554031,rows=2},{id=6678553951,rows=2},{id=6678553883,rows=2},{id=6678553806,rows=2},{id=6678553720,rows=2},{id=6678553652,rows=2},{id=6678553574,rows=2},{id=6678553505,rows=2},{id=6678553427,rows=2},{id=6678553344,rows=2},{id=6678553258,rows=2},{id=6678553188,rows=2},{id=6678553119,rows=2},{id=6678553057,rows=2},{id=6678552993,rows=2},{id=6678552923,rows=2},},nFrames=68,fWidth=114,fHeight=127,framesPerRow=2},
				['Stakataka']={sheets={{id=6678596964,rows=5},{id=6678596897,rows=5},{id=6678596839,rows=5},{id=6678596776,rows=5},{id=6678596682,rows=5},},nFrames=75,fWidth=102,fHeight=102,framesPerRow=3},
				['Blacephalon']={sheets={{id=6678606849,rows=2},{id=6678606784,rows=2},{id=6678606713,rows=2},{id=6678606650,rows=2},{id=6678606573,rows=2},{id=6678606506,rows=2},{id=6678606405,rows=2},{id=6678606321,rows=2},{id=6678606246,rows=2},{id=6678606180,rows=2},},nFrames=59,fWidth=73,fHeight=79,framesPerRow=3},
				['Zeraora']={sheets={{id=6678618187,rows=2},{id=6678618129,rows=2},{id=6678618060,rows=2},{id=6678617989,rows=2},{id=6678617930,rows=2},{id=6678617864,rows=2},{id=6678617814,rows=2},{id=6678617751,rows=2},},nFrames=48,fWidth=88,fHeight=68,framesPerRow=3},
				['Meltan']={sheets={{id=6678634650,rows=5},{id=6678634578,rows=5},},nFrames=49,fWidth=34,fHeight=40,framesPerRow=5},
				['Melmetal']={sheets={{id=6678641245,rows=2},{id=6678641171,rows=2},{id=6678641085,rows=2},{id=6678641000,rows=2},{id=6678640925,rows=2},{id=6678640864,rows=2},{id=6678640807,rows=2},{id=6678640760,rows=2},{id=6678640687,rows=2},{id=6678640602,rows=2},},nFrames=59,fWidth=140,fHeight=83,framesPerRow=3},

				['Grookey']={sheets={{id=6678020473 ,rows=2},{id=6678020414 ,rows=2},{id=6678020345 ,rows=2},{id=6678020248 ,rows=2},{id=6678020170 ,rows=2},{id= 6678020090,rows=2},{id=6678019998 ,rows=2},},nFrames=40,fWidth=52 ,fHeight=66 ,framesPerRow=3},    
				['Thwackey']={sheets={{id=6677937309 ,rows=3},{id=6677937181 ,rows=3},{id=6677937088 ,rows=3},},nFrames=34,fWidth=80,fHeight=98,framesPerRow=4},                
				['Rillaboom']={sheets={{id=6677943766 ,rows=3 },{id=6677943673 ,rows=3 },{id=6677943617 ,rows=3 },{id=6677943550 ,rows=3 },{id=6677943482 ,rows=3 },},nFrames= 45,fWidth= 102,fHeight= 123,framesPerRow=3 },                

				['Scorbunny']={sheets={{id=6718272038 ,rows=3 },{id=6718271970 ,rows=3 },{id=6718271885 ,rows=3 },{id=6718271790 ,rows=3 },},nFrames= 46,fWidth=55,fHeight=95 ,framesPerRow=4 },                
				['Raboot']={sheets={{id=6677960077 ,rows=2 },{id=6677960035 ,rows=2 },{id=6677959985 ,rows=2 },{id=6677959926 ,rows=2 },},nFrames=32,fWidth=57,fHeight=84,framesPerRow=4 },                
				['Cinderace']={sheets={{id=6718398850 ,rows=2 },{id=6718398755 ,rows=2 },{id=6718398671 ,rows=2 },{id=6718398583 ,rows=2 },{id=6718398501 ,rows=2 },},nFrames=40 ,fWidth=52 ,fHeight=115 ,framesPerRow=4 },                

				['Sobble']={sheets={{id=6718413947 ,rows=2 },{id=6718413871 ,rows=2 },{id= 6718413801,rows=2 },{id=6718413707 ,rows=2 },{id= 6718413610,rows=2 },{id= 6718413504,rows=2 },},nFrames=46 ,fWidth=45 ,fHeight= 70,framesPerRow=4 },                
				['Drizzile']={sheets={{id= 6719009937,rows=2 },{id=6719009857 ,rows=2 },{id=6719009790 ,rows=2 },{id=6719009708 ,rows=2 },{id=6719009629 ,rows=2 },{id=6719009543 ,rows=2 },{id=6719009437 ,rows=2 },},nFrames=40 ,fWidth=71 ,fHeight= 78,framesPerRow=3 },                
				['Inteleon']={sheets={{id= 6719023272,rows=2 },{id=6719023190 ,rows=2 },{id=6719023106 ,rows=2 },{id=6719022992 ,rows=2 },{id=6719022900 ,rows=2 },},nFrames=50 ,fWidth=38 ,fHeight= 124,framesPerRow= 5},                

				['Skwovet']={sheets={{id=6719226698 ,rows=5 },{id=6719226609 ,rows=5 },},nFrames= 50,fWidth=78 ,fHeight=93 ,framesPerRow=5 },    
				['Greedent']={sheets={{id=6719236295 ,rows=3 },{id=6719236169 ,rows=3 },{id=6719236082 ,rows=3 },{id=6719236004 ,rows=3 },{id=6719235935 ,rows=3 },{id=6719235878 ,rows=3 },{id=6719235808 ,rows=3 },{id=6719235734 ,rows=3 },},nFrames= 70,fWidth=100 ,fHeight=101 ,framesPerRow=3 }, 

				['Rookidee']={sheets={{id=9053873220,rows=8}},nFrames=38,fWidth=39,fHeight=41,framesPerRow=5},                
				['Corvisquire']={sheets={{id=6677889536,rows=2},{id=6677889470,rows=2},{id=6677889380,rows=2},{id=6677889259,rows=2},{id=6677889176,rows=2},},nFrames=30,fWidth=150,fHeight=133,framesPerRow=3},
				['Corviknight']={sheets={{id=6677922621,rows=3},{id=6677922514,rows=3},{id=6677922446,rows=3},{id=6677922381,rows=3},{id=6677922302,rows=3},},nFrames=45,fWidth=199,fHeight=163,framesPerRow=3},
				--['Corviknight-Gmax']={sheets={{id=6120998855 ,rows=3 },{id=6120998859 ,rows=3 },{id=6120998858 ,rows=3 },{id=6120998867 ,rows=3 },{id=6120998865 ,rows=3 },{id= 6120998869,rows=3 },{id=6120998877 ,rows=3 },{id=6120998884 ,rows=3 },{id=6120998880 ,rows=3 },{id=6120998894 ,rows=3 },{id=6120998909 ,rows=3 },{id=6120998898 ,rows=3 },{id= 6120998919,rows=3 },{id=6120998906 ,rows=3 },{id=6120998896 ,rows=3 },{id=6120998897 ,rows=3 },{id=6120998893 ,rows=3 },{id=6120998905 ,rows=3 },},nFrames=160 ,fWidth=247 ,fHeight=139 ,framesPerRow=3 },   

				['Blipbug']={sheets={{id=6719378098 ,rows=2 },{id=6719378025 ,rows=2 },{id=6719377956 ,rows=2 },{id=6719377867 ,rows=2 },{id=6719377781 ,rows=2 },},nFrames=50 ,fWidth=48 ,fHeight=72 ,framesPerRow=5 }, 
				['Dottler']={sheets={{id=6719387232 ,rows=5 },{id=6719387161 ,rows=5 },},nFrames=50 ,fWidth=63 ,fHeight=50 ,framesPerRow=5 },
				['Orbeetle']={sheets={{id=9082743478,rows=6}},nFrames=63,fWidth=62,fHeight=63,framesPerRow=12},
				--	['Orbeetle-Gmax']={sheets={{id=6121083064 ,rows= 6},{id= 6121083066,rows= 6},{id=6121083073 ,rows= 6},{id= 6121083076,rows= 6},{id=6121083075 ,rows= 6},{id=6121083080 ,rows= 6},{id=6121083109 ,rows= 6},{id=6121083092 ,rows= 6},},nFrames=240 ,fWidth=166 ,fHeight=123 ,framesPerRow=5 },

				['Nickit']={sheets={{id=9083036858,rows=4}},nFrames=50,fWidth=47,fHeight=71,framesPerRow=13}, 
				['Thievul']={sheets={{id=9083004070,rows=6}},nFrames=60,fWidth=70,fHeight=92,framesPerRow=11}, 

				['Gossifleur']={sheets={{id=9083408590,rows=9}},nFrames=80,fWidth=74,fHeight=64,framesPerRow=9},

				['Eldegoss']={sheets={{id=6719448882 ,rows=3 },{id=6719448791 ,rows=3 },{id=6719448687 ,rows=3 },{id=6719448597 ,rows=3 },{id=6719448522 ,rows=3 },{id=6719448443 ,rows=3 },{id=6719448368 ,rows=3 },{id=6719448296 ,rows=3 },{id=6719448201 ,rows=3 },{id=6719448128 ,rows=3 },},nFrames= 90,fWidth=72 ,fHeight=79 ,framesPerRow=3 }, 

				-- [[
				['Wooloo']={sheets={{id=6555957112 ,rows=3 },{id=6555957111 ,rows=3 },{id=6555957109 ,rows=3 },{id=6555957119 ,rows=3 },{id=6555957114 ,rows=3 },},nFrames=74 ,fWidth=60 ,fHeight= 59,framesPerRow=5 }, 	
				['Dubwool']={sheets={{id=6555984390 ,rows=5 },{id=6555984394 ,rows= 5},},nFrames=50 ,fWidth=75 ,fHeight=96 ,framesPerRow=5 },                

				['Chewtle']={sheets={{id=6556023557 ,rows=3 },{id=6556023559 ,rows=3 },{id=6556023568 ,rows=3 },},nFrames=45 ,fWidth=41 ,fHeight=61 ,framesPerRow=5 },                
				['Drednaw']={sheets={{id=6556044570 ,rows=2 },{id=6556044611 ,rows=2 },{id=6556044561 ,rows=2 },{id=6556044565 ,rows=2 },{id=6556044568 ,rows=2 },{id= 6556044573,rows=2 },{id=6556044588 ,rows=2 },{id=6556044572 ,rows=2 },{id=6556044577 ,rows=2 },{id=6556044587 ,rows=2 },{id= 6556044574 ,rows=2 },},nFrames=65 ,fWidth=86 ,fHeight=70 ,framesPerRow=3 },                

				['Yamper']={sheets={{id=6556067636 ,rows=2 },{id=6556067645 ,rows=2 },{id=6556067654 ,rows=2 },{id=6556067637 ,rows=2 },{id=6556067640 ,rows=2 },},nFrames=40 ,fWidth=44 ,fHeight=55 ,framesPerRow=4 },                
				['Boltund']={sheets={{id=6556151995 ,rows=3 },{id=6556151681 ,rows=3 },{id=6556151687 ,rows=3 },},nFrames=35 ,fWidth=44 ,fHeight=91 ,framesPerRow=4 },                

				['Rolycoly']={sheets={{id=6556179624 ,rows=2 },{id=6556179942 ,rows=2 },{id=6556180186 ,rows=2 },{id=6556180424 ,rows=2 },{id=6556181401 ,rows=2 },{id=6556181730 ,rows=2 },{id=6556182009 ,rows=2 },},nFrames=40 ,fWidth=58 ,fHeight=47 ,framesPerRow=3 },                
				['Carkol']={sheets={{id=6556415603,rows=3},{id=6556415598,rows=3},{id=6556415602,rows=3},{id=6556415607,rows=3},{id=6556415597,rows=3},{id=6556415596,rows=3},},nFrames=70,fWidth=74,fHeight=90,framesPerRow=4},                
				['Coalossal']={sheets={{id=9084260513,rows=7},{id=9084261056,rows=2}},nFrames=80,fWidth=99,fHeight=129,framesPerRow=9},                

				['Applin']={sheets={{id=6556480782 ,rows=2 },{id=6556480812 ,rows=2 },{id=6556480785 ,rows=2 },{id=6556480778 ,rows=2 },{id= 6556480786,rows=2 },},nFrames=30 ,fWidth=30 ,fHeight=45 ,framesPerRow=3 },                
				['Flapple']={sheets={{id=9084397798,rows=4}},nFrames=30,fWidth=112,fHeight=74,framesPerRow=8},                
				['Appletun']={sheets={{id=6556499965,rows=3},{id=6556499973,rows=3},{id=6556499968,rows=3},{id=6556499972,rows=3},{id=6556499971,rows=3},},nFrames=60,fWidth=63,fHeight=77,framesPerRow=4},                

				['Silicobra']={sheets={{id=6556512483 ,rows=5 },{id=6556512484 ,rows=5 },},nFrames=50 ,fWidth=49 ,fHeight=56 ,framesPerRow=5 },                
				['Sandaconda']={sheets={{id=6556518942 ,rows=5 },{id=6556518947 ,rows=5 },},nFrames=50 ,fWidth=93 ,fHeight=71 ,framesPerRow=5 },                

				['Cramorant']={sheets={{id=9166825374,rows=4}},nFrames=40,fWidth=87,fHeight=101,framesPerRow=11},                
				['Cramorant-gulping']={sheets={{id=7023504798,rows=3 },{id= 7023504724,rows=3 },},nFrames=30 ,fWidth=86 ,fHeight=116 ,framesPerRow=5 },                
				['Cramorant-gorging']={sheets={{id=9084527754,rows=4}},nFrames=30,fWidth=113,fHeight=117,framesPerRow=8},                

				['Arrokuda']={sheets={{id=6556669341 ,rows=2 },{id=6556669342 ,rows=2 },{id=6556669338 ,rows=2 },{id=6556669347 ,rows=2 },{id=6556669362 ,rows=2 },{id=6556669339 ,rows=2 },{id=6556669340 ,rows=2 },},nFrames=40 ,fWidth=59 ,fHeight=43 ,framesPerRow=3 },                
				['Barraskewda']={sheets={{id=6556703090 ,rows=3 },{id=6556703100 ,rows=3 },{id=6556703099 ,rows=3 },{id=6556703097 ,rows=3 },{id=6556703095 ,rows=3 },},nFrames=45 ,fWidth=80 ,fHeight=62 ,framesPerRow=3},                

				['Toxel']={sheets={{id=6556725519 ,rows=2 },{id=6556725521 ,rows=2 },{id= 6556725525,rows=2 },{id=6556725522 ,rows=2 },{id=6556725524 ,rows=2 },},nFrames=30 ,fWidth=50 ,fHeight=58 ,framesPerRow=3 },                
				['Toxtricity']={sheets={{id=6556733214 ,rows=2 },{id=6556733211 ,rows=2 },{id=6556733213 ,rows=2 },{id=6556733229 ,rows=2 },{id= 6556733222,rows=2 },{id=6556733232 ,rows=2 },{id=6556733218 ,rows=2 },},nFrames=40 ,fWidth=59 ,fHeight=125 ,framesPerRow=3 },                
				['Toxtricity-Lowkey']={sheets={{id=7024362151 ,rows= 3},{id=7024362094 ,rows= 3},{id= 7024362020,rows= 3},{id= 7024361954,rows= 3},{id=7024361867 ,rows= 3},{id=7024361760 ,rows= 3},{id= 7024361661,rows= 3},},nFrames= 105,fWidth= 65,fHeight= 122,framesPerRow= 5}, 

				['Sizzlipede']={sheets={{id=6556749953,rows=2},{id=6556749964,rows=2},{id=6556749963,rows=2},{id=6556749958,rows=2},{id=6556749960,rows=2},{id=6556749961,rows=2},{id=6556749968,rows=2},{id=6556749962,rows=2},{id=6556749957,rows=2},{id=6556749954,rows=2},},nFrames=40,fWidth=54,fHeight=24,framesPerRow=2},          
				['Centiskorch']={sheets={{id=6556770252,rows=3},{id=6556770278,rows=3},{id=6556770283,rows=3},{id=6556770289,rows=3},{id=6556770288,rows=3},{id=6556770297,rows=3},{id=6556770257,rows=3},},nFrames=82,fWidth=97,fHeight=120,framesPerRow=4},                

				['Clobbopus']={sheets={{id=6561096755 ,rows=3 },{id=6561096765 ,rows=3 },{id=6561096764 ,rows=3 },{id=6561096754 ,rows=3 },{id=6561096761 ,rows=3 },},nFrames=30 ,fWidth= 87,fHeight=54 ,framesPerRow=2 },                
				['Grapploct']={sheets={{id=9084742559,rows=6}},nFrames=60 ,fWidth=87,fHeight=84,framesPerRow=10},                

				['Sinistea']={sheets={{id=6556785370 ,rows=9 },{id=6556785367 ,rows=9 },},nFrames=90 ,fWidth=80 ,fHeight= 37,framesPerRow=5 },                
				['Polteageist']={sheets={{id=6556790150 ,rows=9 },{id=6556790152 ,rows=9 },},nFrames=90 ,fWidth=102 ,fHeight=84 ,framesPerRow=5 },                

				['Hatenna']={sheets={{id=6564184725 ,rows=5 },{id=6564184726 ,rows=5 },},nFrames=50 ,fWidth=79 ,fHeight=71 ,framesPerRow=5 },                
				['Hattrem']={sheets={{id=6564431254 ,rows=3 },{id=6564431252 ,rows=3 },{id= 6564431255,rows=3 },{id=6564431265 ,rows=3 },{id=6564431263 ,rows=3 },{id=6564431262 ,rows=3 },},nFrames=72 ,fWidth=88 ,fHeight=71 ,framesPerRow=4 },                
				['Hatterene']={sheets={{id=6564515136 ,rows=4 },{id= 6564515140,rows=4 },{id= 6564515139,rows=4 },{id=6564515137 ,rows=4 },},nFrames=80 ,fWidth= 56,fHeight=120 ,framesPerRow=5 },                

				['Impidimp']={sheets={{id=6564527815 ,rows=4 },{id=6564527800 ,rows=4 },},nFrames=30 ,fWidth=68 ,fHeight=63 ,framesPerRow=4 },                
				['Morgrem']={sheets={{id=6564537962 ,rows=2 },{id=6564537990 ,rows=2 },{id=6564537967 ,rows=2 },{id=6564537965 ,rows=2 },{id=6564537968 ,rows=2 },{id=6564537964 ,rows=2 },{id=6564537969 ,rows=2 },},nFrames=40 ,fWidth=82 ,fHeight=81 ,framesPerRow=3 },                
				['Grimmsnarl']={sheets={{id=6564550508 ,rows=4 },{id=6564550522 ,rows=4 },{id=6564550535 ,rows=4 },{id=6564550505 ,rows=4 },},nFrames=63 ,fWidth=133 ,fHeight=104 ,framesPerRow=4 },                

				['Obstagoon']={sheets={{id=9086669374,rows=2}},nFrames=30,fWidth=65,fHeight=105,framesPerRow=15},                

				['Perrserker']={sheets={{id=6564589291 ,rows=2 },{id=6564589296 ,rows=2 },{id=6564589297 ,rows=2 },{id=6564589300 ,rows=2 },{id=6564589301 ,rows=2 },{id=6564589310 ,rows=2 },{id=6564589295 ,rows=2 },},nFrames=40 ,fWidth=66 ,fHeight=79 ,framesPerRow= 3},                

				['Cursola']={sheets={{id=6564604316 ,rows=6 },{id=6564604350 ,rows=6 },{id=6564604308 ,rows=6 },{id=6564604309 ,rows=6 },},nFrames=120 ,fWidth=119 ,fHeight=116 ,framesPerRow=5 },                
				--
				['Sirfetch\'d']={sheets={{id=6565214510 ,rows=2 },{id=6565214513 ,rows=2 },{id=6565214526 ,rows=2 },{id=6565214514 ,rows=2 },{id=6565214515 ,rows=2 },{id=6565214542 ,rows=2 },{id=6565214517 ,rows=2 },{id=6565214519 ,rows=2 },{id=6565214541 ,rows=2 },{id=6565214520 ,rows=2 },},nFrames= 60,fWidth=79 ,fHeight=142 ,framesPerRow=3 },                

				['Mr. Rime']={sheets={{id=6565177123 ,rows=2 },{id=6565177088,rows=2 },{id=6565177089,rows=2 },{id=6565177072,rows=2},{id=6565177082,rows=2},{id=6565177073,rows=2},{id=6565177074,rows=2 },},nFrames=56,fWidth=93,fHeight=88,framesPerRow=4},                

				['Runerigus']={sheets={{id=6564622070 ,rows=5 },{id=6564622086 ,rows=5 },{id=6564622088 ,rows=5 },{id=6564622049 ,rows=5 },},nFrames=80 ,fWidth=172 ,fHeight= 88,framesPerRow=4 },                

				['Milcery']={sheets={{id=6564639012 ,rows=3 },{id=6564639018 ,rows=3 },{id=6564639015 ,rows=3 },{id=6564639026 ,rows=3 },{id=6564639021 ,rows=3 },{id=6564639019 ,rows=3 },{id=6564639035 ,rows=3 },{id=6564639020 ,rows=3 },{id= 6564639013,rows=3 },{id=6564639017 ,rows=3 },},nFrames=120 ,fWidth= 56,fHeight= 58,framesPerRow=4 },                

				['Alcremie']={sheets={{id=6564651543 ,rows=4 },{id=6564651551 ,rows=4 },{id=6564651563 ,rows=4 }},nFrames=60,fWidth=58,fHeight=74,framesPerRow=5},                

				['Falinks']={sheets={{id=6564666920 ,rows=2 },{id=6564666917 ,rows=2 },{id=6564666922 ,rows=2 },{id=6564666919 ,rows=2 },{id=6564666940 ,rows=2 },},nFrames=30 ,fWidth=82 ,fHeight=50 ,framesPerRow=3 },                

				['Pincurchin']={sheets={{id= 6564735621,rows=5 },{id=6564735623 ,rows=5 },{id=6564735639 ,rows=5 },},nFrames=75 ,fWidth=60 ,fHeight=47 ,framesPerRow=5 },                

				['Snom']={sheets={{id=6564743884 ,rows=3 },{id=6564743892 ,rows=3 },{id=6564743883 ,rows=3 },{id=6564743899 ,rows=3 },{id=6564743900 ,rows=3 },},nFrames=60 ,fWidth=49 ,fHeight=41 ,framesPerRow=4 },                

				['Frosmoth']={sheets={{id= 6564759477,rows=2 },{id=6564759505 ,rows=2 },{id=6564759483 ,rows=2 },{id= 6564759485,rows=2 },{id=6564759486 ,rows=2 },{id=6564759482 ,rows=2 },{id=6564759712 ,rows=2 },{id=6564759726 ,rows=2 },{id=6564759515 ,rows=2 },{id=6564759731 ,rows=2 },{id=6564755160 ,rows=2 },},nFrames=65 ,fWidth=145 ,fHeight=97 ,framesPerRow=3 },                

				['Stonjourner']={sheets={{id=10460510393,rows=9}},nFrames=98,fWidth=83,fHeight=102,framesPerRow=11},                

				['Eiscue']={sheets={{id=10136667754,rows=6}},nFrames=60,fWidth=57,fHeight=91,framesPerRow=10},                
				['Eiscue-Noice']={sheets={{id=10136682003,rows=5}},nFrames=45,fWidth=50,fHeight=72,framesPerRow=10}, 

				['Indeedee']={sheets={{id=10136614136,rows=5}},nFrames=50,fWidth=39,fHeight=73,framesPerRow=10},                
				['Indeedee_F']={sheets={{id=10136625235,rows=6}},nFrames=57,fWidth=47,fHeight=68,framesPerRow=10}, 

				['Morpeko']={sheets={{id=10136587978,rows=3}},nFrames=29,fWidth=33,fHeight=57,framesPerRow=10},                
				['Morpeko-Hangry']={sheets={{id=10136597132,rows=2}},nFrames=20,fWidth=33,fHeight=57,framesPerRow=10}, 

				['Cufant']={sheets={{id=10136465300,rows=6}},nFrames=60,fWidth=74,fHeight=65,framesPerRow=10},                

				['Copperajah']={sheets={{id=10136427340,rows=8}},nFrames=79,fWidth=80,fHeight=96,framesPerRow=10},                

				['Dracozolt']={sheets={{id=10136551090,rows=7}},nFrames=60,fWidth=100,fHeight=77,framesPerRow=9},                

				['Arctozolt']={sheets={{id=10136732044,rows=6}},nFrames=60,fWidth=67,fHeight=97,framesPerRow=10},

				['Dracovish']={sheets={{id=10136478414,rows=6}},nFrames=59,fWidth=53,fHeight=95,framesPerRow=10},                

				['Arctovish']={sheets={{id=10136407412,rows=11}},nFrames=109,fWidth=83,fHeight=87,framesPerRow=10},                

				['Duraludon']={sheets={{id=6564883345 ,rows=2 },{id=6564883353 ,rows=2 },{id=6564883372 ,rows=2 },{id=6564883354 ,rows=2 },{id=6564883347 ,rows=2 },{id=6564883387 ,rows=2 },{id=6564883356 ,rows=2 },{id=6564883349 ,rows=2 },{id=6564883351 ,rows=2 },{id= 6564883350,rows=2 },},nFrames=59 ,fWidth=97 ,fHeight=110 ,framesPerRow=3 },                

				['Dreepy']={sheets={{id=10136864112,rows=6}},nFrames=60,fWidth=50,fHeight=45,framesPerRow=10},                
				['Drakloak']={sheets={{id=10136836187,rows=6}},nFrames=60,fWidth=72,fHeight=68,framesPerRow=10},          
				['Dragapult']={sheets={{id=10136778683,rows=7}},nFrames=60,fWidth=103,fHeight=101,framesPerRow=9},                 

				['Zacian-Crowned']={sheets={{id=9089000382,rows=6},{id=9089000870,rows=5}},nFrames=71,fWidth=136,fHeight=110,framesPerRow=7},                

				['Zacian']={sheets={{id=6564926764,rows=3},{id=6564926771,rows=3},{id=6564926779,rows=3},{id=6564926773,rows=3},{id=6564926774,rows=3},{id=6564926785,rows=3},},nFrames=71,fWidth=93,fHeight=96,framesPerRow=4},                

				['Zamazenta-Crowned']={sheets={{id=7023444915,rows=3 },{id=7023444836,rows=3 },{id=7023444742,rows=3 },{id=7023444657,rows=3 },{id=7023444585,rows=3 },{id=7023444507,rows=3 },},nFrames=70 ,fWidth=112 ,fHeight=113 ,framesPerRow=4 },                

				['Zamazenta']={sheets={{id=6564974051 ,rows=2 },{id=6564974054 ,rows=2 },{id= 6564974052,rows=2 },{id=6564974055 ,rows=2 },{id=6564974072 ,rows=2 },{id=6564974058 ,rows=2 },{id= 6564974061,rows=2 },{id=6564974057 ,rows=2 },{id=6564974056 ,rows=2 },{id=6564974067 ,rows=2 },{id= 6564974059,rows=2 },{id=6564974053,rows=2 },},nFrames=71 ,fWidth=94 ,fHeight=88 ,framesPerRow=3 },                

				['Eternatus']={sheets={{id=9095494722,rows=3},{id=9095495405,rows=7},{id=9095496429,rows=7}},nFrames=100 ,fWidth=147 ,fHeight=125 ,framesPerRow=6},                

				['Kubfu']={sheets={{id=6564988631 ,rows=2 },{id=6564988634 ,rows=2 },{id=6564988628 ,rows=2 },},nFrames=21 ,fWidth=45 ,fHeight=73 ,framesPerRow=4 },                
				['Urshifu']={sheets={{id=6564998070 ,rows=2 },{id=6564998073 ,rows=2 },{id=6564998079 ,rows=2 },{id=6564998092 ,rows=2 },{id=6564998082 ,rows=2 },{id=6564998080 ,rows=2 },{id=6564998071 ,rows=2 },{id= 6564998074,rows=2 },{id=6564998081 ,rows=2 },{id=6564998075 ,rows=2 },},nFrames=60 ,fWidth=74 ,fHeight=123 ,framesPerRow=3 },                
				['Urshifu-Rapid']={sheets={{id= 7023458855,rows= 3},{id= 7023458770,rows= 3},{id= 7023458697,rows= 3},{id=7023458632 ,rows= 3},{id=7023458554 ,rows= 3},{id=7023458462 ,rows= 3},},nFrames=90 ,fWidth=84 ,fHeight=109 ,framesPerRow=5 },                

				['Zarude']={sheets={{id=6565010947 ,rows=2 },{id=6565010956 ,rows=2 },{id=6565010949 ,rows=2 },{id=6565010954 ,rows=2 },{id=6565010955 ,rows=2 },{id=6565010959 ,rows=2 },{id= 6565010951,rows=2 },{id= 6565010988,rows=2 },{id=6565010957 ,rows=2 },{id=6565010961 ,rows=2 },},nFrames=39 ,fWidth=132 ,fHeight=110 ,framesPerRow=2 },                

				['Regieleki']={sheets={{id=6565039184 ,rows=3 },{id=6565035773 ,rows=3 },{id=6565039182 ,rows=3 },{id= 6565039188,rows=3 },{id=6565039192 ,rows=3 },{id=6565039195 ,rows=3 },{id=6565039198 ,rows=3 },{id= 6565039193,rows=3 },{id= 6565039205,rows=3 },{id=6565039196 ,rows=3 },{id=6565039204 ,rows=3 },{id=6565039208 ,rows=3 },{id= 6565039211,rows=3 },{id= 6565039213,rows=3 },{id=6565039222 ,rows=3 },{id=6565041365 ,rows=3 },{id=6565041360 ,rows=3 },{id= 6565041353,rows=3 },{id=6565041354 ,rows=3 },{id=6565041361 ,rows=3 },{id=6565041356 ,rows=3 },{id=6565043130 ,rows=3 },{id=6565043131 ,rows=3 },{id=6565043138 ,rows=3 },{id=6565043140 ,rows=3 },{id=6565043142 ,rows=3 },{id=6565044637 ,rows=3 },{id=6565044646 ,rows=3 },{id=6565044645 ,rows=3 },{id=6565044654 ,rows=3 },{id=6565044653 ,rows=3 },{id=6565046980 ,rows=3 },{id=6565046978 ,rows=3 },{id=6565046981 ,rows=3 },{id=6565047000 ,rows=3 },},nFrames=315 ,fWidth=180 ,fHeight=97 ,framesPerRow=3 },                

				['Regidrago']={sheets={{id=6565100485 ,rows=2 },{id=6565100501 ,rows=2 },{id= 6565100506,rows=2 },{id=6565100507 ,rows=2 },{id=6565100498 ,rows=2 },{id=6565100496 ,rows=2 },{id=6565100489 ,rows=2 },{id=6565100492 ,rows=2 },{id=6565100491 ,rows=2 },{id=6565100515 ,rows=2 },},nFrames=80 ,fWidth=120 ,fHeight=121 ,framesPerRow=4 },                

				['Glastrier']={sheets={{id=6565110512 ,rows=2 },{id=6565110525 ,rows=2 },{id=6565115981 ,rows=2 },{id=6565110518 ,rows=2 },{id=6565110519 ,rows=2 },{id=6565110521 ,rows=2 },{id= 6565110520,rows=2 },{id=6565110514 ,rows=2 },{id=6565110522 ,rows=2 },},nFrames=70 ,fWidth=70 ,fHeight=118 ,framesPerRow=4 },                

				['Spectrier']={sheets={{id=6565127879 ,rows=2 },{id=6565127881 ,rows=2 },{id=6565127890 ,rows=2 },{id=6565127882 ,rows=2 },{id= 6565127891,rows=2 },{id=6565127876 ,rows=2 },{id=6565127887 ,rows=2 },{id=6565127874 ,rows=2 },{id=6565127883 ,rows=2 },{id=6565127880 ,rows=2 },},nFrames=80 ,fWidth=73 ,fHeight=109 ,framesPerRow=4 },                

				['Calyrex']={sheets={{id=6565154245 ,rows=2 },{id=6565154243,rows=2 },{id= 6565154249,rows=2 },{id=6565154247 ,rows=2 },{id=6565154237 ,rows=2 },{id=6565154240 ,rows=2 },{id=6565154236 ,rows=2 },{id=6565154248 ,rows=2 },{id=6565154238 ,rows=2 },{id=6565154242 ,rows=2 },{id=6565154265 ,rows=2 },{id=6565154246 ,rows=2 },{id= 6565154241,rows=2 },{id=6565154244 ,rows=2 },{id=6565157680 ,rows=2 },{id=6565157681 ,rows=2 },},nFrames=91 ,fWidth=65 ,fHeight=107 ,framesPerRow=3 },                
				['Calyrex-icerider']={sheets={{id=7023477434,rows=4},{id=7023477333,rows=4},{id=7023477244,rows=4},{id=7023477169,rows=4},},nFrames=80,fWidth=77,fHeight=119,framesPerRow=5},
				['Calyrex-shadowrider']={sheets={{id=7023484420,rows=4},{id=7023484341,rows=4},{id=7023484247,rows=4},{id=7023484175,rows=4},},nFrames=80,fWidth=86,fHeight=111,framesPerRow=5},


				['Stantler-santa']={sheets={{id=563243284,rows=2}},nFrames=40,fWidth=49,fHeight=92,framesPerRow=20},

				['Sceptile-christmas']={sheets={{id=1259265913,startPixelY=792.5,rows=2},{id=1259269713,rows=10},{id=1259269855,rows=3},},nFrames=150,fWidth=100,fHeight=93,framesPerRow=10},
				['Sceptile-megac']={sheets={{id=1259265408,rows=10},{id=1259265537,rows=9},},nFrames=150,fWidth=120,fHeight=97,framesPerRow=8},
				['Sceptile-whitechristmas']={sheets={{id=8193294931,rows=5},},nFrames=48,fWidth=99,fHeight=92,framesPerRow=10},
				['Sceptile-megaw']={sheets={{id=8194117545,rows=10},},nFrames=49,fWidth=73,fHeight=96,framesPerRow=5},

				['Rattata-Alola']={sheets={{id=6686405101,rows=3},{id=6686405034,rows=3},{id=6686404959,rows=3},},nFrames=25,fWidth=50,fHeight=53,framesPerRow=3},
				['Raticate-Alola']={sheets={{id=6686411959,rows=4},{id=6686411897,rows=4},{id=6686411801,rows=4},{id=6686411728,rows=4},},nFrames=48,fWidth=71,fHeight=60,framesPerRow=3},
				['Raichu-Alola']={sheets={{id=5795791018,rows=5},{id=5795790558,rows=5},},nFrames=79,fWidth=91,fHeight=92,framesPerRow=8},
				['Sandshrew-Alola']={sheets={{id=563246972,startPixelY=278,rows=2},},nFrames=40,fWidth=39,fHeight=46,framesPerRow=25},
				['Sandslash-Alola']={sheets={{id=576577317,rows=2},},nFrames=25,fWidth=74,fHeight=84,framesPerRow=13},--{sheets={{id=563248093,startPixelY=692,rows=2},},nFrames=26,fWidth=74,fHeight=84,framesPerRow=13},
				['Vulpix-Alola']={sheets={{id=563244612,startPixelY=378,rows=2},},nFrames=40,fWidth=44,fHeight=47,framesPerRow=22},
				['Ninetales-Alola']={sheets={{id=563246293,startPixelY=568,rows=6},},nFrames=60,fWidth=89,fHeight=70,framesPerRow=11},
				['Diglett-Alola']={sheets={{id=6686379290,rows=5},{id=6686379200,rows=5},},nFrames=38,fWidth=44,fHeight=44,framesPerRow=4},
				['Dugtrio-Alola']={sheets={{id=6686389157,rows=2},{id=6686389073,rows=2},{id=6686389007,rows=2},{id=6686388936,rows=2},{id=6686388865,rows=2},{id=6686388782,rows=2},{id=6686388704,rows=2},{id=6686388631,rows=2},{id=6686388554,rows=2},{id=6686388499,rows=2},},nFrames=59,fWidth=76,fHeight=50,framesPerRow=3},
				['Meowth-Alola']={sheets={{id=6689731112,rows=2},{id=6689731018,rows=2},{id=6689730923,rows=2},{id=6689730818,rows=2},{id=6689730741,rows=2},{id=6689730657,rows=2},{id=6689730562,rows=2},},nFrames=42,fWidth=60,fHeight=61,framesPerRow=3},
				['Persian-Alola']={sheets={{id=6689744841,rows=3},{id=6689744759,rows=3},{id=6689744645,rows=3},{id=6689744576,rows=3},{id=6689744480,rows=3},},nFrames=44,fWidth=71,fHeight=73,framesPerRow=3},
				['Geodude-Alola']={sheets={{id=6689785395,rows=2},{id=6689785328,rows=2},{id=6689785258,rows=2},{id=6689785177,rows=2},{id=6689785097,rows=2},{id=6689785033,rows=2},{id=6689784958,rows=2},{id=6689784851,rows=2},},nFrames=46,fWidth=61,fHeight=44,framesPerRow=3},
				['Graveler-Alola']={sheets={{id=6689800510,rows=10},},nFrames=49,fWidth=105,fHeight=60,framesPerRow=5},
				['Golem-Alola']={sheets={{id=6689853440,rows=2},{id=6689853348,rows=2},{id=6689853246,rows=2},{id=6689853162,rows=2},{id=6689853076,rows=2},{id=6689852989,rows=2},{id=6689852869,rows=2},{id=6689852762,rows=2},{id=6689852683,rows=2},{id=6689852548,rows=2},},nFrames=59,fWidth=76,fHeight=88,framesPerRow=3},
				['Grimer-Alola']={sheets={{id=6686338011,rows=5},{id=6686337959,rows=5},{id=6686337887,rows=5},{id=6686337820,rows=5},},nFrames=79,fWidth=66,fHeight=53,framesPerRow=4},
				['Muk-Alola']={sheets={{id=6686359247,rows=5},{id=6686359164,rows=5},{id=6686359090,rows=5},{id=6686358992,rows=5},},nFrames=79,fWidth=149,fHeight=87,framesPerRow=4},
				['Exeggutor-Alola']={sheets={{id=5796017986,rows=5},{id=5796017517,rows=5},},nFrames=47,fWidth=110,fHeight=179,framesPerRow=5},
				['Marowak-Alola']={sheets={{id=5796071511,rows=4},{id=5796070980,rows=4},},nFrames=39,fWidth=105,fHeight=89,framesPerRow=5},
				['Greninja-ash']={sheets={{id=577920532,rows=10}},nFrames=119,fWidth=82,fHeight=90,framesPerRow=12},
				['Pikachu-heart']={sheets={{id=648950335,startPixelY=496,rows=3},},nFrames=33,fWidth=60,fHeight=61,framesPerRow=16},

				['Meowth-Galar']={sheets={{id=7053325397,rows=3},{id=7053325327,rows=3},{id=7053325250,rows=3},},nFrames=35,fWidth=56,fHeight=70,framesPerRow=4},
				['Ponyta-Galar']={sheets={{id=7053329743,rows=4},{id=7053329677,rows=4},},nFrames=40,fWidth=61,fHeight=72,framesPerRow=5},
				['Rapidash-Galar']={sheets={{id=7053334151,rows=4},{id=7053334117,rows=4},{id=7053334069,rows=4},{id=7053334021,rows=4},},nFrames=80,fWidth=65,fHeight=99,framesPerRow=5},
				['Slowpoke-Galar']={sheets={{id=9102571271,rows=5}},nFrames=60,fWidth=75,fHeight=49,framesPerRow=12},
				['Slowbro-Galar']={sheets={{id=7053355038,rows=5},{id=7053354961,rows=5},},nFrames=69,fWidth=56,fHeight=76,framesPerRow=7},
				['Slowking-Galar']={sheets={{id=7053359024,rows=5},{id=7053358965,rows=5},},nFrames=80,fWidth=62,fHeight=86,framesPerRow=8},
				['Farfetch\'d-Galar']={sheets={{id=7053445029,rows=6},{id=7053444937,rows=6},},nFrames=60,fWidth=98,fHeight=59,framesPerRow=5},
				['Weezing-Galar']={sheets={{id=10193333341,rows=6},{id=10193334189,rows=6},{id=10193339391,rows=6},{id=10452757753,rows=3},{id=10201777754,rows=2}},nFrames=160,fWidth=137,fHeight=147,framesPerRow=7},
				['Mr.Mime-Galar']={sheets={{id=7053543321,rows=6},},nFrames=26,fWidth=92,fHeight=89,framesPerRow=5},
				['Articuno-Galar']={sheets={{id=7053549958,rows=5},{id=7053549909,rows=5},{id=7053549854,rows=5},},nFrames=89,fWidth=105,fHeight=144,framesPerRow=6},
				['Zapdos-Galar']={sheets={{id=7053555803,rows=5},{id=7053555752,rows=5},{id=7053555686,rows=5},},nFrames=75,fWidth=76,fHeight=101,framesPerRow=5},
				['Moltres-Galar']={sheets={{id=7053561677,rows=4},{id=7053561620,rows=4},{id=7053561569,rows=4},{id=7053561514,rows=4},{id=7053561447,rows=4},{id=7053561380,rows=4},{id=7053561317,rows=4},},nFrames=84,fWidth=156,fHeight=146,framesPerRow=3},
				['Corsola-Galar']={sheets={{id=7053568356,rows=4},{id=7053568305,rows=4},{id=7053568243,rows=4},},nFrames=60,fWidth=70,fHeight=75,framesPerRow=5},
				['Zigzagoon-Galar']={sheets={{id=7053571001,rows=4},},nFrames=20,fWidth=64,fHeight=60,framesPerRow=5},
				['Linoone-Galar']={sheets={{id=7053575390,rows=4},{id=7053575319,rows=4},},nFrames=30,fWidth=99,fHeight=57,framesPerRow=4},
				['Darumaka-Galar']={sheets={{id=7053578730,rows=8},},nFrames=50,fWidth=65,fHeight=57,framesPerRow=7},
				['Darmanitan-Galar']={sheets={{id=7053583694,rows=6},{id=7053583588,rows=6},},nFrames=70,fWidth=105,fHeight=107,framesPerRow=6},
				['Yamask-Galar']={sheets={{id=7053589223,rows=5},{id=7053589161,rows=5},{id=7053589110,rows=5},{id=7053589045,rows=5},},nFrames=135,fWidth=61,fHeight=81,framesPerRow=7},
				['Stunfisk-Galar']={sheets={{id=7053594597,rows=6},{id=7053594547,rows=6},},nFrames=60,fWidth=101,fHeight=62,framesPerRow=5},
				['Darmanitan-zengalar']={sheets={{id=7056576940,rows=4},{id=7056576823,rows=4},},nFrames=40,fWidth=105,fHeight=161,framesPerRow=5},


				['Arceus-Bug']={sheets={{id=7264515223,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Dark']={sheets={{id=7264529133,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Dragon']={sheets={{id=7264547158,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Electric']={sheets={{id=7264552288,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Fairy']={sheets={{id=7264556795,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Fighting']={sheets={{id=7264560838,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Fire']={sheets={{id=7264564598,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Flying']={sheets={{id=7264568522,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Ghost']={sheets={{id=7264572360,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Grass']={sheets={{id=7264576002,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Ground']={sheets={{id=7264580792,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Ice']={sheets={{id=7264585689,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Poison']={sheets={{id=7264590561,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Psychic']={sheets={{id=7264596362,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Rock']={sheets={{id=7264606521,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Steel']={sheets={{id=7264611098,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},
				['Arceus-Water']={sheets={{id=7264620549,rows=8},},nFrames=89,fWidth=81,fHeight=113,framesPerRow=12},


				['Shaymin-sky']={sheets={{id=602910820,startPixelY=722,rows=4},},nFrames=39,fWidth=78,fHeight=73,framesPerRow=12},
				['Deoxys-Attack']={sheets={{id=7065433091,rows=4},{id=7065433013,rows=4},{id=7065432914,rows=4},},nFrames=59,fWidth=91,fHeight=97,framesPerRow=5},
				['Deoxys-Defense']={sheets={{id=7065441866,rows=4},{id=7065441791,rows=4},{id=7065441697,rows=4},},nFrames=59,fWidth=78,fHeight=94,framesPerRow=5},
				['Deoxys-Speed']={sheets={{id=7065447849,rows=5},{id=7065447755,rows=5},},nFrames=47,fWidth=88,fHeight=95,framesPerRow=5},

				['Silvally-bug']={sheets={{id=6462489696,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-dark']={sheets={{id=6462500900,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-dragon']={sheets={{id=6462586065,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-electric']={sheets={{id=6462633870,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-fairy']={sheets={{id=6462638689,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-fighting']={sheets={{id=6462641594,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-fire']={sheets={{id=6460057208,rows=6},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=8},
				['Silvally-flying']={sheets={{id=6462659689,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-ghost']={sheets={{id=6460062545,rows=6},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=8},
				['Silvally-grass']={sheets={{id=6462664540,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-ground']={sheets={{id=6462672816,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-ice']={sheets={{id=6462676825,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-poison']={sheets={{id=6460066289,rows=6},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=8},
				['Silvally-psychic']={sheets={{id=6462681015,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-rock']={sheets={{id=6462684754,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-steel']={sheets={{id=6462689662,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},
				['Silvally-water']={sheets={{id=6462695106,rows=7},},nFrames=47,fWidth=56,fHeight=116,framesPerRow=7},

				['Bidoof-rainbow']={sheets={{id=455526201,rows=3},},nFrames=44,fWidth=52,fHeight=46,framesPerRow=19},
				['Palkia-dark']={sheets={{id=441401296,rows=9},},nFrames=79,fWidth=107,fHeight=107,framesPerRow=9},
				['Umbreon-red']={sheets={{id=443622923,rows=3},},nFrames=45,fWidth=48,fHeight=77,framesPerRow=20},
				['Victini-blue']={sheets={{id=443659559,rows=3},},nFrames=39,fWidth=53,fHeight=73,framesPerRow=18},
				['Ho-Oh-darkice']={sheets={{id=443656651,rows=7},{id=443656736,rows=3},},nFrames=60,fWidth=157,fHeight=144,framesPerRow=6,inAir=.8},
				['Volcanion-black']={sheets={{id=466427326,rows=8},},nFrames=78,fWidth=96,fHeight=91,framesPerRow=10},
				['Electivire-draco']={sheets={{id=506297545,rows=6}},nFrames=59,fWidth=99,fHeight=85,framesPerRow=10},
				['Haunter-hallow']={inAir=.7},--stub, for battle engine (hallow formes are always shiny)
				['Gengar-hallow']={},
				['Mew-rainbow']={sheets={{id=599639713,rows=2}},nFrames=50,fWidth=40,fHeight=51,framesPerRow=25,inAir=1.5},
				['Regigigas-dark']={sheets={{id=664684537,startPixelY=194,rows=8},{id=664685025,rows=6},},nFrames=79,fWidth=166,fHeight=96,framesPerRow=6},
				['Dialga-dark']={sheets={{id=664700157,startPixelY=119,rows=7},{id=664700603,rows=5},},nFrames=119,fWidth=100,fHeight=122,framesPerRow=10},
				['Entei-dark']={sheets={{id=664688113,startPixelY=89,rows=7},},nFrames=80,fWidth=79,fHeight=87,framesPerRow=12},
				['Landorus-dark']={sheets={{id=664689258,rows=7},},nFrames=79,fWidth=84,fHeight=93,framesPerRow=12},
				['Mewtwo-dark']={sheets={{id=664697477,rows=9},},nFrames=90,fWidth=100,fHeight=88,framesPerRow=10},
				['Groudon-dark']={sheets={{id=664695239,rows=7},},nFrames=59,fWidth=107,fHeight=94,framesPerRow=9},
				['Onix-crystal']={sheets={{id=664943466,rows=6},},nFrames=61,fWidth=90,fHeight=115,framesPerRow=11},
				['Steelix-crystal']={sheets={{id=664945183,rows=8},},nFrames=80,fWidth=92,fHeight=105,framesPerRow=11},

				['Pikachu_F']={sheets={{id=523326540,startPixelY=496,rows=3},},nFrames=33,fWidth=60,fHeight=61,framesPerRow=16},
				['Hippowdon_F']={sheets={{id=523338317,startPixelY=354,rows=6},},nFrames=59,fWidth=97,fHeight=58,framesPerRow=10},
				['Combee_F']={sheets={{id=423326513,startPixelY=188,rows=4},},nFrames=43,fWidth=92,fHeight=46,framesPerRow=11},

				['Exeggcute']={sheets={{id=7264630794,rows=5},},nFrames=60,fWidth=76,fHeight=28,framesPerRow=13},
				['Meowstic_F']={sheets={{id=5274590141,rows=4},},nFrames=47,fWidth=63,fHeight=72,framesPerRow=15},

				-- shadow Lugia (temp)
				--		['Lugia']={sheets={{id=319413776,rows=8},{id=319413818,rows=4},},nFrames=69,fWidth=156,fHeight=127,framesPerRow=6},

				['Heatmor']={sheets={{id=7238145510,rows=8},},nFrames=99,fWidth=76,fHeight=82,framesPerRow=13},
				['Pyroar_F']={sheets={{id=6702212222,rows=2},{id=6702212155,rows=2},{id=6702212085,rows=2},{id=6702212010,rows=2},{id=6702211905,rows=2},{id=6702211802,rows=2},{id=6702211715,rows=2},{id=6702211615,rows=2},{id=6702211548,rows=2},{id=6702211451,rows=2},},nFrames=59,fWidth=69,fHeight=96,framesPerRow=3},
				['Abra']={sheets={{id=7238112884,rows=6},},nFrames=79,fWidth=68,fHeight=52,framesPerRow=14},
				['Beedrill']={sheets={{id=5360082442,rows=10},},nFrames=120,fWidth=74,fHeight=85,framesPerRow=13,inAir=.75},

				['Eevee']={sheets={{id=9170458672,rows=1},{id=9170459714,rows=1}},nFrames=25,fWidth=63,fHeight=55,framesPerRow=13},
				['Lanturn']={sheets={{id=5274565789,rows=2},{id=5274568993,rows=4},},nFrames=60,fWidth=84,fHeight=84,framesPerRow=11},
				['Scyther']={sheets={{id=5274577926,rows=4},{id=5274582187,rows=3},},nFrames=60,fWidth=104,fHeight=103,framesPerRow=9,inAir=.25},

				["Abomasnow-mega"]={sheets={{id=173796645,rows=5},{id=173796662,rows=5},{id=173796682,rows=5},{id=173796705,rows=3},},nFrames=71,fWidth=125,fHeight=110,framesPerRow=4},
				["Absol-mega"]={sheets={{id=173796705,startPixelY=333,rows=2},{id=173796718,rows=5},{id=173796734,rows=2},},nFrames=49,fWidth=93,fHeight=97,framesPerRow=6},
				["Aerodactyl-mega"]={sheets={{id=173796734,startPixelY=196,rows=2},{id=173796740,rows=3},{id=173796750,rows=3},{id=173796770,rows=3},{id=173796787,rows=3},{id=173796800,rows=1},},nFrames=44,fWidth=173,fHeight=140,framesPerRow=3,inAir=0.5},
				["Aggron-mega"]={sheets={{id=173796800,startPixelY=141,rows=4},{id=173796817,rows=5},{id=173796831,rows=5},{id=173796853,rows=1},},nFrames=59,fWidth=138,fHeight=101,framesPerRow=4},
				["Alakazam-mega"]={sheets={{id=173796853,startPixelY=102,rows=3},{id=173796871,rows=4},{id=173796882,rows=4},{id=173796891,rows=4},{id=173796909,rows=1},},nFrames=79,fWidth=113,fHeight=115,framesPerRow=5},
				["Ampharos-mega"]={sheets={{id=173796909,startPixelY=116,rows=3},{id=173796922,rows=4},{id=173796937,rows=3},},nFrames=47,fWidth=99,fHeight=112,framesPerRow=5},
				["Banette-mega"]={sheets={{id=173796937,startPixelY=339,rows=2},{id=173796950,rows=5},{id=173796968,rows=5},{id=173796987,rows=3},},nFrames=71,fWidth=98,fHeight=99,framesPerRow=5},
				["Blastoise-mega"]={sheets={{id=173796987,startPixelY=300,rows=2},{id=173796994,rows=4},{id=173797009,rows=4},{id=173797017,rows=4},{id=173797033,rows=1},},nFrames=74,fWidth=110,fHeight=114,framesPerRow=5},
				["Blaziken-mega"]={sheets={{id=173797033,startPixelY=115,rows=4},{id=173797057,rows=5},{id=173797078,rows=5},{id=173797088,rows=5},{id=173797100,rows=5},{id=173797120,rows=1},},nFrames=100,fWidth=118,fHeight=107,framesPerRow=4},
				["Charizard-megax"]={sheets={{id=173797120,startPixelY=108,rows=4},{id=173797129,rows=5},{id=173797145,rows=5},{id=173797158,rows=5},{id=173797166,rows=3},},nFrames=64,fWidth=161,fHeight=107,framesPerRow=3,inAir=1.3},
				["Charizard-megay"]={sheets={{id=173797166,startPixelY=324,rows=1},{id=173797180,rows=3},{id=173797198,rows=3},{id=173797213,rows=3},{id=173797225,rows=3},{id=173797241,rows=3},{id=173797253,rows=3},{id=173797261,rows=3},{id=173797272,rows=3},{id=173797281,rows=3},{id=173797293,rows=3},{id=173797301,rows=3},{id=173797311,rows=3},{id=173797325,rows=3},{id=173797340,rows=3},{id=173797358,rows=3},{id=173797375,rows=2},},nFrames=95,fWidth=201,fHeight=166,framesPerRow=2,inAir=.7},
				["Garchomp-mega"]={sheets={{id=173797375,startPixelY=334,rows=2},{id=173797385,rows=5},{id=173797414,rows=5},{id=173797419,rows=3},},nFrames=59,fWidth=132,fHeight=107,framesPerRow=4},
				["Gardevoir-mega"]={sheets={{id=173797419,startPixelY=324,rows=2},{id=173797438,rows=5},{id=173797459,rows=4},},nFrames=72,fWidth=74,fHeight=98,framesPerRow=7},
				["Gengar-mega"]={sheets={{id=173797459,startPixelY=396,rows=1},{id=173797471,rows=6},{id=173797484,rows=6},{id=173797495,rows=6},{id=173797507,rows=5},},nFrames=119,fWidth=112,fHeight=92,framesPerRow=5},
				["Gyarados-mega"]={sheets={{id=173797522,rows=4},{id=173797534,rows=4},{id=173797545,rows=4},{id=173797551,rows=4},{id=173797571,rows=4},{id=173797584,rows=4},},nFrames=70,fWidth=193,fHeight=122,framesPerRow=3},
				["Heracross-mega"]={sheets={{id=173797598,rows=5},{id=173797612,rows=5},{id=173797619,rows=2},},nFrames=59,fWidth=111,fHeight=111,framesPerRow=5},
				["Houndoom-mega"]={sheets={{id=173797619,startPixelY=224,rows=2},{id=173797633,rows=4},{id=173797652,rows=1},},nFrames=41,fWidth=84,fHeight=114,framesPerRow=6},
				["Kangaskhan-mega"]={sheets={{id=173797652,startPixelY=115,rows=4},{id=173797679,rows=6},{id=173797691,rows=4},},nFrames=69,fWidth=107,fHeight=89,framesPerRow=5},
				["Latias-mega"]={sheets={{id=173797691,startPixelY=360,rows=2},{id=173797712,rows=7},{id=173797724,rows=7},{id=173797737,rows=7},{id=173797757,rows=7},{id=173797781,rows=1},},nFrames=91,fWidth=183,fHeight=77,framesPerRow=3},
				["Latios-mega"]={sheets={{id=173797781,startPixelY=78,rows=5},{id=173797791,rows=6},{id=173797809,rows=6},{id=173797821,rows=6},{id=173797839,rows=6},{id=173797851,rows=2},},nFrames=91,fWidth=187,fHeight=80,framesPerRow=3},
				["Lucario-mega"]={sheets={{id=173797851,startPixelY=162,rows=3},{id=173797864,rows=4},},nFrames=60,fWidth=58,fHeight=101,framesPerRow=9},
				["Manectric-mega"]={sheets={{id=173797864,startPixelY=408,rows=1},{id=173797888,rows=5},{id=173797901,rows=4},},nFrames=59,fWidth=87,fHeight=110,framesPerRow=6},
				["Magearna-Original"]={sheets={{id=7020506998,rows=3},{id=7020506938,rows=3},{id=7020506877,rows=3},},nFrames=44,fWidth=50,fHeight=69,framesPerRow=5},
				["Mawile-mega"]={sheets={{id=173797901,startPixelY=444,rows=1},{id=173797911,rows=7},{id=173797922,rows=7},{id=173797935,rows=5},},nFrames=119,fWidth=93,fHeight=79,framesPerRow=6},
				["Medicham-mega"]={sheets={{id=10168569208,rows=7}},nFrames=43,fWidth=133,fHeight=104,framesPerRow=7},
				["Mewtwo-megax"]={sheets={{id=173797963,rows=5},{id=173797975,rows=3},},nFrames=59,fWidth=69,fHeight=97,framesPerRow=8},
				["Mewtwo-megay"]={sheets={{id=173797975,startPixelY=294,rows=2},{id=173797996,rows=6},{id=173798012,rows=2},},nFrames=89,fWidth=62,fHeight=92,framesPerRow=9},
				["Pinsir-mega"]={sheets={{id=173798012,startPixelY=186,rows=3},{id=173798031,rows=5},{id=173798046,rows=2},},nFrames=39,fWidth=133,fHeight=110,framesPerRow=4},
				["Scizor-mega"]={sheets={{id=173798046,startPixelY=222,rows=3},{id=173798063,rows=5},{id=173798079,rows=1},},nFrames=60,fWidth=79,fHeight=103,framesPerRow=7},
				["Tornadus-Therian"]={sheets={{id=7018804370,rows=5},{id=7018804271,rows=5},},nFrames=39,fWidth=153,fHeight=136,framesPerRow=4},
				["Thundurus-Therian"]={sheets={{id=7018811459,rows=4},{id=7018811361,rows=4},{id=7018811249,rows=4},{id=7018811249,rows=4},{id=7018811100,rows=4},},nFrames=59,fWidth=130,fHeight=109,framesPerRow=3},
				["Landorus-Therian"]={sheets={{id=7018976328,rows=4},{id=7018976244,rows=4},{id=7018976142,rows=4},},nFrames=59,fWidth=74,fHeight=95,framesPerRow=5},
				["Tyranitar-mega"]={sheets={{id=173798079,startPixelY=104,rows=3},{id=173798088,rows=4},{id=173798096,rows=4},{id=173798108,rows=1},},nFrames=59,fWidth=104,fHeight=119,framesPerRow=5},
				["Venusaur-mega"]={sheets={{id=173798108,startPixelY=120,rows=4},{id=173798122,rows=6},{id=173798129,rows=6},{id=173798142,rows=2},},nFrames=71,fWidth=136,fHeight=91,framesPerRow=4},

				["Altaria-mega"]={sheets={{id=191835128,rows=3},{id=191835177,rows=3},{id=191835272,rows=3},{id=191835321,rows=3},{id=191835398,rows=3},{id=191835449,rows=3},{id=191835495,rows=3},{id=191835529,rows=3},{id=191835559,rows=3},{id=191835586,rows=3},},nFrames=119,fWidth=124,fHeight=142,framesPerRow=4},
				["Audino-mega"]={sheets={{id=191835586,startPixelY=429,rows=1},{id=191835611,rows=5},{id=191835637,rows=3},},nFrames=71,fWidth=65,fHeight=96,framesPerRow=8},
				["Beedrill-mega"]={sheets={{id=191835637,startPixelY=291,rows=3},{id=191835648,rows=4},},nFrames=40,fWidth=86,fHeight=81,framesPerRow=6,inAir=.5},
				["Camerupt-mega"]={sheets={{id=191835648,startPixelY=328,rows=2},{id=191835663,rows=6},{id=191835682,rows=6},{id=191835707,rows=3},},nFrames=81,fWidth=102,fHeight=88,framesPerRow=5},
				["Diancie-mega"]={sheets={{id=191835707,startPixelY=267,rows=2},{id=191835731,rows=4},{id=191835773,rows=4},{id=191835818,rows=4},{id=191835836,rows=4},{id=191835876,rows=2},},nFrames=79,fWidth=117,fHeight=114,framesPerRow=4,inAir=.1},
				["Gallade-mega"]={sheets={{id=191835876,startPixelY=230,rows=3},{id=191835904,rows=4},},nFrames=59,fWidth=64,fHeight=99,framesPerRow=9},
				["Glalie-mega"]={sheets={{id=191835904,startPixelY=400,rows=1},{id=191835930,rows=6},{id=191835948,rows=2},},nFrames=74,fWidth=62,fHeight=87,framesPerRow=9},
				["Genesect-Douse"]={sheets={{id=7019209921,rows=6},},nFrames=49,fWidth=71,fHeight=93,framesPerRow=9},
				["Genesect-Shock"]={sheets={{id=7019204895,rows=6},},nFrames=49,fWidth=71,fHeight=93,framesPerRow=9},
				["Genesect-Burn"]={sheets={{id=7019208138,rows=6},},nFrames=49,fWidth=71,fHeight=93,framesPerRow=9},
				["Genesect-Chill"]={sheets={{id=7019202653,rows=6},},nFrames=49,fWidth=71,fHeight=93,framesPerRow=9},
				["Giratina-Origin"]={sheets={{id=7018795188,rows=3},{id=7018795109,rows=3},{id=7018795023,rows=3},{id=7018794936,rows=3},{id=7018794857,rows=3},{id=7018794772,rows=3},},nFrames=69,fWidth=157,fHeight=155,framesPerRow=4},                
				["Groudon-Primal"]={sheets={{id=191835948,startPixelY=176,rows=3},{id=191835998,rows=5},{id=191836026,rows=5},{id=191836061,rows=5},{id=191836102,rows=1},},nFrames=73,fWidth=117,fHeight=99,framesPerRow=4},
				["Hoopa-Unbound"]={sheets={{id=191836102,startPixelY=100,rows=3},{id=191836129,rows=4},{id=191836172,rows=4},{id=191836194,rows=4},{id=191836210,rows=4},},nFrames=74,fWidth=131,fHeight=126,framesPerRow=4},
				["Kyogre-Primal"]={sheets={{id=191836264,rows=8},{id=191836292,rows=8},{id=191836345,rows=8},{id=191836374,rows=8},{id=191836408,rows=3},},nFrames=69,fWidth=230,fHeight=64,framesPerRow=2},
				["Kyurem-White"]={sheets={{id=7018993137,rows=3},{id=7018990064,rows=3},{id=7018989977,rows=3},{id=7018989892,rows=3},{id=7018989810,rows=3},{id=7018989722,rows=3},{id=7018989636,rows=3},{id=7018989551,rows=3},{id=7018989390,rows=3},{id=7018989277,rows=3},},nFrames=89,fWidth=137,fHeight=132,framesPerRow=3},
				["Kyurem-Whiteoverdrive"]={sheets={{id=7019073675,rows=3},{id=7019074830,rows=3},{id=7019073276,rows=3},{id=7019070310,rows=3},{id=7019070215,rows=3},{id=7019070128,rows=3},{id=7019070071,rows=3},{id=7019070008,rows=3},{id=7019069940,rows=3},{id=7019069860,rows=3},},nFrames=89,fWidth=142,fHeight=134,framesPerRow=3},
				["Kyurem-Black"]={sheets={{id=7019101985,rows=3},{id=7019101917,rows=3},{id=7019101758,rows=3},{id=7019099023,rows=3},{id=7019098963,rows=3},{id=7019098893,rows=3},{id=7019098809,rows=3},{id=7019098742,rows=3},{id=7019098669,rows=3},{id=7019098550,rows=3},},nFrames=89,fWidth=116,fHeight=129,framesPerRow=3},
				["Kyurem-Blackoverdrive"]={sheets={{id=7019089929,rows=3},{id=7019089841,rows=3},{id=7019089773,rows=3},{id=7019089705,rows=3},{id=7019089639,rows=3},{id=7019089550,rows=3},{id=7019089485,rows=3},{id=7019089402,rows=3},{id=7019089323,rows=3},},nFrames=80,fWidth=125,fHeight=133,framesPerRow=3},
				["Lopunny-mega"]={sheets={{id=191836408,startPixelY=195,rows=4},},nFrames=29,fWidth=67,fHeight=88,framesPerRow=8},
				["Meloetta-Pirouette"]={sheets={{id=7019195810,rows=5},},nFrames=39,fWidth=60,fHeight=90,framesPerRow=8},
				["Metagross-mega"]={sheets={{id=191836441,rows=4},{id=191836480,rows=4},{id=191836516,rows=4},{id=191836575,rows=4},{id=191836622,rows=4},{id=191836689,rows=4},{id=191836737,rows=3},},nFrames=79,fWidth=146,fHeight=118,framesPerRow=3,inAir=.4},
				["Mimikyu-busted"]={sheets={{id=10180467773,rows=4}},nFrames=39,fWidth=60,fHeight=36,framesPerRow=10},
				["Pidgeot-mega"]={sheets={{id=191836737,startPixelY=357,rows=3},{id=191836781,rows=9},{id=191836818,rows=8},},nFrames=60,fWidth=175,fHeight=60,framesPerRow=3,inAir=2},
				["Rayquaza-mega"]={sheets={{id=191836868,rows=3},{id=191836915,rows=3},{id=191836936,rows=3},{id=191836976,rows=3},{id=191837102,rows=3},{id=191837142,rows=3},{id=191837210,rows=1},},nFrames=75,fWidth=136,fHeight=146,framesPerRow=4},
				["Sableye-mega"]={sheets={{id=191837210,startPixelY=147,rows=5},{id=191837263,rows=4},},nFrames=59,fWidth=76,fHeight=75,framesPerRow=7},
				["Salamence-mega"]={sheets={{id=191837263,startPixelY=304,rows=3},{id=191837310,rows=7},{id=191837334,rows=7},{id=191837407,rows=7},{id=191837471,rows=6},},nFrames=59,fWidth=217,fHeight=71,framesPerRow=2,inAir=.6},
				["Sceptile-mega"]={sheets={{id=191837471,startPixelY=432,rows=1},{id=191837515,rows=5},{id=191837531,rows=1},},nFrames=49,fWidth=74,fHeight=97,framesPerRow=7},
				["Sharpedo-mega"]={sheets={{id=191837531,startPixelY=98,rows=4},{id=191837577,rows=5},{id=191837611,rows=3},},nFrames=69,fWidth=86,fHeight=96,framesPerRow=6},
				["Slowbro-mega"]={sheets={{id=191837611,startPixelY=291,rows=3},{id=191837667,rows=6},{id=191837692,rows=3},},nFrames=79,fWidth=75,fHeight=87,framesPerRow=7},
				["Steelix-mega"]={sheets={{id=191837692,startPixelY=264,rows=2},{id=191837708,rows=4},{id=191837729,rows=4},{id=191837751,rows=4},{id=191837776,rows=4},{id=191837874,rows=2},},nFrames=80,fWidth=121,fHeight=122,framesPerRow=4},
				['Steelix-crystalmega']={sheets={{id=9596735457,rows=5},{id=9596735618,rows=5}},nFrames=80,fWidth=120,fHeight=121,framesPerRow=8},
				["Swampert-mega"]={sheets={{id=191837874,startPixelY=246,rows=3},{id=191837914,rows=6},{id=191837928,rows=6},{id=191837961,rows=5},},nFrames=79,fWidth=122,fHeight=80,framesPerRow=4},

				["Zygarde-10"]={sheets={{id=7019517873,rows=4},{id=7019517776,rows=4},},nFrames=39,fWidth=60,fHeight=74,framesPerRow=5},
				["Zygarde-Complete"]={sheets={{id=7019523914,rows=5},{id=7019523845,rows=5},{id=7019523764,rows=5},{id=7019523690,rows=5},{id=7019523638,rows=5},},nFrames=75,fWidth=159,fHeight=111,framesPerRow=3},

				["Zeraora-Stand"]={sheets={{id=7020515455,rows=3},{id=7020515383,rows=3},{id=7020515314,rows=3},{id=7020515242,rows=3},},nFrames=46,fWidth=106,fHeight=116,framesPerRow=4},

				['Vivillon-archipelago']={sheets={{id=7019260090,rows=4},{id=7019260020,rows=4},{id=7019259907,rows=4},{id=7019259816,rows=4},{id=7019259676,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-continental']={sheets={{id=7019270143,rows=4},{id=7019270062,rows=4},{id=7019269981,rows=4},{id=7019269871,rows=4},{id=7019269805,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-elegant']={sheets={{id=7019274651,rows=4},{id=7019274569,rows=4},{id=7019274497,rows=4},{id=7019274411,rows=4},{id=7019274313,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-garden']={sheets={{id=7019288546,rows=4},{id=7019288453,rows=4},{id=7019288348,rows=4},{id=7019288257,rows=4},{id=7019288164,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-highplains']={sheets={{id=7024479199,rows=4},{id=7024479123,rows=4},{id=7024479037,rows=4},{id=7024478945,rows=4},{id=7024478857,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-icysnow']={sheets={{id=7019358805,rows=4},{id=7019358752,rows=4},{id=7019358682,rows=4},{id=7019358571,rows=4},{id=7019358495,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-jungle']={sheets={{id=7019370236,rows=4},{id=7019370176,rows=4},{id=7019370110,rows=4},{id=7019370036,rows=4},{id=7019369970,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-marine']={sheets={{id=7019376217,rows=4},{id=7019376066,rows=4},{id=7019375966,rows=4},{id=7019375847,rows=4},{id=7019375726,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-modern']={sheets={{id=7019387407,rows=4},{id=7019387332,rows=4},{id=7019387261,rows=4},{id=7019387181,rows=4},{id=7019387118,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-monsoon']={sheets={{id=7019392017,rows=4},{id=7019391942,rows=4},{id=7019391856,rows=4},{id=7019391788,rows=4},{id=7019391722,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-ocean']={sheets={{id=7019396902,rows=4},{id=7019396807,rows=4},{id=7019396666,rows=4},{id=7019396578,rows=4},{id=7019396509,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-polar']={sheets={{id=7019413111,rows=4},{id=7019413050,rows=4},{id=7019412989,rows=4},{id=7019412900,rows=4},{id=7019412820,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-river']={sheets={{id=7019401690,rows=4},{id=7019401605,rows=4},{id=7019401506,rows=4},{id=7019401415,rows=4},{id=7019401320,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-sandstorm']={sheets={{id=7019420999,rows=4},{id=7019420932,rows=4},{id=7019420870,rows=4},{id=7019420806,rows=4},{id=7019420724,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-savannah']={sheets={{id=7019430111,rows=4},{id=7019430022,rows=4},{id=7019429933,rows=4},{id=7019429806,rows=4},{id=7019429715,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-sun']={sheets={{id=7019435893,rows=4},{id=7019435826,rows=4},{id=7019435744,rows=4},{id=7019435666,rows=4},{id=7019435591,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},
				['Vivillon-tundra']={sheets={{id=7019442090,rows=4},{id=7019442010,rows=4},{id=7019441923,rows=4},{id=7019441844,rows=4},{id=7019441761,rows=4},},nFrames=79,fWidth=105,fHeight=105,framesPerRow=4},

				['Aegislash-blade']={sheets={{id=6303679096,rows=5},},nFrames=59,fWidth=81,fHeight=103,framesPerRow=12},
				['Darmanitan-zen']={sheets={{id=610979350,startPixelY=177,rows=1}},nFrames=1,fWidth=62,fHeight=58,framesPerRow=1},

				['Flabebe-blue']={sheets={{id=5787887713,rows=4},{id=5787887344,rows=4},{id=5787887020,rows=4},{id=5787886699,rows=4},},nFrames=79,fWidth=75,fHeight=77,framesPerRow=5,inAir=.5},
				['Flabebe-orange']={sheets={{id=5787931410,rows=4},{id=5787930974,rows=4},{id=5787930604,rows=4},{id=5787930037,rows=4},},nFrames=79,fWidth=75,fHeight=77,framesPerRow=5,inAir=.5},
				['Flabebe-white']={sheets={{id=5788076769,rows=4},{id=5788076355,rows=4},{id=5788076025,rows=4},{id=5788075589,rows=4},},nFrames=79,fWidth=75,fHeight=77,framesPerRow=5,inAir=.5},
				['Flabebe-yellow']={sheets={{id=5788093553,rows=4},{id=5788093266,rows=4},{id=5788092912,rows=4},{id=5788092533,rows=4},},nFrames=79,fWidth=75,fHeight=77,framesPerRow=5,inAir=.5},
				['Floette-blue']={sheets={{id=5790787417,rows=5},{id=5790786874,rows=5},},nFrames=47,fWidth=60,fHeight=94,framesPerRow=5,inAir=.5},
				['Floette-eternal']={sheets={{id=5790806693,rows=5},{id=5790807577,rows=5},},nFrames=47,fWidth=80,fHeight=89,framesPerRow=5,inAir=.5},
				['Floette-orange']={sheets={{id=5790822264,rows=5},{id=5790821514,rows=5},},nFrames=47,fWidth=60,fHeight=94,framesPerRow=5,inAir=.5},
				['Floette-white']={sheets={{id=5790833431,rows=5},{id=5790832770,rows=5},},nFrames=47,fWidth=60,fHeight=94,framesPerRow=5,inAir=.5},
				['Floette-yellow']={sheets={{id=9326285977,rows=10}},nFrames=47,fWidth=60,fHeight=94,framesPerRow=5,inAir=.5},
				['Florges-blue']={sheets={{id=5790861916,rows=5},{id=5790861340,rows=5},{id=5790860653,rows=5},},nFrames=74,fWidth=79,fHeight=99,framesPerRow=5},
				['Florges-orange']={sheets={{id=5790877852,rows=5},{id=5790877289,rows=5},{id=5790876695,rows=5},},nFrames=74,fWidth=79,fHeight=99,framesPerRow=5},
				['Florges-white']={sheets={{id=5790889189,rows=5},{id=5790888654,rows=5},{id=5790888107,rows=5},},nFrames=74,fWidth=79,fHeight=99,framesPerRow=5},
				['Florges-yellow']={sheets={{id=5790898219,rows=5},{id=5790897721,rows=5},{id=5790897018,rows=5},},nFrames=74,fWidth=79,fHeight=99,framesPerRow=5},

				['Minior-Red']={sheets={{id=7019562269,rows=4},{id=7019562208,rows=4},{id=7019562133,rows=4},{id=7019562073,rows=4},{id=7019562002,rows=4},{id=7019561919,rows=4},{id=7019561850,rows=4},},nFrames=139,fWidth=78,fHeight=78,framesPerRow=5},
				['Minior-Orange']={sheets={{id=7019578684,rows=4},{id=7019578684,rows=4},{id=7019575626,rows=4},{id=7019575552,rows=4},{id=7019575451,rows=4},{id=7019575368,rows=4},{id=7019575288,rows=4},},nFrames=139,fWidth=78,fHeight=78,framesPerRow=5},
				['Minior-Yellow']={sheets={{id=7019812014,rows=4},{id=7019811943,rows=4},{id=7019811868,rows=4},{id=7019811807,rows=4},{id=7019811727,rows=4},{id=7019811655,rows=4},{id=7019811582,rows=4},},nFrames=139,fWidth=78,fHeight=78,framesPerRow=5},
				['Minior-Green']={sheets={{id=7019817117,rows=4},{id=7019817028,rows=4},{id=7019816941,rows=4},{id=7019816872,rows=4},{id=7019816805,rows=4},{id=7019816737,rows=4},{id=7019816670,rows=4},},nFrames=139,fWidth=78,fHeight=78,framesPerRow=5},
				['Minior-Blue']={sheets={{id=7019821289,rows=4},{id=7019821222,rows=4},{id=7019821152,rows=4},{id=7019821072,rows=4},{id=7019821011,rows=4},{id=7019820938,rows=4},{id=7019820878,rows=4},},nFrames=139,fWidth=78,fHeight=78,framesPerRow=5},
				['Minior-Indigo']={sheets={{id=7019826924,rows=4},{id=7019826924,rows=4},{id=7019826757,rows=4},{id=7019826683,rows=4},{id=7019826618,rows=4},{id=7019826545,rows=4},{id=7019826441,rows=4},},nFrames=138,fWidth=78,fHeight=78,framesPerRow=5},
				['Minior-Violet']={sheets={{id=7019831192,rows=4},{id=7019831117,rows=4},{id=7019831042,rows=4},{id=7019830962,rows=4},{id=7019830894,rows=4},{id=7019830846,rows=4},{id=7019830778,rows=4},},nFrames=139,fWidth=78,fHeight=78,framesPerRow=5},

		--[[['Necrozma-Duskmane']={sheets={{id=7020061629,rows=5},{id=7020061564,rows=5},{id=7020061516,rows=5},{id=7020061448,rows=5},{id=7020061384,rows=5},},nFrames=99,fWidth=132,fHeight=109,framesPerRow=5},
		['Necrozma-Dawnwings']={sheets={{id=7020073712,rows=3},{id=7020072830,rows=3},{id=7020070660,rows=3},{id=7020070599,rows=3},{id=7020070548,rows=3},{id=7020070477,rows=3},{id=7020070410,rows=3},{id=7020070339,rows=3},{id=7020070285,rows=3},{id=7020070244,rows=3},{id=7020070192,rows=3},},nFrames=99,fWidth=139,fHeight=105,framesPerRow=3},
		['Necrozma-Ultra']={sheets={{id=7020276562,rows=2},{id=7020276503,rows=2},{id=7020276458,rows=2},{id=7020276727,rows=2},{id=7020274405,rows=2},{id=7020272492,rows=2},{id=7020272442,rows=2},{id=7020272372,rows=2},{id=7020272316,rows=2},{id=7020272316,rows=2},{id=7020272194,rows=2},{id=7020272147,rows=2},{id=7020272094,rows=2},{id=7020272018,rows=2},{id=7020271968,rows=2},{id=7020271910,rows=2},{id=7020269899,rows=2},{id=7020269837,rows=2},{id=7020269801,rows=2},{id=7020269769,rows=2},{id=7020269721,rows=2},{id=7020269673,rows=2},{id=7020269612,rows=2},},nFrames=92,fWidth=219,fHeight=116,framesPerRow=2},]]

				['Unown']={sheets={{id=606685611,startPixelY=128,rows=5},},nFrames=80,fWidth=58,fHeight=73,framesPerRow=17,inAir=.6},
				['Unown-b']={sheets={{id=606623397,rows=5},},nFrames=79,fWidth=63,fHeight=63,framesPerRow=16,inAir=.6},
				['Unown-c']={sheets={{id=606623397,startPixelY=320,rows=5},},nFrames=79,fWidth=56,fHeight=57,framesPerRow=17,inAir=.6},
				['Unown-d']={sheets={{id=606623397,startPixelY=610,rows=4},},nFrames=79,fWidth=46,fHeight=77,framesPerRow=21,inAir=.6},
				['Unown-e']={sheets={{id=606623397,startPixelY=922,rows=1},{id=606677146,rows=4},},nFrames=79,fWidth=61,fHeight=58,framesPerRow=16,inAir=.6},
				['Unown-f']={sheets={{id=606677146,startPixelY=476,rows=6},},nFrames=79,fWidth=66,fHeight=54,framesPerRow=15,inAir=.6},
				['Unown-g']={sheets={{id=606677146,startPixelY=806,rows=3},{id=606678152,rows=1},},nFrames=79,fWidth=37,fHeight=69,framesPerRow=26,inAir=.6},
				['Unown-h']={sheets={{id=606678152,startPixelY=70,rows=7},},nFrames=79,fWidth=82,fHeight=51,framesPerRow=12,inAir=.6},
				['Unown-i']={sheets={{id=606678152,startPixelY=434,rows=5},},nFrames=79,fWidth=54,fHeight=67,framesPerRow=18,inAir=.6},
				['Unown-j']={sheets={{id=606679862,startPixelY=57,rows=7},},nFrames=79,fWidth=73,fHeight=51,framesPerRow=13,inAir=.6},
				['Unown-k']={sheets={{id=606679862,startPixelY=421,rows=4},},nFrames=59,fWidth=65,fHeight=72,framesPerRow=15,inAir=.6},
				['Unown-l']={sheets={{id=606679862,startPixelY=713,rows=5},},nFrames=79,fWidth=56,fHeight=52,framesPerRow=17,inAir=.6},
				['Unown-m']={sheets={{id=606680975,rows=4},},nFrames=79,fWidth=46,fHeight=57,framesPerRow=21,inAir=.6},
				['Unown-n']={sheets={{id=606680975,startPixelY=232,rows=7},},nFrames=79,fWidth=82,fHeight=79,framesPerRow=12,inAir=.6},
				['Unown-o']={sheets={{id=606680975,startPixelY=792,rows=4},{id=606681911,rows=2},},nFrames=79,fWidth=65,fHeight=53,framesPerRow=15,inAir=.6},
				['Unown-p']={sheets={{id=606681911,startPixelY=108,rows=5},},nFrames=79,fWidth=58,fHeight=62,framesPerRow=17,inAir=.6},
				['Unown-q']={sheets={{id=606681911,startPixelY=423,rows=5},},nFrames=79,fWidth=53,fHeight=54,framesPerRow=18,inAir=.6},
				['Unown-r']={sheets={{id=606681911,startPixelY=698,rows=5},},nFrames=79,fWidth=51,fHeight=62,framesPerRow=19,inAir=.6},
				['Unown-s']={sheets={{id=606683624,rows=7},},nFrames=79,fWidth=75,fHeight=69,framesPerRow=13,inAir=.6},
				['Unown-t']={sheets={{id=606683624,startPixelY=490,rows=3},},nFrames=79,fWidth=36,fHeight=57,framesPerRow=27,inAir=.6},
				['Unown-u']={sheets={{id=606683624,startPixelY=664,rows=5},},nFrames=79,fWidth=59,fHeight=49,framesPerRow=17,inAir=.6},
				['Unown-v']={sheets={{id=606683624,startPixelY=914,rows=2},{id=606684606,rows=2},},nFrames=79,fWidth=38,fHeight=53,framesPerRow=26,inAir=.6},
				['Unown-w']={sheets={{id=606684606,startPixelY=108,rows=6},},nFrames=71,fWidth=77,fHeight=62,framesPerRow=13,inAir=.6},
				['Unown-x']={sheets={{id=606684606,startPixelY=486,rows=5},},nFrames=79,fWidth=51,fHeight=55,framesPerRow=19,inAir=.6},
				['Unown-y']={sheets={{id=606684606,startPixelY=766,rows=3},},nFrames=79,fWidth=32,fHeight=50,framesPerRow=31,inAir=.6},
				['Unown-z']={sheets={{id=606684606,startPixelY=919,rows=1},{id=606685611,rows=2},},nFrames=79,fWidth=35,fHeight=63,framesPerRow=28,inAir=.6},
				['Unown-exclaim']={sheets={{id=606677146,startPixelY=236,rows=3},},nFrames=59,fWidth=35,fHeight=79,framesPerRow=28,inAir=.6},
				['Unown-query']={sheets={{id=606678152,startPixelY=774,rows=4},{id=606679862,rows=1},},nFrames=79,fWidth=55,fHeight=56,framesPerRow=18,inAir=.6},

				['Rotom-fan']={sheets={{id=631176258,startPixelY=444,rows=7},},nFrames=59,fWidth=112,fHeight=74,framesPerRow=9},
				['Rotom-frost']={sheets={{id=631178768,startPixelY=462,rows=8},},nFrames=59,fWidth=117,fHeight=65,framesPerRow=8},
				['Rotom-heat']={sheets={{id=631180663,startPixelY=63,rows=7},},nFrames=59,fWidth=107,fHeight=62,framesPerRow=9},
				['Rotom-mow']={sheets={{id=631181614,startPixelY=500,rows=6},},nFrames=59,fWidth=93,fHeight=59,framesPerRow=10},
				['Rotom-wash']={sheets={{id=631183501,startPixelY=130,rows=7},},nFrames=59,fWidth=110,fHeight=64,framesPerRow=9},

				["Abomasnow"]={sheets={{id=174837556,rows=6},{id=174837583,rows=6},{id=174837598,rows=3},},nFrames=59,fWidth=128,fHeight=87,framesPerRow=4},
				["Absol"]={sheets={{id=174837605,startPixelY=270,rows=3},{id=174837620,rows=4},},nFrames=59,fWidth=59,fHeight=92,framesPerRow=9},
				["Accelgor"]={sheets={{id=174837620,startPixelY=372,rows=2},{id=174837625,rows=6},{id=174837637,rows=2},},nFrames=59,fWidth=92,fHeight=82,framesPerRow=6},
				["Aegislash"]={sheets={{id=174837637,startPixelY=166,rows=4},{id=174837651,rows=5},},nFrames=59,fWidth=75,fHeight=97,framesPerRow=7},
				["Aerodactyl"]={sheets={{id=174837663,rows=3},{id=174837686,rows=3},{id=174837696,rows=3},{id=174837708,rows=3},{id=174837717,rows=1},},nFrames=39,fWidth=189,fHeight=145,framesPerRow=3,inAir=0.1},
				["Aggron"]={sheets={{id=174837717,startPixelY=146,rows=4},{id=174837731,rows=5},{id=174837739,rows=3},},nFrames=59,fWidth=106,fHeight=97,framesPerRow=5},
				["Aipom"]={sheets={{id=174837739,startPixelY=294,rows=4},},nFrames=29,fWidth=63,fHeight=61,framesPerRow=9},
				["Alakazam"]={sheets={{id=174837753,rows=7},{id=174837766,rows=4},},nFrames=74,fWidth=77,fHeight=79,framesPerRow=7},
				["Alomomola"]={sheets={{id=174837766,startPixelY=320,rows=2},{id=174837780,rows=3},},nFrames=59,fWidth=44,fHeight=100,framesPerRow=13},
				["Altaria"]={sheets={{id=174837780,startPixelY=303,rows=2},{id=174837792,rows=6},{id=174837804,rows=6},{id=174837820,rows=1},},nFrames=59,fWidth=144,fHeight=89,framesPerRow=4,inAir=.9},
				["Amaura"]={sheets={{id=174837820,startPixelY=90,rows=5},{id=174837834,rows=3},},nFrames=87,fWidth=52,fHeight=90,framesPerRow=11},
				["Ambipom"]={sheets={{id=174837834,startPixelY=273,rows=3},{id=174837845,rows=6},{id=174837869,rows=1},},nFrames=49,fWidth=104,fHeight=88,framesPerRow=5},
				["Amoonguss"]={sheets={{id=174837869,startPixelY=89,rows=6},{id=174837891,rows=5},},nFrames=74,fWidth=78,fHeight=75,framesPerRow=7},
				["Ampharos"]={sheets={{id=174837891,startPixelY=380,rows=1},{id=174837908,rows=5},},nFrames=48,fWidth=69,fHeight=101,framesPerRow=8},
				["Anorith"]={sheets={{id=174837908,startPixelY=510,rows=1},{id=174837926,rows=6},},nFrames=59,fWidth=64,fHeight=37,framesPerRow=9},
				["Arbok"]={sheets={{id=174837926,startPixelY=228,rows=3},{id=174837938,rows=6},{id=174837950,rows=5},},nFrames=80,fWidth=87,fHeight=83,framesPerRow=6},
				["Arcanine"]={sheets={{id=174837950,startPixelY=420,rows=1},{id=174837965,rows=6},{id=174837981,rows=1},},nFrames=52,fWidth=74,fHeight=82,framesPerRow=7},
				["Arceus"]={sheets={{id=174837981,startPixelY=83,rows=4},{id=174837995,rows=4},{id=174838005,rows=4},{id=174838016,rows=1},},nFrames=89,fWidth=82,fHeight=114,framesPerRow=7},
				["Archen"]={sheets={{id=174838016,startPixelY=115,rows=8},{id=174838033,rows=4},},nFrames=59,fWidth=104,fHeight=52,framesPerRow=5},
				["Archeops"]={sheets={{id=174838033,startPixelY=212,rows=2},{id=174838046,rows=4},{id=174838065,rows=4},},nFrames=39,fWidth=144,fHeight=127,framesPerRow=4},
				["Ariados"]={sheets={{id=174838078,rows=6},},nFrames=40,fWidth=82,fHeight=61,framesPerRow=7},
				["Armaldo"]={sheets={{id=174838078,startPixelY=372,rows=2},{id=174838099,rows=6},{id=174838111,rows=1},},nFrames=59,fWidth=76,fHeight=81,framesPerRow=7},
				["Aromatisse"]={sheets={{id=174838111,startPixelY=82,rows=5},{id=174838126,rows=3},},nFrames=59,fWidth=67,fHeight=80,framesPerRow=8},
				["Aron"]={sheets={{id=174838126,startPixelY=243,rows=3},},nFrames=39,fWidth=39,fHeight=45,framesPerRow=14},
				["Articuno"]={sheets={{id=174838126,startPixelY=381,rows=1},{id=174838138,rows=3},{id=174838149,rows=3},{id=174838156,rows=3},{id=174838169,rows=3},{id=174838180,rows=1},},nFrames=40,fWidth=172,fHeight=171,framesPerRow=3},
				["Audino"]={sheets={{id=174838180,startPixelY=172,rows=5},{id=174838190,rows=2},},nFrames=60,fWidth=63,fHeight=75,framesPerRow=9},
				["Aurorus"]={sheets={{id=174838190,startPixelY=152,rows=3},{id=174838203,rows=4},{id=174838216,rows=4},{id=174838233,rows=1},},nFrames=89,fWidth=67,fHeight=123,framesPerRow=8},
				["Avalugg"]={sheets={{id=174838233,startPixelY=124,rows=7},{id=174838247,rows=9},{id=174838263,rows=4},},nFrames=79,fWidth=121,fHeight=57,framesPerRow=4},
				["Axew"]={sheets={{id=174838263,startPixelY=232,rows=4},{id=174838277,rows=1},},nFrames=55,fWidth=47,fHeight=66,framesPerRow=12},
				["Azelf"]={sheets={{id=174838277,startPixelY=67,rows=5},{id=174838300,rows=6},{id=174838319,rows=4},},nFrames=89,fWidth=83,fHeight=86,framesPerRow=6},
				["Azumarill"]={sheets={{id=174838319,startPixelY=348,rows=2},{id=174838326,rows=6},{id=174838335,rows=2},},nFrames=59,fWidth=89,fHeight=90,framesPerRow=6},
				["Azurill"]={sheets={{id=174838335,startPixelY=182,rows=2},},nFrames=34,fWidth=33,fHeight=72,framesPerRow=17},
				["Bagon"]={sheets={{id=174838335,startPixelY=328,rows=2},},nFrames=29,fWidth=35,fHeight=59,framesPerRow=16},
				["Baltoy"]={sheets={{id=174838335,startPixelY=448,rows=1},{id=174838343,rows=7},},nFrames=59,fWidth=65,fHeight=60,framesPerRow=8,inAir=.6},
				["Banette"]={sheets={{id=174838343,startPixelY=427,rows=1},{id=174838355,rows=6},},nFrames=59,fWidth=62,fHeight=67,framesPerRow=9},
				["Barbaracle"]={sheets={{id=174838355,startPixelY=408,rows=1},{id=174838361,rows=5},{id=174838377,rows=5},{id=174838391,rows=5},{id=174838397,rows=4},},nFrames=79,fWidth=118,fHeight=109,framesPerRow=4},
				["Barboach"]={sheets={{id=174838397,startPixelY=440,rows=2},{id=174838409,rows=4},},nFrames=59,fWidth=49,fHeight=42,framesPerRow=11},
				["Basculin"]={sheets={{id=174838409,startPixelY=172,rows=4},},nFrames=29,fWidth=71,fHeight=56,framesPerRow=8},
				["Basculin-Blue-Striped"]={sheets={{id=7392136902,rows=6},},nFrames=29,fWidth=70,fHeight=59,framesPerRow=6},
				["Bastiodon"]={sheets={{id=174838409,startPixelY=400,rows=1},{id=174838420,rows=6},{id=174838436,rows=3},},nFrames=59,fWidth=90,fHeight=80,framesPerRow=6},
				["Bayleef"]={sheets={{id=174838436,startPixelY=243,rows=3},{id=174838448,rows=2},},nFrames=52,fWidth=49,fHeight=84,framesPerRow=11},
				["Beartic"]={sheets={{id=174838448,startPixelY=170,rows=3},{id=174838456,rows=5},{id=174838467,rows=4},},nFrames=59,fWidth=105,fHeight=104,framesPerRow=5},
				["Beautifly"]={sheets={{id=174838467,startPixelY=420,rows=1},{id=174838474,rows=6},{id=174838488,rows=5},},nFrames=79,fWidth=81,fHeight=83,framesPerRow=7},
				["Beheeyem"]={sheets={{id=174838522,startPixelY=435,rows=1},{id=174838538,rows=3},},nFrames=42,fWidth=49,fHeight=84,framesPerRow=11,inAir=.65},
				["Beldum"]={sheets={{id=174838538,startPixelY=255,rows=5},},nFrames=58,fWidth=46,fHeight=33,framesPerRow=12,inAir=1.2},
				["Bellossom"]={sheets={{id=174838538,startPixelY=425,rows=2},{id=174838549,rows=3},},nFrames=48,fWidth=57,fHeight=55,framesPerRow=10},
				["Bellsprout"]={sheets={{id=174838549,startPixelY=168,rows=6},},nFrames=60,fWidth=55,fHeight=49,framesPerRow=10},
				["Bergmite"]={sheets={{id=174838549,startPixelY=468,rows=1},{id=174838559,rows=6},},nFrames=71,fWidth=50,fHeight=60,framesPerRow=11},
				["Bibarel"]={sheets={{id=174838559,startPixelY=366,rows=3},{id=174838582,rows=3},},nFrames=39,fWidth=81,fHeight=56,framesPerRow=7},
				["Bidoof"]={sheets={{id=174838582,startPixelY=171,rows=4},},nFrames=43,fWidth=52,fHeight=46,framesPerRow=11},
				["Binacle"]={sheets={{id=174838582,startPixelY=359,rows=2},{id=174838589,rows=5},},nFrames=44,fWidth=76,fHeight=71,framesPerRow=7},
				["Bisharp"]={sheets={{id=174838589,startPixelY=360,rows=2},{id=174838602,rows=2},},nFrames=39,fWidth=52,fHeight=99,framesPerRow=11},
				["Blastoise"]={sheets={{id=174838602,startPixelY=200,rows=4},{id=174838612,rows=6},{id=174838628,rows=4},},nFrames=79,fWidth=88,fHeight=83,framesPerRow=6},
				["Blaziken"]={sheets={{id=174838628,startPixelY=336,rows=2},{id=174838639,rows=5},{id=174838652,rows=1},},nFrames=47,fWidth=83,fHeight=96,framesPerRow=6},
				["Blissey"]={sheets={{id=174838652,startPixelY=97,rows=6},{id=174838667,rows=3},},nFrames=52,fWidth=83,fHeight=74,framesPerRow=6},
				["Blitzle"]={sheets={{id=174838667,startPixelY=225,rows=3},{id=174838678,rows=2},},nFrames=59,fWidth=42,fHeight=84,framesPerRow=13},
				["Boldore"]={sheets={{id=174838678,startPixelY=170,rows=5},{id=174838694,rows=8},},nFrames=89,fWidth=81,fHeight=67,framesPerRow=7},
				["Bonsly"]={sheets={{id=174838707,rows=3},},nFrames=39,fWidth=37,fHeight=57,framesPerRow=15},
				["Bouffalant"]={sheets={{id=174838707,startPixelY=174,rows=4},{id=174838724,rows=2},},nFrames=29,fWidth=111,fHeight=87,framesPerRow=5},
				["Braixen"]={sheets={{id=174838724,startPixelY=176,rows=4},{id=174838736,rows=2},},nFrames=41,fWidth=74,fHeight=86,framesPerRow=7},
				["Braviary"]={sheets={{id=174838736,startPixelY=174,rows=2},{id=174838747,rows=3},{id=174838755,rows=3},{id=174838764,rows=3},},nFrames=21,fWidth=207,fHeight=176,framesPerRow=2,inAir=.25},
				["Breloom"]={sheets={{id=174838781,rows=5},},nFrames=39,fWidth=66,fHeight=73,framesPerRow=8},
				["Bronzong"]={sheets={{id=174838781,startPixelY=370,rows=2},{id=174838802,rows=7},{id=174838814,rows=5},},nFrames=79,fWidth=89,fHeight=73,framesPerRow=6,inAir=.8},
				["Bronzor"]={sheets={{id=174838814,startPixelY=370,rows=3},{id=174838826,rows=2},},nFrames=59,fWidth=40,fHeight=55,framesPerRow=14,inAir=1},
				["Budew"]={sheets={{id=174838826,startPixelY=112,rows=5},},nFrames=60,fWidth=42,fHeight=49,framesPerRow=13},
				["Buizel"]={sheets={{id=174838826,startPixelY=362,rows=2},{id=174838837,rows=5},},nFrames=49,fWidth=66,fHeight=69,framesPerRow=8},
				["Bulbasaur"]={sheets={{id=174838837,startPixelY=350,rows=4},},nFrames=41,fWidth=45,fHeight=49,framesPerRow=12},
				["Buneary"]={sheets={{id=174838849,rows=5},},nFrames=47,fWidth=54,fHeight=73,framesPerRow=10},
				["Bunnelby"]={sheets={{id=174838849,startPixelY=370,rows=2},{id=174838867,rows=4},},nFrames=47,fWidth=64,fHeight=92,framesPerRow=9},
				["Burmy"]={sheets={{id=174838867,startPixelY=372,rows=2},{id=174838873,rows=3},},nFrames=59,fWidth=47,fHeight=64,framesPerRow=12},
				["Butterfree"]={sheets={{id=174838873,startPixelY=195,rows=4},{id=174838879,rows=6},{id=174838885,rows=1},},nFrames=63,fWidth=90,fHeight=85,framesPerRow=6},
				["Cacnea"]={sheets={{id=174838885,startPixelY=86,rows=7},},nFrames=49,fWidth=81,fHeight=50,framesPerRow=7},
				["Cacturne"]={sheets={{id=174838885,startPixelY=443,rows=1},{id=174838896,rows=6},{id=174838905,rows=3},},nFrames=59,fWidth=83,fHeight=87,framesPerRow=6},
				["Camerupt"]={sheets={{id=174838905,startPixelY=264,rows=3},{id=174838911,rows=6},},nFrames=59,fWidth=81,fHeight=74,framesPerRow=7},
				["Carbink"]={sheets={{id=174838911,startPixelY=450,rows=1},{id=174838925,rows=8},},nFrames=83,fWidth=54,fHeight=57,framesPerRow=10,inAir=1},
				["Carnivine"]={sheets={{id=174838925,startPixelY=464,rows=1},{id=174838939,rows=6},{id=174838951,rows=6},{id=174838964,rows=2},},nFrames=59,fWidth=119,fHeight=91,framesPerRow=4},
				["Carracosta"]={sheets={{id=174838964,startPixelY=184,rows=4},{id=174838977,rows=5},},nFrames=59,fWidth=78,fHeight=85,framesPerRow=7},
				["Carvanha"]={sheets={{id=174838977,startPixelY=430,rows=1},{id=174838987,rows=7},},nFrames=79,fWidth=52,fHeight=72,framesPerRow=11},
				["Cascoon"]={sheets={{id=174838987,startPixelY=511,rows=1},{id=174838998,rows=6},},nFrames=69,fWidth=50,fHeight=40,framesPerRow=11},
				["Castform"]={sheets={{id=174838998,startPixelY=246,rows=3},},nFrames=45,fWidth=37,fHeight=59,framesPerRow=15},
				["Caterpie"]={sheets={{id=174838998,startPixelY=426,rows=2},{id=174839012,rows=3},},nFrames=49,fWidth=46,fHeight=45,framesPerRow=12},
				["Celebi"]={sheets={{id=174839012,startPixelY=138,rows=6},{id=174839023,rows=4},},nFrames=76,fWidth=67,fHeight=65,framesPerRow=8},
				["Chandelure"]={sheets={{id=174839023,startPixelY=264,rows=2},{id=174839032,rows=5},{id=174839038,rows=5},{id=174839046,rows=5},{id=174839054,rows=1},},nFrames=69,fWidth=123,fHeight=108,framesPerRow=4,inAir=.5},
				["Chansey"]={sheets={{id=174839054,startPixelY=109,rows=7},{id=174839072,rows=1},},nFrames=52,fWidth=74,fHeight=58,framesPerRow=7},
				["Charizard"]={sheets={{id=174839072,startPixelY=59,rows=3},{id=174839083,rows=3},{id=174839089,rows=3},{id=174839091,rows=3},},nFrames=47,fWidth=133,fHeight=140,framesPerRow=4,inAir=0.4},
				["Charmander"]={sheets={{id=174839091,startPixelY=423,rows=2},{id=174839100,rows=5},},nFrames=69,fWidth=48,fHeight=57,framesPerRow=11},
				["Charmeleon"]={sheets={{id=174839100,startPixelY=290,rows=3},{id=174839112,rows=4},},nFrames=59,fWidth=60,fHeight=70,framesPerRow=9},
				["Chatot"]={sheets={{id=174839112,startPixelY=284,rows=3},},nFrames=29,fWidth=48,fHeight=60,framesPerRow=11},
				["Cherrim"]={sheets={{id=174839112,startPixelY=467,rows=1},{id=174839126,rows=8},},nFrames=99,fWidth=50,fHeight=57,framesPerRow=11},
				["Cherubi"]={sheets={{id=174839126,startPixelY=464,rows=1},{id=174839135,rows=4},},nFrames=49,fWidth=50,fHeight=48,framesPerRow=11},
				["Chesnaught"]={sheets={{id=174839135,startPixelY=196,rows=3},{id=174839143,rows=5},{id=174839149,rows=5},{id=174839159,rows=2},},nFrames=59,fWidth=128,fHeight=106,framesPerRow=4},
				["Chespin"]={sheets={{id=174839159,startPixelY=214,rows=4},},nFrames=44,fWidth=50,fHeight=64,framesPerRow=11},
				["Chikorita"]={sheets={{id=174839159,startPixelY=474,rows=1},{id=174839169,rows=2},},nFrames=48,fWidth=32,fHeight=63,framesPerRow=17},
				["Chimchar"]={sheets={{id=174839169,startPixelY=128,rows=3},},nFrames=27,fWidth=54,fHeight=70,framesPerRow=10},
				["Chimecho"]={sheets={{id=174839169,startPixelY=341,rows=2},{id=174839176,rows=4},},nFrames=69,fWidth=41,fHeight=73,framesPerRow=13,inAir=.5},
				["Chinchou"]={sheets={{id=174839176,startPixelY=296,rows=4},{id=174839188,rows=5},},nFrames=60,fWidth=81,fHeight=53,framesPerRow=7},
				["Chingling"]={sheets={{id=174839188,startPixelY=270,rows=4},},nFrames=39,fWidth=50,fHeight=66,framesPerRow=11},
				["Cinccino"]={sheets={{id=174839196,rows=8},{id=174839214,rows=1},},nFrames=59,fWidth=80,fHeight=63,framesPerRow=7},
				["Clamperl"]={sheets={{id=174839214,startPixelY=64,rows=6},},nFrames=54,fWidth=56,fHeight=54,framesPerRow=10},
				["Clauncher"]={sheets={{id=174839214,startPixelY=394,rows=3},{id=174839218,rows=2},},nFrames=39,fWidth=70,fHeight=52,framesPerRow=8},
				["Clawitzer"]={sheets={{id=174839218,startPixelY=106,rows=4},{id=174839230,rows=5},{id=174839239,rows=3},},nFrames=47,fWidth=138,fHeight=95,framesPerRow=4},
				["Claydol"]={sheets={{id=174839239,startPixelY=288,rows=3},{id=174839254,rows=6},{id=174839268,rows=1},},nFrames=79,fWidth=69,fHeight=85,framesPerRow=8,inAir=.7},
				["Clefable"]={sheets={{id=174839268,startPixelY=86,rows=6},},nFrames=40,fWidth=80,fHeight=65,framesPerRow=7},
				["Clefairy"]={sheets={{id=174839268,startPixelY=482,rows=1},{id=174839282,rows=3},},nFrames=40,fWidth=56,fHeight=48,framesPerRow=10},
				["Cleffa"]={sheets={{id=174839282,startPixelY=147,rows=4},},nFrames=42,fWidth=46,fHeight=44,framesPerRow=12},
				["Cloyster"]={sheets={{id=174839282,startPixelY=327,rows=2},{id=174839295,rows=6},{id=174839308,rows=2},},nFrames=59,fWidth=83,fHeight=85,framesPerRow=6,inAir=.9},
				["Cobalion"]={sheets={{id=174839308,startPixelY=172,rows=3},{id=174839319,rows=5},},nFrames=74,fWidth=56,fHeight=109,framesPerRow=10},
				["Cofagrigus"]={sheets={{id=174839334,rows=4},{id=174839347,rows=4},{id=174839360,rows=4},{id=174839372,rows=1},},nFrames=39,fWidth=165,fHeight=119,framesPerRow=3},
				["Combee"]={sheets={{id=174839372,startPixelY=120,rows=8},},nFrames=43,fWidth=92,fHeight=46,framesPerRow=6,inAir=1},
				["Combusken"]={sheets={{id=174839382,rows=3},},nFrames=27,fWidth=61,fHeight=83,framesPerRow=9},
				["Conkeldurr"]={sheets={{id=174839382,startPixelY=252,rows=3},{id=174839390,rows=6},{id=174839404,rows=6},},nFrames=59,fWidth=123,fHeight=89,framesPerRow=4},
				["Corphish"]={sheets={{id=174839418,rows=4},},nFrames=35,fWidth=64,fHeight=55,framesPerRow=9},
				["Corsola"]={sheets={{id=174839418,startPixelY=224,rows=4},{id=174839429,rows=4},},nFrames=60,fWidth=70,fHeight=69,framesPerRow=8},
				["Cottonee"]={sheets={{id=174839429,startPixelY=280,rows=6},{id=174839447,rows=8},},nFrames=119,fWidth=61,fHeight=40,framesPerRow=9},
				["Cradily"]={sheets={{id=174839447,startPixelY=328,rows=2},{id=174839454,rows=6},{id=174839461,rows=1},},nFrames=59,fWidth=74,fHeight=88,framesPerRow=7},
				["Cranidos"]={sheets={{id=174839461,startPixelY=89,rows=4},},nFrames=39,fWidth=48,fHeight=68,framesPerRow=11},
				["Crawdaunt"]={sheets={{id=174839461,startPixelY=365,rows=2},{id=174839468,rows=7},{id=174839482,rows=6},},nFrames=72,fWidth=102,fHeight=74,framesPerRow=5},
				["Cresselia"]={sheets={{id=174839482,startPixelY=450,rows=1},{id=174839502,rows=5},{id=174839514,rows=5},{id=174839522,rows=5},{id=174839543,rows=5},{id=174839561,rows=3},},nFrames=119,fWidth=113,fHeight=96,framesPerRow=5},
				["Croagunk"]={sheets={{id=174839561,startPixelY=291,rows=5},},nFrames=39,fWidth=60,fHeight=52,framesPerRow=9},
				["Crobat"]={sheets={{id=174839570,rows=5},{id=174839576,rows=2},},nFrames=27,fWidth=143,fHeight=107,framesPerRow=4},
				["Croconaw"]={sheets={{id=174839576,startPixelY=216,rows=4},{id=174839585,rows=2},},nFrames=60,fWidth=52,fHeight=78,framesPerRow=11},
				["Crustle"]={sheets={{id=174839585,startPixelY=158,rows=4},{id=174839602,rows=6},{id=174839614,rows=2},},nFrames=59,fWidth=97,fHeight=83,framesPerRow=5},
				["Cryogonal"]={sheets={{id=174839614,startPixelY=168,rows=3},{id=174839623,rows=5},{id=174839642,rows=4},},nFrames=78,fWidth=78,fHeight=99,framesPerRow=7},
				["Cubchoo"]={sheets={{id=174839642,startPixelY=400,rows=2},{id=174839650,rows=3},},nFrames=49,fWidth=51,fHeight=59,framesPerRow=11},
				["Cubone"]={sheets={{id=174839650,startPixelY=180,rows=4},},nFrames=48,fWidth=40,fHeight=49,framesPerRow=14},
				["Cyndaquil"]={sheets={{id=174839650,startPixelY=380,rows=3},{id=174839659,rows=1},},nFrames=50,fWidth=38,fHeight=45,framesPerRow=15},
				["Darkrai"]={sheets={{id=174839659,startPixelY=46,rows=4},{id=174839668,rows=4},{id=174839684,rows=4},{id=174839693,rows=3},},nFrames=59,fWidth=124,fHeight=116,framesPerRow=4},
				["Darmanitan"]={sheets={{id=174839693,startPixelY=351,rows=2},{id=174839699,rows=6},{id=174839715,rows=1},},nFrames=45,fWidth=99,fHeight=91,framesPerRow=5},
				["Darumaka"]={sheets={{id=174839715,startPixelY=92,rows=6},},nFrames=39,fWidth=74,fHeight=61,framesPerRow=7},
				["Dedenne"]={sheets={{id=174839715,startPixelY=464,rows=1},{id=174839728,rows=4},},nFrames=39,fWidth=68,fHeight=50,framesPerRow=8},
				["Deerling"]={sheets={{id=174839728,startPixelY=204,rows=4},{id=174839741,rows=1},},nFrames=59,fWidth=46,fHeight=71,framesPerRow=12},
				["Deino"]={sheets={{id=174839741,startPixelY=72,rows=6},},nFrames=67,fWidth=43,fHeight=76,framesPerRow=13},
				["Delcatty"]={sheets={{id=174839753,rows=7},{id=174839762,rows=1},},nFrames=60,fWidth=65,fHeight=77,framesPerRow=8},
				["Delibird"]={sheets={{id=174839762,startPixelY=78,rows=5},},nFrames=40,fWidth=59,fHeight=71,framesPerRow=9},
				["Delphox"]={sheets={{id=174839762,startPixelY=438,rows=1},{id=174839767,rows=5},{id=174839772,rows=4},},nFrames=59,fWidth=95,fHeight=110,framesPerRow=6},
				["Deoxys"]={sheets={{id=174839772,startPixelY=444,rows=1},{id=174839786,rows=6},{id=174839795,rows=5},},nFrames=59,fWidth=115,fHeight=86,framesPerRow=5},
				["Dewgong"]={sheets={{id=174839795,startPixelY=435,rows=1},{id=174839805,rows=8},{id=174839813,rows=3},},nFrames=59,fWidth=99,fHeight=69,framesPerRow=5},
				["Dewott"]={sheets={{id=174839813,startPixelY=210,rows=3},},nFrames=29,fWidth=44,fHeight=73,framesPerRow=13},
				["Dialga"]={sheets={{id=174839813,startPixelY=432,rows=1},{id=174839820,rows=4},{id=174839832,rows=4},{id=174839838,rows=4},{id=174839846,rows=4},{id=174839860,rows=4},{id=174839875,rows=3},},nFrames=119,fWidth=100,fHeight=122,framesPerRow=5},
				["Diancie"]={sheets={{id=174839875,startPixelY=369,rows=2},{id=174839886,rows=4},},nFrames=59,fWidth=50,fHeight=90,framesPerRow=11,inAir=.2},
				["Diggersby"]={sheets={{id=174839886,startPixelY=364,rows=1},{id=174839894,rows=5},{id=174839902,rows=5},{id=174839915,rows=2},},nFrames=49,fWidth=121,fHeight=105,framesPerRow=4},
				["Diglett"]={sheets={{id=174839915,startPixelY=212,rows=4},},nFrames=40,fWidth=43,fHeight=35,framesPerRow=13},
				["Ditto"]={sheets={{id=174839915,startPixelY=356,rows=5},},nFrames=60,fWidth=43,fHeight=35,framesPerRow=13},
				["Dodrio"]={sheets={{id=174839925,rows=5},{id=174839932,rows=3},},nFrames=59,fWidth=68,fHeight=102,framesPerRow=8},
				["Doduo"]={sheets={{id=174839932,startPixelY=309,rows=3},{id=174839946,rows=1},},nFrames=45,fWidth=42,fHeight=70,framesPerRow=13},
				["Donphan"]={sheets={{id=174839946,startPixelY=71,rows=7},{id=174839955,rows=3},},nFrames=49,fWidth=109,fHeight=67,framesPerRow=5},
				["Doublade"]={sheets={{id=174839955,startPixelY=204,rows=4},{id=174839958,rows=7},{id=174839976,rows=5},},nFrames=63,fWidth=121,fHeight=76,framesPerRow=4},
				["Dragalge"]={sheets={{id=174839976,startPixelY=385,rows=1},{id=174839984,rows=4},{id=174839991,rows=4},{id=174840003,rows=4},{id=174840014,rows=4},{id=174840024,rows=3},},nFrames=79,fWidth=139,fHeight=137,framesPerRow=4},
				["Dragonair"]={sheets={{id=174840024,startPixelY=414,rows=1},{id=174840031,rows=5},{id=174840034,rows=2},},nFrames=59,fWidth=67,fHeight=93,framesPerRow=8},
				["Dragonite"]={sheets={{id=174840034,startPixelY=188,rows=3},{id=174840044,rows=5},},nFrames=44,fWidth=85,fHeight=98,framesPerRow=6},
				["Drapion"]={sheets={{id=174840052,rows=6},{id=174840063,rows=6},{id=174840072,rows=6},},nFrames=69,fWidth=141,fHeight=85,framesPerRow=4},
				["Dratini"]={sheets={{id=174840080,rows=4},},nFrames=48,fWidth=46,fHeight=63,framesPerRow=12},
				["Drifblim"]={sheets={{id=174840080,startPixelY=256,rows=3},{id=174840090,rows=4},},nFrames=79,fWidth=47,fHeight=89,framesPerRow=12,inAir=.5},
				["Drifloon"]={sheets={{id=174840090,startPixelY=360,rows=2},{id=174840101,rows=3},},nFrames=69,fWidth=32,fHeight=75,framesPerRow=17,inAir=.5},
				["Drilbur"]={sheets={{id=174840101,startPixelY=228,rows=6},{id=174840117,rows=2},},nFrames=47,fWidth=83,fHeight=49,framesPerRow=6},
				["Drowzee"]={sheets={{id=174840117,startPixelY=100,rows=7},{id=174840126,rows=1},},nFrames=70,fWidth=62,fHeight=57,framesPerRow=9},
				["Druddigon"]={sheets={{id=174840126,startPixelY=58,rows=4},{id=174840135,rows=5},{id=174840144,rows=5},{id=174840152,rows=4},},nFrames=69,fWidth=123,fHeight=104,framesPerRow=4},
				["Ducklett"]={sheets={{id=174840152,startPixelY=420,rows=2},{id=174840161,rows=2},},nFrames=48,fWidth=42,fHeight=62,framesPerRow=13},
				["Dugtrio"]={sheets={{id=174840161,startPixelY=126,rows=8},{id=174840178,rows=7},},nFrames=120,fWidth=65,fHeight=50,framesPerRow=8},
				["Dunsparce"]={sheets={{id=174840178,startPixelY=357,rows=4},{id=174840189,rows=2},},nFrames=49,fWidth=62,fHeight=41,framesPerRow=9},
				["Duosion"]={sheets={{id=174840189,startPixelY=84,rows=6},},nFrames=59,fWidth=52,fHeight=64,framesPerRow=11,inAir=.8},
				["Durant"]={sheets={{id=174840189,startPixelY=474,rows=2},{id=174840205,rows=5},},nFrames=59,fWidth=64,fHeight=38,framesPerRow=9},
				["Dusclops"]={sheets={{id=174840205,startPixelY=195,rows=4},{id=174840216,rows=6},},nFrames=59,fWidth=96,fHeight=81,framesPerRow=6},
				["Dusknoir"]={sheets={{id=174840224,rows=5},{id=174840231,rows=5},{id=174840244,rows=5},{id=174840254,rows=4},},nFrames=74,fWidth=128,fHeight=101,framesPerRow=4},
				["Duskull"]={sheets={{id=174840254,startPixelY=408,rows=2},{id=174840273,rows=4},},nFrames=59,fWidth=48,fHeight=64,framesPerRow=11,inAir=.5},
				["Dustox"]={sheets={{id=174840273,startPixelY=260,rows=4},{id=174840276,rows=5},},nFrames=43,fWidth=100,fHeight=71,framesPerRow=5},
				["Dwebble"]={sheets={{id=174840276,startPixelY=360,rows=4},{id=174840280,rows=2},},nFrames=59,fWidth=53,fHeight=42,framesPerRow=10},
				["Eelektrik"]={sheets={{id=174840280,startPixelY=86,rows=5},{id=174840289,rows=4},},nFrames=59,fWidth=74,fHeight=80,framesPerRow=7,inAir=.6},
				["Eelektross"]={sheets={{id=174840289,startPixelY=324,rows=3},{id=174840296,rows=7},{id=174840309,rows=2},},nFrames=59,fWidth=111,fHeight=70,framesPerRow=5,inAir=1},
				["Ekans"]={sheets={{id=174840309,startPixelY=310,rows=4},},nFrames=48,fWidth=46,fHeight=42,framesPerRow=12},
				["Electabuzz"]={sheets={{id=174840319,rows=5},},nFrames=33,fWidth=78,fHeight=78,framesPerRow=7},
				["Electivire"]={sheets={{id=174840319,startPixelY=395,rows=1},{id=174840329,rows=6},{id=174840342,rows=5},},nFrames=59,fWidth=99,fHeight=85,framesPerRow=5},
				["Electrike"]={sheets={{id=174840342,startPixelY=430,rows=3},{id=174840351,rows=1},},nFrames=39,fWidth=53,fHeight=38,framesPerRow=10},
				["Electrode"]={sheets={{id=174840351,startPixelY=39,rows=8},{id=174840362,rows=4},},nFrames=90,fWidth=72,fHeight=59,framesPerRow=8},
				["Elekid"]={sheets={{id=174840362,startPixelY=240,rows=5},},nFrames=32,fWidth=73,fHeight=63,framesPerRow=7},
				["Elgyem"]={sheets={{id=174840369,rows=5},},nFrames=75,fWidth=33,fHeight=67,framesPerRow=17,inAir=.9},
				["Emboar"]={sheets={{id=174840369,startPixelY=340,rows=2},{id=174840387,rows=5},{id=174840396,rows=5},},nFrames=59,fWidth=107,fHeight=102,framesPerRow=5},
				["Emolga"]={sheets={{id=174840420,rows=9},{id=174840433,rows=4},},nFrames=99,fWidth=66,fHeight=59,framesPerRow=8},
				["Empoleon"]={sheets={{id=174840433,startPixelY=240,rows=2},{id=174840444,rows=5},{id=174840452,rows=3},},nFrames=59,fWidth=92,fHeight=111,framesPerRow=6},
				["Entei"]={sheets={{id=174840452,startPixelY=336,rows=2},{id=174840461,rows=6},{id=174840467,rows=4},},nFrames=80,fWidth=79,fHeight=87,framesPerRow=7},
				["Escavalier"]={sheets={{id=174840467,startPixelY=352,rows=2},{id=174840478,rows=5},{id=174840485,rows=1},},nFrames=39,fWidth=105,fHeight=101,framesPerRow=5},
				["Espeon"]={sheets={{id=174840485,startPixelY=102,rows=5},{id=174840490,rows=2},},nFrames=60,fWidth=60,fHeight=77,framesPerRow=9},
				["Espurr"]={sheets={{id=174840490,startPixelY=156,rows=4},},nFrames=39,fWidth=47,fHeight=58,framesPerRow=12},
				["Excadrill"]={sheets={{id=174840490,startPixelY=392,rows=2},{id=174840498,rows=6},},nFrames=47,fWidth=89,fHeight=79,framesPerRow=6},
				["Exeggutor"]={sheets={{id=174840509,startPixelY=210,rows=3},{id=174840518,rows=5},{id=174840529,rows=4},},nFrames=48,fWidth=142,fHeight=99,framesPerRow=4},
				["Exploud"]={sheets={{id=174840529,startPixelY=400,rows=1},{id=174840538,rows=6},{id=174840551,rows=5},},nFrames=80,fWidth=82,fHeight=84,framesPerRow=7},
				["Farfetch\'d"]={sheets={{id=174840551,startPixelY=425,rows=2},{id=174840558,rows=2},},nFrames=51,fWidth=44,fHeight=50,framesPerRow=13},
				["Fearow"]={sheets={{id=174840558,startPixelY=102,rows=3},{id=174840568,rows=4},{id=174840574,rows=4},{id=174840585,rows=4},{id=174840594,rows=2},},nFrames=50,fWidth=148,fHeight=135,framesPerRow=3,inAir=.2},
				["Feebas"]={sheets={{id=174840594,startPixelY=272,rows=5},},nFrames=59,fWidth=43,fHeight=52,framesPerRow=13},
				["Fennekin"]={sheets={{id=174840609,rows=3},},nFrames=25,fWidth=51,fHeight=59,framesPerRow=11},
				["Feraligatr"]={sheets={{id=174840609,startPixelY=180,rows=3},{id=174840614,rows=5},{id=174840622,rows=2},},nFrames=64,fWidth=82,fHeight=98,framesPerRow=7},
				["Ferroseed"]={sheets={{id=174840622,startPixelY=198,rows=1},},nFrames=1,fWidth=51,fHeight=64,framesPerRow=1},
				["Ferrothorn"]={sheets={{id=174840622,startPixelY=263,rows=4},{id=174840633,rows=6},},nFrames=39,fWidth=128,fHeight=70,framesPerRow=4},
				["Finneon"]={sheets={{id=174840633,startPixelY=426,rows=3},{id=174840647,rows=3},},nFrames=59,fWidth=50,fHeight=42,framesPerRow=11},
				["Flaaffy"]={sheets={{id=174840647,startPixelY=129,rows=5},},nFrames=48,fWidth=52,fHeight=67,framesPerRow=11},
				["Flabebe"]={sheets={{id=174840647,startPixelY=469,rows=1},{id=174840662,rows=7},{id=174840684,rows=4},},nFrames=79,fWidth=76,fHeight=78,framesPerRow=7,inAir=.5},
				["Flareon"]={sheets={{id=174840684,startPixelY=316,rows=2},{id=174840693,rows=2},},nFrames=29,fWidth=59,fHeight=93,framesPerRow=9},
				["Fletchinder"]={sheets={{id=174840693,startPixelY=188,rows=3},{id=174840697,rows=2},},nFrames=24,fWidth=109,fHeight=107,framesPerRow=5},
				["Fletchling"]={sheets={{id=174840697,startPixelY=216,rows=4},},nFrames=44,fWidth=47,fHeight=43,framesPerRow=12},
				["Floatzel"]={sheets={{id=174840697,startPixelY=392,rows=1},{id=174840706,rows=5},{id=174840716,rows=2},},nFrames=47,fWidth=88,fHeight=93,framesPerRow=6},
				["Floette"]={sheets={{id=174840716,startPixelY=188,rows=3},{id=174840723,rows=3},},nFrames=47,fWidth=61,fHeight=95,framesPerRow=9,inAir=.5},
				["Florges"]={sheets={{id=174840723,startPixelY=288,rows=2},{id=174840733,rows=5},{id=174840744,rows=4},},nFrames=74,fWidth=80,fHeight=100,framesPerRow=7},
				["Flygon"]={sheets={{id=174840744,startPixelY=404,rows=1},{id=174840752,rows=5},{id=174840766,rows=5},},nFrames=43,fWidth=133,fHeight=106,framesPerRow=4},
				["Foongus"]={sheets={{id=174840775,rows=4},},nFrames=39,fWidth=47,fHeight=48,framesPerRow=12},
				["Forretress"]={sheets={{id=174840775,startPixelY=196,rows=5},{id=174840783,rows=5},},nFrames=60,fWidth=93,fHeight=69,framesPerRow=6},
				["Fraxure"]={sheets={{id=174840783,startPixelY=350,rows=2},{id=174840794,rows=6},},nFrames=39,fWidth=111,fHeight=78,framesPerRow=5},
				["Frillish"]={sheets={{id=174840805,rows=6},{id=174840817,rows=2},},nFrames=59,fWidth=68,fHeight=86,framesPerRow=8},
				["Froakie"]={sheets={{id=174840817,startPixelY=174,rows=3},},nFrames=29,fWidth=45,fHeight=52,framesPerRow=12},
				["Frogadier"]={sheets={{id=174840817,startPixelY=333,rows=3},{id=174840829,rows=3},},nFrames=39,fWidth=73,fHeight=58,framesPerRow=7},
				["Froslass"]={sheets={{id=174840829,startPixelY=177,rows=4},{id=174840838,rows=5},},nFrames=69,fWidth=66,fHeight=79,framesPerRow=8},
				["Furfrou"]={sheets={{id=174840838,startPixelY=400,rows=1},{id=174840851,rows=3},},nFrames=47,fWidth=47,fHeight=84,framesPerRow=12},
				['Furfrou-Heart']={sheets={{id=7019469671,rows=3},{id=7019469592,rows=3},},nFrames=40,fWidth=53,fHeight=84,framesPerRow=7},
				['Furfrou-Star']={sheets={{id=7019476970,rows=3},{id=7019476904,rows=3},},nFrames=40,fWidth=54,fHeight=85,framesPerRow=7},
				['Furfrou-Diamond']={sheets={{id=7019483534,rows=3},{id=7019483464,rows=3},},nFrames=40,fWidth=52,fHeight=87,framesPerRow=7},
				['Furfrou-Debutante']={sheets={{id=7019487843,rows=5},},nFrames=35,fWidth=57,fHeight=78,framesPerRow=7},
				['Furfrou-Matron']={sheets={{id=7019494292,rows=3},{id=7019494211,rows=3},},nFrames=40,fWidth=55,fHeight=76,framesPerRow=7},
				['Furfrou-Dandy']={sheets={{id=7019497628,rows=5},},nFrames=35,fWidth=57,fHeight=81,framesPerRow=7},
				['Furfrou-Lareine']={sheets={{id=7019501525,rows=6},},nFrames=37,fWidth=50,fHeight=80,framesPerRow=7},
				['Furfrou-Kabuki']={sheets={{id=7019507589,rows=3},{id=7019507503,rows=3},},nFrames=38,fWidth=54,fHeight=79,framesPerRow=7},
				['Furfrou-Pharoah']={sheets={{id=7019513117,rows=3},{id=7019513043,rows=3},},nFrames=37,fWidth=50,fHeight=85,framesPerRow=7},
				["Furret"]={sheets={{id=174840851,startPixelY=255,rows=4},{id=174840864,rows=6},},nFrames=59,fWidth=85,fHeight=73,framesPerRow=6},
				["Gabite"]={sheets={{id=174840864,startPixelY=444,rows=1},{id=174840886,rows=4},},nFrames=39,fWidth=63,fHeight=76,framesPerRow=9},
				["Gallade"]={sheets={{id=174840886,startPixelY=308,rows=2},{id=174840891,rows=2},},nFrames=39,fWidth=52,fHeight=97,framesPerRow=11},
				["Galvantula"]={sheets={{id=174840891,startPixelY=196,rows=7},{id=174840903,rows=1},},nFrames=47,fWidth=93,fHeight=49,framesPerRow=6},
				["Garbodor"]={sheets={{id=174840903,startPixelY=50,rows=5},{id=174840918,rows=6},{id=174840935,rows=4},},nFrames=59,fWidth=118,fHeight=88,framesPerRow=4},
				["Garchomp"]={sheets={{id=10692840852,rows=8}},nFrames=59,fWidth=114,fHeight=107,framesPerRow=8},
				["Gardevoir"]={sheets={{id=10692852595,rows=8}},nFrames=77,fWidth=93,fHeight=95,framesPerRow=10},
				["Gastly"]={sheets={{id=174840976,startPixelY=465,rows=1},{id=174840986,rows=5},},nFrames=64,fWidth=52,fHeight=61,framesPerRow=11},
				["Gastrodon"]={sheets={{id=174840986,startPixelY=310,rows=3},{id=174840993,rows=4},},nFrames=59,fWidth=63,fHeight=77,framesPerRow=9},
				["Genesect"]={sheets={{id=174840993,startPixelY=312,rows=2},{id=174840999,rows=5},},nFrames=49,fWidth=70,fHeight=92,framesPerRow=8},
				["Gengar"]={sheets={{id=174840999,startPixelY=465,rows=1},{id=174841009,rows=6},},nFrames=39,fWidth=84,fHeight=78,framesPerRow=6},
				["Geodude"]={sheets={{id=174841009,startPixelY=474,rows=2},{id=174841015,rows=6},},nFrames=50,fWidth=75,fHeight=35,framesPerRow=7,inAir=.7},
				["Gible"]={sheets={{id=174841015,startPixelY=216,rows=4},},nFrames=31,fWidth=58,fHeight=57,framesPerRow=9},
				["Gigalith"]={sheets={{id=174841015,startPixelY=448,rows=1},{id=174841030,rows=5},{id=174841044,rows=5},{id=174841057,rows=2},},nFrames=63,fWidth=101,fHeight=97,framesPerRow=5},
				["Girafarig"]={sheets={{id=174841057,startPixelY=196,rows=4},{id=174841070,rows=6},{id=174841083,rows=1},},nFrames=119,fWidth=48,fHeight=88,framesPerRow=11},
				["Giratina"]={sheets={{id=174841083,startPixelY=89,rows=4},{id=174841091,rows=4},{id=174841100,rows=4},{id=174841108,rows=4},{id=174841117,rows=4},},nFrames=79,fWidth=140,fHeight=114,framesPerRow=4},
				["Glaceon"]={sheets={{id=174841117,startPixelY=460,rows=1},{id=174841128,rows=6},{id=174841136,rows=1},},nFrames=59,fWidth=69,fHeight=80,framesPerRow=8},
				["Glalie"]={sheets={{id=174841136,startPixelY=81,rows=6},{id=174841145,rows=2},},nFrames=61,fWidth=72,fHeight=75,framesPerRow=8},
				["Glameow"]={sheets={{id=174841145,startPixelY=152,rows=4},{id=174841153,rows=2},},nFrames=47,fWidth=60,fHeight=86,framesPerRow=9},
				["Gligar"]={sheets={{id=174841153,startPixelY=174,rows=4},{id=174841164,rows=5},},nFrames=59,fWidth=76,fHeight=90,framesPerRow=7,inAir=.3},
				["Gliscor"]={sheets={{id=174841164,startPixelY=455,rows=1},{id=174841173,rows=5},{id=174841184,rows=5},{id=174841193,rows=3},},nFrames=69,fWidth=111,fHeight=101,framesPerRow=5,inAir=.2},
				["Gloom"]={sheets={{id=174841193,startPixelY=306,rows=4},{id=174841204,rows=1},},nFrames=37,fWidth=62,fHeight=53,framesPerRow=9},
				["Gogoat"]={sheets={{id=174841204,startPixelY=54,rows=6},},nFrames=59,fWidth=57,fHeight=83,framesPerRow=10},
				["Golbat"]={sheets={{id=174841215,rows=4},{id=174841222,rows=4},{id=174841232,rows=4},{id=174841237,rows=4},{id=174841243,rows=4},},nFrames=59,fWidth=160,fHeight=136,framesPerRow=3},
				["Goldeen"]={sheets={{id=174841255,rows=10},},nFrames=68,fWidth=79,fHeight=54,framesPerRow=7,inAir=1.1},
				["Golduck"]={sheets={{id=174841270,rows=7},},nFrames=50,fWidth=68,fHeight=74,framesPerRow=8},
				["Golem"]={sheets={{id=174841278,rows=7},{id=174841288,rows=3},},nFrames=60,fWidth=94,fHeight=78,framesPerRow=6},
				["Golett"]={sheets={{id=174841288,startPixelY=237,rows=4},{id=174841300,rows=3},},nFrames=59,fWidth=62,fHeight=65,framesPerRow=9},
				["Golurk"]={sheets={{id=174841300,startPixelY=198,rows=3},{id=174841314,rows=5},{id=174841324,rows=5},{id=174841336,rows=1},},nFrames=79,fWidth=89,fHeight=108,framesPerRow=6},
				["Goodra"]={sheets={{id=174841336,startPixelY=109,rows=4},{id=174841350,rows=3},},nFrames=59,fWidth=60,fHeight=102,framesPerRow=9},
				["Goomy"]={sheets={{id=174841350,startPixelY=309,rows=4},},nFrames=53,fWidth=39,fHeight=50,framesPerRow=14},
				["Gorebyss"]={sheets={{id=174841360,rows=7},{id=174841372,rows=5},},nFrames=79,fWidth=82,fHeight=74,framesPerRow=7},
				["Gothita"]={sheets={{id=174841372,startPixelY=375,rows=3},{id=174841380,rows=1},},nFrames=37,fWidth=46,fHeight=59,framesPerRow=12},
				["Gothitelle"]={sheets={{id=174841380,startPixelY=60,rows=4},{id=174841387,rows=1},},nFrames=39,fWidth=62,fHeight=101,framesPerRow=9},
				["Gothorita"]={sheets={{id=174841387,startPixelY=102,rows=4},},nFrames=31,fWidth=69,fHeight=77,framesPerRow=8},
				["Gourgeist"]={sheets={{id=174841387,startPixelY=414,rows=1},{id=174841396,rows=5},},nFrames=59,fWidth=53,fHeight=83,framesPerRow=10},
				["Granbull"]={sheets={{id=174841396,startPixelY=420,rows=1},{id=174841403,rows=6},{id=174841411,rows=2},},nFrames=60,fWidth=77,fHeight=84,framesPerRow=7},
				["Graveler"]={sheets={{id=174841411,startPixelY=170,rows=6},{id=174841417,rows=4},},nFrames=50,fWidth=107,fHeight=59,framesPerRow=5},
				["Greninja"]={sheets={{id=174841417,startPixelY=240,rows=4},{id=174841425,rows=6},},nFrames=39,fWidth=131,fHeight=76,framesPerRow=4},
				["Grimer"]={sheets={{id=174841425,startPixelY=462,rows=1},{id=174841433,rows=9},},nFrames=80,fWidth=68,fHeight=51,framesPerRow=8},
				["Grotle"]={sheets={{id=174841433,startPixelY=468,rows=1},{id=174841444,rows=7},},nFrames=59,fWidth=70,fHeight=69,framesPerRow=8},
				["Groudon"]={sheets={{id=174841453,rows=5},{id=174841461,rows=5},{id=174841470,rows=2},},nFrames=59,fWidth=107,fHeight=94,framesPerRow=5},
				["Grovyle"]={sheets={{id=174841470,startPixelY=190,rows=4},{id=174841478,rows=3},},nFrames=49,fWidth=78,fHeight=79,framesPerRow=7},
				["Growlithe"]={sheets={{id=174841478,startPixelY=240,rows=2},},nFrames=24,fWidth=45,fHeight=57,framesPerRow=12},
				["Grumpig"]={sheets={{id=174841478,startPixelY=356,rows=2},{id=174841490,rows=5},},nFrames=47,fWidth=81,fHeight=73,framesPerRow=7},
				["Gulpin"]={sheets={{id=174841490,startPixelY=370,rows=3},{id=174841495,rows=4},},nFrames=59,fWidth=64,fHeight=52,framesPerRow=9},
				["Gurdurr"]={sheets={{id=174841495,startPixelY=212,rows=4},{id=174841502,rows=4},},nFrames=39,fWidth=98,fHeight=78,framesPerRow=5},
				["Gyarados"]={sheets={{id=174841502,startPixelY=316,rows=2},{id=174841512,rows=5},{id=174841525,rows=5},},nFrames=59,fWidth=115,fHeight=99,framesPerRow=5},
				--['Gyarados-OrangeTwoTone']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Gyarados-OrangeOrca']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Gyarados-OrangeDapples']={sheets={{id=7081510860,rows=8},},nFrames=43,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				--['Gyarados-PinkTwoTone']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Gyarados-PinkOrca']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Gyarados-PinkDapples']={sheets={{id=7081588440,rows=8},},nFrames=43,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				--['Gyarados-PurpleBubbles']={sheets={{id=7081621491,rows=7},},nFrames=42,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				--['Gyarados-PurpleDiamonds']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Gyarados-PurplePatches']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Gyarados-CalicoOrangeGold']={sheets={{id=7082183587,rows=8},},nFrames=43,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				['Gyarados-CalicoOrangeWhite']={sheets={{id=7081734961,rows=8},},nFrames=43,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				--['Gyarados-CalicoOrangeWhiteBlack']={sheets={{id=7081879563,rows=8},},nFrames=43,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				['Gyarados-Monochrome']={sheets={{id=7081798127,rows=8},},nFrames=43,fWidth=116,fHeight=97,framesPerRow=6}, -- 117 x 98
				--['Gyarados-GrayBubbles']={sheets={{id=7081843461,rows=8},},nFrames=43,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				--['Gyarados-GrayDiamonds']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Gyarados-GrayPatches']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Gyarados-Skeletal']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Gyarados-Wasp']={sheets={{id=7077255454,rows=8},},nFrames=43,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				['Gyarados-YinYang']={sheets={{id=7081912208,rows=7},},nFrames=42,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				--['Gyarados-Manga']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Gyarados-Fuchsia']={sheets={{id=7077358211,rows=7},},nFrames=42,fWidth=116,fHeight=97,framesPerRow=6}, -- 117 x 98
				--['Gyarados-Goldeen']={sheets={{id=7081979696,rows=7},},nFrames=42,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				['Gyarados-Seaking']={sheets={{id=7082006244,rows=7},},nFrames=42,fWidth=107,fHeight=97,framesPerRow=6}, -- 108 x 98
				['Gyarados-Gyarados']={sheets={{id=7082152259,rows=7},},nFrames=42,fWidth=116,fHeight=97,framesPerRow=6}, -- 117 x 98
				--['Gyarados-Feebas']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Gyarados-Relicanth']={sheets={{id=7082198592,rows=8},},nFrames=43,fWidth=117,fHeight=97,framesPerRow=6}, -- 118 x 98
				['Gyarados-Rayquaza']={sheets={{id=7076873683,rows=8},},nFrames=43,fWidth=115,fHeight=95,framesPerRow=6}, -- 116 x 96

				["Happiny"]={sheets={{id=174841525,startPixelY=500,rows=1},{id=174841532,rows=2},},nFrames=39,fWidth=39,fHeight=53,framesPerRow=14},
				["Hariyama"]={sheets={{id=174841532,startPixelY=108,rows=5},{id=174841548,rows=6},{id=174841551,rows=1},},nFrames=59,fWidth=102,fHeight=87,framesPerRow=5},
				["Haunter"]={sheets={{id=174841551,startPixelY=88,rows=6},{id=174841561,rows=4},},nFrames=59,fWidth=85,fHeight=73,framesPerRow=6,inAir=.7},
				["Hawlucha"]={sheets={{id=174841561,startPixelY=296,rows=3},{id=174841569,rows=5},},nFrames=39,fWidth=98,fHeight=72,framesPerRow=5},
				["Haxorus"]={sheets={{id=174841569,startPixelY=365,rows=1},{id=174841573,rows=4},{id=174841582,rows=4},{id=174841600,rows=3},},nFrames=59,fWidth=115,fHeight=118,framesPerRow=5},
				["Heatran"]={sheets={{id=174841627,startPixelY=84,rows=7},{id=174841632,rows=8},{id=174841643,rows=3},},nFrames=69,fWidth=124,fHeight=64,framesPerRow=4},
				["Heliolisk"]={sheets={{id=174841643,startPixelY=195,rows=4},{id=174841655,rows=3},},nFrames=49,fWidth=71,fHeight=78,framesPerRow=8},
				["Helioptile"]={sheets={{id=174841655,startPixelY=237,rows=4},},nFrames=35,fWidth=58,fHeight=54,framesPerRow=9},
				["Heracross"]={sheets={{id=174841655,startPixelY=457,rows=1},{id=174841663,rows=6},{id=174841674,rows=3},},nFrames=59,fWidth=90,fHeight=87,framesPerRow=6},
				["Herdier"]={sheets={{id=174841674,startPixelY=264,rows=3},},nFrames=29,fWidth=57,fHeight=74,framesPerRow=10},
				["Hippopotas"]={sheets={{id=174841674,startPixelY=489,rows=1},{id=174841687,rows=7},},nFrames=69,fWidth=63,fHeight=53,framesPerRow=9},
				["Hippowdon"]={sheets={{id=174841687,startPixelY=378,rows=3},{id=174841701,rows=9},},nFrames=59,fWidth=97,fHeight=58,framesPerRow=5},
				["Hitmonchan"]={sheets={{id=174841715,rows=2},},nFrames=20,fWidth=51,fHeight=77,framesPerRow=11},
				["Hitmonlee"]={sheets={{id=174841715,startPixelY=156,rows=3},},nFrames=28,fWidth=45,fHeight=68,framesPerRow=12},
				["Hitmontop"]={sheets={{id=174841715,startPixelY=363,rows=2},{id=174841728,rows=7},{id=174841738,rows=1},},nFrames=59,fWidth=86,fHeight=71,framesPerRow=6},
				["Ho-Oh"]={sheets={{id=174841738,startPixelY=72,rows=3},{id=174841745,rows=3},{id=174841756,rows=3},{id=174841768,rows=3},{id=174841773,rows=3},{id=174841777,rows=3},{id=174841789,rows=2},},nFrames=60,fWidth=157,fHeight=144,framesPerRow=3},
				["Honchkrow"]={sheets={{id=174841789,startPixelY=290,rows=1},{id=174841798,rows=3},{id=174841802,rows=3},{id=174841816,rows=3},{id=174841824,rows=3},{id=174841835,rows=1},},nFrames=41,fWidth=192,fHeight=182,framesPerRow=3},
				["Honedge"]={sheets={{id=174841835,startPixelY=183,rows=4},{id=174841841,rows=5},},nFrames=59,fWidth=76,fHeight=79,framesPerRow=7},
				["Hoothoot"]={sheets={{id=174841841,startPixelY=400,rows=2},{id=174841846,rows=4},},nFrames=48,fWidth=64,fHeight=63,framesPerRow=9},
				["Hoppip"]={sheets={{id=174841846,startPixelY=256,rows=4},{id=174841856,rows=5},},nFrames=49,fWidth=88,fHeight=61,framesPerRow=6,inAir=1},
				["Horsea"]={sheets={{id=174841856,startPixelY=310,rows=4},},nFrames=60,fWidth=31,fHeight=57,framesPerRow=18},
				["Houndoom"]={sheets={{id=174841864,rows=5},},nFrames=41,fWidth=59,fHeight=86,framesPerRow=9},
				["Houndour"]={sheets={{id=174841864,startPixelY=435,rows=2},{id=174841873,rows=2},},nFrames=48,fWidth=36,fHeight=59,framesPerRow=15},
				["Huntail"]={sheets={{id=174841873,startPixelY=120,rows=6},{id=174841886,rows=4},},nFrames=59,fWidth=93,fHeight=65,framesPerRow=6,inAir=.5},
				["Hydreigon"]={sheets={{id=174841886,startPixelY=264,rows=2},{id=174841902,rows=4},{id=174841914,rows=4},{id=174841927,rows=4},{id=174841934,rows=4},{id=174841951,rows=4},},nFrames=85,fWidth=137,fHeight=130,framesPerRow=4,inAir=1},
				["Hypno"]={sheets={{id=174841958,rows=7},{id=174841964,rows=1},},nFrames=47,fWidth=86,fHeight=78,framesPerRow=6},
				["Igglybuff"]={sheets={{id=174841964,startPixelY=79,rows=6},},nFrames=80,fWidth=40,fHeight=56,framesPerRow=14},
				["Illumise"]={sheets={{id=174841964,startPixelY=421,rows=2},{id=174841975,rows=2},},nFrames=40,fWidth=53,fHeight=65,framesPerRow=10},
				["Infernape"]={sheets={{id=174841975,startPixelY=132,rows=3},{id=174841987,rows=4},{id=174841993,rows=1},},nFrames=39,fWidth=98,fHeight=119,framesPerRow=5},
				["Inkay"]={sheets={{id=174841993,startPixelY=120,rows=7},{id=174842009,rows=1},},nFrames=59,fWidth=68,fHeight=61,framesPerRow=8,inAir=1},
				["Ivysaur"]={sheets={{id=174842009,startPixelY=62,rows=7},{id=174842022,rows=2},},nFrames=49,fWidth=84,fHeight=66,framesPerRow=6},
				["Jellicent"]={sheets={{id=174842022,startPixelY=134,rows=4},{id=174842036,rows=5},{id=174842047,rows=5},{id=174842052,rows=1},},nFrames=89,fWidth=86,fHeight=105,framesPerRow=6},
				["Jigglypuff"]={sheets={{id=174842052,startPixelY=106,rows=5},},nFrames=49,fWidth=46,fHeight=46,framesPerRow=12},
				["Jirachi"]={sheets={{id=174842052,startPixelY=341,rows=3},{id=174842063,rows=7},},nFrames=59,fWidth=92,fHeight=68,framesPerRow=6},
				["Jolteon"]={sheets={{id=174842063,startPixelY=483,rows=1},{id=174842073,rows=3},},nFrames=40,fWidth=49,fHeight=69,framesPerRow=11},
				["Joltik"]={sheets={{id=174842073,startPixelY=210,rows=4},},nFrames=39,fWidth=47,fHeight=31,framesPerRow=12},
				["Jumpluff"]={sheets={{id=174842073,startPixelY=338,rows=2},{id=174842083,rows=6},{id=174842104,rows=6},},nFrames=79,fWidth=90,fHeight=82,framesPerRow=6,inAir=.75},
				["Jynx"]={sheets={{id=174842117,rows=8},{id=174842128,rows=1},},nFrames=60,fWidth=77,fHeight=66,framesPerRow=7},
				["Kabuto"]={sheets={{id=174842128,startPixelY=67,rows=5},},nFrames=60,fWidth=47,fHeight=33,framesPerRow=12},
				["Kabutops"]={sheets={{id=174842128,startPixelY=237,rows=4},},nFrames=36,fWidth=58,fHeight=73,framesPerRow=9},
				["Kadabra"]={sheets={{id=174842138,rows=7},},nFrames=51,fWidth=70,fHeight=71,framesPerRow=8},
				["Kakuna"]={sheets={{id=174842148,rows=5},},nFrames=74,fWidth=36,fHeight=58,framesPerRow=15},
				["Kangaskhan"]={sheets={{id=174842148,startPixelY=295,rows=3},{id=174842165,rows=6},{id=174842172,rows=3},},nFrames=70,fWidth=96,fHeight=87,framesPerRow=6},
				["Karrablast"]={sheets={{id=174842172,startPixelY=264,rows=3},},nFrames=39,fWidth=44,fHeight=67,framesPerRow=13},
				["Kecleon"]={sheets={{id=174842172,startPixelY=468,rows=1},{id=174842182,rows=5},},nFrames=60,fWidth=51,fHeight=67,framesPerRow=11},
				["Keldeo"]={sheets={{id=174842182,startPixelY=340,rows=2},{id=174842205,rows=3},},nFrames=39,fWidth=60,fHeight=88,framesPerRow=9},
				["Kingdra"]={sheets={{id=174842205,startPixelY=267,rows=2},{id=174842217,rows=4},},nFrames=72,fWidth=46,fHeight=97,framesPerRow=12},
				["Kingler"]={sheets={{id=174842217,startPixelY=392,rows=2},{id=174842234,rows=6},},nFrames=46,fWidth=87,fHeight=83,framesPerRow=6},
				["Kirlia"]={sheets={{id=174842243,rows=3},},nFrames=38,fWidth=44,fHeight=68,framesPerRow=13},
				["Klang"]={sheets={{id=174842243,startPixelY=207,rows=4},{id=174842248,rows=7},{id=174842258,rows=2},},nFrames=75,fWidth=84,fHeight=79,framesPerRow=6,inAir=.55},
				["Klefki"]={sheets={{id=174842258,startPixelY=160,rows=4},{id=174842264,rows=6},},nFrames=79,fWidth=69,fHeight=88,framesPerRow=8},
				["Klink"]={sheets={{id=174842270,rows=7},{id=174842277,rows=5},},nFrames=83,fWidth=78,fHeight=73,framesPerRow=7,inAir=.8},
				["Klinklang"]={sheets={{id=174842277,startPixelY=370,rows=2},{id=174842297,rows=7},{id=174842305,rows=7},{id=174842313,rows=4},},nFrames=79,fWidth=124,fHeight=72,framesPerRow=4,inAir=.5},
				["Koffing"]={sheets={{id=174842313,startPixelY=292,rows=3},{id=174842324,rows=7},{id=174842329,rows=7},{id=174842336,rows=1},},nFrames=122,fWidth=77,fHeight=77,framesPerRow=7,inAir=.8},
				["Krabby"]={sheets={{id=174842336,startPixelY=78,rows=5},},nFrames=40,fWidth=64,fHeight=50,framesPerRow=9},
				["Kricketot"]={sheets={{id=174842336,startPixelY=333,rows=3},{id=174842348,rows=4},},nFrames=59,fWidth=60,fHeight=61,framesPerRow=9},
				["Kricketune"]={sheets={{id=174842348,startPixelY=248,rows=4},{id=174842358,rows=2},},nFrames=44,fWidth=67,fHeight=73,framesPerRow=8},
				["Krokorok"]={sheets={{id=174842358,startPixelY=148,rows=5},{id=174842367,rows=2},},nFrames=49,fWidth=81,fHeight=76,framesPerRow=7},
				["Krookodile"]={sheets={{id=174842367,startPixelY=154,rows=4},{id=174842376,rows=5},{id=174842385,rows=5},{id=174842395,rows=2},},nFrames=79,fWidth=97,fHeight=94,framesPerRow=5},
				["Kyogre"]={sheets={{id=174842395,startPixelY=190,rows=6},{id=174842400,rows=10},{id=174842416,rows=10},{id=174842421,rows=10},{id=174842429,rows=2},},nFrames=75,fWidth=234,fHeight=55,framesPerRow=2,inAir=0.8},
				["Kyurem"]={sheets={{id=174842429,startPixelY=112,rows=4},{id=174842434,rows=6},{id=174842444,rows=6},{id=174842455,rows=2},},nFrames=87,fWidth=109,fHeight=91,framesPerRow=5},
				["Lairon"]={sheets={{id=174842455,startPixelY=184,rows=6},{id=174842459,rows=3},},nFrames=59,fWidth=74,fHeight=58,framesPerRow=7},
				["Lampent"]={sheets={{id=174842459,startPixelY=177,rows=4},{id=174842473,rows=6},{id=174842483,rows=5},},nFrames=71,fWidth=98,fHeight=82,framesPerRow=5},
				["Landorus"]={sheets={{id=174842483,startPixelY=415,rows=1},{id=174842493,rows=5},{id=174842499,rows=5},{id=174842514,rows=3},},nFrames=79,fWidth=84,fHeight=93,framesPerRow=6,inAir=.6},
				["Lapras"]={sheets={{id=174842530,startPixelY=85,rows=5},{id=174842543,rows=6},{id=174842555,rows=4},},nFrames=89,fWidth=94,fHeight=84,framesPerRow=6},
				["Larvesta"]={sheets={{id=174842555,startPixelY=340,rows=3},{id=174842573,rows=5},},nFrames=67,fWidth=62,fHeight=68,framesPerRow=9},
				["Larvitar"]={sheets={{id=174842573,startPixelY=345,rows=3},},nFrames=35,fWidth=46,fHeight=65,framesPerRow=12},
				["Latias"]={sheets={{id=174842581,rows=8},{id=174842589,rows=8},{id=174842602,rows=2},},nFrames=87,fWidth=108,fHeight=69,framesPerRow=5},
				["Latios"]={sheets={{id=174842602,startPixelY=140,rows=5},{id=174842607,rows=6},{id=174842618,rows=6},{id=174842627,rows=5},},nFrames=87,fWidth=121,fHeight=80,framesPerRow=4},
				["Leafeon"]={sheets={{id=174842627,startPixelY=405,rows=2},{id=174842635,rows=3},},nFrames=47,fWidth=50,fHeight=73,framesPerRow=11},
				["Leavanny"]={sheets={{id=174842635,startPixelY=222,rows=3},{id=174842649,rows=1},},nFrames=44,fWidth=52,fHeight=109,framesPerRow=11},
				["Ledian"]={sheets={{id=174842649,startPixelY=110,rows=4},},nFrames=41,fWidth=46,fHeight=83,framesPerRow=12},
				["Ledyba"]={sheets={{id=174842649,startPixelY=446,rows=2},{id=174842657,rows=3},},nFrames=39,fWidth=61,fHeight=50,framesPerRow=9},
				["Lickilicky"]={sheets={{id=174842657,startPixelY=153,rows=5},{id=174842664,rows=1},},nFrames=44,fWidth=69,fHeight=79,framesPerRow=8},
				["Lickitung"]={sheets={{id=174842664,startPixelY=80,rows=3},},nFrames=23,fWidth=58,fHeight=59,framesPerRow=9},
				["Liepard"]={sheets={{id=174842664,startPixelY=260,rows=2},{id=174842682,rows=3},},nFrames=39,fWidth=60,fHeight=109,framesPerRow=9},
				["Lileep"]={sheets={{id=174842682,startPixelY=330,rows=3},{id=174842691,rows=8},{id=174842702,rows=4},},nFrames=99,fWidth=74,fHeight=68,framesPerRow=7},
				["Lilligant"]={sheets={{id=174842702,startPixelY=276,rows=3},{id=174842712,rows=4},},nFrames=49,fWidth=67,fHeight=89,framesPerRow=8},
				["Lillipup"]={sheets={{id=174842712,startPixelY=360,rows=2},},nFrames=21,fWidth=41,fHeight=55,framesPerRow=13},
				["Linoone"]={sheets={{id=174842712,startPixelY=472,rows=2},{id=174842731,rows=7},},nFrames=50,fWidth=96,fHeight=39,framesPerRow=6},
				["Litleo"]={sheets={{id=174842731,startPixelY=280,rows=4},},nFrames=39,fWidth=51,fHeight=61,framesPerRow=11},
				["Litwick"]={sheets={{id=174842744,rows=5},},nFrames=59,fWidth=43,fHeight=68,framesPerRow=13},
				["Lombre"]={sheets={{id=174842744,startPixelY=345,rows=3},{id=174842755,rows=4},},nFrames=59,fWidth=62,fHeight=62,framesPerRow=9},
				["Lopunny"]={sheets={{id=174842755,startPixelY=252,rows=3},{id=174842767,rows=2},},nFrames=49,fWidth=57,fHeight=87,framesPerRow=10},
				["Lotad"]={sheets={{id=174842767,startPixelY=176,rows=3},},nFrames=19,fWidth=58,fHeight=31,framesPerRow=9},
				["Loudred"]={sheets={{id=174842767,startPixelY=272,rows=3},{id=174842774,rows=7},},nFrames=56,fWidth=93,fHeight=78,framesPerRow=6},
				["Lucario"]={sheets={{id=174842787,rows=5},{id=174842792,rows=1},},nFrames=59,fWidth=52,fHeight=96,framesPerRow=11},
				["Ludicolo"]={sheets={{id=174842792,startPixelY=97,rows=5},{id=174842802,rows=6},{id=174842811,rows=1},},nFrames=59,fWidth=110,fHeight=90,framesPerRow=5},
				["Lugia"]={sheets={{id=174842811,startPixelY=91,rows=3},{id=174842817,rows=4},{id=174842826,rows=4},{id=174842836,rows=4},{id=174842844,rows=4},{id=174842853,rows=4},{id=174842859,rows=1},},nFrames=70,fWidth=156,fHeight=127,framesPerRow=3},
				["Lumineon"]={sheets={{id=174842859,startPixelY=128,rows=5},{id=174842870,rows=5},},nFrames=59,fWidth=85,fHeight=84,framesPerRow=6},
				["Lunatone"]={sheets={{id=174842870,startPixelY=425,rows=2},{id=174842881,rows=6},},nFrames=89,fWidth=45,fHeight=64,framesPerRow=12},
				["Luvdisc"]={sheets={{id=174842881,startPixelY=390,rows=3},{id=174842891,rows=1},},nFrames=59,fWidth=34,fHeight=43,framesPerRow=16},
				["Luxio"]={sheets={{id=174842891,startPixelY=44,rows=6},{id=174842899,rows=1},},nFrames=49,fWidth=70,fHeight=77,framesPerRow=8},
				["Luxray"]={sheets={{id=174842899,startPixelY=78,rows=4},{id=174842910,rows=5},{id=174842920,rows=1},},nFrames=59,fWidth=87,fHeight=99,framesPerRow=6},
				["Machamp"]={sheets={{id=174842920,startPixelY=100,rows=4},{id=174842924,rows=3},},nFrames=40,fWidth=84,fHeight=100,framesPerRow=6},
				["Machoke"]={sheets={{id=174842924,startPixelY=303,rows=2},{id=174842940,rows=2},},nFrames=32,fWidth=72,fHeight=87,framesPerRow=8},
				["Machop"]={sheets={{id=174842940,startPixelY=176,rows=3},},nFrames=30,fWidth=39,fHeight=63,framesPerRow=14},
				["Magby"]={sheets={{id=174842940,startPixelY=368,rows=3},},nFrames=32,fWidth=46,fHeight=62,framesPerRow=12},
				["Magcargo"]={sheets={{id=174842951,rows=7},{id=174842966,rows=1},},nFrames=60,fWidth=67,fHeight=70,framesPerRow=8},
				["Magikarp"]={sheets={{id=14854744576,rows=5},},nFrames=30,fWidth=58,fHeight=60,framesPerRow=6},
				--['Magikarp-OrangeTwoTone']={sheets={{id=7081470550,rows=5},},nFrames=21,fWidth=58,fHeight=61,framesPerRow=5}, -- 59 x 62
				--['Magikarp-OrangeOrca']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Magikarp-OrangeDapples']={sheets={{id=7081507752,rows=5},},nFrames=21,fWidth=58,fHeight=59,framesPerRow=5}, -- 59 x 60
				--['Magikarp-PinkTwoTone']={sheets={{id=7077471899,rows=6},},nFrames=34,fWidth=58,fHeight=61,framesPerRow=6}, -- 59 x 62
				--['Magikarp-PinkOrca']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Magikarp-PinkDapples']={sheets={{id=7077453908,rows=5},},nFrames=22,fWidth=58,fHeight=60,framesPerRow=5}, -- 59 x 61
				--['Magikarp-PurpleBubbles']={sheets={{id=7081620038,rows=5},},nFrames=21,fWidth=58,fHeight=61,framesPerRow=5}, -- 59 x 62
				--['Magikarp-PurpleDiamonds']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Magikarp-PurplePatches']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Magikarp-CalicoOrangeGold']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Magikarp-CalicoOrangeWhite']={sheets={{id=7081737004,rows=5},},nFrames=21,fWidth=58,fHeight=61,framesPerRow=5}, -- 59 x 62
				--['Magikarp-CalicoOrangeWhiteBlack']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Magikarp-Monochrome']={sheets={{id=7081796801,rows=5},},nFrames=21,fWidth=58,fHeight=61,framesPerRow=5}, -- 59 x 62
				--['Magikarp-GrayBubbles']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Magikarp-GrayDiamonds']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Magikarp-GrayPatches']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Magikarp-Skeletal']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Magikarp-Wasp']={sheets={{id=7077256998,rows=5},},nFrames=21,fWidth=58,fHeight=61,framesPerRow=5}, -- 59 x 62
				['Magikarp-YinYang']={sheets={{id=7081911050,rows=5},},nFrames=22,fWidth=58,fHeight=60,framesPerRow=5}, -- 59 x 61
				--['Magikarp-Manga']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Magikarp-Fuchsia']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				--['Magikarp-Goldeen']={sheets={{id=7081978197,rows=5},},nFrames=21,fWidth=58,fHeight=61,framesPerRow=5}, -- 59 x 62
				['Magikarp-Seaking']={sheets={{id=7082005194,rows=5},},nFrames=22,fWidth=58,fHeight=61,framesPerRow=5}, -- 59 x 62
				['Magikarp-Gyarados']={sheets={{id=7082007256,rows=5},},nFrames=22,fWidth=58,fHeight=60,framesPerRow=5}, -- 59 x 61
				--['Magikarp-Feebas']={sheets={{id=,rows=},},nFrames=,fWidth=,fHeight=,framesPerRow=}, -- 00 x 00
				['Magikarp-Relicanth']={sheets={{id=7082197675,rows=4},},nFrames=20,fWidth=58,fHeight=61,framesPerRow=5}, -- 59 x 62
				['Magikarp-Rayquaza']={sheets={{id=7076869968,rows=8},},nFrames=50,fWidth=56,fHeight=58,framesPerRow=7}, -- 57 x 59

				["Magmar"]={sheets={{id=174842966,startPixelY=315,rows=2},{id=174842972,rows=6},{id=174842981,rows=1},},nFrames=60,fWidth=78,fHeight=81,framesPerRow=7},
				["Magmortar"]={sheets={{id=174842981,startPixelY=82,rows=5},{id=174842990,rows=6},{id=174843005,rows=1},},nFrames=59,fWidth=102,fHeight=89,framesPerRow=5},
				["Magnemite"]={sheets={{id=174843005,startPixelY=90,rows=4},},nFrames=35,fWidth=49,fHeight=35,framesPerRow=11,inAir=1.5},
				["Magneton"]={sheets={{id=174843005,startPixelY=234,rows=4},{id=174843017,rows=6},},nFrames=60,fWidth=89,fHeight=69,framesPerRow=6,inAir=.85},
				["Magnezone"]={sheets={{id=174843017,startPixelY=420,rows=1},{id=174843024,rows=7},{id=174843042,rows=7},{id=174843055,rows=1},},nFrames=79,fWidth=109,fHeight=73,framesPerRow=5,inAir=.85},
				["Makuhita"]={sheets={{id=174843055,startPixelY=74,rows=4},},nFrames=31,fWidth=70,fHeight=66,framesPerRow=8},
				["Malamar"]={sheets={{id=174843055,startPixelY=342,rows=2},{id=174843064,rows=5},{id=174843077,rows=5},{id=174843088,rows=5},{id=174843094,rows=5},{id=174843105,rows=1},},nFrames=89,fWidth=130,fHeight=105,framesPerRow=4},
				["Mamoswine"]={sheets={{id=174843105,startPixelY=106,rows=5},{id=174843114,rows=6},{id=174843121,rows=5},},nFrames=79,fWidth=104,fHeight=84,framesPerRow=5},
				["Manaphy"]={sheets={{id=174843121,startPixelY=425,rows=2},{id=174843135,rows=3},},nFrames=39,fWidth=65,fHeight=55,framesPerRow=8},
				["Mandibuzz"]={sheets={{id=174843135,startPixelY=168,rows=3},{id=174843140,rows=4},{id=174843151,rows=4},{id=174843158,rows=4},{id=174843170,rows=4},{id=174843178,rows=4},},nFrames=69,fWidth=150,fHeight=126,framesPerRow=3,inAir=.2},
				["Manectric"]={sheets={{id=174843190,rows=6},},nFrames=49,fWidth=63,fHeight=80,framesPerRow=9},
				["Mankey"]={sheets={{id=174843190,startPixelY=486,rows=1},{id=174843202,rows=2},},nFrames=28,fWidth=52,fHeight=56,framesPerRow=11},
				["Mantine"]={sheets={{id=174843202,startPixelY=114,rows=7},{id=174843209,rows=9},{id=174843212,rows=4},},nFrames=80,fWidth=131,fHeight=59,framesPerRow=4,inAir=1},
				["Mantyke"]={sheets={{id=174843212,startPixelY=240,rows=7},{id=174843232,rows=3},},nFrames=79,fWidth=69,fHeight=44,framesPerRow=8},
				["Maractus"]={sheets={{id=174843232,startPixelY=135,rows=5},{id=174843240,rows=2},},nFrames=49,fWidth=80,fHeight=84,framesPerRow=7},
				["Mareep"]={sheets={{id=174843240,startPixelY=170,rows=7},},nFrames=75,fWidth=52,fHeight=54,framesPerRow=11},
				["Marill"]={sheets={{id=174843248,rows=5},},nFrames=54,fWidth=51,fHeight=48,framesPerRow=11},
				["Marowak"]={sheets={{id=174843248,startPixelY=245,rows=4},},nFrames=42,fWidth=47,fHeight=67,framesPerRow=12},
				["Marshtomp"]={sheets={{id=174843262,rows=6},},nFrames=51,fWidth=60,fHeight=77,framesPerRow=9},
				["Masquerain"]={sheets={{id=174843262,startPixelY=468,rows=1},{id=174843277,rows=8},},nFrames=60,fWidth=77,fHeight=58,framesPerRow=7},
				["Mawile"]={sheets={{id=174843277,startPixelY=472,rows=1},{id=174843285,rows=5},},nFrames=33,fWidth=83,fHeight=54,framesPerRow=6},
				["Medicham"]={sheets={{id=174843285,startPixelY=275,rows=3},{id=174843299,rows=6},},nFrames=79,fWidth=63,fHeight=90,framesPerRow=9},
				["Meditite"]={sheets={{id=174843308,rows=4},},nFrames=39,fWidth=52,fHeight=59,framesPerRow=11},
				["Meganium"]={sheets={{id=174843308,startPixelY=240,rows=3},{id=174843314,rows=4},},nFrames=59,fWidth=64,fHeight=93,framesPerRow=9},
				["Meloetta"]={sheets={{id=174843314,startPixelY=376,rows=2},{id=174843324,rows=1},},nFrames=39,fWidth=37,fHeight=71,framesPerRow=15},
				["Meowstic"]={sheets={{id=174843324,startPixelY=72,rows=5},},nFrames=47,fWidth=55,fHeight=72,framesPerRow=10},
				["Meowth"]={sheets={{id=174843324,startPixelY=437,rows=1},{id=174843334,rows=3},},nFrames=42,fWidth=49,fHeight=61,framesPerRow=11},
				["Mesprit"]={sheets={{id=174843334,startPixelY=186,rows=4},{id=174843341,rows=4},},nFrames=59,fWidth=72,fHeight=78,framesPerRow=8},
				["Metagross"]={sheets={{id=174843341,startPixelY=316,rows=3},{id=174843350,rows=7},{id=174843360,rows=7},{id=174843366,rows=3},},nFrames=79,fWidth=142,fHeight=73,framesPerRow=4},
				["Metang"]={sheets={{id=174843366,startPixelY=222,rows=4},{id=174843372,rows=8},},nFrames=59,fWidth=105,fHeight=69,framesPerRow=5,inAir=.4},
				["Metapod"]={sheets={{id=174843379,rows=5},},nFrames=60,fWidth=42,fHeight=54,framesPerRow=13},
				["Mew"]={sheets={{id=174843379,startPixelY=275,rows=4},},nFrames=50,fWidth=40,fHeight=51,framesPerRow=14,inAir=1.5},
				["Mewtwo"]={sheets={{id=174843386,rows=6},{id=174843396,rows=6},{id=174843407,rows=6},},nFrames=90,fWidth=100,fHeight=88,framesPerRow=5},
				["Mienfoo"]={sheets={{id=174843414,rows=7},},nFrames=59,fWidth=58,fHeight=67,framesPerRow=9},
				["Mienshao"]={sheets={{id=174843419,rows=5},{id=174843426,rows=5},{id=174843430,rows=2},},nFrames=59,fWidth=105,fHeight=96,framesPerRow=5},
				["Mightyena"]={sheets={{id=174843430,startPixelY=194,rows=4},{id=174843443,rows=3},},nFrames=49,fWidth=73,fHeight=79,framesPerRow=7},
				["Milotic"]={sheets={{id=174843443,startPixelY=240,rows=3},{id=174843451,rows=5},{id=174843459,rows=5},},nFrames=63,fWidth=98,fHeight=94,framesPerRow=5},
				["Miltank"]={sheets={{id=174843459,startPixelY=475,rows=1},{id=174843464,rows=7},{id=174843473,rows=1},},nFrames=60,fWidth=80,fHeight=76,framesPerRow=7},
				["Mime Jr."]={sheets={{id=174843473,startPixelY=77,rows=3},},nFrames=31,fWidth=49,fHeight=63,framesPerRow=11},
				["Minccino"]={sheets={{id=174843473,startPixelY=269,rows=4},{id=174843483,rows=1},},nFrames=39,fWidth=72,fHeight=61,framesPerRow=8},
				["Minun"]={sheets={{id=174843483,startPixelY=62,rows=5},},nFrames=40,fWidth=67,fHeight=59,framesPerRow=8},
				["Misdreavus"]={sheets={{id=174843483,startPixelY=362,rows=3},{id=174843487,rows=4},},nFrames=50,fWidth=66,fHeight=63,framesPerRow=8,inAir=.5},
				["Mismagius"]={sheets={{id=174843487,startPixelY=256,rows=2},{id=174843494,rows=4},{id=174843503,rows=2},},nFrames=59,fWidth=71,fHeight=116,framesPerRow=8},
				["Moltres"]={sheets={{id=174843503,startPixelY=234,rows=1},{id=174843510,rows=3},{id=174843519,rows=3},{id=174843526,rows=3},{id=174843542,rows=3},{id=174843550,rows=3},{id=174843562,rows=3},{id=174843570,rows=3},{id=174843577,rows=1},},nFrames=46,fWidth=217,fHeight=181,framesPerRow=2},
				["Monferno"]={sheets={{id=174843577,startPixelY=182,rows=3},},nFrames=29,fWidth=57,fHeight=91,framesPerRow=10},
				["Mothim"]={sheets={{id=174843577,startPixelY=458,rows=1},{id=174843586,rows=6},{id=174843597,rows=6},{id=174843602,rows=1},},nFrames=42,fWidth=150,fHeight=86,framesPerRow=3},
				["Mr. Mime"]={sheets={{id=174843602,startPixelY=87,rows=6},{id=174843618,rows=5},},nFrames=75,fWidth=75,fHeight=76,framesPerRow=7},
				["Mudkip"]={sheets={{id=174843618,startPixelY=385,rows=2},{id=174843624,rows=3},},nFrames=50,fWidth=47,fHeight=66,framesPerRow=12},
				["Muk"]={sheets={{id=174843624,startPixelY=201,rows=4},{id=174843631,rows=7},{id=174843640,rows=7},{id=174843648,rows=2},},nFrames=80,fWidth=137,fHeight=79,framesPerRow=4},
				["Munchlax"]={sheets={{id=174843648,startPixelY=160,rows=5},},nFrames=60,fWidth=47,fHeight=59,framesPerRow=12},
				["Munna"]={sheets={{id=174843648,startPixelY=460,rows=1},{id=174843658,rows=4},},nFrames=59,fWidth=46,fHeight=54,framesPerRow=12},
				["Murkrow"]={sheets={{id=174843658,startPixelY=220,rows=5},},nFrames=39,fWidth=58,fHeight=65,framesPerRow=9},
				["Musharna"]={sheets={{id=11042222706,rows=8}},nFrames=79,fWidth=94,fHeight=111,framesPerRow=10},
				["Natu"]={sheets={{id=174843701,startPixelY=226,rows=3},},nFrames=38,fWidth=42,fHeight=48,framesPerRow=13},
				["Nidoking"]={sheets={{id=174843701,startPixelY=373,rows=2},{id=174843706,rows=6},{id=174843717,rows=1},},nFrames=42,fWidth=105,fHeight=83,framesPerRow=5},
				["Nidoqueen"]={sheets={{id=174843717,startPixelY=84,rows=5},{id=174843728,rows=1},},nFrames=50,fWidth=64,fHeight=82,framesPerRow=9},
				["Nidoran[F]"]={sheets={{id=174843728,startPixelY=83,rows=5},},nFrames=64,fWidth=43,fHeight=41,framesPerRow=13},
				["Nidoran[M]"]={sheets={{id=174843728,startPixelY=293,rows=5},},nFrames=50,fWidth=52,fHeight=52,framesPerRow=11},
				["Nidorina"]={sheets={{id=174843744,rows=4},},nFrames=40,fWidth=41,fHeight=56,framesPerRow=13},
				["Nidorino"]={sheets={{id=174843744,startPixelY=228,rows=5},{id=174843747,rows=1},},nFrames=50,fWidth=60,fHeight=56,framesPerRow=9},
				["Nincada"]={sheets={{id=174843747,startPixelY=57,rows=4},},nFrames=40,fWidth=57,fHeight=30,framesPerRow=10},
				["Ninetales"]={sheets={{id=174843747,startPixelY=181,rows=4},{id=174843756,rows=5},},nFrames=59,fWidth=79,fHeight=77,framesPerRow=7},
				["Ninjask"]={sheets={{id=174843756,startPixelY=390,rows=2},{id=174843763,rows=7},},nFrames=50,fWidth=91,fHeight=69,framesPerRow=6},
				["Noctowl"]={sheets={{id=174843767,rows=6},},nFrames=30,fWidth=111,fHeight=84,framesPerRow=5},
				["Noibat"]={sheets={{id=174843783,rows=5},{id=174843790,rows=4},},nFrames=49,fWidth=85,fHeight=96,framesPerRow=6,inAir=.8},
				["Noivern"]={sheets={{id=174843790,startPixelY=388,rows=1},{id=174843796,rows=3},{id=174843808,rows=3},{id=174843817,rows=3},{id=174843829,rows=3},{id=174843836,rows=3},{id=174843839,rows=3},{id=174843845,rows=1},},nFrames=59,fWidth=184,fHeight=156,framesPerRow=3,inAir=.1},
				["Nosepass"]={sheets={{id=174843845,startPixelY=157,rows=6},{id=174843859,rows=2},},nFrames=68,fWidth=62,fHeight=58,framesPerRow=9},
				["Numel"]={sheets={{id=174843859,startPixelY=118,rows=6},},nFrames=59,fWidth=52,fHeight=56,framesPerRow=11},
				["Nuzleaf"]={sheets={{id=174843859,startPixelY=460,rows=1},{id=174843865,rows=3},},nFrames=29,fWidth=63,fHeight=69,framesPerRow=9},
				["Octillery"]={sheets={{id=174843865,startPixelY=210,rows=5},{id=174843873,rows=5},},nFrames=59,fWidth=90,fHeight=60,framesPerRow=6},
				["Oddish"]={sheets={{id=174843873,startPixelY=305,rows=5},},nFrames=50,fWidth=52,fHeight=48,framesPerRow=11},
				["Omanyte"]={sheets={{id=174843890,rows=7},},nFrames=80,fWidth=44,fHeight=45,framesPerRow=13},
				["Omastar"]={sheets={{id=174843890,startPixelY=322,rows=3},{id=174843895,rows=8},{id=174843910,rows=1},},nFrames=80,fWidth=73,fHeight=64,framesPerRow=7},
				["Onix"]={sheets={{id=174843910,startPixelY=65,rows=4},{id=174843919,rows=4},{id=174843934,rows=3},},nFrames=61,fWidth=90,fHeight=115,framesPerRow=6},
				["Oshawott"]={sheets={{id=174843934,startPixelY=348,rows=2},},nFrames=25,fWidth=41,fHeight=49,framesPerRow=13},
				["Pachirisu"]={sheets={{id=174843934,startPixelY=448,rows=1},{id=174843941,rows=4},},nFrames=49,fWidth=57,fHeight=75,framesPerRow=10},
				["Palkia"]={sheets={{id=174843941,startPixelY=304,rows=2},{id=174843953,rows=5},{id=174843966,rows=5},{id=174843976,rows=4},},nFrames=79,fWidth=107,fHeight=107,framesPerRow=5},
				["Palpitoad"]={sheets={{id=174843976,startPixelY=432,rows=1},{id=174843985,rows=4},},nFrames=55,fWidth=49,fHeight=66,framesPerRow=11},
				["Pancham"]={sheets={{id=174843985,startPixelY=268,rows=4},{id=174843995,rows=1},},nFrames=49,fWidth=47,fHeight=64,framesPerRow=12},
				["Pangoro"]={sheets={{id=174843995,startPixelY=65,rows=4},{id=174844007,rows=5},{id=174844015,rows=3},},nFrames=59,fWidth=97,fHeight=102,framesPerRow=5},
				["Panpour"]={sheets={{id=174844015,startPixelY=309,rows=3},{id=174844029,rows=1},},nFrames=32,fWidth=59,fHeight=64,framesPerRow=9},
				["Pansage"]={sheets={{id=174844029,startPixelY=65,rows=5},},nFrames=36,fWidth=65,fHeight=66,framesPerRow=8},
				["Pansear"]={sheets={{id=174844029,startPixelY=400,rows=2},{id=174844035,rows=3},},nFrames=40,fWidth=65,fHeight=63,framesPerRow=8},
				["Paras"]={sheets={{id=174844035,startPixelY=192,rows=4},},nFrames=40,fWidth=52,fHeight=34,framesPerRow=11},
				["Parasect"]={sheets={{id=174844035,startPixelY=332,rows=3},{id=174844047,rows=6},},nFrames=60,fWidth=77,fHeight=62,framesPerRow=7},
				["Patrat"]={sheets={{id=174844047,startPixelY=378,rows=3},},nFrames=29,fWidth=46,fHeight=55,framesPerRow=12},
				["Pawniard"]={sheets={{id=174844053,rows=2},},nFrames=23,fWidth=46,fHeight=68,framesPerRow=12},
				["Pelipper"]={sheets={{id=174844053,startPixelY=138,rows=4},{id=174844060,rows=2},},nFrames=29,fWidth=101,fHeight=92,framesPerRow=5},
				["Persian"]={sheets={{id=174844060,startPixelY=186,rows=5},{id=174844069,rows=1},},nFrames=50,fWidth=61,fHeight=70,framesPerRow=9},
				["Petilil"]={sheets={{id=174844069,startPixelY=71,rows=3},},nFrames=38,fWidth=42,fHeight=69,framesPerRow=13},
				["Phanpy"]={sheets={{id=174844069,startPixelY=281,rows=5},{id=174844077,rows=2},},nFrames=52,fWidth=67,fHeight=50,framesPerRow=8},
				["Phantump"]={sheets={{id=174844077,startPixelY=102,rows=7},{id=174844086,rows=6},},nFrames=99,fWidth=67,fHeight=60,framesPerRow=8},
				["Phione"]={sheets={{id=174844086,startPixelY=366,rows=3},{id=174844104,rows=7},},nFrames=79,fWidth=65,fHeight=56,framesPerRow=8},
				["Pichu"]={sheets={{id=174844104,startPixelY=399,rows=3},{id=174844117,rows=2},},nFrames=47,fWidth=51,fHeight=52,framesPerRow=11},
				["Pidgeot"]={sheets={{id=174844117,startPixelY=106,rows=3},{id=174844126,rows=4},{id=174844131,rows=4},{id=174844140,rows=3},},nFrames=53,fWidth=124,fHeight=124,framesPerRow=4,inAir=.7},
				["Pidgeotto"]={sheets={{id=174844140,startPixelY=375,rows=2},{id=174844149,rows=2},},nFrames=20,fWidth=115,fHeight=86,framesPerRow=5,inAir=1},
				["Pidgey"]={sheets={{id=174844149,startPixelY=174,rows=2},},nFrames=24,fWidth=36,fHeight=49,framesPerRow=15},
				["Pidove"]={sheets={{id=174844149,startPixelY=274,rows=4},},nFrames=44,fWidth=41,fHeight=49,framesPerRow=13},
				["Pignite"]={sheets={{id=174844149,startPixelY=474,rows=1},{id=174844164,rows=5},},nFrames=39,fWidth=73,fHeight=78,framesPerRow=7},
				["Pikachu"]={sheets={{id=174844164,startPixelY=395,rows=2},{id=174844176,rows=2},},nFrames=33,fWidth=60,fHeight=60,framesPerRow=9},
				["Piloswine"]={sheets={{id=174844176,startPixelY=122,rows=6},{id=174844187,rows=2},},nFrames=59,fWidth=70,fHeight=72,framesPerRow=8},
				["Pineco"]={sheets={{id=174844187,startPixelY=146,rows=6},},nFrames=53,fWidth=56,fHeight=59,framesPerRow=10},
				["Pinsir"]={sheets={{id=174844194,rows=7},},nFrames=40,fWidth=92,fHeight=76,framesPerRow=6},
				["Piplup"]={sheets={{id=174844203,rows=4},},nFrames=39,fWidth=54,fHeight=59,framesPerRow=10},
				["Plusle"]={sheets={{id=174844203,startPixelY=240,rows=5},},nFrames=40,fWidth=67,fHeight=59,framesPerRow=8},
				["Politoed"]={sheets={{id=174844212,rows=7},},nFrames=59,fWidth=63,fHeight=77,framesPerRow=9},
				["Poliwag"]={sheets={{id=174844224,rows=5},},nFrames=45,fWidth=55,fHeight=40,framesPerRow=10},
				["Poliwhirl"]={sheets={{id=174844224,startPixelY=205,rows=6},},nFrames=40,fWidth=73,fHeight=50,framesPerRow=7},
				["Poliwrath"]={sheets={{id=174844235,rows=6},},nFrames=37,fWidth=73,fHeight=63,framesPerRow=7},
				["Ponyta"]={sheets={{id=174844235,startPixelY=384,rows=2},{id=174844247,rows=7},},nFrames=99,fWidth=51,fHeight=68,framesPerRow=11},
				["Poochyena"]={sheets={{id=174844247,startPixelY=483,rows=1},{id=174844256,rows=3},},nFrames=34,fWidth=52,fHeight=54,framesPerRow=11},
				["Porygon-Z"]={sheets={{id=174844256,startPixelY=165,rows=5},{id=174844262,rows=5},},nFrames=79,fWidth=70,fHeight=68,framesPerRow=8},
				["Porygon"]={sheets={{id=174844262,startPixelY=345,rows=3},{id=174844280,rows=1},},nFrames=48,fWidth=47,fHeight=53,framesPerRow=12},
				["Porygon2"]={sheets={{id=174844280,startPixelY=54,rows=7},{id=174844289,rows=1},},nFrames=80,fWidth=54,fHeight=63,framesPerRow=10},
				["Primeape"]={sheets={{id=174844289,startPixelY=64,rows=5},},nFrames=40,fWidth=71,fHeight=65,framesPerRow=8},
				["Prinplup"]={sheets={{id=174844289,startPixelY=394,rows=2},{id=174844304,rows=5},},nFrames=44,fWidth=77,fHeight=75,framesPerRow=7},
				["Probopass"]={sheets={{id=174844304,startPixelY=380,rows=2},{id=174844321,rows=6},{id=174844338,rows=2},},nFrames=59,fWidth=94,fHeight=81,framesPerRow=6},
				["Psyduck"]={sheets={{id=174844338,startPixelY=164,rows=5},},nFrames=49,fWidth=51,fHeight=53,framesPerRow=11},
				["Pumpkaboo"]={sheets={{id=174844338,startPixelY=434,rows=2},{id=174844352,rows=9},{id=174844365,rows=1},},nFrames=119,fWidth=56,fHeight=59,framesPerRow=10},
				["Pupitar"]={sheets={{id=174844365,startPixelY=60,rows=7},},nFrames=70,fWidth=55,fHeight=68,framesPerRow=10},
				["Purrloin"]={sheets={{id=174844376,rows=7},},nFrames=55,fWidth=59,fHeight=70,framesPerRow=9},
				["Purugly"]={sheets={{id=174844384,rows=6},{id=174844397,rows=4},},nFrames=79,fWidth=70,fHeight=81,framesPerRow=8},
				["Pyroar"]={sheets={{id=174844397,startPixelY=328,rows=2},{id=174844411,rows=5},{id=174844419,rows=2},},nFrames=59,fWidth=79,fHeight=99,framesPerRow=7},
				["Quagsire"]={sheets={{id=174844419,startPixelY=200,rows=4},{id=174844426,rows=3},},nFrames=69,fWidth=48,fHeight=77,framesPerRow=11},
				["Quilava"]={sheets={{id=174844426,startPixelY=234,rows=5},},nFrames=50,fWidth=52,fHeight=42,framesPerRow=11},
				["Quilladin"]={sheets={{id=174844426,startPixelY=449,rows=1},{id=174844440,rows=5},},nFrames=39,fWidth=73,fHeight=68,framesPerRow=7},
				["Qwilfish"]={sheets={{id=174844440,startPixelY=345,rows=4},{id=174844446,rows=4},},nFrames=72,fWidth=61,fHeight=50,framesPerRow=9},
				["Raichu"]={sheets={{id=174844446,startPixelY=204,rows=3},{id=174844463,rows=1},},nFrames=29,fWidth=69,fHeight=103,framesPerRow=8},
				["Raikou"]={sheets={{id=174844463,startPixelY=104,rows=5},{id=174844477,rows=3},},nFrames=60,fWidth=68,fHeight=82,framesPerRow=8},
				["Ralts"]={sheets={{id=174844477,startPixelY=249,rows=4},},nFrames=60,fWidth=32,fHeight=52,framesPerRow=17},
				["Rampardos"]={sheets={{id=174844477,startPixelY=461,rows=1},{id=174844489,rows=6},{id=174844499,rows=2},},nFrames=59,fWidth=75,fHeight=89,framesPerRow=7},
				["Rapidash"]={sheets={{id=174844499,startPixelY=180,rows=3},{id=174844511,rows=5},{id=174844523,rows=5},},nFrames=78,fWidth=91,fHeight=95,framesPerRow=6},
				["Raticate"]={sheets={{id=174844523,startPixelY=480,rows=1},{id=174844529,rows=7},},nFrames=61,fWidth=68,fHeight=64,framesPerRow=8},
				["Rattata"]={sheets={{id=174844529,startPixelY=455,rows=1},{id=174844538,rows=1},},nFrames=25,fWidth=43,fHeight=61,framesPerRow=13},
				["Rayquaza"]={sheets={{id=174844538,startPixelY=62,rows=3},{id=174844549,rows=3},{id=174844557,rows=3},{id=174844572,rows=3},{id=174844582,rows=3},{id=174844598,rows=3},{id=174844612,rows=3},{id=174844624,rows=3},},nFrames=95,fWidth=142,fHeight=153,framesPerRow=4,inAir=0.4},
				["Regice"]={sheets={{id=174844624,startPixelY=462,rows=1},{id=174844642,rows=6},{id=174844649,rows=6},{id=174844658,rows=3},},nFrames=79,fWidth=107,fHeight=82,framesPerRow=5},
				["Regigigas"]={sheets={{id=174844658,startPixelY=249,rows=3},{id=174844666,rows=5},{id=174844674,rows=5},{id=174844684,rows=5},{id=174844690,rows=5},{id=174844703,rows=4},},nFrames=79,fWidth=166,fHeight=96,framesPerRow=3},
				["Regirock"]={sheets={{id=174844703,startPixelY=388,rows=2},{id=174844709,rows=6},{id=174844713,rows=4},},nFrames=69,fWidth=92,fHeight=83,framesPerRow=6},
				["Registeel"]={sheets={{id=174844713,startPixelY=336,rows=2},{id=174844722,rows=7},{id=174844733,rows=7},{id=174844743,rows=2},},nFrames=69,fWidth=123,fHeight=77,framesPerRow=4},
				["Relicanth"]={sheets={{id=174844743,startPixelY=156,rows=5},{id=174844750,rows=5},},nFrames=79,fWidth=69,fHeight=68,framesPerRow=8,inAir=.6},
				["Remoraid"]={sheets={{id=174844750,startPixelY=345,rows=3},{id=174844761,rows=3},},nFrames=60,fWidth=57,fHeight=62,framesPerRow=10},
				["Reshiram"]={sheets={{id=174844761,startPixelY=189,rows=3},{id=174844773,rows=4},{id=174844785,rows=4},{id=174844793,rows=4},{id=174844798,rows=4},{id=174844807,rows=4},},nFrames=69,fWidth=163,fHeight=115,framesPerRow=3},
				["Reuniclus"]={sheets={{id=174844807,startPixelY=464,rows=1},{id=174844813,rows=7},{id=174844823,rows=7},{id=174844831,rows=5},},nFrames=59,fWidth=160,fHeight=75,framesPerRow=3,inAir=.6},
				["Rhydon"]={sheets={{id=174844831,startPixelY=380,rows=2},{id=174844835,rows=6},},nFrames=47,fWidth=96,fHeight=82,framesPerRow=6},
				["Rhyhorn"]={sheets={{id=174844835,startPixelY=498,rows=1},{id=174844840,rows=8},},nFrames=71,fWidth=66,fHeight=57,framesPerRow=8},
				["Rhyperior"]={sheets={{id=174844840,startPixelY=464,rows=1},{id=174844851,rows=5},{id=174844858,rows=5},{id=174844921,rows=1},},nFrames=59,fWidth=105,fHeight=94,framesPerRow=5},
				["Riolu"]={sheets={{id=174844921,startPixelY=95,rows=3},},nFrames=30,fWidth=42,fHeight=61,framesPerRow=13},
				["Roggenrola"]={sheets={{id=174844921,startPixelY=281,rows=4},{id=174844928,rows=1},},nFrames=49,fWidth=46,fHeight=60,framesPerRow=12},
				["Roselia"]={sheets={{id=174844928,startPixelY=61,rows=8},{id=174844948,rows=1},},nFrames=71,fWidth=71,fHeight=58,framesPerRow=8},
				["Roserade"]={sheets={{id=174844948,startPixelY=59,rows=4},},nFrames=39,fWidth=54,fHeight=78,framesPerRow=10},
				["Rotom"]={sheets={{id=174844948,startPixelY=375,rows=2},{id=174845001,rows=7},{id=174845011,rows=3},},nFrames=59,fWidth=105,fHeight=70,framesPerRow=5},
				["Rufflet"]={sheets={{id=174845011,startPixelY=213,rows=3},},nFrames=31,fWidth=45,fHeight=65,framesPerRow=12},
				["Sableye"]={sheets={{id=174845011,startPixelY=411,rows=2},{id=174845013,rows=2},},nFrames=43,fWidth=49,fHeight=64,framesPerRow=11},
				["Salamence"]={sheets={{id=174845013,startPixelY=130,rows=4},{id=174845016,rows=6},{id=174845023,rows=5},},nFrames=59,fWidth=137,fHeight=92,framesPerRow=4,inAir=.7},
				["Samurott"]={sheets={{id=174845032,rows=5},{id=174845039,rows=5},{id=174845045,rows=2},},nFrames=59,fWidth=103,fHeight=108,framesPerRow=5},
				["Sandile"]={sheets={{id=174845045,startPixelY=218,rows=6},},nFrames=49,fWidth=63,fHeight=47,framesPerRow=9},
				["Sandshrew"]={sheets={{id=174845045,startPixelY=506,rows=1},{id=174845054,rows=2},},nFrames=30,fWidth=45,fHeight=47,framesPerRow=12},
				["Sandslash"]={sheets={{id=174845054,startPixelY=96,rows=6},},nFrames=48,fWidth=61,fHeight=68,framesPerRow=9},
				["Sawk"]={sheets={{id=174845061,rows=6},{id=174845066,rows=3},},nFrames=59,fWidth=81,fHeight=83,framesPerRow=7},
				["Sawsbuck"]={sheets={{id=174845066,startPixelY=252,rows=3},{id=174845077,rows=2},},nFrames=47,fWidth=53,fHeight=100,framesPerRow=10},
				["Scatterbug"]={sheets={{id=174845077,startPixelY=202,rows=4},},nFrames=55,fWidth=38,fHeight=56,framesPerRow=15},
				["Sceptile"]={sheets={{id=174845077,startPixelY=430,rows=1},{id=174845082,rows=5},{id=174845088,rows=4},},nFrames=49,fWidth=100,fHeight=93,framesPerRow=5},
				["Scizor"]={sheets={{id=174845088,startPixelY=376,rows=1},{id=174845098,rows=5},{id=174845105,rows=2},},nFrames=59,fWidth=67,fHeight=93,framesPerRow=8},
				["Scolipede"]={sheets={{id=174845105,startPixelY=188,rows=2},{id=174845110,rows=4},{id=174845116,rows=4},{id=174845126,rows=2},},nFrames=60,fWidth=112,fHeight=124,framesPerRow=5},
				["Scrafty"]={sheets={{id=174845126,startPixelY=250,rows=3},{id=174845133,rows=2},},nFrames=50,fWidth=56,fHeight=77,framesPerRow=10},
				["Scraggy"]={sheets={{id=174845133,startPixelY=156,rows=4},},nFrames=40,fWidth=52,fHeight=63,framesPerRow=11},
				["Seadra"]={sheets={{id=174845155,startPixelY=104,rows=6},{id=174845162,rows=2},},nFrames=60,fWidth=69,fHeight=74,framesPerRow=8},
				["Seaking"]={sheets={{id=174845162,startPixelY=150,rows=5},{id=174845170,rows=5},},nFrames=59,fWidth=85,fHeight=69,framesPerRow=6,inAir=.9},
				["Sealeo"]={sheets={{id=174845170,startPixelY=350,rows=4},{id=174845179,rows=5},},nFrames=59,fWidth=79,fHeight=50,framesPerRow=7},
				["Seedot"]={sheets={{id=174845179,startPixelY=255,rows=2},},nFrames=29,fWidth=37,fHeight=46,framesPerRow=15},
				["Seel"]={sheets={{id=174845179,startPixelY=349,rows=4},{id=174845191,rows=4},},nFrames=60,fWidth=66,fHeight=45,framesPerRow=8},
				["Seismitoad"]={sheets={{id=174845191,startPixelY=184,rows=4},{id=174845197,rows=4},},nFrames=44,fWidth=95,fHeight=90,framesPerRow=6},
				["Sentret"]={sheets={{id=174845197,startPixelY=364,rows=3},{id=174845205,rows=2},},nFrames=47,fWidth=52,fHeight=55,framesPerRow=11},
				["Serperior"]={sheets={{id=174845205,startPixelY=112,rows=4},{id=174845212,rows=5},{id=174845231,rows=5},},nFrames=79,fWidth=90,fHeight=108,framesPerRow=6},
				["Servine"]={sheets={{id=174845247,rows=5},},nFrames=44,fWidth=58,fHeight=82,framesPerRow=9},
				["Seviper"]={sheets={{id=174845247,startPixelY=415,rows=1},{id=174845257,rows=6},{id=174845262,rows=2},},nFrames=59,fWidth=73,fHeight=88,framesPerRow=7},
				["Sewaddle"]={sheets={{id=174845262,startPixelY=178,rows=5},},nFrames=59,fWidth=44,fHeight=47,framesPerRow=13},
				["Sharpedo"]={sheets={{id=174845262,startPixelY=418,rows=1},{id=174845269,rows=5},{id=174845276,rows=3},},nFrames=60,fWidth=78,fHeight=102,framesPerRow=7},
				["Shaymin"]={sheets={{id=174845276,startPixelY=309,rows=5},},nFrames=49,fWidth=48,fHeight=43,framesPerRow=11},
				["Shedinja"]={sheets={{id=174845282,rows=5},},nFrames=50,fWidth=57,fHeight=58,framesPerRow=10},
				["Shelgon"]={sheets={{id=174845282,startPixelY=295,rows=4},{id=174845291,rows=3},},nFrames=68,fWidth=57,fHeight=59,framesPerRow=10},
				["Shellder"]={sheets={{id=174845291,startPixelY=180,rows=8},},nFrames=80,fWidth=52,fHeight=37,framesPerRow=11},
				["Shellos"]={sheets={{id=174845291,startPixelY=484,rows=1},{id=174845298,rows=4},},nFrames=59,fWidth=44,fHeight=62,framesPerRow=13},
				["Shelmet"]={sheets={{id=174845298,startPixelY=252,rows=6},{id=174845305,rows=1},},nFrames=59,fWidth=59,fHeight=49,framesPerRow=9},
				["Shieldon"]={sheets={{id=174845305,startPixelY=50,rows=5},},nFrames=59,fWidth=46,fHeight=55,framesPerRow=12},
				["Shiftry"]={sheets={{id=174845305,startPixelY=330,rows=2},{id=174845320,rows=7},{id=174845329,rows=6},},nFrames=44,fWidth=156,fHeight=78,framesPerRow=3},
				["Shinx"]={sheets={{id=174845329,startPixelY=474,rows=1},{id=174845341,rows=4},},nFrames=39,fWidth=62,fHeight=59,framesPerRow=9},
				["Shroomish"]={sheets={{id=174845341,startPixelY=240,rows=5},},nFrames=49,fWidth=51,fHeight=36,framesPerRow=11},
				["Shuckle"]={sheets={{id=174845341,startPixelY=425,rows=2},{id=174845347,rows=6},},nFrames=60,fWidth=71,fHeight=57,framesPerRow=8},
				["Shuppet"]={sheets={{id=174845347,startPixelY=348,rows=3},{id=174845354,rows=1},},nFrames=59,fWidth=37,fHeight=63,framesPerRow=15,inAir=.5},
				['Sigilyph']={sheets={{id=611077436,startPixelY=425,rows=5},{id=611080790,rows=5},},nFrames=69,fWidth=143,fHeight=117,framesPerRow=7,inAir=.5},
				["Silcoon"]={sheets={{id=174845382,startPixelY=236,rows=8},},nFrames=79,fWidth=51,fHeight=39,framesPerRow=11},
				["Simipour"]={sheets={{id=174845390,rows=6},{id=174845399,rows=2},},nFrames=50,fWidth=76,fHeight=83,framesPerRow=7},
				["Simisage"]={sheets={{id=174845399,startPixelY=168,rows=4},},nFrames=30,fWidth=71,fHeight=95,framesPerRow=8},
				["Simisear"]={sheets={{id=174845408,rows=6},{id=174845417,rows=4},},nFrames=66,fWidth=76,fHeight=81,framesPerRow=7},
				["Skarmory"]={sheets={{id=174845417,startPixelY=328,rows=3},{id=174845421,rows=8},{id=174845429,rows=1},},nFrames=60,fWidth=116,fHeight=64,framesPerRow=5,inAir=1.6},
				["Skiddo"]={sheets={{id=174845429,startPixelY=65,rows=6},},nFrames=59,fWidth=48,fHeight=63,framesPerRow=11},
				["Skiploom"]={sheets={{id=174845429,startPixelY=449,rows=2},{id=174845441,rows=4},},nFrames=49,fWidth=64,fHeight=41,framesPerRow=9,inAir=1},
				["Skitty"]={sheets={{id=174845441,startPixelY=168,rows=4},},nFrames=35,fWidth=59,fHeight=55,framesPerRow=9},
				["Skorupi"]={sheets={{id=174845441,startPixelY=392,rows=2},{id=174845444,rows=6},},nFrames=51,fWidth=75,fHeight=64,framesPerRow=7},
				["Skrelp"]={sheets={{id=174845444,startPixelY=390,rows=2},{id=174845452,rows=4},},nFrames=77,fWidth=43,fHeight=77,framesPerRow=13},
				["Skuntank"]={sheets={{id=174845452,startPixelY=312,rows=3},{id=174845461,rows=3},},nFrames=34,fWidth=87,fHeight=79,framesPerRow=6},
				["Slaking"]={sheets={{id=174845461,startPixelY=240,rows=4},{id=174845467,rows=7},{id=174845477,rows=7},},nFrames=89,fWidth=102,fHeight=72,framesPerRow=5},
				["Slakoth"]={sheets={{id=174845477,startPixelY=511,rows=1},{id=174845485,rows=13},},nFrames=79,fWidth=92,fHeight=31,framesPerRow=6},
				["Sliggoo"]={sheets={{id=174845485,startPixelY=416,rows=1},{id=174845487,rows=4},},nFrames=59,fWidth=42,fHeight=82,framesPerRow=13},
				["Slowbro"]={sheets={{id=174845487,startPixelY=332,rows=3},{id=174845500,rows=7},},nFrames=59,fWidth=92,fHeight=71,framesPerRow=6},
				["Slowking"]={sheets={{id=174845514,rows=6},{id=174845519,rows=1},},nFrames=60,fWidth=62,fHeight=85,framesPerRow=9},
				["Slowpoke"]={sheets={{id=174845519,startPixelY=86,rows=5},},nFrames=49,fWidth=47,fHeight=58,framesPerRow=12},
				["Slugma"]={sheets={{id=174845519,startPixelY=381,rows=2},{id=174845527,rows=5},},nFrames=60,fWidth=62,fHeight=63,framesPerRow=9},
				["Slurpuff"]={sheets={{id=174845527,startPixelY=320,rows=3},{id=174845536,rows=3},},nFrames=47,fWidth=68,fHeight=70,framesPerRow=8},
				["Smeargle"]={sheets={{id=174845536,startPixelY=213,rows=4},{id=174845542,rows=1},},nFrames=40,fWidth=58,fHeight=74,framesPerRow=9},
				["Smoochum"]={sheets={{id=174845542,startPixelY=75,rows=4},},nFrames=39,fWidth=46,fHeight=61,framesPerRow=12},
				["Sneasel"]={sheets={{id=174845542,startPixelY=323,rows=3},{id=174845549,rows=2},},nFrames=49,fWidth=47,fHeight=72,framesPerRow=12},
				["Snivy"]={sheets={{id=174845549,startPixelY=146,rows=4},},nFrames=39,fWidth=56,fHeight=55,framesPerRow=10},
				["Snorlax"]={sheets={{id=174845549,startPixelY=370,rows=2},{id=174845554,rows=6},{id=174845562,rows=5},},nFrames=75,fWidth=85,fHeight=80,framesPerRow=6},
				["Snorunt"]={sheets={{id=174845562,startPixelY=405,rows=3},{id=174845574,rows=2},},nFrames=59,fWidth=44,fHeight=47,framesPerRow=13},
				["Snover"]={sheets={{id=174845574,startPixelY=96,rows=7},{id=174845583,rows=8},},nFrames=89,fWidth=88,fHeight=61,framesPerRow=6},
				["Snubbull"]={sheets={{id=174845583,startPixelY=496,rows=1},{id=174845593,rows=6},},nFrames=50,fWidth=67,fHeight=58,framesPerRow=8},
				["Solosis"]={sheets={{id=174845593,startPixelY=354,rows=4},{id=174845604,rows=1},},nFrames=59,fWidth=45,fHeight=45,framesPerRow=12,inAir=1.2},
				["Solrock"]={sheets={{id=174845604,startPixelY=46,rows=6},{id=174845612,rows=7},{id=174845618,rows=2},},nFrames=89,fWidth=90,fHeight=79,framesPerRow=6},
				["Spearow"]={sheets={{id=174845618,startPixelY=160,rows=2},},nFrames=24,fWidth=33,fHeight=52,framesPerRow=17},
				["Spewpa"]={sheets={{id=174845618,startPixelY=266,rows=5},},nFrames=59,fWidth=44,fHeight=43,framesPerRow=13},
				["Spheal"]={sheets={{id=174845618,startPixelY=486,rows=1},{id=174845627,rows=3},},nFrames=39,fWidth=45,fHeight=42,framesPerRow=12},
				["Spinarak"]={sheets={{id=174845627,startPixelY=129,rows=4},},nFrames=40,fWidth=57,fHeight=27,framesPerRow=10},
				["Spinda"]={sheets={{id=174845627,startPixelY=241,rows=4},{id=174845638,rows=5},},nFrames=79,fWidth=61,fHeight=69,framesPerRow=9},
				["Spiritomb"]={sheets={{id=174845638,startPixelY=350,rows=2},{id=174845646,rows=7},{id=174845652,rows=7},{id=174845656,rows=2},},nFrames=124,fWidth=78,fHeight=73,framesPerRow=7},
				["Spoink"]={sheets={{id=174845656,startPixelY=148,rows=2},},nFrames=29,fWidth=35,fHeight=96,framesPerRow=16},
				["Spritzee"]={sheets={{id=174845656,startPixelY=342,rows=3},{id=174845663,rows=9},{id=174845665,rows=3},},nFrames=119,fWidth=69,fHeight=61,framesPerRow=8},
				["Squirtle"]={sheets={{id=174845665,startPixelY=186,rows=3},},nFrames=29,fWidth=53,fHeight=54,framesPerRow=10},
				["Stantler"]={sheets={{id=174845665,startPixelY=351,rows=2},{id=174845675,rows=2},},nFrames=40,fWidth=49,fHeight=92,framesPerRow=11},
				["Staraptor"]={sheets={{id=174845675,startPixelY=186,rows=2},{id=174845677,rows=3},{id=174845685,rows=3},{id=174845691,rows=2},},nFrames=29,fWidth=193,fHeight=176,framesPerRow=3},
				["Staravia"]={sheets={{id=174845691,startPixelY=354,rows=1},{id=174845696,rows=3},},nFrames=15,fWidth=135,fHeight=122,framesPerRow=4},
				["Starly"]={sheets={{id=174845696,startPixelY=369,rows=2},},nFrames=23,fWidth=35,fHeight=46,framesPerRow=16},
				["Starmie"]={sheets={{id=174845696,startPixelY=463,rows=1},{id=174845710,rows=6},},nFrames=57,fWidth=62,fHeight=61,framesPerRow=9},
				["Staryu"]={sheets={{id=174845710,startPixelY=372,rows=3},{id=174845716,rows=3},},nFrames=60,fWidth=48,fHeight=50,framesPerRow=11},
				["Steelix"]={sheets={{id=174845716,startPixelY=153,rows=3},{id=174845727,rows=5},{id=174845737,rows=5},{id=174845746,rows=1},},nFrames=79,fWidth=92,fHeight=105,framesPerRow=6},
				["Stoutland"]={sheets={{id=174845746,startPixelY=106,rows=5},{id=174845754,rows=3},},nFrames=47,fWidth=91,fHeight=88,framesPerRow=6},
				["Stunfisk"]={sheets={{id=174845754,startPixelY=267,rows=10},},nFrames=47,fWidth=98,fHeight=15,framesPerRow=5},
				["Stunky"]={sheets={{id=174845754,startPixelY=427,rows=1},{id=174845761,rows=4},},nFrames=29,fWidth=85,fHeight=66,framesPerRow=6},
				["Sudowoodo"]={sheets={{id=174845761,startPixelY=268,rows=4},{id=174845770,rows=3},},nFrames=59,fWidth=58,fHeight=66,framesPerRow=9},
				["Suicune"]={sheets={{id=174845770,startPixelY=201,rows=4},{id=174845778,rows=6},{id=174845786,rows=2},},nFrames=60,fWidth=107,fHeight=86,framesPerRow=5},
				["Sunflora"]={sheets={{id=174845786,startPixelY=174,rows=5},{id=174845793,rows=1},},nFrames=40,fWidth=73,fHeight=74,framesPerRow=7},
				["Sunkern"]={sheets={{id=174845793,startPixelY=75,rows=5},},nFrames=60,fWidth=44,fHeight=44,framesPerRow=13},
				["Surskit"]={sheets={{id=174845793,startPixelY=300,rows=4},{id=174845805,rows=6},},nFrames=70,fWidth=75,fHeight=52,framesPerRow=7},
				["Swablu"]={sheets={{id=174845805,startPixelY=318,rows=4},{id=174845812,rows=10},},nFrames=79,fWidth=93,fHeight=53,framesPerRow=6,inAir=1},
				["Swadloon"]={sheets={{id=174845818,rows=9},{id=174845831,rows=1},},nFrames=74,fWidth=70,fHeight=57,framesPerRow=8},
				["Swalot"]={sheets={{id=174845831,startPixelY=58,rows=7},{id=174845841,rows=2},},nFrames=59,fWidth=79,fHeight=70,framesPerRow=7},
				["Swampert"]={sheets={{id=174845841,startPixelY=142,rows=4},{id=174845843,rows=6},},nFrames=59,fWidth=94,fHeight=90,framesPerRow=6},
				["Swanna"]={sheets={{id=174845847,rows=3},{id=174845854,rows=3},{id=174845867,rows=2},},nFrames=24,fWidth=184,fHeight=161,framesPerRow=3},
				["Swellow"]={sheets={{id=174845867,startPixelY=324,rows=5},{id=174845877,rows=2},},nFrames=19,fWidth=166,fHeight=44,framesPerRow=3,inAir=1.7},
				["Swinub"]={sheets={{id=174845877,startPixelY=90,rows=10},},nFrames=109,fWidth=49,fHeight=33,framesPerRow=11},
				["Swirlix"]={sheets={{id=174845877,startPixelY=430,rows=2},{id=174845888,rows=2},},nFrames=47,fWidth=47,fHeight=49,framesPerRow=12},
				["Swoobat"]={sheets={{id=174845888,startPixelY=100,rows=4},{id=174845892,rows=5},{id=174845899,rows=5},{id=174845910,rows=1},},nFrames=59,fWidth=144,fHeight=107,framesPerRow=4,inAir=.2},
				["Sylveon"]={sheets={{id=174845910,startPixelY=108,rows=5},{id=174845924,rows=1},},nFrames=47,fWidth=59,fHeight=86,framesPerRow=9},
				["Taillow"]={sheets={{id=174845924,startPixelY=87,rows=4},},nFrames=39,fWidth=49,fHeight=46,framesPerRow=11},
				["Talonflame"]={sheets={{id=174845924,startPixelY=275,rows=1},{id=174845930,rows=3},{id=174845936,rows=3},{id=174845943,rows=3},{id=174845952,rows=1},},nFrames=31,fWidth=152,fHeight=185,framesPerRow=3},
				["Tangela"]={sheets={{id=174845952,startPixelY=186,rows=6},{id=174845959,rows=1},},nFrames=56,fWidth=58,fHeight=53,framesPerRow=9},
				["Tangrowth"]={sheets={{id=174845959,startPixelY=54,rows=6},{id=174845969,rows=6},{id=174845981,rows=6},},nFrames=69,fWidth=145,fHeight=82,framesPerRow=4},
				["Tauros"]={sheets={{id=174845989,rows=5},{id=174845998,rows=5},},nFrames=48,fWidth=97,fHeight=95,framesPerRow=5},
				["Teddiursa"]={sheets={{id=174845998,startPixelY=480,rows=1},{id=174846005,rows=4},},nFrames=50,fWidth=47,fHeight=57,framesPerRow=12},
				["Tentacool"]={sheets={{id=174846005,startPixelY=232,rows=4},{id=174846021,rows=1},},nFrames=60,fWidth=45,fHeight=73,framesPerRow=12},
				["Tentacruel"]={sheets={{id=174846021,startPixelY=74,rows=5},{id=174846024,rows=5},},nFrames=80,fWidth=68,fHeight=85,framesPerRow=8},
				["Tepig"]={sheets={{id=174846024,startPixelY=430,rows=2},{id=174846030,rows=2},},nFrames=39,fWidth=46,fHeight=62,framesPerRow=12},
				["Terrakion"]={sheets={{id=174846030,startPixelY=126,rows=5},{id=174846035,rows=6},{id=174846043,rows=1},},nFrames=59,fWidth=99,fHeight=84,framesPerRow=5},
				["Throh"]={sheets={{id=174846043,startPixelY=85,rows=5},{id=174846048,rows=6},{id=174846063,rows=3},},nFrames=69,fWidth=109,fHeight=88,framesPerRow=5},
				["Thundurus"]={sheets={{id=174846063,startPixelY=267,rows=2},{id=174846076,rows=5},{id=174846084,rows=5},{id=174846090,rows=2},},nFrames=79,fWidth=96,fHeight=103,framesPerRow=6,inAir=.6},
				["Timburr"]={sheets={{id=174846090,startPixelY=208,rows=4},},nFrames=35,fWidth=63,fHeight=61,framesPerRow=9},
				["Tirtouga"]={sheets={{id=174846090,startPixelY=456,rows=3},{id=174846106,rows=13},},nFrames=79,fWidth=105,fHeight=32,framesPerRow=5},
				["Togekiss"]={sheets={{id=174846106,startPixelY=429,rows=2},{id=174846115,rows=6},},nFrames=47,fWidth=93,fHeight=60,framesPerRow=6,inAir=1.1},
				["Togepi"]={sheets={{id=174846115,startPixelY=366,rows=4},},nFrames=48,fWidth=47,fHeight=47,framesPerRow=12},
				["Togetic"]={sheets={{id=174846125,rows=3},},nFrames=26,fWidth=58,fHeight=71,framesPerRow=9},
				["Torchic"]={sheets={{id=174846125,startPixelY=216,rows=4},},nFrames=61,fWidth=33,fHeight=61,framesPerRow=17},
				["Torkoal"]={sheets={{id=174846125,startPixelY=464,rows=1},{id=174846132,rows=7},{id=174846139,rows=7},{id=174846149,rows=7},{id=174846154,rows=5},},nFrames=239,fWidth=63,fHeight=77,framesPerRow=9},
				["Tornadus"]={sheets={{id=174846154,startPixelY=390,rows=1},{id=174846157,rows=5},{id=174846163,rows=5},{id=174846168,rows=1},},nFrames=79,fWidth=82,fHeight=100,framesPerRow=7,inAir=.6},
				["Torterra"]={sheets={{id=174846168,startPixelY=101,rows=4},{id=174846174,rows=5},{id=174846181,rows=3},},nFrames=59,fWidth=98,fHeight=106,framesPerRow=5},
				["Totodile"]={sheets={{id=174846181,startPixelY=321,rows=3},},nFrames=26,fWidth=52,fHeight=58,framesPerRow=11},
				["Toxicroak"]={sheets={{id=174846186,rows=3},},nFrames=15,fWidth=92,fHeight=81,framesPerRow=6},
				["Tranquill"]={sheets={{id=174846186,startPixelY=246,rows=2},{id=174846195,rows=4},},nFrames=21,fWidth=144,fHeight=124,framesPerRow=4},
				["Trapinch"]={sheets={{id=174846195,startPixelY=500,rows=1},{id=174846206,rows=8},},nFrames=79,fWidth=62,fHeight=45,framesPerRow=9},
				["Treecko"]={sheets={{id=174846206,startPixelY=368,rows=3},{id=174846214,rows=1},},nFrames=39,fWidth=47,fHeight=59,framesPerRow=12},
				["Trevenant"]={sheets={{id=174846214,startPixelY=60,rows=4},{id=174846222,rows=5},{id=174846231,rows=5},{id=174846236,rows=2},},nFrames=79,fWidth=114,fHeight=100,framesPerRow=5},
				["Tropius"]={sheets={{id=174846236,startPixelY=202,rows=4},{id=174846247,rows=7},{id=174846254,rows=7},{id=174846257,rows=7},{id=174846262,rows=7},{id=174846265,rows=7},{id=174846271,rows=7},{id=174846278,rows=7},{id=174846282,rows=7},},nFrames=119,fWidth=203,fHeight=79,framesPerRow=2,inAir=.6},
				["Trubbish"]={sheets={{id=174846290,rows=6},},nFrames=41,fWidth=75,fHeight=57,framesPerRow=7},
				["Turtwig"]={sheets={{id=174846290,startPixelY=348,rows=3},{id=174846300,rows=1},},nFrames=47,fWidth=45,fHeight=59,framesPerRow=12},
				["Tympole"]={sheets={{id=174846300,startPixelY=60,rows=5},},nFrames=59,fWidth=47,fHeight=38,framesPerRow=12},
				["Tynamo"]={sheets={{id=174846300,startPixelY=255,rows=8},},nFrames=79,fWidth=49,fHeight=26,framesPerRow=11,inAir=1.3},
				["Typhlosion"]={sheets={{id=174846303,rows=5},{id=174846315,rows=2},},nFrames=60,fWidth=62,fHeight=95,framesPerRow=9},
				["Tyranitar"]={sheets={{id=174846315,startPixelY=192,rows=3},{id=174846322,rows=5},{id=174846332,rows=1},},nFrames=60,fWidth=75,fHeight=101,framesPerRow=7},
				["Tyrantrum"]={sheets={{id=174846332,startPixelY=102,rows=4},{id=174846341,rows=5},{id=174846351,rows=4},},nFrames=61,fWidth=100,fHeight=108,framesPerRow=5},
				["Tyrogue"]={sheets={{id=174846351,startPixelY=436,rows=1},{id=174846359,rows=2},},nFrames=35,fWidth=38,fHeight=69,framesPerRow=15},
				["Tyrunt"]={sheets={{id=174846359,startPixelY=140,rows=6},{id=174846364,rows=2},},nFrames=63,fWidth=65,fHeight=68,framesPerRow=8},
				["Umbreon"]={sheets={{id=174846364,startPixelY=138,rows=5},},nFrames=45,fWidth=48,fHeight=77,framesPerRow=11},
				["Unfezant"]={sheets={{id=174846373,rows=3},{id=174846380,rows=3},{id=174846388,rows=3},{id=174846395,rows=2},},nFrames=31,fWidth=156,fHeight=142,framesPerRow=3},
				["Ursaring"]={sheets={{id=174846402,startPixelY=444,rows=1},{id=174846408,rows=5},},nFrames=44,fWidth=68,fHeight=95,framesPerRow=8},
				["Uxie"]={sheets={{id=174846408,startPixelY=480,rows=1},{id=174846414,rows=7},{id=174846418,rows=2},},nFrames=89,fWidth=63,fHeight=78,framesPerRow=9},
				["Vanillish"]={sheets={{id=174846418,startPixelY=158,rows=4},{id=174846428,rows=3},},nFrames=59,fWidth=58,fHeight=85,framesPerRow=9},
				["Vanillite"]={sheets={{id=174846428,startPixelY=258,rows=4},{id=174846435,rows=1},},nFrames=51,fWidth=49,fHeight=63,framesPerRow=11},
				["Vanilluxe"]={sheets={{id=174846435,startPixelY=64,rows=5},{id=174846439,rows=5},},nFrames=59,fWidth=83,fHeight=89,framesPerRow=6},
				["Vaporeon"]={sheets={{id=174846439,startPixelY=450,rows=1},{id=174846443,rows=7},{id=174846452,rows=5},},nFrames=63,fWidth=102,fHeight=72,framesPerRow=5},
				["Venipede"]={sheets={{id=174846452,startPixelY=365,rows=4},},nFrames=32,fWidth=63,fHeight=44,framesPerRow=9},
				["Venomoth"]={sheets={{id=174846457,rows=6},{id=174846461,rows=6},},nFrames=48,fWidth=123,fHeight=85,framesPerRow=4},
				["Venonat"]={sheets={{id=174846467,rows=7},},nFrames=60,fWidth=58,fHeight=63,framesPerRow=9},
				["Venusaur"]={sheets={{id=174846467,startPixelY=448,rows=1},{id=174846470,rows=7},{id=174846475,rows=4},},nFrames=59,fWidth=106,fHeight=77,framesPerRow=5},
				["Vespiquen"]={sheets={{id=174846475,startPixelY=312,rows=2},{id=174846484,rows=5},},nFrames=48,fWidth=75,fHeight=88,framesPerRow=7,inAir=.7},
				["Vibrava"]={sheets={{id=174846484,startPixelY=445,rows=2},{id=174846490,rows=10},{id=174846496,rows=8},},nFrames=79,fWidth=117,fHeight=50,framesPerRow=4,inAir=1.2},
				["Victini"]={sheets={{id=174846496,startPixelY=408,rows=2},{id=174846499,rows=2},},nFrames=39,fWidth=53,fHeight=73,framesPerRow=10},
				["Victreebel"]={sheets={{id=174846499,startPixelY=148,rows=4},{id=174846509,rows=6},{id=174846522,rows=2},},nFrames=60,fWidth=98,fHeight=82,framesPerRow=5},
				["Vigoroth"]={sheets={{id=174846522,startPixelY=166,rows=4},{id=174846529,rows=5},},nFrames=59,fWidth=82,fHeight=80,framesPerRow=7},
				["Vileplume"]={sheets={{id=174846529,startPixelY=405,rows=2},{id=174846536,rows=2},},nFrames=28,fWidth=81,fHeight=56,framesPerRow=7},
				["Virizion"]={sheets={{id=174846536,startPixelY=114,rows=4},{id=174846539,rows=5},},nFrames=59,fWidth=76,fHeight=97,framesPerRow=7},
				["Vivillon"]={sheets={{id=174846544,rows=5},{id=174846549,rows=5},{id=174846560,rows=5},{id=174846567,rows=1},},nFrames=79,fWidth=104,fHeight=104,framesPerRow=5},
				["Volbeat"]={sheets={{id=174846567,startPixelY=105,rows=5},},nFrames=35,fWidth=68,fHeight=74,framesPerRow=8},
				["Volcarona"]={sheets={{id=174846571,rows=5},{id=174846581,rows=5},{id=174846588,rows=1},},nFrames=44,fWidth=129,fHeight=93,framesPerRow=4,inAir=0.5},
				["Voltorb"]={sheets={{id=174846588,startPixelY=94,rows=5},},nFrames=60,fWidth=45,fHeight=43,framesPerRow=12},
				["Vullaby"]={sheets={{id=174846588,startPixelY=314,rows=3},{id=174846593,rows=1},},nFrames=31,fWidth=64,fHeight=69,framesPerRow=9},
				["Vulpix"]={sheets={{id=174846593,startPixelY=70,rows=4},},nFrames=40,fWidth=52,fHeight=47,framesPerRow=11},
				["Wailmer"]={sheets={{id=174846593,startPixelY=262,rows=4},{id=174846600,rows=8},},nFrames=59,fWidth=106,fHeight=68,framesPerRow=5,inAir=0.5},
				["Wailord"]={sheets={{id=174846608,rows=6},{id=174846610,rows=6},{id=174846614,rows=6},{id=174846624,rows=6},{id=174846631,rows=6},{id=174846644,rows=6},{id=174846651,rows=4},},nFrames=119,fWidth=146,fHeight=81,framesPerRow=3},
				["Walrein"]={sheets={{id=174846651,startPixelY=328,rows=3},{id=174846659,rows=7},{id=174846665,rows=2},},nFrames=59,fWidth=98,fHeight=71,framesPerRow=5},
				["Wartortle"]={sheets={{id=174846665,startPixelY=144,rows=4},},nFrames=31,fWidth=56,fHeight=73,framesPerRow=10},
				["Watchog"]={sheets={{id=174846665,startPixelY=440,rows=1},{id=174846677,rows=4},},nFrames=54,fWidth=48,fHeight=79,framesPerRow=11},
				["Weavile"]={sheets={{id=174846677,startPixelY=320,rows=3},{id=174846682,rows=1},},nFrames=30,fWidth=63,fHeight=78,framesPerRow=9},
				["Weedle"]={sheets={{id=174846682,startPixelY=79,rows=4},},nFrames=59,fWidth=35,fHeight=53,framesPerRow=16},
				["Weepinbell"]={sheets={{id=174846682,startPixelY=295,rows=5},{id=174846698,rows=3},},nFrames=60,fWidth=65,fHeight=51,framesPerRow=8},
				["Weezing"]={sheets={{id=174846698,startPixelY=156,rows=4},{id=174846710,rows=6},{id=174846718,rows=6},{id=174846730,rows=6},{id=174846733,rows=6},{id=174846740,rows=6},{id=174846751,rows=6},{id=174846760,rows=6},{id=174846768,rows=2},},nFrames=239,fWidth=103,fHeight=88,framesPerRow=5,inAir=.5},
				["Whimsicott"]={sheets={{id=174846768,startPixelY=178,rows=5},{id=174846778,rows=7},},nFrames=81,fWidth=75,fHeight=67,framesPerRow=7},
				["Whirlipede"]={sheets={{id=174846778,startPixelY=476,rows=1},{id=174846790,rows=8},{id=174846795,rows=5},},nFrames=80,fWidth=96,fHeight=65,framesPerRow=6},
				["Whiscash"]={sheets={{id=174846795,startPixelY=330,rows=3},{id=174846810,rows=6},},nFrames=58,fWidth=75,fHeight=62,framesPerRow=7,inAir=1.2},
				["Whismur"]={sheets={{id=174846810,startPixelY=378,rows=3},{id=174846816,rows=2},},nFrames=50,fWidth=51,fHeight=48,framesPerRow=11},
				["Wigglytuff"]={sheets={{id=174846816,startPixelY=98,rows=6},{id=174846823,rows=2},},nFrames=60,fWidth=72,fHeight=68,framesPerRow=8},
				["Wingull"]={sheets={{id=174846823,startPixelY=138,rows=16},{id=174846829,rows=4},},nFrames=79,fWidth=143,fHeight=24,framesPerRow=4,inAir=2},
				["Wobbuffet"]={sheets={{id=174846829,startPixelY=100,rows=6},},nFrames=74,fWidth=41,fHeight=68,framesPerRow=13},
				["Woobat"]={sheets={{id=174846838,rows=9},{id=174846851,rows=3},},nFrames=71,fWidth=95,fHeight=56,framesPerRow=6,inAir=1},
				["Wooper"]={sheets={{id=174846851,startPixelY=171,rows=8},{id=174846864,rows=1},},nFrames=79,fWidth=59,fHeight=47,framesPerRow=9},
				["Wormadam"]={sheets={{id=174846864,startPixelY=48,rows=6},{id=174846869,rows=6},},nFrames=79,fWidth=81,fHeight=82,framesPerRow=7},
				["Wurmple"]={sheets={{id=174846869,startPixelY=498,rows=1},{id=174846881,rows=4},},nFrames=59,fWidth=40,fHeight=53,framesPerRow=14},
				["Wynaut"]={sheets={{id=174846881,startPixelY=216,rows=6},},nFrames=39,fWidth=76,fHeight=53,framesPerRow=7},
				["Xatu"]={sheets={{id=174846891,rows=6},},nFrames=29,fWidth=103,fHeight=58,framesPerRow=5},
				["Xerneas"]={sheets={{id=174846891,startPixelY=354,rows=1},{id=174846899,rows=4},{id=174846902,rows=4},{id=174846909,rows=4},{id=174846916,rows=2},},nFrames=74,fWidth=104,fHeight=125,framesPerRow=5},
				["Yamask"]={sheets={{id=174846916,startPixelY=252,rows=4},{id=174846921,rows=6},},nFrames=89,fWidth=64,fHeight=67,framesPerRow=9},
				["Yanma"]={sheets={{id=174846921,startPixelY=408,rows=1},{id=174846926,rows=7},{id=174846929,rows=7},{id=174846939,rows=7},{id=174846948,rows=7},{id=174846958,rows=1},},nFrames=120,fWidth=120,fHeight=77,framesPerRow=4,inAir=1},
				["Yanmega"]={sheets={{id=174846958,startPixelY=78,rows=7},{id=174846971,rows=8},},nFrames=59,fWidth=143,fHeight=67,framesPerRow=4,inAir=1},
				["Yveltal"]={sheets={{id=174846981,rows=2},{id=174846993,rows=2},{id=174846999,rows=2},{id=174847007,rows=2},{id=174847015,rows=2},{id=174847022,rows=2},{id=174847031,rows=2},{id=174847046,rows=2},{id=174847051,rows=2},{id=174847059,rows=2},{id=174847065,rows=2},{id=174847072,rows=2},{id=174847078,rows=2},{id=174847089,rows=2},{id=174847095,rows=2},{id=174847104,rows=2},{id=174847109,rows=2},{id=174847119,rows=2},},nFrames=71,fWidth=201,fHeight=188,framesPerRow=2},
				["Zangoose"]={sheets={{id=174847119,startPixelY=378,rows=2},{id=174847124,rows=3},},nFrames=39,fWidth=67,fHeight=78,framesPerRow=8},
				["Zapdos"]={sheets={{id=174847124,startPixelY=237,rows=3},{id=174847133,rows=5},},nFrames=30,fWidth=145,fHeight=106,framesPerRow=4},
				["Zebstrika"]={sheets={{id=174847142,rows=5},{id=174847152,rows=3},},nFrames=63,fWidth=66,fHeight=96,framesPerRow=8},
				["Zekrom"]={sheets={{id=174847152,startPixelY=291,rows=1},{id=174847157,rows=4},{id=174847168,rows=4},{id=174847179,rows=4},{id=174847187,rows=1},},nFrames=67,fWidth=116,fHeight=136,framesPerRow=5},
				["Zigzagoon"]={sheets={{id=174847187,startPixelY=137,rows=6},},nFrames=48,fWidth=65,fHeight=47,framesPerRow=8},
				["Zoroark"]={sheets={{id=174847187,startPixelY=425,rows=1},{id=174847197,rows=5},{id=174847202,rows=3},},nFrames=49,fWidth=86,fHeight=94,framesPerRow=6},
				["Zorua"]={sheets={{id=174847202,startPixelY=285,rows=3},},nFrames=25,fWidth=47,fHeight=63,framesPerRow=12},
				["Zubat"]={sheets={{id=174847211,rows=6},{id=174847215,rows=2},},nFrames=39,fWidth=104,fHeight=84,framesPerRow=5},
				["Zweilous"]={sheets={{id=174847215,startPixelY=170,rows=4},{id=174847223,rows=7},{id=174847226,rows=4},},nFrames=89,fWidth=95,fHeight=79,framesPerRow=6},
				["Zygarde"]={sheets={{id=174847226,startPixelY=320,rows=2},{id=174847233,rows=5},{id=174847252,rows=5},{id=174847266,rows=2},},nFrames=79,fWidth=96,fHeight=107,framesPerRow=6},

				--['Diancie']={sheets={{id=174839875,startPixelY=369,rows=2},{id=174839886,rows=4},},nFrames=59,fWidth=50,fHeight=90,framesPerRow=11,inAir=.2},
				['Hoopa']={sheets={{id=5382607439,rows=7},},nFrames=79,fWidth=72,fHeight=67,framesPerRow=13},
				['Volcanion']={sheets={{id=6532116374,rows=87},},nFrames=78,fWidth=95,fHeight=90,framesPerRow=10},
				['Iron-Azumarill']={sheets={{id=14278133908,rows=5}},nFrames=39,fWidth=169,fHeight=143,framesPerRow=8},
			}
			local anim = animation:new(gifdata[denData.displayData.iconData.Name])
			local icon = anim.spriteLabel
			local scale = (gifdata[denData.displayData.iconData.Name] and gifdata[denData.displayData.iconData.Name].scale) or 1
			local x = ((gifdata[denData.displayData.iconData.Name] and gifdata[denData.displayData.iconData.Name].fWidth) or 0) / 135 * scale / 1.5
			local y = ((gifdata[denData.displayData.iconData.Name] and gifdata[denData.displayData.iconData.Name].fHeight) or 0) / 135 * scale / 1.5
			icon.Size = UDim2.new(x, 0, y, 0)
			icon.Position = UDim2.new(0.2-x/2, 0, 0.85-y, 0)
			icon.ZIndex = 9
			icon.Parent = backdrop
			icon.ImageColor3 = Color3.new(0,0,0)
			anim:Play()
			Utilities.Write('???') ({
				Frame = Create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.15, 0),
					Parent = backdrop,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			})
			Utilities.Write('Generated: '..tostring(model.GenerateTime.Value)) {
				Frame = Create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.02, 0),
					Position = UDim2.new(0.04, 0, .975, 0),
					Parent = backdrop,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			Utilities.Write('Den Name: '..tostring(denData.displayData.DenName)) {
				Frame = Create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.02, 0),
					Position = UDim2.new(0.04, 0, .95, 0),
					Parent = backdrop,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			for i, t in pairs(_p.Pokemon:getTypes(denData.displayData.iconData.Typing or 1)) do
				local rf =  _p.RoundedFrame:new {
					BackgroundColor3 = _p.BattleGui.typeColors[t],
					Size = UDim2.new(0, 211, 0, 50),
					Font = Enum.Font.SourceSansBold,
					TextScaled = true,
					TextSize = 14.000,
					TextWrapped = true,
					Position = UDim2.new(0.05+0.18*(i-1), 0, 0.28, 0), 
					ZIndex = 6, Style = 'HorizontalBar', Parent = backdrop,
				}
				Utilities.Write(t) {
					Frame = Create 'Frame' {
						ZIndex = 7, Parent = rf.gui, BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.7, 0),
						Position = UDim2.new(0.5, 0, 0.15, 0),

					}, Scaled = true,
				}

			end
			local X = 0.07
			for stars = 1, denData.displayData.Tier >= 6 and 5 or denData.displayData.Tier do
				local Star = Create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://279798627',
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(0, 61, 0, 57),
					Position = UDim2.new(X, 0, 0, 0),
					--ImageColor3 = Color3.new(0.4, 0.4, 1),
					Parent = backdrop,
				}
				X += .07
				if denData.displayData.Tier == 5 then
					local UIGradient = Create 'UIGradient' {
						Color = Utilities.uiGradient('darknight'),
						Parent = Star,
					}
					spawn(function() Utilities.shineGradient(UIGradient)  end)
				elseif denData.displayData.Tier == 6 then
					local UIGradient = Create 'UIGradient' {
						Color = Utilities.uiGradient('moonlit'),
						Parent = Star,
					}
					spawn(function() Utilities.shineGradient(UIGradient)  end)
				end
			end
		end
		local UICorner = Instance.new("UICorner")
		local Play = Create 'TextButton' {
			BackgroundColor3 = Color3.fromRGB(212, 212, 212),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Text = " ",
			Size = UDim2.new(0, 309, 0, 46),
			Position = UDim2.new(0.634016037, 0, 0.729689837, 0),
			Parent = backdrop,
		}
		UICorner.Parent = Play
		UICorner.CornerRadius = UDim.new(1, 0)
		local playbtn = Utilities.Write 'Play' {
			Frame = Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.7, 0),
				Position = UDim2.new(0.0, 0, 0.15, 0),
				ZIndex = 10, Parent = Play
			}, Scaled = true,
		}
		for i,a in pairs(playbtn.Labels) do
			a.ImageColor3 = Color3.new(0,0,0)
		end
		local UICorner = Instance.new("UICorner")
		local Quit = Create 'TextButton' {
			BackgroundColor3 = Color3.fromRGB(212, 212, 212),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0,
			Text = " ",
			Size = UDim2.new(0, 309, 0, 46),
			Position =  UDim2.new(0.634016037, 0, 0.890694261, 0),
			Parent = backdrop,
		}
		UICorner.Parent = Quit
		UICorner.CornerRadius = UDim.new(1, 0)
		local quitbtn = Utilities.Write 'Quit' {
			Frame = Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.7, 0),
				Position = UDim2.new(0.0, 0, 0.15, 0),
				ZIndex = 10, Parent = Quit
			}, Scaled = true,
		}
		for i,a in pairs(quitbtn.Labels) do
			a.ImageColor3 = Color3.new(0,0,0)
		end
		local opt = nil
		Play.MouseButton1Click:Connect(function ()
			opt = 1
		end)
		Quit.MouseButton1Click:Connect(function ()
			opt = 2
		end)
		while opt == nil do
			wait(0.7)
		end
		if opt == 2 then 
			Tween(.3, nil, function(a)
				backdrop.Position = UDim2.new(-1.05*a, 0, 0, 0)
			end)
			frame:Destroy()
			RaidUI:Destroy()
			backdrop:Destroy()
			spawn(function() _p.Menu:enable() end)

			return 'Cancel'
		else do
				Tween(.3, nil, function(a)
					backdrop.Position = UDim2.new(-1.05*a, 0, 0, 0)
				end)
				frame:Destroy()
				RaidUI:Destroy()
				backdrop:Destroy()
				spawn(function() _p.Menu:enable() end)

				return true
			end
		end
	end



	function MaxRaid:init()

	end
	function MaxRaid:Update()

	end


	function MaxRaid:GenerateRaidDen(targ)
		local maxRaidData = _p.Network:get('PDS', 'getRaidDenData', nil, nil, targ.DenID.Value)
		if maxRaidData and maxRaidData == 'disabled' then 
			maxRaidData = {
				displayData={
					iconData = {
						Typing = '',
						IconId = '',
					},
					Tier='',
					DenName=''
				},
				Key='[EMPTY]'
			}
		end

		Create 'StringValue' {
			Value = getTime(),
			Name = 'GenerateTime',
			Parent = targ,
		}
		Create 'StringValue' {
			Value = maxRaidData.Key,
			Name = 'Key',
			Parent = targ,
		}
		self.generatedData[maxRaidData.Key] = maxRaidData

		if maxRaidData.displayData.Tier ~= '' then
			self:maxRaidBeam(targ, maxRaidData.displayData.Tier)
		end
	end
	function MaxRaid:UpdateRaidDen(targ, clr)
		self.generatedData[targ.Key.Value] = nil
		_p.Network:get('PDS', 'getRaidDenData', true, targ.Key.Value)
		targ.Key.Value = '[EMPTY]'
		--Clears existing KeyData
		if not clr then
			local maxRaidData = _p.Network:get('PDS', 'getRaidDenData', nil, nil, targ.DenID.Value) --Need to show it's forced
			targ.Key.Value = maxRaidData.Key
			targ.GenerateTime.Value = getTime() 
			self.generatedData[maxRaidData.Key] = maxRaidData

		end
	end
	function MaxRaid:Raid(encData, maxRaid,denData)


		local win = _p.Battle:doWildBattle(encData, {
			cantRun = true,
			cantUseBag = true,
			battleSceneType = 'DmaxV1',
			musicId = 6463398333,
			genEncounter = maxRaid,
			isRaid = true
		})
		if win and maxRaid.unCatchable then

			--//Rewards
			local Rewards = _p.Network:get('PDS', 'raidPrizes', denData)
			local RaidUI = Instance.new("ScreenGui")
			local backdrop = Instance.new("ImageLabel")
			RaidUI.Name = "RaidUI"
			RaidUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
			RaidUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			RaidUI.IgnoreGuiInset = true
			backdrop.Name = "background"
			backdrop.Parent = RaidUI
			backdrop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			backdrop.BorderColor3 = Color3.fromRGB(0, 0, 0)
			backdrop.BorderSizePixel = 0
			backdrop.Position = UDim2.new(0.039,0,1,0)
			backdrop.Size = UDim2.new(0.84,0,0.77,0)
			backdrop.Image = "http://www.roblox.com/asset/?id=14849332507"
			local UICorner = Instance.new("UICorner")
			UICorner.Parent = backdrop
			UICorner.CornerRadius = UDim.new(0,50)
			local X = 0.03
			spawn(function() _p.Menu:disable() end)

			task.spawn(function()
				for stars = 1, denData.displayData.Tier >= 6 and 5 or denData.displayData.Tier do
					local Star = Create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://279798627',
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(0, 61, 0, 57),
						Position = UDim2.new(X, 0, 0.025, 0),
						--ImageColor3 = Color3.new(0.4, 0.4, 1),
						Parent = backdrop,
					}
					X = X + 0.7
					if denData.displayData.Tier == 5 then
						local UIGradient = Create 'UIGradient' {
							Color = Utilities.uiGradient('darknight'),
							Parent = Star,
						}
						spawn(function() Utilities.shineGradient(UIGradient)  end)
					elseif denData.displayData.Tier == 6 then
						local UIGradient = Create 'UIGradient' {
							Color = Utilities.uiGradient('moonlit'),
							Parent = Star,
						}
						spawn(function() Utilities.shineGradient(UIGradient)  end)
					end
				end
			end)
			local ScrollFrame = Instance.new("ScrollingFrame", backdrop)
			ScrollFrame.Size = UDim2.new(0.455, 0, 0.6, 0)
			ScrollFrame.Position = UDim2.new(0.272, 0, 0.2, 0)
			ScrollFrame.BackgroundTransparency = 1
			ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
			ScrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always
			local Y = 0.01
			for i = 1, #Rewards do
				local item = Rewards[i]
				local Frame = game.ReplicatedStorage.ItemTemplate:Clone()
				Frame.Parent = ScrollFrame
				Frame.Position = UDim2.new(0,0,Y,0)
				Y = Y + 0.04
				--Frame.ItemLogo.ImageRectOffset = getoffset(item)
				--Frame.ItemLogo.ImageRectSize = getSize(item)
				Frame.ItemLogo.Image = "rbxassetid://7046334764"
				Frame.ItemLogo.ItemName.Text = "!!!"
				Frame.ItemLogo.ItemName.Quantity.Text = "X       1"
			end
			local closed = false
			local close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = BrickColor.new('Deep blue').Color,
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, .889, 0),
				ZIndex = 9, Parent = backdrop,
				MouseButton1Click = function()
					closed = true
				end
			}
			Utilities.Write 'Next' {
				Frame = Create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 10, Parent = close.gui
				}, Scaled = true,
			}
			game.TweenService:Create(backdrop, TweenInfo.new(.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = UDim2.new(0.039,0,0.117,0)}):Play()
			repeat wait() until closed == true
			game.TweenService:Create(backdrop, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Position = UDim2.new(-1,0,0.117,0)}):Play()
			wait(1)
			backdrop:Destroy()
			chat:say('This Pokemon is unable to be captured.')
		elseif win and not maxRaid.unCatchable then

		end

		--//Rewards  HEREE
		local Rewards = _p.Network:get('PDS', 'raidPrizes', denData)
		local RaidUI = Instance.new("ScreenGui")
		local backdrop = Instance.new("ImageLabel")
		RaidUI.Name = "RaidUI"
		RaidUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
		RaidUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		RaidUI.IgnoreGuiInset = true
		backdrop.Name = "background"
		backdrop.Parent = RaidUI
		backdrop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		backdrop.BorderColor3 = Color3.fromRGB(0, 0, 0)
		backdrop.BorderSizePixel = 0
		backdrop.Position = UDim2.new(0.039,0,1,0)
		backdrop.Size = UDim2.new(0.84,0,0.77,0)
		backdrop.Image = "http://www.roblox.com/asset/?id=14849332507"
		local UICorner = Instance.new("UICorner")
		UICorner.Parent = backdrop
		UICorner.CornerRadius = UDim.new(0,50)
		local X = 0.03
		spawn(function() _p.Menu:disable() end)

		task.spawn(function()
			for stars = 1, denData.displayData.Tier >= 6 and 5 or denData.displayData.Tier do
				local Star = Instance.new('ImageLabel')
				Star.BackgroundTransparency = 1.0
				Star.Image = 'rbxassetid://279798627'
				Star.SizeConstraint = Enum.SizeConstraint.RelativeYY
				Star.Size = UDim2.new(0, 61, 0, 57)
				Star.Position = UDim2.new(X, 0, 0.025, 0)
				Star.Parent = backdrop
				X += .07
				local UIGradient = Instance.new('UIGradient')
				UIGradient.Color = Utilities.uiGradient(denData.displayData.Tier == 5 and 'darknight' or 'moonlit')
				UIGradient.Parent = Star
				spawn(function() Utilities.shineGradient(UIGradient)  end)
			end
		end)

		local ScrollFrame = Instance.new("ScrollingFrame", backdrop)
		ScrollFrame.Size = UDim2.new(0.455, 0, 0.6, 0)
		ScrollFrame.Position = UDim2.new(0.272, 0, 0.2, 0)
		ScrollFrame.BackgroundTransparency = 1
		ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
		ScrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always
		local Y = 0.01
		for item, quantity in pairs(Rewards or {}) do
			local Frame = game.ReplicatedStorage.ItemTemplate:Clone()
			--local camClone = Instance.new("Camera", Frame.ItemLogo)
			--camClone.Name = "Camera"
			--local clone = item:Clone()
			--clone.Parent = Frame.ItemLogo
			Frame.Parent = ScrollFrame
			Frame.Position = UDim2.new(0,0,Y,0)
			Y += 0.04
			--Frame.ItemLogo.Image = "rbxassetid://10416507287"
			Frame.ItemLogo.ItemName.Text = item -- Set the item name
			Frame.ItemLogo.ItemName.Quantity.Text = "X " .. quantity -- Set the quantity
		end

		local closed = false
		local close = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = BrickColor.new('Deep blue').Color,
			Size = UDim2.new(.31, 0, .08, 0),
			Position = UDim2.new(.65, 0, .889, 0),
			ZIndex = 9, Parent = backdrop,
			MouseButton1Click = function()
				closed = true
			end
		}

		local closeButton = Instance.new('TextButton')
		closeButton.Size = UDim2.new(1, 0, 1, 0)
		closeButton.Position = UDim2.new(0, 0, 0, 0)
		closeButton.Text = "Close"
		closeButton.Parent = close.gui
		closeButton.MouseButton1Click:Connect(function()
			closed = true
		end)

		game.TweenService:Create(backdrop, TweenInfo.new(.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = UDim2.new(0.039,0,0.117,0)}):Play()
		repeat wait() until closed == true
		game.TweenService:Create(backdrop, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Position = UDim2.new(-1,0,0.117,0)}):Play()
		wait(1)
		backdrop:Destroy()

		local opt = (chat and chat.choose) and chat:choose('Capture', 'Run') or nil
		if opt == 1 then
			_p.Battle:doWildBattle(encData, {
				cantRun = false,
				genEncounter = maxRaid,
				isRaid = false,
			})
		elseif opt == 2 then
			if maxRaid.cannotRun then
				chat:say('You cannot run from the opposing Pokemon.')
			else
				chat:say('You successfully fled!')
				_p.Menu:enable()

			end
		end
	end
	function MaxRaid:OnDenClicked(pos, targ, encData)
		if self.isOpen then
			return
		end
		self.isOpen = true
		_p.MasterControl.WalkEnabled = false        
		_p.MasterControl:Stop()
		_p.Hoverboard:unequip(true)
		spawn(function() _p.MasterControl:LookAt(pos) end)

		self:UpdateRaidDen(targ)
		local denData = self.generatedData[targ.Key.Value]

		local option = generateMaxInterface(denData, targ, encData)
		_p.MasterControl.WalkEnabled = true

		if option == 'Cancel' then
			self.isOpen = false
			return
		end

		self:Raid(encData, targ.Key.Value, denData)
		self:UpdateRaidDen(targ, true)
		self.isOpen = false
	end

	return MaxRaid end