-- gobble if u need help adding pokemon lmk ;)
return function(_p)
	local Utilities = _p.Utilities 
	local Tween = Utilities.Tween
	local pkShop = {} 
	local npcChat = _p.NPCChat 
	local v5 = Color3.fromRGB(102, 204, 255) 
	local u1 = nil 
	local create = Utilities.Create 
	local Write = Utilities.Write 
	local saying
	local selection
	local update
	function pkShop:buySelection()
		local item = selection.item
		_p.Network:get('PDS', 'buyShop',item.name)
	end
	function pkShop:buildList()
		local v6 = _p.Network:get("PDS", "getShop", "poke") 
		local scroll = u1.Scroller 
		local ContentContainer = scroll.ContentContainer 
		ContentContainer:ClearAllChildren() 
		scroll.CanvasSize = UDim2.new(scroll.Size.X.Scale, -1, (#v6 + 1) * 0.06 * ContentContainer.AbsoluteSize.X / scroll.AbsoluteSize.Y * scroll.Size.Y.Scale, 0) 
		selection = nil

		for v9, thing in pairs(v6) do
			local v11 = {
				AutoButtonColor = false, 
				BackgroundColor3 = Color3.fromRGB(102, 204, 255)
			} 
			local v12
			if v9 % 2 == 0 then
				v12 = 0 
			else
				v12 = 1 
			end 
			v11.BackgroundTransparency = v12 
			v11.BorderSizePixel = 0 
			v11.Size = UDim2.new(0.80*1.2, 0, 0.06, 0)
			v11.Position = UDim2.new(0.025, 0, 0.06 * (v9 - 1), 0) 
			v11.ZIndex = 2 
			v11.ScaleType = Enum.ScaleType.Fit 
			v11.Parent = ContentContainer 
			local u4 = create("ImageButton")(v11) 
			Utilities.fastSpawn(function()
				local tm = false
				local item, move, pknm, hover
				if thing[1]:sub(1, 2) == 'TM' then
				elseif thing[1]:sub(1, 4) == 'PKMN' then
					local mon = string.split(thing[1], ' ')[2]
					print('ismon ',mon)
					pknm = true
					item = true
					if mon == 'Random-Shiny' then
						item = {
							name = mon,
							desc = 'Random Shiny',
							iconnumber = 2013
						}
					elseif mon == 'Random-6x31' then
						item = {
							name = mon,
							desc = 'Random 6x31 Pokemon',
							iconnumber = 2013
						}
					elseif mon == 'Random-Shiny-6x31' then
						item = {
							name = mon,
							desc = 'Random 6x31 Shiny Pokemon',
							iconnumber = 2013
						}
					elseif mon == 'Bidoof-Rainbow' then
						item = {
							name = mon,
							desc = 'Rainbow Bidoof',
							iconnumber = 888
						}
					elseif mon == 'Mew-Rainbow' then
						item = {
							name = mon,
							desc = 'Rainbow Mew',
							iconnumber = 162
						}
					elseif mon == 'Mewtwo-Shadow' then
						item = {
							name = mon,
							desc = 'Shadow Mewtwo',
							iconnumber = 2012
						}
						--elseif mon == 'Iron-Frill' then
						--	item = {
						--		name = mon,
						--		desc = '',
						--		iconnumber = 1
						--	}
						--elseif mon == 'Frigid-Wing' then
						--	item = {
						--		name = mon,
						--		desc = '',
						--		iconnumber = 1
						--	}
					end
					--if item == 'masterball' then
					--	item = {
					--		name = item,
					--		desc = '100% Capture Rate',
					--		iconnumber = 1,
					--	}
					--end
				else
					item = _p.DataManager:getData('Items', thing[1])
				end

				if not u4.Parent then return end
				local text = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.91, 0, 0.7, 0),
					Position = UDim2.new(0.072, 0, 0.15, 0),
					ZIndex = 3, Parent = u4,
				}
				Write((tm and thing[1]) or item.name) { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }
				local price = thing[2]
				local isRobux = type(price) == 'string' and price:sub(1,1) == 'r'
				if isRobux then
					price = tonumber(price:sub(2))
					local icon = _p.Pokemon:getIcon(item.iconnumber, false)
					icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
					icon.Size = UDim2.new(1, 0, 1, 0)
					icon.Position = UDim2.new()
					icon.Parent = u4
					Write(_p.PlayerData:formatMoney(price)..' R$') { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right }
				else
					Write('[$] '.._p.PlayerData:formatMoney(price)) { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right }
				end		
				u4.MouseButton1Click:connect(function()
					local descContainer = u1.Details.DescContainer
					descContainer:ClearAllChildren()
					if tm then
					elseif item.desc then
						Write(item.desc) { Frame = descContainer, Size = descContainer.AbsoluteSize.Y/5.8, Wraps = true }
					end
					u1.Details.IconContainer:ClearAllChildren()

					local icon = _p.Pokemon:getIcon(item.iconnumber, false)
					icon.SizeConstraint = Enum.SizeConstraint.RelativeXY
					icon.Size = UDim2.new(1.0, 0, 1.0, 0)
					icon.Parent = u1.Details.IconContainer
					selection = {item = item, price = thing[2], icon = icon, index = v9}--, encryptedId = encryptedId}

					pcall(function() u1.Details.BuyButton.BuyText:Remove() end)
					Write("Buy")({
						Frame = create("Frame")({
							BackgroundTransparency = 1, 
							Size = UDim2.new(1, 0, 0.6, 0), 
							Position = UDim2.new(0, 0, 0.2, 0),
							Name = 'BuyText',
							ZIndex = 5, 
							Parent = u1.Details.BuyButton
						}), 
						Scaled = true
					}) 
					u1.Details.BuyButton.Visible = true
				end)
			end)
		end
	end

	local u5 = nil 
	local u6 = Color3.fromRGB(89, 179, 255) 
	local u7 = Color3.fromRGB(33, 84, 185) 
	local u8 = Color3.fromRGB(0, 32, 96) 
	function pkShop:loadShop()
		local l__fadeGui__18 = Utilities.fadeGui 
		if not u1 then
			local v19 = Utilities.gui.AbsoluteSize.Y * 0.035 
			u5 = Utilities.Signal() 
			local v20 = {
				Name = "ArcadeShopGUI", 
				BackgroundColor3 = u6, 
				SizeConstraint = Enum.SizeConstraint.RelativeYY, 
				--ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.new(1.2, 0, .9, 0),
				Position = UDim2.new(0, Utilities.gui.AbsoluteSize.X * 1.2, 0.05, 0), 
				Parent = Utilities.gui, 
				ZIndex = 2
			} 
			local v21 = {
				Name = "Details", 
				BackgroundColor3 = u7, 
				Size = UDim2.new(1.05, 0, 0.2, 0), 
				Position = UDim2.new(-0.025, 0, 0.775, 0), 
				ZIndex = 3
			} 
			local v22 = {
				Name = "BuyButton", 
				Button = true, 
				BackgroundColor3 = u8,
				Size = UDim2.new(0.2, 0, 0.425, 0),
				Position = UDim2.new(0.0125, 0, 0.5, 0), 
				ZIndex = 4, 
				Visible = false
			} 
			function v22.MouseButton1Click()
				self:buySelection() 
			end 
			v21[1] = create("Frame")({
				Name = "DescContainer", 
				BackgroundTransparency = 1, 
				Size = UDim2.new(0.75, 0, 0.85, 0), 
				Position = UDim2.new(0.225, 0, 0.075, 0), 
				ZIndex = 4
			}) 
			v21[2] = create("Frame")({
				Name = "IconContainer", 
				BackgroundTransparency = 1, 
				SizeConstraint = Enum.SizeConstraint.RelativeYY, 
				Size = UDim2.new(0.5, 0, 0.5, 0), 
				Position = UDim2.new(0.04, 0, 0, 0)
			}) 
			v21[3] = _p.RoundedFrame:new(v22) 
			v20[1] = _p.RoundedFrame:new({
				Name = "TitleBar", 
				BackgroundColor3 = u7, 
				Size = UDim2.new(1.05, 0, 0.1, 0), 
				Position = UDim2.new(-0.025, 0, 0.025, 0), 
				ZIndex = 3,
				create("Frame")({
					Name = "TextContainer", 
					BackgroundTransparency = 1, 
					Size = UDim2.new(0.75, 0, 0.7, 0),
					Position = UDim2.new(0.025, 0, 0.15, 0), 
					ZIndex = 4
				})
			}) 
			v20[2] = create("ScrollingFrame")({
				Name = "Scroller", 
				BackgroundTransparency = 1, 
				BorderSizePixel = 0, 
				Size = UDim2.new(0.80*1.2, 0, 0.6, 0),
				Position = UDim2.new(0.025, 0, 0.15, 0),
				ScrollBarThickness = v19, 
				ZIndex = 3,
				create("Frame")({
					BackgroundTransparency = 1, 
					Name = "ContentContainer", 
					Size = UDim2.new(1, -v19, 1, -v19), 
					SizeConstraint = Enum.SizeConstraint.RelativeXX
				})
			}) 
			v20[3] = _p.RoundedFrame:new(v21) 
			u1 = _p.RoundedFrame:new(v20).gui 
			Write("Pok[e\']Shop")({
				Frame = u1.TitleBar.TextContainer, 
				Scaled = true, 
				TextXAlignment = Enum.TextXAlignment.Left
			}) 
			Write("Buy")({
				Frame = create("Frame")({
					BackgroundTransparency = 1, 
					Size = UDim2.new(1, 0, 0.6, 0), 
					Position = UDim2.new(0, 0, 0.2, 0),
					Name = 'BuyText',
					ZIndex = 5, 
					Parent = u1.Details.BuyButton
				}), 
				Scaled = true
			}) 
			local v23 = {
				Button = true, 
				BackgroundColor3 = u8, 
				Size = UDim2.new(0.3, 0, 0.8, 0), 
				Position = UDim2.new(0.69, 0, 0.1, 0), 
				ZIndex = 4, 
				Parent = u1.TitleBar
			} 
			local u9 = "off" 
			function v23.MouseButton1Click()
				if u9 == "transition" then
					return 
				end 
				u9 = "transition" 
				delay(0.3, function()
					u5:fire() 
				end) 
				local l__Offset__10 = u1.Position.X.Offset 
				local u11 = Utilities.gui.AbsoluteSize.X * 1.2 
				Utilities.Tween(0.8, "easeOutCubic", function(p4)
					u1.Position = UDim2.new(0, l__Offset__10 + (u11 - l__Offset__10) * p4, 0.05, 0) 
					l__fadeGui__18.BackgroundTransparency = 0.3 + p4 * 0.7 
				end) 
				l__fadeGui__18.BackgroundTransparency = 1 
				u9 = "off" 
			end 
			Write("Close")({
				Frame = create("Frame")({
					BackgroundTransparency = 1, 
					Size = UDim2.new(1, 0, 0.7, 0), 
					Position = UDim2.new(0, 0, 0.15, 0), 
					ZIndex = 5, 
					Parent = _p.RoundedFrame:new(v23).gui
				}), 
				Scaled = true
			}) 
		end 
		self:buildList()
		u1.Details.BuyButton.Visible = false
		l__fadeGui__18.ZIndex = 1 
		l__fadeGui__18.BackgroundColor3 = Color3.new(0, 0, 0) 
		local l__Offset__12 = u1.Position.X.Offset 
		local u13 = Utilities.gui.AbsoluteSize.X / 2 - u1.AbsoluteSize.X / 2 
		Utilities.Tween(0.8, "easeOutCubic", function(p5)
			u1.Position = UDim2.new(0, l__Offset__12 + (u13 - l__Offset__12) * p5, 0.05, 0) 
			l__fadeGui__18.BackgroundTransparency = 1 - p5 * 0.7 
		end) 
		u5:wait()
	end 
	return pkShop 
end 
