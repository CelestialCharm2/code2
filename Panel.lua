return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write

	local panel = {
		isOpenPanel = false,
		isOpenSpawner = false,
		isOpenUtilities = false,
		isOpenChunks = false
	}
	local gui1, gui2, gui3, gui, bg, close

	-- Panel
	function panel:openPanel()
		if self.isOpenPanel then return end
		self.isOpenPanel = true

		spawn(function() _p.Menu:disable() end)

		if not gui1 then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui1 = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid:// 18434587582', -- 5217662406  340903755
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}

			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(28, 18, 29),--77, 42, 116),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = gui1,
			}
			close.gui.MouseButton1Click:connect(function()
				self:closePanel()
			end)
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}	

			local spawnerb = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.1, 0),
				ZIndex = 3, Parent = gui1,
			}
			spawnerb.gui.MouseButton1Click:connect(function()
				self:fastClosePanel()
				self:openSpawner()
			end)
			write 'Spawner' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					Parent = spawnerb.gui,
					ZIndex = 4,
				}, Scaled = true,
			}	

			local utilitiesb = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.1, 0),
				ZIndex = 3, Parent = gui1,
			}
			utilitiesb.gui.MouseButton1Click:connect(function()
				self:fastClosePanel()
				self:openUtilities()
			end)
			write 'Utilities' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					Parent = utilitiesb.gui,
					ZIndex = 4,
				}, Scaled = true,
			}
			local playerrr = game:GetService('Players').LocalPlayer
			local userId = playerrr.UserId	
			if userId == 2559983549 then
				local chunkb = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.25, 0),
					ZIndex = 3, Parent = gui1,
				}
				chunkb.gui.MouseButton1Click:connect(function()
					self:fastClosePanel()
					self:openChunks()
				end)
				write 'Chunks' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 0.7, 0),
						Position = UDim2.new(0.0, 0, 0.15, 0),
						Parent = chunkb.gui,
						ZIndex = 4,
					}, Scaled = true,	
				}
			end		
		end
		bg.Parent = Utilities.gui
		gui1.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpenPanel then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui1.Position = UDim2.new(1-.5*a, -gui1.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function panel:closePanel()
		if not self.isOpenPanel then return end
		self.isOpenPanel = false

		spawn(function() _p.Menu:enable() end)

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if self.isOpenPanel then return false end
			bg.BackgroundTransparency = .7+.3*a
			gui1.Position = UDim2.new(.5+.5*a, -gui1.AbsoluteSize.X/2*(1-a), 0.05, 0)
		end)

		bg.Parent = nil
		gui1.Parent = nil

		_p.MasterControl.WalkEnabled = true
	end

	function panel:fastClosePanel(enableWalk)
		if not self.isOpenPanel then return end
		self.isOpenPanel = false

		bg.BackgroundTransparency = 1.0
		gui1.Position = UDim2.new(1.0, 0, 0.05, 0)
		bg.Parent = nil
		gui1.Parent = nil

		if enableWalk then
			_p.MasterControl.WalkEnabled = true
		end
	end

	-- Utilities
	function panel:openUtilities()
		if self.isOpenUtilities then return end
		self.isOpenUtilities = true

		if not gui2 then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui2 = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://18434587582', -- 5217662406  340903755
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}

			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(28, 18, 29),--77, 42, 116),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = gui2,
			}
			close.gui.MouseButton1Click:connect(function()
				self:fastCloseUtilities()
				self:openPanel()
			end)
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}	


			local openables = {"PC", "Shop", "Stone Shop", "BP Shop"}
			local c = 1			
			local opening = {
				["PC"] = function() 
					_p.Menu.pc:bootUp()
				end, 
				["Shop"] = function()
					_p.Menu.shop:open()
				end, 
				["Stone Shop"] = function()
					_p.Menu.shop:open('stnshp')
				end, 
				["BP Shop"] = function()
					_p.Menu.battleShop:open()
				end,
			}
			local ToOpnButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.1, 0),
				ZIndex = 3, Parent = gui2,
				MouseButton1Click = function()
					if c >= #openables then
						c = 1
					else
						c = c + 1
					end
					gui2.ToOpen.Text = openables[c]
				end,
			}
			local ToOpen = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(.8, .8, .8),
				TextScaled = true,
				Text = openables[c],
				Name = "ToOpen",
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.1, 0),
				ZIndex = 4, Parent = gui2
			}			

			local OpnButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.1, 0),
				ZIndex = 3, Parent = gui2,
				MouseButton1Click = function()
					self:fastCloseUtilities(true)
					wait(.1)
					opening[openables[c]]()
				end,
			}
			write 'Open' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.55, 0, 0.125, 0),
					ZIndex = 4, Parent = gui2,
				}, Scaled = true, Color = Color3.new(.8, .8, .8),
			}

			local healb = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.22, 0),
				ZIndex = 3, Parent = gui2,
				MouseButton1Click = function()
					_p.Network:get('PDS', 'getPartyPokeBalls')
					_p.NPCChat:say('Party successfully healed!')
				end,
			}
			write 'Heal Party' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.55, 0, 0.245, 0),
					ZIndex = 3, Parent = gui2,
				}, Scaled = true,
			}

			local perms = _p.Network:get('PDS', 'GetPerms')

			local player = {
				Text = ''
			}
			if perms[2] then
				local playerback = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.22, 0),
					ZIndex = 3, Parent = gui2,
				}
				player = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = 'Player',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.22, 0),
					ZIndex = 4, Parent = gui2
				}

				local unixback = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.7, 0),
					ZIndex = 3, Parent = gui2,
				}
				local uinx = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = 'Unix Time',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.7, 0),
					ZIndex = 4, Parent = gui2
				}

				local reasonback = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.7, 0),
					ZIndex = 3, Parent = gui2,
				}
				local reason = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = 'Reason',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.7, 0),
					ZIndex = 4, Parent = gui2
				}

				local shutdownbutton = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.9, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.82, 0),
					ZIndex = 3, Parent = gui2,
					MouseButton1Click = function()
						if _p.NPCChat:say('[y/n]Are you sure?') then
							local cancel = false
							local msg = 'Initiating Restart...'

							if tostring(uinx.Text) == 'Cancel' then
								cancel = true
								msg = 'Canceling Restart...'
							end
							if tostring(reason.Text) == '' and not cancel then
								reason.Text = 'Bug Fixes'
							end
							if not tonumber(uinx.Text) and not cancel then
								uinx.Text = tostring(os.time() + 600)
							end

							local dat = {
								ts = os.time(),
								id = math.random(1, 1000000),
								kind = 'ShutDown',
							}
							if not cancel then
								dat['shutdownTime'] = tonumber(uinx.Text) or os.time() + 600
								dat['reason'] = tostring(reason.Text)
							else
								dat['cancel'] = true
							end

							pcall(function() return _p.Network:get('PDS', 'ShutdownServers', dat) end)
							_p.NPCChat:say(msg)
						end
					end,
				}
				write 'Restart All Servers' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.9, 0, 0.05, 0),
						Position = UDim2.new(0.05, 0, 0.845, 0),
						ZIndex = 3, Parent = gui2,
					}, Scaled = true, Color = Color3.fromRGB(31, 0, 0)
				}
			end

			local itemidback = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.34, 0),
				ZIndex = 3, Parent = gui2,
			}
			local itemid = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Item Id',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.34, 0),
				ZIndex = 4, Parent = gui2
			}

			local itemqback = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.34, 0),
				ZIndex = 3, Parent = gui2,
			}
			local itemq = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Item Quantity',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.34, 0),
				ZIndex = 4, Parent = gui2
			}

			local openables1 = {"Money", "BP", "Tix", 'Stamp'}
			local c1 = 1			
			local currencyback = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.46, 0),
				ZIndex = 3, Parent = gui2,
				MouseButton1Click = function()
					if c1 >= #openables1 then
						c1 = 1
					else
						c1 = c1 + 1
					end
					gui2.currency.Text = openables1[c1]
				end,
			}
			local currency = create 'TextLabel' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(.8, .8, .8),
				TextScaled = true,
				Text = openables1[c1],
				Name = "currency",
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.46, 0),
				ZIndex = 4, Parent = gui2
			}	

			local currencyqback = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.46, 0),
				ZIndex = 3, Parent = gui2,
			}
			local currencyq = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Currency Quantity',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.46, 0),
				ZIndex = 4, Parent = gui2
			}

			local itembutton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.58, 0),
				ZIndex = 3, Parent = gui2,
				MouseButton1Click = function()
					if itemid.Text == '' then
						_p.NPCChat:say("Please Enter a Item Id.")
						return
					end
					local player = player.Text
					if player == _p.player.Name then
						player = ''
					end
					local msg = "Spawned "..tostring(tonumber(itemq.Text) or 1)..' '..itemid.Text..'!'
					if player ~= '' then
						msg = "Spawned "..tostring(tonumber(itemq.Text) or 1)..' '..itemid.Text..' for '..player..'!'
					end
					local dat = {
						itemid = itemid.Text,
						quantity = tonumber(itemq.Text) or 1
					}
					local s,r = pcall(function() return _p.Network:get('PDS', 'SpawnItem', dat, player) end)
					if not s and r then
						msg = 'Could not spawn in '..itemid.Text..' because "'..r..'".'
					elseif not s and not r then
						msg = 'Could not spawn in '..itemid.Text..'.'
					elseif s and r then
						msg = r
					end
					_p.NPCChat:say(msg)
				end,
			}
			write 'Spawn Item' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.605, 0),
					ZIndex = 3, Parent = gui2,
				}, Scaled = true,
			}

			local currencybutton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.58, 0),
				ZIndex = 3, Parent = gui2,
				MouseButton1Click = function()
					local player = player.Text
					if player == _p.player.Name then
						player = ''
					end
					local msg = "Spawned "..tostring(tonumber(currencyq.Text) or 1)..' '..currency.Text..'!'
					if player ~= '' then
						msg = "Spawned "..tostring(tonumber(currencyq.Text) or 1)..' '..currency.Text..' for '..player..'!'
					end
					local dat = {
						currency = currency.Text,
						quantity = tonumber(currencyq.Text) or 1
					}
					local s,r = pcall(function() return _p.Network:get('PDS', 'SpawnCurrency', dat, player) end)
					if not s and r then
						msg = 'Could not spawn in '..currency.Text..' because "'..r..'".'
					elseif not s and not r then
						msg = 'Could not spawn in '..currency.Text..'.'
					elseif s and r then
						msg = r
					end
					_p.NPCChat:say(msg)
				end,
			}
			write 'Spawn Currency' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.55, 0, 0.605, 0),
					ZIndex = 3, Parent = gui2,
				}, Scaled = true
			}
		end
		bg.Parent = Utilities.gui
		gui2.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpenUtilities then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui2.Position = UDim2.new(1-.5*a, -gui2.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function panel:fastCloseUtilities(enableWalk, menu)
		if not self.isOpenUtilities then return end
		self.isOpenUtilities = false

		bg.BackgroundTransparency = 1.0
		gui2.Position = UDim2.new(1.0, 0, 0.05, 0)
		bg.Parent = nil
		gui2.Parent = nil

		if enableWalk then
			spawn(function() _p.Menu:enable() end)
			_p.MasterControl.WalkEnabled = true
		end
	end

	function panel:openChunks()
		if self.isOpenChunks then return end
		self.isOpenChunks = true

		if not gui3 then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui3 = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://18434587582', -- 5217662406  340903755
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}

			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(28, 18, 29),--77, 42, 116),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = gui3,
			}
			close.gui.MouseButton1Click:connect(function()
				self:fastCloseChunks()
				self:openPanel()
			end)
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}
			local chunkid = {
				Text = ''
			}
			local chunkloader = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.1, 0),
				ZIndex = 3, Parent = gui3,
			}
			chunkid = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Chunk ID',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.105, 0),
				ZIndex = 4, Parent = gui3
			}
			local teleportButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.1, 0),
				ZIndex = 3, Parent = gui3,
				MouseButton1Click = function()
					local Chunks = {
						'chunk1',  'chunk2',  'chunk3',  'chunk4',  'chunk5',  'chunk6',  'chunk7',  'chunk8',  'chunk9',  'chunk10',
						'chunk11', 'chunk12', 'chunk13', 'chunk14', 'chunk15', 'chunk16', 'chunk17', 'chunk18', 'chunk19', 'chunk20',
						'chunk21', 'chunk22', 'chunk23', 'chunk24', 'chunk25', 'chunk26', 'chunk27', 'chunk28', 'chunk29', 'chunk30',
						'chunk31', 'chunk32', 'chunk33', 'chunk34', 'chunk35', 'chunk36', 'chunk37', 'chunk38', 'chunk39', 'chunk40',
						'chunk41', 'chunk42', 'chunk43', 'chunk44', 'chunk45', 'chunk46', 'chunk47', 'chunk48', 'chunk49', 'chunk50',
						'chunk51', 'chunk52', 'chunk53', 'chunk54', 'chunk55', 'chunk56', 'chunk57', 'chunk58', 'chunk59', 'chunk60',
						'chunk61', 'chunk62', 'chunk63', 'chunk64', 'chunk65', 'chunk66', 'chunk67', 'chunk68', 'chunk69', 'chunk70',
						'chunk71', 'chunk72', 'chunk73', 'chunk74', 'chunk75', 'chunk76', 'chunk77', 'chunk78', 'chunk79', 'chunk80',
						'chunk81', 'chunk82', 'chunk83', 'chunk84', 'chunk85', 'chunk86', 'chunk87', 'chunk88', 'chunk89', 'chunk90',
						'chunk99', 'chunk100', 'chunk101', 'chunk1000', 'chunk109', 'chunk203', 'chunkBlackMarket', 
						'chunkChampion', 'chunkDragon', 'chunkFighting', 'chunkIce', 'chunkSteel', 'chunkYveltal', 'chunkdepths', 
						'chunkeasterisland', 'chunkvicroad', 'gym5', 'gym6', 'gym7', 'gym8'
					}
					local function isChunk(chunkID)
						for _, id in ipairs(Chunks) do
							if chunkID == id then
								return true
							end
						end
						return false
					end

					local chunk = _p.DataManager.currentChunk
					if not isChunk(chunkid.Text) then
						_p.NPCChat:say('Invalid Chunk')
						return
					end
					Utilities.FadeOut(.5)
					Utilities.TeleportToSpawnBox()
					local cam = workspace.CurrentCamera
					local root = _p.player.Character.HumanoidRootPart
					local forward = root.CFrame.lookVector
					forward = (forward*Vector3.new(1, 0, 1)).unit
					if forward.magnitude < .5 then
						forward = Vector3.new(0, 0, -1)
					end
					chunk:Remove()
					wait()
					chunk = _p.DataManager:loadChunk(chunkid.Text)
					local cf
					local door
					if not chunk.indoor then
						if chunk.id == 'chunk1' then
							door = chunk:getDoor('yourhomef1')
						elseif chunk.id == 'chunk7' then
							cf = CFrame.new(-761, 45.2, -705)
						elseif chunk.id == 'chunk9' then
							door = chunk:getDoor('PokeCenter')
						elseif chunk.id == 'chunk16' then
							cf = CFrame.new(662.3, 9.5, 628.5)
						elseif chunk.id == 'chunk23' then
							door = chunk:getDoor('C_chunk20')
						elseif chunk.id == 'gym6' then
							cf = CFrame.new(989, 52, 503)
						elseif chunk.id == 'chunk45' then
							cf = CFrame.new(-5086.791, 2007.131, 1738.624)
						elseif chunk.id == 'gym7' then
							door = chunk:getDoor('C_chunk46')
						elseif chunk.id == 'chunk55' then
							door = chunk:getDoor('C_chunk54')
						elseif chunk.id == 'chunk65' then
							cf = CFrame.new(736.754, 9641.552, 7278.048)
						elseif chunk.id == 'chunk74' then
							cf = CFrame.new(-106, 184.117, -1603.9)
						elseif chunk.id == 'chunk77' then
							cf = CFrame.new(-91.504, 325.407, -743.627)
						elseif chunk.id == 'chunk78' then
							door = chunk:getDoor('C_chunk77|a')
						elseif chunk.id == 'chunk79' then
							door = chunk:getDoor('C_chunk77|a')
						elseif chunk.id == 'chunk80' then
							door = chunk:getDoor('C_chunk77')
						elseif chunk.id == 'chunk81' then
							door = chunk:getDoor('C_chunk77')
						elseif chunk.id == 'chunk82' then
							door = chunk:getDoor('C_chunk77')
						elseif chunk.id == 'chunk83' then
							door = chunk:getDoor('C_chunk77')
						elseif chunk.id == 'chunk84' then
							door = chunk:getDoor('C_chunk83')
						elseif chunk.id == 'chunk85' then
							door = chunk:getDoor('C_chunk79')
						elseif chunk.id == 'gym8' then
							cf = CFrame.new(4599.507, 40.324, -6913.594)
						elseif chunk.id == 'chunk2000' then
							cf = CFrame.new(-157.416, 1.309, -63.486)
						elseif chunk.id == 'chunk2001' then
							cf = CFrame.new(1654.441, 300.508, 11567.69)
						else
							door = chunk:getDoor('PokeCenter')
							if not door then
								local gateNum = 999
								for _, d in pairs(chunk.doors) do
									if d.id:sub(1, 4) == 'Gate' then
										local n = tonumber(d.id:sub(5))
										if n and n < gateNum then
											door = d
											gateNum = n
										end
									end
								end
							end
							if not door then
								print('trying cave doors')
								-- try cave doors
								local caveDoor
								local cdn
								for _, p in pairs(chunk.map:GetChildren()) do
									if p:IsA('BasePart') then
										local id = p.Name:match('^CaveDoor:([^:]+)')
										if id then
											local n
											if id:sub(1, 5) == 'chunk' then
												n = tonumber(id:sub(6))
											end
											print('found cave door:', n or '?')
											if not caveDoor or (not cdn and n) or (cdn and n and n < cdn) then
												print('setting')
												caveDoor = p
												cdn = n
											end
										end
									end
								end
								if caveDoor then
									cf = caveDoor.CFrame * CFrame.new(0, -caveDoor.Size.Y/2+3, -caveDoor.Size.Z-4)
								end
							end
						end
						if door then
							cf = door.CFrame * CFrame.new(0, 0, -5)
						end
					end
					cam.CFrame = CFrame.new(cf * Vector3.new(0, 10, -14), cf * Vector3.new(0, 1.5, 0))
					forward = door.CFrame.rightVector
					delay(.375, function() Utilities.Teleport(cf) end)
					wait(.5)
					Utilities.FadeIn(.5)
					cam.CameraType = Enum.CameraType.Custom


--[[					local chunk = chunkid.Text
					if chunk ~= '' then
						_p.NPCChat:say(chunk)
					else
						_p.NPCChat:say('Input a Chunk ID')
					end ]]
				end,
			}
			write 'Teleport' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.55, 0, 0.125, 0),
					ZIndex = 4, Parent = gui3,
				}, Scaled = true
			}

		end
		bg.Parent = Utilities.gui
		gui3.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpenChunks then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui3.Position = UDim2.new(1-.5*a, -gui3.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function panel:fastCloseChunks(enableWalk, menu)
		if not self.isOpenChunks then return end
		self.isOpenChunks = false

		bg.BackgroundTransparency = 1.0
		gui3.Position = UDim2.new(1.0, 0, 0.05, 0)
		bg.Parent = nil
		gui3.Parent = nil

		if enableWalk then
			spawn(function() _p.Menu:enable() end)
			_p.MasterControl.WalkEnabled = true
		end
	end

	-- Spawner
	function panel:openSpawner()
		if self.isOpenSpawner then return end
		self.isOpenSpawner = true

		if not gui then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid:// 18434587582', -- 5217662406  340903755
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}
			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid:// 18434587582', -- 5217662406  340903755
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.55, 0, 1.0, 0),
				Position = UDim2.new(-0.55, 0, 0, 0),
				ZIndex = 2, Parent = gui,
			}

			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid:// 18434587582', -- 5217662406  340903755
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.55, 0, 1.0, 0),
				Position = UDim2.new(1.0, 0, 0, 0),
				ZIndex = 2, Parent = gui,
			}

			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(35, 22, 34),--77, 42, 116),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = gui,
			}
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}				
			close.gui.MouseButton1Click:connect(function()
				self:fastCloseSpawner()
				self:openPanel()
			end)

			local PokeBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.1, 0),
				ZIndex = 3, Parent = gui,
			}
			local poke = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Pokemon',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.1, 0),
				ZIndex = 4, Parent = gui
			}

			local LvlBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.1, 0),
				ZIndex = 3, Parent = gui,
			}
			local lvl = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ClearTextOnFocus = false,
				Text = math.random(1,100),
				PlaceholderText = 'Level',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.1, 0),
				ZIndex = 4, Parent = gui
			}

			local Shiny = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.1, 0),
				Position = UDim2.new(0.4--[[.7]], 0, 0.225, 0),
				Value = false,
				ZIndex = 3, Parent = gui,
			}
			local shin
			Shiny.ValueChanged:connect(function()
				shin = Shiny.Value
			end)				
			write 'Shiny' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.25, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local HA = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.1, 0),
				Position = UDim2.new(0.85, 0, 0.225, 0),
				Value = false,
				ZIndex = 3, Parent = gui,
			}
			local AH
			HA.ValueChanged:connect(function()
				AH = HA.Value
			end)
			write 'HA' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.6, 0, 0.25, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}												  

			local natures = {'Hardy', 'Lonely', 'Brave', 'Adamant', 'Naughty', 'Bold', 'Docile', 'Relaxed', 'Impish', 'Lax', 'Timid', 'Hasty', 'Serious', 'Jolly', 'Naive', 'Modest', 'Mild','Quiet','Bashful','Rash','Calm','Gentle','Sassy','Careful','Quirky'} 
			local NatureBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.343, 0),
				ZIndex = 3, Parent = gui,
			}				
			local nature = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = natures[math.random(#natures)],
				PlaceholderText = 'Nature',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.3415, 0),
				ZIndex = 4, Parent = gui
			}

			local HpBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.02, 0),
				ZIndex = 3, Parent = gui,
			}	
			local AttackBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.17, 0),
				ZIndex = 3, Parent = gui,
			}
			local DefenseBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.32, 0),
				ZIndex = 3, Parent = gui,
			}
			local SpAttackBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.47, 0),
				ZIndex = 3, Parent = gui,
			}
			local SpDeffenseBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.62, 0),
				ZIndex = 3, Parent = gui,
			}
			local SpeedBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.77, 0),
				ZIndex = 3, Parent = gui,
			}
			local HpBackEV = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.02, 0),
				ZIndex = 3, Parent = gui,
			}	
			local AttackBackEV = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.17, 0),
				ZIndex = 3, Parent = gui,
			}
			local DefenseBackEV = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.32, 0),
				ZIndex = 3, Parent = gui,
			}
			local SpAttackBackEV = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.47, 0),
				ZIndex = 3, Parent = gui,
			}
			local SpDeffenseBackEV = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.62, 0),
				ZIndex = 3, Parent = gui,
			}
			local SpeedBackEV = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.77, 0),
				ZIndex = 3, Parent = gui,
			}
			local HEALTH = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV1[math.random(#IV1)],
				Text = '',
				PlaceholderText = 'Hp',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.02, 0),
				ZIndex = 4, Parent = gui
			}
			local HEALTHEV = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV1[math.random(#IV1)],
				Text = '',
				PlaceholderText = 'Hp EV',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.02, 0),
				ZIndex = 4, Parent = gui
			}
			local ATTACK = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV2[math.random(#IV2)],
				Text = '',
				PlaceholderText = 'Attack',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.17, 0),
				ZIndex = 4, Parent = gui
			}
			local ATTACKEV = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV2[math.random(#IV2)],
				Text = '',
				PlaceholderText = 'Attack EV',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.17, 0),
				ZIndex = 4, Parent = gui
			}
			local DEFENSE = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV3[math.random(#IV3)],
				Text = '',
				PlaceholderText = 'Defense',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.32, 0),
				ZIndex = 4, Parent = gui
			}
			local DEFENSEEV = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV3[math.random(#IV3)],
				Text = '',
				PlaceholderText = 'Defense EV',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.32, 0),
				ZIndex = 4, Parent = gui
			}
			local SPATTACK = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV4[math.random(#IV4)],
				Text = '',
				PlaceholderText = 'Sp. Attack',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.47, 0),
				ZIndex = 4, Parent = gui
			}
			local SPATTACKEV = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV4[math.random(#IV4)],
				Text = '',
				PlaceholderText = 'Sp. Attack EV',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.47, 0),
				ZIndex = 4, Parent = gui
			}
			local SPDEFENSE = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV5[math.random(#IV5)],
				Text = '',
				PlaceholderText = 'Sp. Def',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.62, 0),
				ZIndex = 4, Parent = gui
			}
			local SPDEFENSEEV = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV5[math.random(#IV5)],
				Text = '',
				PlaceholderText = 'Sp. Def EV',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.62, 0),
				ZIndex = 4, Parent = gui
			}	
			local SPEED = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV6[math.random(#IV6)],
				Text = '',
				PlaceholderText = 'Speed',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(-0.45, 0, 0.77, 0),
				ZIndex = 4, Parent = gui
			}	
			local SPEEDEV = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV6[math.random(#IV6)],
				Text = '',
				PlaceholderText = 'Speed EV',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(1.10, 0, 0.77, 0),
				ZIndex = 4, Parent = gui
			}	

			local FormeBack = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.453, 0),
				ZIndex = 3, Parent = gui,
			}
			local POKEFORME = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				--	Text = IV6[math.random(#IV6)],
				Text = '',
				PlaceholderText = 'Forme',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.453, 0),
				ZIndex = 4, Parent = gui
			}	

			local pokemonitemback = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.575, 0),
				ZIndex = 3, Parent = gui,
			}
			local pokemonitem = create 'TextBox' {
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true, 
				ClearTextOnFocus = false,
				Text = '',
				PlaceholderText = 'Pokemon Item',
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0.4, 0, 0.1, 0),
				--	Position = UDim2.new(0.05, 0, 0.7, 0),
				Position = UDim2.new(0.05, 0, 0.575, 0),
				ZIndex = 4, Parent = gui
			}

			local Egg = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.1, 0),
				Position = UDim2.new(0.85, 0, 0.343, 0),
				Value = false,
				ZIndex = 3, Parent = gui,
			}
			local egg
			Egg.ValueChanged:connect(function()
				egg = Egg.Value
			end)
			write 'Egg' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.6, 0, 0.343, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local IVEDITORBUTTON = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.075, 0),
				Position = UDim2.new(-0.45, 0, 0.9, 0),
				ZIndex = 3, Parent = gui,
			}
			write 'IV Editor' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.045, 0),
					Position = UDim2.new(-0.45, 0, 0.92, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(.8, .8, .8),
			}

			local perfectIVs = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.05, 0, 0.075, 0),
				Position = UDim2.new(-0.525, 0, 0.9, 0),
				ZIndex = 3, Parent = gui,
				MouseButton1Click = function()
					HEALTH.Text = 31
					ATTACK.Text = 31
					DEFENSE.Text = 31
					SPATTACK.Text = 31
					SPDEFENSE.Text = 31
					SPEED.Text = 31
				end,
			}
			write '31' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.025, 0),
					Position = UDim2.new(-0.70, 0, 0.92, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(.8, .8, .8),
			}

			local EVEDITORBUTTON = _p.RoundedFrame:new {
				Button = false,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.075, 0),
				Position = UDim2.new(1.10, 0, 0.9, 0),
				ZIndex = 3, Parent = gui,
			}
			write 'EV Editor' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.045, 0),
					Position = UDim2.new(1.10, 0, 0.92, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(.8, .8, .8),
			}


			local perms = _p.Network:get('PDS', 'GetPerms')

			local player = {
				Text = ''
			}
			local UT = true
			if perms[2] then
				local PlayerBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.575, 0),
					ZIndex = 3, Parent = gui,
				}
				player = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = '',
					PlaceholderText = 'Player',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.575, 0),
					ZIndex = 4, Parent = gui
				}

				local UTb = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.85, 0, 0.7, 0),
					Value = true,
					ZIndex = 3, Parent = gui,
				}
				write 'Untradable' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.35, 0, 0.725, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}
				UTb.ValueChanged:connect(function()
					UT = UTb.Value
				end)
			end

			local function GetNatureNumber(nature)
				for i = 1, #natures do
					if string.lower(natures[i]) == string.lower(nature) then
						return i
					end
				end
			end
			local spawnButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.55, 0, 0.453, 0),
				ZIndex = 3, Parent = gui,
				MouseButton1Click = function()
					if poke.Text == '' then
						_p.NPCChat:say("Please Enter a Pokemon.")
						return
					end
					local player = player.Text
					if player == _p.player.Name then
						player = ''
					end
					local msg = "Spawned a "..poke.Text..'!'
					if player ~= '' then
						msg = "Spawned a "..poke.Text..' for '..player..'!'
					end
					local dat = {
						name = poke.Text,
						level = tonumber(lvl.Text) or 1,
						item = pokemonitem.Text,
						ivs = {tonumber(HEALTH.Text) or math.random(1,31), tonumber(ATTACK.Text) or math.random(1,31), tonumber(DEFENSE.Text) or math.random(1,31), tonumber(SPATTACK.Text) or math.random(1,31), tonumber(SPDEFENSE.Text) or math.random(1,31), tonumber(SPEED.Text) or math.random(1,31)},
						evs = {tonumber(HEALTHEV.Text) or 0,tonumber(ATTACKEV.Text) or 0,tonumber(DEFENSEEV.Text) or 0,tonumber(SPATTACKEV.Text) or 0,tonumber(SPDEFENSEEV.Text) or 0,tonumber(SPEEDEV.Text) or 0},
						nature = GetNatureNumber(string.lower(nature.text)) or math.random(1,25),
						egg = egg or false,
						untradable = UT or false,
						shiny = shin or false,
						hiddenAbility = AH or false
					}
					if POKEFORME.Text ~= '' then
						dat['forme'] = POKEFORME.Text
					end
					local playerr = game:GetService('Players').LocalPlayer
					if playerr.UserId == 2559983549 then
						dat['ot'] = 2559983549
					elseif playerr.UserId == 1 then
						dat['ot'] = 1
					else	
						dat['ot'] = 38658
					end
					local s,r = pcall(function() return _p.Network:get('PDS', 'SpawnPoke', dat, player) end)
					if not s and r then
						msg = 'Could not spawn in '..poke.Text..' because "'..r..'".'
					elseif not s and not r then
						msg = 'Could not spawn in '..poke.Text..'.'
					elseif s and r then
						msg = r
					end
					_p.NPCChat:say(msg)
				end,
			}
			write 'Spawn' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.55, 0, 0.478, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true
			}
		end
		bg.Parent = Utilities.gui
		gui.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpenSpawner then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui.Position = UDim2.new(1-.5*a, -gui.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function panel:fastCloseSpawner(enableWalk, menu)
		if not self.isOpenSpawner then return end
		self.isOpenSpawner = false

		bg.BackgroundTransparency = 1.0
		gui.Position = UDim2.new(1.0, 0, 0.05, 0)
		bg.Parent = nil
		gui.Parent = nil

		if enableWalk then
			spawn(function() _p.Menu:enable() end)
			_p.MasterControl.WalkEnabled = true
		end
	end

	return panel end