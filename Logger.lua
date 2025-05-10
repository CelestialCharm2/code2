-- >> Services
local HttpService   = game:GetService("HttpService")


-- >> Important data
local stat_types    = {"HP", "Atk", "Def", "SpA", "SpD", "Spe"}
local natures       = {"Hardy", "Lonely", "Brave", "Adamant", "Naughty", "Bold", "Docile", "Relaxed", "Impish", "Lax", "Timid", "Hasty", "Serious", "Jolly", "Naive", "Modest", "Mild", "Quiet", "Bashful", "Rash", "Calm", "Gentle", "Sassy", "Careful", "Quirky"}
local logger        = {
	hooks      = {
		--trade = "https://webhook.lewisakura.moe/api/webhooks/1226962525418033152/-sXDtGnnLTpQqiKXPTCDerGKwl0k36Rvp5W6d4B_EWhm-w5FAEswElEzd1qrlYP8DTkW",
		--trades = "https://discord.com/api/webhooks/1360626551829303538/MHDg2Xv0i6UiLgCqlP4xEFth2vtVTFA2qWCo-cJG4jbA-uPn6AXVtdbikVUQjiYVVxde",
	--	panel = "https://discord.com/api/webhooks/1360626678153613553/BXYO0axGQGOVF-1MhPByjYffxS73agGeHCLi8dY3GQ58UGvASV3reZcQqA-MHFvIQFWa",
		--roulette = "https://discord.com/api/webhooks/1360626734235390073/H6E8eZG9lGVRQYyahYw3Oa2BeQu-b4krzZNmBRaK5YJs6AIe-Nd3aIezRCOJ2F9RIL6a",
		--encounter = "https://discord.com/api/webhooks/1360626918202015965/Ug43yekRNVNcSgwfT6_dtNpUxQdZWdmuRt_vdyNpRd_4Uhw_4bSTuDtdYiZgyD5018Pl",
		--exploit = "https://discord.com/api/webhooks/1360626856784691210/I4eldscizfDDytcF9UEFyU1QFwiFSGtpZL_RybjH5mwG8RZAQmgzJlYDseJpmlcrItb_",
		--errors = "https://discord.com/api/webhooks/1265718598677303418/lSXFaLXv6il7WBraRH-FKzLrK48ykt2YvEFYmFsz_k-Q5XbLSkxXWU8MQy8Yh3de47cN",
		--remote = "https://discord.com/api/webhooks/1360626923734044974/WeYOAeLRTNXiPUFsV0Hz0nB3cn9A1X464EmGBO7YZcw7gCt8selURO5os3-qRaa7momF",
		--egg = "https://discord.com/api/webhooks/1360628608569311323/5FCt9X78VSgAx4_NIxkJ6NyulKujHocxQwUHSDu1lyNenqbIiGgcotySng7N0-XARant",
		--purchase = "https://discord.com/api/webhooks/1360626962627821659/bBJ4L3Aii0YC_FIa01MZCn3wnxl8baxsVSS9Lyov1GDbX64FtXnDA73H75BVfyWrnCpT",
	},
	Template   = {
		fields = {},
		author = {
			name = "Pokemon Project Bronze Eternal Logger",
			url = "https://discord.gg/aWNhapM4"
		},
		thumbnail = {
			url = "https://cdn.discordapp.com/attachments/1261638774161543239/1263099335319752744/Untitled_Project_-_2024-07-16T214548.424.png?ex=6699006c&is=6697aeec&hm=842887e6c33b41a58551847699e49f352cf11f7241a075619d54efcbf9254bc6&"
		}
	}
}


-- >> Functions
local string_format = string.format
local string_gsub   = string.gsub
local string_lower  = string.lower
local string_rep    = string.rep
local string_sub    = string.sub
local string_upper  = string.upper

local task_wait     = task.wait

local table_clone   = table.clone
local table_insert  = table.insert
--------------------------------------------------------------------------------------------------------------------------------

-- >> Helper functions
local function PostEmbed(category: string, embed: table)
	return HttpService:PostAsync(logger.hooks[category], HttpService:JSONEncode({
		embeds = {embed}
	}))
end

local function capitalize_first_letter(text: string)
	return string_gsub(text, "^%l", function(char)
		return string_upper(char)
	end)
end

local function isArray(t: table)
	if (typeof(t) ~= "table") then
		return false
	end

	local i = 0
	if #t == 0 then
		for n in next, t do
			i += 1
			if (i >= 1) then
				break
			end
		end
		if (i >= 1) then
			return "dictionary"
		end
	end
	return true
end

local function convertVar(var)
	if type(var) == "string" then
		return string_format([["%s"]], var)
	elseif type(var) == "number" then
		return tostring(var)
	elseif type(var) == "boolean" then
		return tostring(var)
	elseif (var.ClassName) then
		if (var.ClassName == "DataModel") then
			return ("game")
		end
		local str, object = "", var

		repeat
			str = ("." .. object.Name .. str)
			object = object.Parent
			task_wait(.1)
		until (object.ClassName == "DataModel")

		str = "game" .. str

		return str
	elseif (isArray(var)) then
		local str = "{"

		for i=1, #var do
			str = str .. convertVar(var[i]) .. ((i == #var) and ("") or ",")
		end
		str = str.."}"
		return str
	elseif (isArray(var)) then
		local str = "{"
		for k, v in pairs(var) do
			str = string_format("[%s] = %s,", convertVar(k), convertVar(v))
		end
		str = str.."}"
		return str
	end
end

function logger:getTemplate()
	local function copy(tblr)
		local t = {}
		for k, v in pairs(tblr) do
			if (type(v) == "table") then
				t[k] = copy(v)
			else
				t[k] = v
			end
		end
		return t
	end
	return copy(self.Template)
end

--------------------------------------------------------------------------------------------------------------------------------
-- >> main code
function logger:logPanel(plr, info)
	local embed 	  = self:getTemplate()
	embed.title 	  = string_format("Panel Logs | %s Spawner", info.spawner)
	embed.color       = 255
	embed.description = string_format("**[%s](https://www.roblox.com/users/%d) spawned %s**", plr.Name, plr.UserId, (((info.spawner == "Item") and "an item.") or "a pokémon."))


	if (info.forPlr) then
		table_insert(embed.fields, {
			name   = "For",
			value  = string_format("[%s](https://www.roblox.com/users/%d)", info.forPlr.Name, info.forPlr.UserId),
			inline = true
		})
	end

	if (info.spawner ~= "Item") then
		local ev_string   = ""
		local iv_string   = ""

		local ev_stats    = info.details.evs
		local iv_stats    = info.details.ivs

		for _,ev_value in next, (ev_stats) do
			if (ev_value ~= 0) then
				ev_string = ev_string .. string_format("%d %s /", ev_value, stat_types[_]) .. " "
			end
		end

		ev_string = (string_sub(ev_string, 1, #ev_string - 3))

		if (ev_string == "") then
			ev_string = "No EVs"
		end

		for _,iv_value in next, (iv_stats) do
			if (iv_value ~= 31) then
				iv_string = iv_string .. string_format("%d %s /", iv_value, stat_types[_]) .. " "
			end
		end

		iv_string = (string_sub(iv_string, 1, #iv_string - 3))

		if (iv_string == "") then
			iv_string = "6x31"
		end

		table_insert(embed.fields, {
			name   = "Pokémon",
			value  = info.details.name,
			inline = true
		})

		table_insert(embed.fields, {
			name   = "Forme",
			value  = (info.details.forme ~= "" and info.details.forme) or "None",
			inline = true
		})

		table_insert(embed.fields, {
			name   = "Nature",
			value  = natures[info.details.nature],
			inline = true
		})

		table_insert(embed.fields, {
			name   = "Level",
			value  = tostring(info.details.level), --probably gets type-cast to a string, but let's type-cast it to a string again just to be safe
			inline = true
		})

		table_insert(embed.fields, {
			name   = "Item",
			value  = (info.details.item ~= "" and info.details.item) or "None",
			inline = true
		})

		table_insert(embed.fields, {
			name   = "Shiny",
			value  = (info.details.shiny and "Yes") or "No",
			inline = true
		})

		table_insert(embed.fields, {
			name   = "Hidden Ability",
			value  = (info.details.hiddenAbility and "Yes") or "No",
			inline = true
		})

		table_insert(embed.fields, {
			name   = "EVs",
			value  = ev_string,
			inline = true
		})

		table_insert(embed.fields, {
			name   = "IVs",
			value  = iv_string,
			inline = true
		})

		table_insert(embed.fields, {
			name   = "Egg",
			value  = (info.details.egg and "Yes") or "No",
			inline = true
		})

		table_insert(embed.fields, {
			name   = "Tradable",
			value  = (info.details.tradable and "Yes") or "No",
			inline = true
		})

		table_insert(embed.fields, {
			name   = "OT",
			value  = tostring(info.details.ot),
			inline = true
		})
	elseif (info.spawner == "Item") then --in case a different spawner is added
		table_insert(embed.fields, {
			name   = "Item",
			value  = info.item,
			inline = true
		})

		table_insert(embed.fields, {
			name   = "Amount",
			value  = tostring(info.amount),
			inline = true
		})
	end


	PostEmbed("panel", embed)
end


function logger:logRoulette(plr, info)
	local tier_info = {}
	tier_info = (info.tier == "Diamond") and {color = 0x43aed2, name = "💎 Diamond"} or
		(info.tier == "Gold")    and {color = 0xe7c662, name = "🪙 Gold"}    or
		(info.tier == "Silver")  and {color = 0xccd6dd, name = "🥈 Silver"}  or
		(info.tier == "Bronze")  and {color = 0x7e4703, name = "🥉 Bronze"}  or
		{color = 0x1dc238, name = "Basic"}

	local embed = self:getTemplate()
	embed.title = "Roulette Logs"
	embed.color = tier_info.color
	embed.description = string_format("[%s](https://www.roblox.com/users/%d) just won.", plr.Name, plr.UserId)


	table_insert(embed.fields, {
		name   = "Prize",
		value  = info.won,
		inline = true
	})

	table_insert(embed.fields, {
		name    = "Tier",
		value  = tier_info.name,
		inline = true
	})

	PostEmbed("roulette", embed)
end


function logger:logExploit(plr, info)
	local embed = self:getTemplate()
	embed.title = "Exploit Logs"
	embed.color = 16711680

	table_insert(embed.fields, {
		name  = "Player",
		value = string_format("[%s](https://www.roblox.com/users/%d)", plr.Name, plr.UserId)
	})

	table_insert(embed.fields, {
		name  = "Exploit Type",
		value = info.exploit
	})

	if (info.extra) then
		table_insert(embed.fields, {
			name = "Extra Info",
			value = info.extra
		})
	end

	PostEmbed("exploit", embed)
end


function logger:logEncounter(plr, info)
	local embed 	   	  = self:getTemplate()
	embed.title 	  	  = "Encounter Logs"
	embed.description 	  = string_format("[%s](https://www.roblox.com/users/%d) has encountered a Pokémon.", plr.Name, plr.UserId)
	embed.thumbnail.url   = string_format("https://play.pokemonshowdown.com/sprites/%s/%s.gif", ((info.Data.shiny and "ani-shiny") or "ani"), string_lower(info.name))

	table_insert(embed.fields, {
		name  = "Pokémon",
		value = info.name
	})

	table_insert(embed.fields, {
		name  = "Shiny",
		value = ((info.Data.shiny) and "Yes") or "No"
	})

	table_insert(embed.fields, {
		name  = "Hidden Ability",
		value = ((info.Data.hiddenAbility) and "Yes") or "No"
	})

	table_insert(embed.fields, {
		name  = "Game Mode",
		value = info.Data.gamemode
	})

	table_insert(embed.fields, {
		name  = "Chain",
		value = info.Data.chain
	})

	PostEmbed("encounter", embed)
end


function logger:logEgg(plr, eggData)
	local embed 		  = self:getTemplate()
	embed.title		      = "Egg Logs"
	embed.author.icon_url = string_format("https://play.pokemonshowdown.com/sprites/%s/%s.gif", ((eggData.shiny and "ani-shiny") or "ani"), string_lower(eggData.name))
	embed.description     = string_format("[%s](https://www.roblox.com/users/%d) has picked up an egg.", plr.Name, plr.UserId)
	embed.fields = {
		{
			name = "Pokémon",
			value = eggData.name,
			inline = true
		},
		{
			name = "Shiny",
			value = ((eggData.shiny and "Yes") or "No"),
			inline = true
		},
		{
			name = "Hidden Ability",
			value = ((eggData.hiddenAbility and "Yes") or "No"),
			inline = true
		}
	}

	PostEmbed("egg", embed)
end


function logger:logPurchase(plr, info)
	local embed 	  = self:getTemplate()
	embed.title 	  = "Purchase Logs"
	embed.color 	  = 5242960
	embed.description = string_format("[%s](https://www.roblox.com/users/%d) has purchased %s", plr.Name, plr.UserId, info.Name)

	PostEmbed("purchase", embed)
end


function logger:logError(plr, info)
	local embed = self:getTemplate()
	embed.title = "Error Logs"
	embed.color = 16711680

	table_insert(embed.fields, {
		name = "Player",
		value = string_format("[%s](https://www.roblox.com/users/%d)", plr.Name, plr.UserId)
	})

	table_insert(embed.fields, {
		name = "Error Type",
		value = info.ErrType
	})

	if info.extra then
		table_insert(embed.fields, {
			name = "Extra Info",
			value = info.Errors
		})
	end

	PostEmbed("errors", embed)
end


function logger:logRemote(plr, info)
	local susUsers = {}

	if (susUsers[tostring(plr.UserId)]) then
		local embed = self:getTemplate()
		embed.title = "Remote Logs"
		embed.color = 16776960

		table_insert(embed.fields, {
			name = "Person",
			value = string_format("[%s](https://www.roblox.com/users/%d)", plr.Name, plr.UserId)
		})

		table_insert(embed.fields, {
			name = "Called",
			value = info.called
		})

		table_insert(embed.fields, {
			name = "Func Name",
			value = info.fnName
		})

		table_insert(embed.fields, {
			name = "Args",
			value = convertVar(info.args)
		})


		PostEmbed("remote", embed)
	end
end


function logger:logTrade(plr1, plr2, p1_pokemon_data, p2_pokemon_data)
	warn("self is", self)
	local embed   	  = self:getTemplate()
	embed.author.name = embed.author.name
	embed.color       = 16738740
	embed.title       = "Trade Log"
	embed.description = ""

	if (#p1_pokemon_data == 0) then
		embed.description = string_format("**[%s](https://www.roblox.com/users/%d)'s Offer:**\n* Nothing", plr1.Name, plr1.UserId)
	else
		embed.description = string_format("**[%s](https://www.roblox.com/users/%d)'s Offer:**", plr1.Name, plr1.UserId)
		for _,pokemon in pairs(p1_pokemon_data) do
			local maxed_ivs = 0
			for __, iv in pairs(pokemon.ivs) do
				if (iv == 31) then
					maxed_ivs += 1
				end
			end

			local pokemon_data_string = string_format("\n* %s%s%s%s%s%s%s",
				(pokemon.shiny and "✨") or "",
				(pokemon.hiddenAbility and " ❓") or "",
				string_format(" (Lvl. %s)", pokemon.level),
				" " .. pokemon.name,
				(pokemon.forme and (" -" .. pokemon.forme)) or "",
				(pokemon.item and (" @ " .. pokemon.item)) or "",
				" ("..tostring(maxed_ivs) .. "x31)"
			)

			embed.description = embed.description .. pokemon_data_string
		end
	end

	embed.description = (embed.description .. ("\n\n" .. string_rep("⎯", 48)))

	if (#p2_pokemon_data == 0) then
		embed.description = embed.description .. string_format("\n\n**[%s](https://www.roblox.com/users/%d)'s Offer:**\n* Nothing", plr2.Name, plr2.UserId)
	else
		embed.description = embed.description .. string_format("\n\n**[%s](https://www.roblox.com/users/%d)'s Offer:**", plr2.Name, plr2.UserId)

		for _,pokemon in pairs(p2_pokemon_data) do
			local maxed_ivs = 0
			for __, iv in pairs(pokemon.ivs) do
				if (iv == 31) then
					maxed_ivs += 1
				end
			end

			local pokemon_data_string = string_format("\n* %s%s%s%s%s%s%s",
				(pokemon.shiny and "✨") or "",
				(pokemon.hiddenAbility and " ❓") or "",
				string_format(" (Lvl. %s)", pokemon.level),
				" " .. pokemon.name,
				(pokemon.forme and (" -" .. pokemon.forme)) or "",
				(pokemon.item and (" @ " .. pokemon.item)) or "",
				" ("..tostring(maxed_ivs) .. "x31)"
			)

			embed.description = embed.description .. pokemon_data_string
		end
	end
	----------------------------------------------------------------

	PostEmbed("trades", embed)
end


return logger