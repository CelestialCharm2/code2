local _f = require(script.Parent.Parent)

local null, toId, Not, deepcopy, shallowcopy, indexOf; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	null = util.null
	toId = util.toId
	Not = util.Not
	deepcopy = util.deepcopy
	shallowcopy = util.shallowcopy
	indexOf = util.indexOf
end

local function Or(a, b)
	if Not(a) then
		return b
	end
	return a
end

local MegaColors = {
	Venusaur   = {{'Artichoke','Bright red'},{'Sea green','Bright yellow'}},
	CharizardX = {{'Black','Cyan'},{'Bright bluish green','Crimson'}},
	CharizardY = {{'Bright orange','Bright bluish green'},{'Lavender','Crimson'}},
	Blastoise  = {{'Brown','Bright blue'},{'Earth green','Alder'}},
	Alakazam   = {{'Brown','Bright yellow'},{'Lilac','Bright yellow'}},
	Gengar     = {{'Mulberry','Pink'},{'White','Mauve'}},
	GengarH    = {{'Black','Black'},{'Bright orange','Bright green'}},-- can only be shiny
	NecrozmaU   = {{'Black','Bright yellow'},{'Gold','Neon orange'}},-- can only be shiny
	SceptileC   = {{'Earth green','Fog'},{'Bright red','Pastel yellow'}},
	Kangaskhan = {{'Brown','Medium blue'},{'Cloudy grey','Alder'}},
	Pinsir     = {{'Flint','Pastel blue-green'},{'Alder','Pastel blue-green'}},
	Gyarados   = {{'Bright blue','Persimmon'},{'Bright red','White'}},
	Aerodactyl = {{'Medium stone grey','Alder'},{'Alder','Electric blue'}},
	MewtwoX    = {{'Carnation pink','Sunrise'},{'Lime green','Fossil'}},-- move non-mega left
	MewtwoY    = {{'Sunrise','White'},{'Mint','White'}},
	Ampharos   = {{'Bright yellow','White'},{'Mauve','White'}},
	Scizor     = {{'Bright red','Bright blue'},{'Br. yellowish green','Bright yellow'}},
	Heracross  = {{'Bright blue','Bright red'},{'Carnation pink','Bright red'}},
	Houndoom   = {{'Dark stone grey','Bright orange'},{'Storm blue','Bright red'}},
	Tyranitar  = {{'Medium green','Bright red'},{'Daisy orange','Alder'}},
	Blaziken   = {{'Bright red','Bright orange'},{'Gold','Neon orange'}},
	Gardevoir  = {{'Mint','White','Persimmon'},{'Smoky grey','Medium blue','Bright orange'}},
	GardevoirH    = {{'Black','Bright orange'},{'Bright orange','Bright green'}},
	Mawile     = {{'Dark stone grey','Lavender'},{'Lilac','Bright violet'}},
	Aggron     = {{'Dark stone grey','White'},{'Bright bluish green','Brick yellow'}},
	Medicham   = {{'Pink','Fossil'},{'Steel blue','Cork'}},
	Manectric  = {{'Daisy orange','Medium blue'},{'Smoky grey','Bright yellow'}},
	Banette    = {{'Smoky grey','Pink'},{'Storm blue','Pink'}},
	Absol      = {{'Sand blue','White'},{'Persimmon','Pastel orange'}},
	Garchomp   = {{'Lavender','Bright red'},{'Lilac','Hot pink'}},
	Lucario    = {{'Bright bluish green','Black'},{'Olive','Sand blue'}},
	Abomasnow  = {{'Bright bluish green','White','Medium blue'},{'Storm blue','White','Medium blue'}},
	Beedrill   = {{'Black','Bright yellow'},{'Black','Bright green'}},-- clean wings
	Pidgeot    = {{'Nougat','Persimmon','Brick yellow'},{'Br. yellowish orange','Daisy orange','Bright violet'}},-- move left
	Slowbro    = {{'Baby blue','Light reddish violet'},{'Cork','Alder'}},
	Steelix    = {{'Fossil','White'},{'Daisy orange','White'}},
	Sceptile   = {{'Moss','Persimmon'},{'Bright bluish green','Daisy orange'}},
	Swampert   = {{'Cyan','Bright orange'},{'Carnation pink','Bright orange'}},
	Sableye    = {{'Lavender','Persimmon'},{'Gold','Bright green'}},
	Sharpedo   = {{'Electric blue','White'},{'Lilac','Mauve'}},
	Camerupt   = {{'Smoky grey','Neon orange'},{'Smoky grey','Neon orange'}},
	Altaria    = {{'Pastel Blue','White'},{'Cool yellow','White'}},
	Glalie     = {{'White','Bright blue'},{'White','Bright red'}},
	Salamence  = {{'Cyan','Bright red'},{'Lime green','Neon orange'}},
	Metagross  = {{'Cyan','Fossil'},{'Fossil','Bright yellow'}},
	Latias     = {{'Pastel violet','White','Bright red'},{'Neon green','White','Bright yellow'}},
	Latios     = {{'Pastel violet','White','Bright blue'},{'Neon green','White','Bright bluish green'}},
	Rayquaza   = {{'Dark green','Bright yellow'},{'Black','Bright yellow'}},-- move left
	Lopunny    = {{'Brown','Beige'},{'Linen','Pink'}},
	Gallade    = {{'White','Bright green'},{'White','Bright blue'}},
	Audino     = {{'White','Carnation pink'},{'White','Alder'}},
	Diancie    = {{'White','Pink'},{'Black','Pink'}},
}

do
	local cache = {['Neon orange']=1005}
	local default = BrickColor.new('aofpisjadf')
	for name, t in pairs(MegaColors) do
		for i, set in pairs(t) do
			for j, color in pairs(set) do
				local n = cache[color]
				if n then
					set[j] = n
				else
					local bc = BrickColor.new(color)
					if bc == default and color ~= 'Medium stone grey' then
						error('typo in color for '..name..': '..color, 0)
					end
					n = bc.Number
					cache[color] = n
				end
			end
		end
	end
	--	print('colors passed')
end


return function(Battle)
	function Battle:runMove(move, pokemon, target, sourceEffect, zMove, maxMove)--, zMove)
		local baseMove = self:getMove(move)
		if not sourceEffect and (toId(baseMove) ~= 'struggle' and not zMove and not maxMove) then
			local changedMove = self:runEvent('OverrideDecision', pokemon, target, baseMove)
			if changedMove and changedMove ~= true then
				baseMove = changedMove
				target = nil
			end
		end
		move = baseMove
		if not target and target ~= false then target = self:resolveTarget(pokemon, move) end
		if (zMove) then move = self:getActiveZMove(move, pokemon) end
		if (maxMove) then move = self:getMaxMove(move, pokemon) end

		self:setActiveMove(move, pokemon, target)

		--[[if pokemon.moveThisTurn ~= '' then
			-- THIS IS PURELY A SANITY CHECK
			-- DO NOT TAKE ADVANTAGE OF THIS TO PREVENT A POKEMON FROM MOVING;
			-- USE self:cancelMove INSTEAD
			self:debug(pokemon.id .. ' INCONSISTENT STATE, ALREADY MOVED: ' .. pokemon.moveThisTurn)
			self:clearActiveMove(true)
			return
		end]]

		local ev_res = self:runEvent('BeforeMove', pokemon, target, move)
		--		self:debug('BeforeMove event result:', ev_res == null and 'null' or ev_res)
		if Not(ev_res) then
			-- Prevent invulnerability from persisting until the turn ends
			pokemon:removeVolatile('twoturnmove')
			-- Prevent Pursuit from running again against a slower U-turn/Volt Switch/Parting Shot
			pokemon.moveThisTurn = true
			self:clearActiveMove(true)
			return
		end
		if move.beforeMoveCallback then
			if self:call(move.beforeMoveCallback, pokemon, target, move) then
				self:clearActiveMove(true)
				return
			end
		end
		pokemon.lastDamage = 0
		local lockedMove = self:runEvent('LockMove', pokemon)
		if lockedMove == true then lockedMove = false end
		if not lockedMove then
			if not pokemon:deductPP(baseMove, nil, target) and (move.id ~= 'struggle') then
				self:add('cant', pokemon, 'nopp', move)
				self:clearActiveMove(true)
				return
			end
		else
			sourceEffect = self:getEffect('lockedmove')
		end
		pokemon:moveUsed(move)
		self:useMove(move, pokemon, target, sourceEffect, zMove)
		self:singleEvent('AfterMove', move, nil, pokemon, target, move)
	end
	function Battle:useMove(move, pokemon, target, sourceEffect, zMove)
		if not sourceEffect and self.effect.id then sourceEffect = self.effect end
		move = self:getMoveCopy(move)
		if self.activeMove then move.priority = self.activeMove.priority end
		local baseTarget = move.target
		if not target and target ~= false then target = self:resolveTarget(pokemon, move) end
		if move.target == 'self' or move.target == 'allies' then
			target = pokemon
		end
		if sourceEffect then move.sourceEffect = sourceEffect.id end
		local moveResult = false

		self:setActiveMove(move, pokemon, target)

		self:singleEvent('ModifyMove', move, nil, pokemon, target, move, move)
		if baseTarget ~= move.target then
			-- Target changed in ModifyMove, so we must adjust it here
			-- Adjust before the next event so the correct target is passed to the
			-- event
			target = self:resolveTarget(pokemon, move)
		end
		move = self:runEvent('ModifyMove', pokemon, target, move, move)
		if baseTarget ~= move.target then
			-- Adjust again
			target = self:resolveTarget(pokemon, move)
		end
		if not move then return false end

		local attrs = ''
		local missed = false
		if pokemon.fainted then
			return false
		end

		if move.flags['charge'] and not pokemon.volatiles[move.id] then
			attrs = '|[still]' -- suppress the default move animation
		end

		local movename = move.name
		if move.id == 'hiddenpower' then movename = 'Hidden Power' end
		if sourceEffect and sourceEffect ~= '' and sourceEffect.id ~= '' then attrs = attrs .. '|[from]' .. self:getEffect(sourceEffect) end
		if zMove and move.category == 'Status' then
			attrs = '|[anim]'..movename..''..attrs
			--movename = 'Z-'..movename
		end
		self:addMove('move', pokemon, movename, ((type(target)=='table' and target.toString) and target or tostring(target)) .. attrs) -- tbh we don't really need target in here, do we?
		if zMove then self:runZPower(move, pokemon) end

		if target == false then
			self:attrLastMove('[notarget]')
			self:add('-notarget')
			if move.target == 'normal' then pokemon.isStaleCon = 0 end
			return true
		end

		local targets = pokemon:getMoveTargets(move, target)
		local extraPP = 0
		for _, target in pairs(targets) do
			if target ~= null then
				local ppDrop = self:singleEvent('DeductPP', target:getAbility(), target.abilityData, target, pokemon, move)
				if ppDrop ~= true then
					extraPP = extraPP + (ppDrop or 0)
				end
			end
		end
		if extraPP > 0 then
			pokemon:deductPP(move, extraPP)
		end
		if Not(self:runEvent('TryMove', pokemon, target, move)) then
			return true
		end

		self:singleEvent('UseMoveMessage', move, nil, pokemon, target, move)

		if move.ignoreImmunity == nil then
			move.ignoreImmunity = (move.category == 'Status')
		end

		local damage = false
		if move.target == 'all' or move.target == 'foeSide' or move.target == 'allySide' or move.target == 'allyTeam' then
			damage = self:tryMoveHit(target, pokemon, move)
			if damage or damage == nil then moveResult = true end
		elseif move.target == 'allAdjacent' or move.target == 'allAdjacentFoes' then
			if move.selfdestruct then
				self:faint(pokemon, pokemon, move)
			end
			if #targets == 0 then
				self:attrLastMove('[notarget]')
				self:add('-notarget')
				return true
			end
			if #targets > 1 then move.spreadHit = true end
			damage = 0
			for _, target in pairs(targets) do
				local hitResult = self:tryMoveHit(target, pokemon, move, true)
				--				require(game.ReplicatedStorage.src.Utilities).print_r({damage, hitResult})
				if hitResult ~= null and hitResult ~= false then moveResult = true end
				damage = damage + Or(hitResult, 0)
			end
			if pokemon.hp <= 0 then pokemon:faint() end
		else
			target = targets[1]
			local lacksTarget = target==null or target.fainted
			if not lacksTarget then
				if move.target == 'adjacentFoe' or move.target == 'adjacentAlly' or move.target == 'normal' or move.target == 'randomNormal' then
					lacksTarget = not self:isAdjacent(target, pokemon)
				end
			end
			if lacksTarget then
				self:attrLastMove('[notarget]')
				self:add('-notarget')
				if move.target == 'normal' then pokemon.isStaleCon = 0 end
				return true
			end
			damage = self:tryMoveHit(target, pokemon, move)
			if damage or damage == nil then moveResult = true end
		end
		if pokemon.hp <= 0 then
			self:faint(pokemon, pokemon, move)
		end

		if not moveResult then
			self:singleEvent('MoveFail', move, nil, target, pokemon, move)
			return true
		end

		if move.selfdestruct then
			self:faint(pokemon, pokemon, move)
		end

		if not move.negateSecondary and not (pokemon:hasAbility('sheerforce') and pokemon.volatiles['sheerforce']) then
			self:singleEvent('AfterMoveSecondarySelf', move, nil, pokemon, target, move)
			self:runEvent('AfterMoveSecondarySelf', pokemon, target, move)
		end
		return true
	end
	function Battle:tryMoveHit(target, pokemon, move, spreadHit)
		if move.selfdestruct and spreadHit then pokemon.hp = 0 end

		self:setActiveMove(move, pokemon, target)
		local hitResult = true

		hitResult = self:singleEvent('PrepareHit', move, {}, target, pokemon, move)
		if Not(hitResult) then
			if hitResult == false then self:add('-fail', target) end
			return false
		end
		self:runEvent('PrepareHit', pokemon, target, move)

		if Not(self:singleEvent('Try', move, nil, pokemon, target, move)) then
			return false
		end

		if move.target == 'all' or move.target == 'foeSide' or move.target == 'allySide' or move.target == 'allyTeam' then
			if move.target == 'all' then
				hitResult = self:runEvent('TryHitField', target, pokemon, move)
			else
				hitResult = self:runEvent('TryHitSide', target, pokemon, move)
			end
			if Not(hitResult) then
				if hitResult == false then self:add('-fail', target) end
				return true
			end
			return self:moveHit(target, pokemon, move)
		end

		if move.ignoreImmunity == nil then
			move.ignoreImmunity = (move.category == 'Status')
		end

		if move.ignoreImmunity ~= true and (move.ignoreImmunity == false or not move.ignoreImmunity[move.type]) and not target:runImmunity(move.type, true) then
			return false
		end

		hitResult = self:runEvent('TryHit', target, pokemon, move)
		if Not(hitResult) then
			if hitResult == false then self:add('-fail', target) end
			return false
		end

		local boostTable = {4/3, 5/3, 2, 7/3, 8/3, 3}

		-- calculate true accuracy
		local accuracy = move.accuracy
		if accuracy ~= true then
			if not move.ignoreAccuracy then
				local boosts = self:runEvent('ModifyBoost', pokemon, nil, nil, deepcopy(pokemon.boosts))
				local boost = self:clampIntRange(boosts['accuracy'], -6, 6)
				if boost > 0 then
					accuracy = accuracy * boostTable[boost]
				elseif boost < 0 then
					accuracy = accuracy / boostTable[-boost]
				end
			end
			if not move.ignoreEvasion then
				local boosts = self:runEvent('ModifyBoost', target, nil, nil, deepcopy(target.boosts))
				local boost = self:clampIntRange(boosts['evasion'], -6, 6)
				if boost > 0 then
					accuracy = accuracy / boostTable[boost]
				elseif boost < 0 then
					accuracy = accuracy * boostTable[-boost]
				end
			end
		end
		if move.ohko then -- bypasses accuracy modifiers
			if not target:isSemiInvulnerable() then
				accuracy = 30
				if pokemon.level >= target.level then
					accuracy = accuracy + (pokemon.level - target.level)
				else
					self:add('-immune', target, '[ohko]')
					return false
				end
			end
		else
			accuracy = self:runEvent('ModifyAccuracy', target, pokemon, move, accuracy)
		end
		if move.alwaysHit then
			accuracy = true -- bypasses ohko accuracy modifiers
		else
			accuracy = self:runEvent('Accuracy', target, pokemon, move, accuracy)
		end
		if accuracy ~= true and math.random(99) >= accuracy then
			if not spreadHit then self:attrLastMove('[miss]') end
			self:add('-miss', pokemon, target)
			return false
		end
		if move.stealsBoost then
			local stolen = false
			local boosts = {}
			for _, statName in pairs(target.boosts) do
				local stage = target.boosts[statName]
				if (stage > 0) then
					boosts[statName] = stage
					stolen = true
				end
			end
			if stolen then
				self:attrLastMove('[still]')
				self:add('-clearpositiveboost', target, pokemon, 'move: '..move.name)
				self:boost(boosts, pokemon, pokemon)
				for _, statName2 in pairs(boosts) do
					boosts[statName2] = 0
				end
				target:setBoost(boosts)
				self:addMove('-anim', pokemon, "Spectral Thief", target)
			end
		end
		if move.breaksProtect then
			local broke = false
			for _, v in pairs({'kingsshield', 'protect', 'spikyshield'}) do
				if target:removeVolatile(v) then
					broke = true
				end
			end
			for _, sc in pairs({'craftyshield', 'matblock', 'quickguard', 'wideguard'}) do
				if target.side:removeSideCondition(sc) then
					broke = true
				end
			end
			if broke then
				if move.id == 'feint' then
					self:add('-activate', target, 'move: Feint')
				else
					self:add('-activate', target, 'move: ' .. move.name, '[broken]')
				end
			end
		end

		local totalDamage = 0
		local damage = 0
		pokemon.lastDamage = 0
		if move.multihit then
			self.currentMoveMultiHits = true
			local hits = move.multihit
			if type(hits) == 'table' then
				if hits[1] == 2 and hits[2] == 5 then
					hits = ({2, 2, 3, 3, 4, 5})[math.random(6)]
				else
					hits = math.random(hits[1], hits[2])
				end
			end
			--		hits = math.floor(hits)
			local nullDamage = true
			local moveDamage
			local isSleepUsable = move.sleepUsable or self:getMove(move.sourceEffect).sleepUsable
			local actualHits = 0
			for i = 1, hits do
				if target.hp <= 0 or pokemon.hp <= 0 then break end
				if pokemon.status == 'slp' and not isSleepUsable then break end

				moveDamage = self:moveHit(target, pokemon, move)
				if moveDamage == false then break end
				if nullDamage and (moveDamage or moveDamage == nil) then nullDamage = false end
				-- Damage from each hit is individually counted for the
				-- purposes of Counter, Metal Burst, and Mirror Coat.
				damage = moveDamage or 0
				-- Total damage dealt is accumulated for the purposes of recoil (Parental Bond).
				totalDamage = totalDamage + damage
				self:eachEvent('Update')
				actualHits = actualHits + 1
			end
			if actualHits == 0 then return true end
			if nullDamage then damage = false end
			self:add('-hitcount', target, actualHits)
		else
			self.currentMoveMultiHits = false
			damage = self:moveHit(target, pokemon, move)
			totalDamage = damage
		end

		if move.recoil then
			self:damage(self:clampIntRange(math.floor(totalDamage * move.recoil[1] / move.recoil[2] + 0.5), 1), pokemon, target, 'recoil')
		end

		if target and pokemon ~= target then target:gotAttacked(move, damage, pokemon) end

		if move.ohko then self:add('-ohko') end

		if Not(damage) and damage ~= 0 then return damage end

		if target and not move.negateSecondary and not (pokemon:hasAbility('sheerforce') and pokemon.volatiles['sheerforce']) then
			self:singleEvent('AfterMoveSecondary', move, nil, target, pokemon, move)
			self:runEvent('AfterMoveSecondary', target, pokemon, move)
		end

		return damage
	end
	function Battle:moveHit(target, pokemon, move, moveData, isSecondary, isSelf)
		local damage
		move = self:getMoveCopy(move)

		if not moveData then moveData = move end
		if not moveData.flags then moveData.flags = {} end
		local hitResult = true

		-- TryHit events:
		--   STEP 1: we see if the move will succeed at all:
		--   - TryHit, TryHitSide, or TryHitField are run on the move,
		--     depending on move target (these events happen in useMove
		--     or tryMoveHit, not below)
		--   == primary hit line ==
		--   Everything after this only happens on the primary hit (not on
		--   secondary or self-hits)
		--   STEP 2: we see if anything blocks the move from hitting:
		--   - TryFieldHit is run on the target
		--   STEP 3: we see if anything blocks the move from hitting the target:
		--   - If the move's target is a pokemon, TryHit is run on that pokemon

		-- Note:
		--   If the move target is `foeSide`:
		--     event target = pokemon 0 on the target side
		--   If the move target is `allySide` or `all`:
		--     event target = the move user
		--
		--   This is because events can't accept actual sides or fields as
		--   targets. Choosing these event targets ensures that the correct
		--   side or field is hit.
		--
		--   It is the `TryHitField` event handler's responsibility to never
		--   use `target`.
		--   It is the `TryFieldHit` event handler's responsibility to read
		--   move.target and react accordingly.
		--   An exception is `TryHitSide` as a single event (but not as a normal
		--   event), which is passed the target side.

		if move.target == 'all' and not isSelf then
			hitResult = self:singleEvent('TryHitField', moveData, {}, target, pokemon, move)
		elseif (move.target == 'foeSide' or move.target == 'allySide') and not isSelf then
			hitResult = self:singleEvent('TryHitSide', moveData, {}, target.side, pokemon, move)
		elseif target then
			hitResult = self:singleEvent('TryHit', moveData, {}, target, pokemon, move)
		end
		if Not(hitResult) then
			if hitResult == false then self:add('-fail', target) end
			return false
		end

		if target and not isSecondary and not isSelf then
			if move.target ~= 'all' and move.target ~= 'allySide' and move.target ~= 'foeSide' then
				hitResult = self:runEvent('TryPrimaryHit', target, pokemon, moveData)
				if hitResult == 0 then
					-- special Substitute flag
					hitResult = true
					target = nil
				end
			end
		end
		if target and isSecondary and moveData.self then
			hitResult = true
		end
		if Not(hitResult) then
			return false
		end

		if target then
			local didSomething = false

			damage = self:getDamage(pokemon, target, moveData)

			-- getDamage has several possible return values:
			--
			--   a number:
			--     means that much damage is dealt (0 damage still counts as dealing
			--     damage for the purposes of things like Static)
			--   false:
			--     gives error message: "But it failed!" and move ends
			--   null:
			--     the move ends, with no message (usually, a custom fail message
			--     was already output by an event handler)
			--   undefined:
			--     means no damage is dealt and the move continues
			--
			-- basically, these values have the same meanings as they do for event handlers.

			if not Not(damage) and not target.fainted then
				if move.noFaint and damage >= target.hp then
					damage = target.hp - 1
				end
				damage = self:damage(damage, target, pokemon, move, nil, true)
				if not damage then
					self:debug('damage interrupted')
					return false
				end
				didSomething = true
			end
			if damage == false or damage == null then
				if damage == false and not isSecondary and not isSelf then
					self:add('-fail', target)
				end
				self:debug('damage calculation interrupted')
				return false
			end

			if moveData.boosts and not target.fainted then
				hitResult = self:boost(moveData.boosts, target, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.heal and not target.fainted then
				local d = target:heal(math.floor(target.maxhp * moveData.heal[1] / moveData.heal[2] + 0.5))
				if not d then
					self:add('-fail', target)
					self:debug('heal interrupted')
					return false
				end
				self:add('-heal', target, target.getHealth)
				didSomething = true
			end
			if moveData.status then
				if Not(target.status) then
					hitResult = target:setStatus(moveData.status, pokemon, move)
					if not hitResult and move.status then
						self:add('-immune', target, '[msg]')
						return false
					end
					didSomething = Or(didSomething, hitResult)
				elseif not isSecondary then
					if target.status == moveData.status then
						self:add('-fail', target, target.status)
					else
						self:add('-fail', target)
					end
					return false
				end
			end
			if moveData.forceStatus then
				hitResult = target:setStatus(moveData.forceStatus, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.volatileStatus then
				hitResult = target:addVolatile(moveData.volatileStatus, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.sideCondition then
				hitResult = target.side:addSideCondition(moveData.sideCondition, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.weather then
				hitResult = self:setWeather(moveData.weather, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.terrain then	
				hitResult = self:setTerrain(moveData.terrain, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.pseudoWeather then
				hitResult = self:addPseudoWeather(moveData.pseudoWeather, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.forceSwitch then
				if target.side:canSwitch(target.position) then didSomething = true end -- at least defer the fail message to later
			end
			--if moveData.stealsBoost then
			--	if target.side:canSwitch(target.position) then didSomething = true end -- at least defer the fail message to later
			--end
			if moveData.selfSwitch then
				if pokemon.side:canSwitch(target.position) then didSomething = true end -- at least defer the fail message to later
			end
			-- Hit events
			--   These are like the TryHit events, except we don't need a FieldHit event.
			--   Scroll up for the TryHit event documentation, and just ignore the "Try" part. ;)
			hitResult = nil
			if move.target == 'all' and not isSelf then
				if moveData.onHitField then hitResult = self:singleEvent('HitField', moveData, {}, target, pokemon, move) end
			elseif (move.target == 'foeSide' or move.target == 'allySide') and not isSelf then
				if moveData.onHitSide then hitResult = self:singleEvent('HitSide', moveData, {}, target.side, pokemon, move) end
			else
				if moveData.onHit then hitResult = self:singleEvent('Hit', moveData, {}, target, pokemon, move) end
				if not isSelf and not isSecondary then
					self:runEvent('Hit', target, pokemon, move)
				end
				if moveData.onAfterHit then hitResult = self:singleEvent('AfterHit', moveData, {}, target, pokemon, move) end
			end

			--			if moveData.boosts then print(hitResult, didSomething) end
			if Not(hitResult) and not didSomething and not moveData.self and not moveData.selfdestruct then
				if not isSelf and not isSecondary then
					if hitResult == false or didSomething == false then self:add('-fail', target) end
				end
				self:debug('move failed because it did nothing')
				return false
			end
		end
		if moveData.self then
			local selfRoll
			if not isSecondary and moveData.self.boosts then selfRoll = math.random(100) end
			-- This is done solely to mimic in-game RNG behaviour. All self drops have a 100% chance of happening but still grab a random number.
			if moveData.self.chance == nil or selfRoll <= moveData.self.chance then
				self:moveHit(pokemon, pokemon, move, moveData.self, isSecondary, true)
			end
		end
		if moveData.secondaries then
			local secondaryRoll
			local secondaries = self:runEvent('ModifySecondaries', target, pokemon, moveData, shallowcopy(moveData.secondaries))
			for _, secondary in pairs(secondaries) do
				secondaryRoll = math.random(100)
				if secondary.chance == nil or secondaryRoll <= secondary.chance then
					self:moveHit(target, pokemon, move, secondary, true, isSelf)
				end
			end
		end
		-- whirlwind, growl, etc.
		if moveData.forceSwitch and (target and target ~= null) and target.hp > 0 and pokemon.hp > 0 and target.side:canSwitch(target.position) then
			hitResult = self:runEvent('DragOut', target, pokemon, move)
			local canReallySwitch = false
			for _, pokemon in pairs(target.side.pokemon) do
				if not pokemon.fainted and pokemon ~= target and (not target.teamn or pokemon.teamn == target.teamn) then
					canReallySwitch = true
					break
				end
			end
			if not canReallySwitch then
				hitResult = false
			end
			if not Not(hitResult) then
				target.forceSwitchFlag = true
			elseif hitResult == false and move.category == 'Status' then
				self:add('-fail', target)
			end
		end
		if move.selfSwitch and pokemon.hp > 0 then
			pokemon.switchFlag = move.selfSwitch
		end
		return damage
	end
	function Battle:canMegaEvo(pokemon)
		if pokemon.side.isTwoPlayerSide then -- player must have a Mega Keystone
			if not pokemon.side.megaAdornment[pokemon.teamn] then return false end
		else
			if not pokemon.side.megaAdornment then return false end
		end
		local altForme = pokemon.baseTemplate.otherFormes and self:getTemplate(pokemon.baseTemplate.otherFormes[1])
		if altForme and altForme.isMega and altForme.requiredMove and indexOf(pokemon.moves, toId(altForme.requiredMove)) then
			return altForme.species
		end
		local item = pokemon:getItem()
		if item.megaEvolves ~= pokemon.baseTemplate.baseSpecies or item.megaStone == pokemon.species then
			return false
		end
		if item.id == 'sceptilitec' and (pokemon.set.forme ~= 'Christmas') then
			print('wrong sceptile')
			return false
			-- special condition: only Halloween Gengars can use Gengarite H
		elseif item.id == 'gengariteh' and (pokemon.set.forme ~= 'hallow' or not pokemon.shiny) then
			print('wrong gengar')
			return false
			--elseif item.id == 'ultranecrozniumz' and (pokemon.set.forme ~= 'Dawnwings' or pokemon.set.forme ~= 'Duskmane' or not pokemon.shiny) then
			--	print('wrong necrozma')
			--return false
		end

		return item.megaStone
	end
	function Battle:runMegaEvo(pokemon)
		local template = self:getTemplate(pokemon.canMegaEvo)
		local side = pokemon.side

		-- Pokemon affected by Sky Drop cannot mega evolve. Enforce it here for now.
		for _, foe in pairs(side.foe.active) do
			if foe ~= null and foe.volatiles['skydrop'] and foe.volatiles['skydrop'].source == pokemon then
				return false
			end
		end
		pokemon:formeChange(template)
		pokemon.baseTemplate = template -- mega evolution is permanent
		pokemon.details = template.species .. ', L' .. pokemon.level .. (pokemon.gender == '' and '' or ', ') .. pokemon.gender .. (pokemon.set.shiny and ', shiny' or '')
		self:add('detailschange', pokemon, pokemon.details, '[forMega]', '[icon] '..(template.icon or 0))

		local megaId = 'mega'
		local colorSuffix = ''
		if template.megaId then
			megaId = template.megaId
			colorSuffix = megaId:sub(-1):upper()
		end
		local colors = MegaColors[template.baseSpecies..colorSuffix][pokemon.shiny and 2 or 1]
		self:add('-mega', pokemon, template.baseSpecies, pokemon:getItem().name, 
			colors[1], colors[2], colors[3] or 0, '[megaId] '..megaId)--template.requiredItem)
		local shinyPrefix = pokemon.shiny and '_SHINY' or ''
		local spriteId = template.baseSpecies..'-'..megaId
		self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_FRONT/'..spriteId)
		self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_BACK/'..spriteId)
		pokemon:setAbility(template.abilities[1])
		pokemon.baseAbility = pokemon.ability

		-- for Summary page:
		pokemon.iconOverride = template.icon-1
		pokemon.frontSpriteOverride = _f.Database.GifData[shinyPrefix..'_FRONT'][spriteId]
		pokemon.abilityOverride = template.abilities[1]
		pokemon.typeOverride = template.types
		pokemon.baseStatOverride = template.baseStats

		pokemon.didMegaEvo = true
		pokemon.canMegaEvo = false
		-- Limit one mega evolution
		for _, ally in pairs(side.pokemon) do
			if ally.canMegaEvo and ally ~= pokemon and ally.teamn == pokemon.teamn then
				ally.couldMegaEvo = true
				ally.canMegaEvo = false
			end
		end
		return true
	end
	function Battle:isAdjacent(pokemon1, pokemon2)
		if pokemon1.fainted or pokemon2.fainted then return false end
		if pokemon1.side == pokemon2.side then return math.abs(pokemon1.position - pokemon2.position) == 1 end
		return math.abs(pokemon1.position + pokemon2.position - 1 - #pokemon1.side.active) <= 1
		--because
		-- 1 2 3
		-- 3 2 1
	end





	-- coming soon
	function Battle:calcRecoilDamage(damageDealt, move)
		return math.max(1, math.floor(damageDealt * move.recoil[0] / move.recoil[1] + .5))
	end
	Battle.zStatus = {
		clearnegativeboost = {'Acid Armor', 'Agility', 'Amnesia', 'Attract', 'Autotomize', 'Barrier', 'Baton Pass', 'Calm Mind', 'Coil', 'Cotton Guard', 'Cotton Spore', 'Dark Void', 'Disable', 'Double Team', 'Dragon Dance', 'Endure', 'Floral Healing', 'Follow Me', 'Heal Order', 'Heal Pulse', 'Helping Hand', 'Iron Defense', "King's Shield", 'Leech Seed', 'Milk Drink', 'Minimize', 'Moonlight', 'Morning Sun', 'Nasty Plot', 'Perish Song', 'Protect', 'Quiver Dance', 'Rage Powder', 'Recover', 'Rest', 'Rock Polish', 'Roost', 'Shell Smash', 'Shift Gear', 'Shore Up', 'Slack Off', 'Soft-Boiled', 'Spore', 'Substitute', 'Swagger', 'Swallow', 'Swords Dance', 'Synthesis', 'Tail Glow'},
		spd1 = {'Charge', 'Confide', 'Cosmic Power', 'Crafty Shield', 'Eerie Impulse', 'Entrainment', 'Flatter', 'Glare', 'Ingrain', 'Light Screen', 'Magic Room', 'Magnetic Flux', 'Mean Look', 'Misty Terrain', 'Mud Sport', 'Spotlight', 'Stun Spore', 'Thunder Wave', 'Water Sport', 'Whirlwind', 'Wish', 'Wonder Room'},
		spd2 = {'Aromatic Mist', 'Captivate', 'Imprison', 'Magic Coat', 'Powder'},
		eva = {'Camouflage', 'Detect', 'Flash', 'Kinesis', 'Lucky Chant', 'Magnet Rise', 'Sand Attack', 'Smokescreen'},
		atk1 = {'Bulk Up', 'Hone Claws', 'Howl', 'Laser Focus', 'Leer', 'Meditate', 'Odor Sleuth', 'Power Trick', 'Rototiller', 'Screech', 'Sharpen', 'Tail Whip', 'Taunt', 'Topsy-Turvy', 'Will-O-Wisp', 'Work Up'},
		atk2 = {'Mirror Move'},
		atk3 = {'Splash'},
		spa1 = {'Confuse Ray', 'Electrify', 'Embargo', 'Fake Tears', 'Gear Up', 'Gravity', 'Growth', 'Instruct', 'Ion Deluge', 'Metal Sound', 'Mind Reader', 'Miracle Eye', 'Nightmare', 'Psychic Terrain', 'Reflect Type', 'Simple Beam', 'Soak', 'Sweet Kiss', 'Teeter Dance', 'Telekinesis'}, 
		spa2 = {'Heal Block', 'Psycho Shift'},
		def1 = {'Aqua Ring', 'Baby-Doll Eyes', 'Baneful Bunker', 'Block', 'Charm', 'Defend Order', 'Fairy Lock', 'Feather Dance', 'Flower Shield', 'Grassy Terrain', 'Growl', 'Harden', 'Mat Block', 'Noble Roar', 'Pain Split', 'Play Nice', 'Poison Gas', 'Poison Powder', 'Quick Guard', 'Reflect', 'Roar', 'Spider Web', 'Spikes', 'Spiky Shield', 'Stealth Rock', 'Strength Sap', 'Tearful Look', 'Tickle', 'Torment', 'Toxic', 'Toxic Spikes', 'Venom Drench', 'Wide Guard', 'Withdraw'},
		spe1 = {'After You', 'Aurora Veil', 'Electric Terrain', 'Encore', 'Gastro Acid', 'Grass Whistle', 'Guard Split', 'Guard Swap', 'Hail', 'Hypnosis', 'Lock-On', 'Lovely Kiss', 'Power Split', 'Power Swap', 'Quash', 'Rain Dance', 'Role Play', 'Safeguard', 'Sandstorm', 'Scary Face', 'Sing', 'Skill Swap', 'Sleep Powder', 'Speed Swap', 'Sticky Web', 'String Shot', 'Sunny Day', 'Supersonic', 'Toxic Thread', 'Worry Seed', 'Yawn'},
		spe2 = {'Ally Switch', 'Bestow', 'Me First', 'Recycle', 'Snatch', 'Switcheroo', 'Trick'},
		heal = {'Aromatherapy', 'Belly Drum', 'Conversion 2', 'Haze', 'Heal Bell', 'Mist', 'Psych Up', 'Refresh', 'Spite, Stockpile', 'Teleport', 'Transform'},
		acc = {'Copycat', 'Defense Curl', 'Defog', 'Focus Energy', 'Mimic', 'Sweet Scent', 'Trick Room'},
		all = {'Celebrate', 'Conversion', "Forest's Curse", 'Geomancy', 'Happy Hour', 'Hold Hands', 'Purify', 'Sketch', 'Trick-or-Treat'},
		crit2 = {'Acupressure', 'Foresight', 'Heart Swap', 'Sleep Talk', 'Tailwind'},
		healreplacement = {'Memento', 'Parting Shot'},
		redirect = {'Destiny Bond', 'Grudge'},
		runrandom = {'Metronome'}
	}
	Battle.gmaxMoveTable = {
		gmaxwildfire = {"Blast Burn","Blaze Kick","Blue Flare","Burn Up","Burning Jealousy","Ember","Eruption","Fiery Dance","Fire Blast","Fire Fang","Fire Lash","Fire Pledge","Fire Punch","Fire Spin","Flame Charge","Flame Wheel","Flamethrower","Flare Blitz","Fusion Flare","Heat Crash","Heat Wave","Incinerate","Inferno","Lava Plume","Magma Storm","Mind Blown","Mystical Fire","Overheat","Pyro Ball","Sacred Fire","Searing Shot","Shell Trap","V-create"},
		gmaxvinelash = {"Absorb","Apple Acid","Branch Poke","Bullet Seed","Drum Beating","Energy Ball","Frenzy Plant","Giga Drain","Grass Knot","Grass Pledge","Grassy Glide","Grav Apple","Horn Leech","Leaf Blade","Leaf Storm","Leaf Tornado","Leafage","Magical Leaf","Mega Drain","Petal Blizzard","Petal Dance","Power Whip","Razor Leaf","Seed Bomb","Seed Flare","Snap Trap","Solar Beam","Solar Blade","Trop Kick","Vine Whip","Wood Hammer"},
		gmaxcannonade = {"Aqua Jet","Aqua Tail","Brine","Bubble Beam","Crabhammer","Dive","Fishious Rend","Flip Turn","Hydro Cannon","Hydro Pump","Liquidation","Muddy Water","Octazooka","Origin Pulse","Razor Shell","Scald","Snipe Shot","Sparkling Aria","Steam Eruption","Surf","Surging Strikes","Water Gun","Water Pledge","Water Pulse","Water Shuriken","Water Spout","Waterfall","Whirlpool"},
		gmaxbefuddle = {"Attack Order","Bug Bite","Bug Buzz","Fell Stinger","First Impression","Fury Cutter","Infestation","Leech Life","Lunge","Megahorn","Pin Missile","Pollen Puff","Skitter Smack","Struggle Bug","U-turn","X-Scissor"},
		gmaxvoltcrash = {"Aura Wheel","Bolt Beak","Bolt Strike","Charge Beam","Discharge","Electro Ball","Electroweb","Fusion Bolt","Nuzzle","Overdrive","Parabolic Charge","Plasma Fists","Rising Voltage","Shock Wave","Spark","Thunder","Thunder Cage","Thunder Fang","Thunder Punch","Thunder Shock","Thunderbolt","Volt Switch","Volt Tackle","Wild Charge","Zap Cannon","Zing Zap"},
		gmaxgoldrush = {"Bind","Body Slam","Boomburst","Covet","Crush Claw","Crush Grip","Cut","Double Hit","Double-Edge","Echoed Voice","Endeavor","Explosion","Extreme Speed","Facade","Fake Out","False Swipe","Feint","Flail","Fury Attack","Fury Swipes","Giga Impact","Guillotine","Head Charge","Headbutt","Hold Back","Horn Attack","Horn Drill","Hyper Beam","Hyper Fang","Hyper Voice","Judgment","Last Resort","Mega Kick","Mega Punch","Multi-Attack","Pay Day","Pound","Present","Quick Attack","Rapid Spin","Relic Song","Retaliate","Revelation Dance","Round","Scratch","Self-Destruct","Skull Bash","Slam","Slash","Snore","Spit Up","Stomp","Strength","Super Fang","Swift","Tackle","Tail Slap","Take Down","Techno Blast","Terrain Pulse","Thrash","Tri Attack","Uproar","Vise Grip","Weather Ball","Wrap"},
		gmaxchistrike = {"Arm Thrust","Aura Sphere","Body Press","Brick Break","Circle Throw","Close Combat","Counter","Cross Chop","Double Kick","Drain Punch","Dynamic Punch","Final Gambit","Flying Press","Focus Blast","Focus Punch","Force Palm","Hammer Arm","High Jump Kick","Low Kick","Low Sweep","Mach Punch","Meteor Assault","Power-Up Punch","Revenge","Reversal","Rock Smash","Sacred Sword","Secret Sword","Seismic Toss","Storm Throw","Submission","Superpower","Thunderous Kick","Triple Kick","Vacuum Wave","Vital Throw"},
		gmaxterror = {"Astonish","Astral Barrage","Hex","Lick","Moongeist Beam","Night Shade","Phantom Force","Poltergeist","Shadow Ball","Shadow Bone","Shadow Claw","Shadow Force","Shadow Punch","Shadow Sneak","Spectral Thief","Spirit Shackle"},
		gmaxfoamburst = {"Aqua Jet","Aqua Tail","Brine","Bubble Beam","Crabhammer","Dive","Fishious Rend","Flip Turn","Hydro Cannon","Hydro Pump","Liquidation","Muddy Water","Octazooka","Origin Pulse","Razor Shell","Scald","Snipe Shot","Sparkling Aria","Steam Eruption","Surf","Surging Strikes","Water Gun","Water Pledge","Water Pulse","Water Shuriken","Water Spout","Waterfall","Whirlpool"},
		gmaxresonance = {"Aurora Beam","Avalanche","Blizzard","Freeze Shock","Freeze-Dry","Frost Breath","Glacial Lance","Glaciate","Ice Beam","Ice Burn","Ice Fang","Ice Hammer","Ice Punch","Ice Shard","Icicle Crash","Icicle Spear","Icy Wind","Powder Snow","Sheer Cold","Triple Axel"},
		gmaxcuddle = {"Bind","Body Slam","Boomburst","Covet","Crush Claw","Crush Grip","Cut","Double Hit","Double-Edge","Echoed Voice","Endeavor","Explosion","Extreme Speed","Facade","Fake Out","False Swipe","Feint","Flail","Fury Attack","Fury Swipes","Giga Impact","Guillotine","Head Charge","Headbutt","Hold Back","Horn Attack","Horn Drill","Hyper Beam","Hyper Fang","Hyper Voice","Judgment","Last Resort","Mega Kick","Mega Punch","Multi-Attack","Pay Day","Pound","Present","Quick Attack","Rapid Spin","Relic Song","Retaliate","Revelation Dance","Round","Scratch","Self-Destruct","Skull Bash","Slam","Slash","Snore","Spit Up","Stomp","Strength","Super Fang","Swift","Tackle","Tail Slap","Take Down","Techno Blast","Thrash","Tri Attack","Uproar","Vise Grip","Weather Ball","Wrap"},
		gmaxreplenish = {"Bind","Body Slam","Boomburst","Covet","Crush Claw","Crush Grip","Cut","Double Hit","Double-Edge","Echoed Voice","Endeavor","Explosion","Extreme Speed","Facade","Fake Out","False Swipe","Feint","Flail","Fury Attack","Fury Swipes","Giga Impact","Guillotine","Head Charge","Headbutt","Hold Back","Horn Attack","Horn Drill","Hyper Beam","Hyper Fang","Hyper Voice","Judgment","Last Resort","Mega Kick","Mega Punch","Multi-Attack","Pay Day","Pound","Present","Quick Attack","Rapid Spin","Relic Song","Retaliate","Revelation Dance","Round","Scratch","Self-Destruct","Skull Bash","Slam","Slash","Snore","Spit Up","Stomp","Strength","Super Fang","Swift","Tackle","Tail Slap","Take Down","Techno Blast","Terrain Pulse","Thrash","Tri Attack","Uproar","Vise Grip","Weather Ball","Wrap"},
		gmaxmalodor = {"Acid","Acid Spray","Belch","Clear Smog","Cross Poison","Gunk Shot","Poison Fang","Poison Jab","Poison Sting","Poison Tail","Shell Side Arm","Sludge","Sludge Bomb","Sludge Wave","Smog","Venoshock"},
		gmaxmeltdown = {"Anchor Shot","Behemoth Bash","Behemoth Blade","Bullet Punch","Doom Desire","Double Iron Bash","Flash Cannon","Gear Grind","Gyro Ball","Heavy Slam","Iron Head","Iron Tail","Metal Burst","Metal Claw","Meteor Mash","Smart Strike","Steel Beam","Steel Roller","Steel Wing","Sunsteel Strike"},
		gmaxdrumsolo = {"Absorb","Apple Acid","Branch Poke","Bullet Seed","Drum Beating","Energy Ball","Frenzy Plant","Giga Drain","Grass Knot","Grass Pledge","Grassy Glide","Grav Apple","Horn Leech","Leaf Blade","Leaf Storm","Leaf Tornado","Leafage","Magical Leaf","Mega Drain","Petal Blizzard","Petal Dance","Power Whip","Razor Leaf","Seed Bomb","Seed Flare","Snap Trap","Solar Beam","Solar Blade","Trop Kick","Vine Whip","Wood Hammer"},
		gmaxfireball = {"Blast Burn","Blaze Kick","Blue Flare","Burn Up","Burning Jealousy","Ember","Eruption","Fiery Dance","Fire Blast","Fire Fang","Fire Lash","Fire Pledge","Fire Punch","Fire Spin","Flame Charge","Flame Wheel","Flamethrower","Flare Blitz","Fusion Flare","Heat Crash","Heat Wave","Incinerate","Inferno","Lava Plume","Magma Storm","Mind Blown","Mystical Fire","Overheat","Pyro Ball","Sacred Fire","Searing Shot","Shell Trap","V-create"},
		gmaxhydrosnipe = {"Aqua Jet","Aqua Tail","Brine","Bubble Beam","Crabhammer","Dive","Fishious Rend","Flip Turn","Hydro Cannon","Hydro Pump","Liquidation","Muddy Water","Octazooka","Origin Pulse","Razor Shell","Scald","Snipe Shot","Sparkling Aria","Steam Eruption","Surf","Surging Strikes","Water Gun","Water Pledge","Water Pulse","Water Shuriken","Water Spout","Waterfall","Whirlpool"},
		gmaxwindrage = {"Acrobatics","Aerial Ace","Aeroblast","Air Cutter","Air Slash","Beak Blast","Bounce","Brave Bird","Chatter","Dragon Ascent","Drill Peck","Dual Wingbeat","Fly","Gust","Hurricane","Oblivion Wing","Peck","Pluck","Sky Attack","Wing Attack"},
		gmaxgravitas = {"Confusion","Dream Eater","Eerie Spell","Expanding Force","Extrasensory","Freezing Glare","Future Sight","Hyperspace Hole","Luster Purge","Mirror Coat","Mist Ball","Photon Geyser","Prismatic Laser","Psybeam","Psychic","Psychic Fangs","Psycho Boost","Psycho Cut","Psyshock","Psystrike","Stored Power","Zen Headbutt"},
		gmaxstonesurge = {"Aqua Jet","Aqua Tail","Brine","Bubble Beam","Crabhammer","Dive","Fishious Rend","Flip Turn","Hydro Cannon","Hydro Pump","Liquidation","Muddy Water","Octazooka","Origin Pulse","Razor Shell","Scald","Snipe Shot","Sparkling Aria","Steam Eruption","Surf","Surging Strikes","Water Gun","Water Pledge","Water Pulse","Water Shuriken","Water Spout","Waterfall","Whirlpool"},
		gmaxtartness = {"Absorb","Apple Acid","Branch Poke","Bullet Seed","Drum Beating","Energy Ball","Frenzy Plant","Giga Drain","Grass Knot","Grass Pledge","Grassy Glide","Grav Apple","Horn Leech","Leaf Blade","Leaf Storm","Leaf Tornado","Leafage","Magical Leaf","Mega Drain","Petal Blizzard","Petal Dance","Power Whip","Razor Leaf","Seed Bomb","Seed Flare","Snap Trap","Solar Beam","Solar Blade","Trop Kick","Vine Whip","Wood Hammer"},
		gmaxsweetness = {"Absorb","Apple Acid","Branch Poke","Bullet Seed","Drum Beating","Energy Ball","Frenzy Plant","Giga Drain","Grass Knot","Grass Pledge","Grassy Glide","Grav Apple","Horn Leech","Leaf Blade","Leaf Storm","Leaf Tornado","Leafage","Magical Leaf","Mega Drain","Petal Blizzard","Petal Dance","Power Whip","Razor Leaf","Seed Bomb","Seed Flare","Snap Trap","Solar Beam","Solar Blade","Trop Kick","Vine Whip","Wood Hammer"},
		gmaxvolcalith = {"Accelerock","Ancient Power","Diamond Storm","Head Smash","Meteor Beam","Power Gem","Rock Blast","Rock Slide","Rock Throw","Rock Tomb","Rock Wrecker","Rollout","Smack Down","Stone Edge"},
		gmaxsandblast = {"Bone Rush","Bonemerang","Bulldoze","Dig","Drill Run","Earth Power","Earthquake","Fissure","High Horsepower","Land's Wrath","Mud Shot","Mud-Slap","Precipice Blades","Sand Tomb","Scorching Sands","Stomping Tantrum","Thousand Arrows","Thousand Waves"},
		gmaxstunshock = {"Aura Wheel","Bolt Beak","Bolt Strike","Charge Beam","Discharge","Electro Ball","Electroweb","Fusion Bolt","Nuzzle","Overdrive","Parabolic Charge","Plasma Fists","Rising Voltage","Shock Wave","Spark","Thunder","Thunder Cage","Thunder Fang","Thunder Punch","Thunder Shock","Thunderbolt","Volt Switch","Volt Tackle","Wild Charge","Zap Cannon","Zing Zap"},
		gmaxcentiferno = {"Blast Burn","Blaze Kick","Blue Flare","Burn Up","Burning Jealousy","Ember","Eruption","Fiery Dance","Fire Blast","Fire Fang","Fire Lash","Fire Pledge","Fire Punch","Fire Spin","Flame Charge","Flame Wheel","Flamethrower","Flare Blitz","Fusion Flare","Heat Crash","Heat Wave","Incinerate","Inferno","Lava Plume","Magma Storm","Mind Blown","Mystical Fire","Overheat","Pyro Ball","Sacred Fire","Searing Shot","Shell Trap","V-create"},
		gmaxsmite = {"Dazzling Gleam","Disarming Voice","Draining Kiss","Fairy Wind","Fleur Cannon","Light of Ruin","Misty Explosion","Moonblast","Nature's Madness","Play Rough","Spirit Break","Strange Steam"},
		gmaxsnooze = {"Assurance","Beat Up","Bite","Brutal Swing","Crunch","Dark Pulse","Darkest Lariat","False Surrender","Fiery Wrath","Fling","Foul Play","Hyperspace Fury","Jaw Lock","Knock Off","Lash Out","Night Daze","Night Slash","Payback","Power Trip","Snarl","Sucker Punch","Thief","Throat Chop","Wicked Blow"},
		gmaxfinale = {"Dazzling Gleam","Disarming Voice","Draining Kiss","Fairy Wind","Fleur Cannon","Light of Ruin","Misty Explosion","Moonblast","Nature's Madness","Play Rough","Spirit Break","Strange Steam"},
		gmaxsteelsurge = {"Breaking Swipe","Clanging Scales","Core Enforcer","Draco Meteor","Dragon Breath","Dragon Claw","Dragon Darts","Dragon Energy","Dragon Hammer","Dragon Pulse","Dragon Rush","Dragon Tail","Dual Chop","Dynamax Cannon","Eternabeam","Outrage","Roar of Time","Scale Shot","Spacial Rend","Twister"},
		gmaxdepletion = {"Anchor Shot","Behemoth Bash","Behemoth Blade","Bullet Punch","Doom Desire","Double Iron Bash","Flash Cannon","Gear Grind","Gyro Ball","Heavy Slam","Iron Head","Iron Tail","Metal Burst","Metal Claw","Meteor Mash","Smart Strike","Steel Beam","Steel Roller","Steel Wing","Sunsteel Strike"},
		gmaxoneblow = {"Assurance","Beat Up","Bite","Brutal Swing","Crunch","Dark Pulse","Darkest Lariat","False Surrender","Fiery Wrath","Fling","Foul Play","Hyperspace Fury","Jaw Lock","Knock Off","Lash Out","Night Daze","Night Slash","Payback","Power Trip","Snarl","Sucker Punch","Thief","Throat Chop","Wicked Blow"},
		gmaxrapidflow = {"Aqua Jet","Aqua Tail","Brine","Bubble Beam","Crabhammer","Dive","Fishious Rend","Flip Turn","Hydro Cannon","Hydro Pump","Liquidation","Muddy Water","Octazooka","Origin Pulse","Razor Shell","Scald","Snipe Shot","Sparkling Aria","Steam Eruption","Surf","Surging Strikes","Water Gun","Water Pledge","Water Pulse","Water Shuriken","Water Spout","Waterfall","Whirlpool"},
	}--Change to exclusive typings e.g Kingler + Water moves  = Gmax move
	Battle.maxMoveTable = { -- 69 said not to touch
		Flying = 'Max Airstream',
		Dark = 'Max Darkness',
		Fire = 'Max Flare',
		Bug = 'Max Flutterby',
		Water = 'Max Geyser',
		Status = 'Max Guard', --All status moves turn into this
		Ice = 'Max Hailstorm',
		Fighting = 'Max Knuckle',
		Electric = 'Max Lightning',
		Psychic = 'Max Mindstorm',
		Poison = 'Max Ooze',
		Grass = 'Max Overgrowth',
		Ghost = 'Max Phantasm',
		Ground = 'Max Quake',
		Rock = 'Max Rockfall',
		Fairy = 'Max Starfall',
		Steel = 'Max Steelspike',
		Normal = 'Max Strike',
		Dragon = 'Max Wyrmwind',
	}

	Battle.zMoveTable = {
		Poison   = "Acid Downpour",
		Fighting = "All-Out Pummeling",
		Dark     = "Black Hole Eclipse",
		Grass    = "Bloom Doom",
		Normal   = "Breakneck Blitz",
		Rock     = "Continental Crush",
		Steel    = "Corkscrew Crash",
		Dragon   = "Devastating Drake",
		Electric = "Gigavolt Havoc",
		Water    = "Hydro Vortex",
		Fire     = "Inferno Overdrive",
		Ghost    = "Never-Ending Nightmare",
		Bug      = "Savage Spin-Out",
		Psychic  = "Shattered Psyche",
		Ice      = "Subzero Slammer",
		Flying   = "Supersonic Skystrike",
		Ground   = "Tectonic Rage",
		Fairy    = "Twinkle Tackle",
	}

	function Battle:findIn(moveName, Gmax, pokemon)

		for name, t in pairs ((Gmax or self.zStatus)) do
			local foundForMove = false
			for _, move in pairs (t) do		
				if move == moveName then
					if pokemon and 	indexOf(self:getMove(toId(name)).isMax, pokemon.species) then
						return name
					elseif not pokemon then
						foundForMove = true
						return name
					end
				end
			end		
		end
	end
	function Battle:canUltra(pokemon)
	--	if pokemon.side.isTwoPlayerSide then 
		--	if not pokemon.side.zmoveAdornment[pokemon.teamn] then return false end
	--	else
		--	if not pokemon.side.zmoveAdornment then return false end
	--	end
		--Checker for Z-Ring
		if pokemon:getItem().id == 'ultranecroziumz' then
			if pokemon.set.forme == 'Dawnwings' or pokemon.set.forme == 'Duskmane' then
				return 'Necrozma-ultra'
				--Checker for item + forme
			else
				return false
			end
		end
	end
	function Battle:getMaxMove(move, pokemon) 

		move = self:getMove(move) 
		local maxMove = self:getMove(self:findIn(move.name, self.gmaxMoveTable, pokemon))
		local movename = move.name
		if (move.id == 'struggle') then 
			return move
		elseif (pokemon.gigantamax and maxMove and indexOf(maxMove.isMax, pokemon.species)) then
			maxMove.basePower = self:newBasePower(move, maxMove)
			return maxMove
		else
			local maxMove = self:getMove(self.maxMoveTable[(move.category == 'Status' and 'Status' or move.type)])
			if (maxMove) then
				maxMove.basePower = self:newBasePower(move, maxMove)
				return maxMove
			end
		end
	end
	function Battle:MaxMove(move, pokemon) 	
		if not (self.canDynamax) then return false end
		if (self.baseTemplate.isMega or self.baseTemplate.isPrimal or self.baseTemplate.forme == "ultra" or self:getItem().zMove or self.canMegaEvo) then
			return false
		end
		-- Some pokemon species are unable to dynamaxin
		if (self.baseTemplate.cannotDynamax) then return false -- Zacian Zamazenta Eternatus (although Eternatus is dealt diffrently)
		end

		--return true
		local result = {maxMoves ={}}
		----Check for MaxMoves
		for i, v in pairs(pokemon.moves) do
			move = self:getMove(move) 
			local maxMove = self:getMaxMove(move, self)
			print("the move is "..maxMove)
			if (maxMove) then
					table.insert(result.maxMoves,{
						move = maxMove.id,
						target = maxMove.target,
						disabled = false,})
			end
		end

		return result
	end
	function Battle:canMaxMove(pokemon)
		local atLeastOne = false
		local maxMoves = {}
		for _, m in pairs(pokemon.moves) do
			local move = self:getMove(m)
			print(move)
			print("move here2")
			local maxMove = self:getMaxMove(move, pokemon).name or ''
			print(maxMoves)
			print("here1")
			table.insert(maxMoves, maxMove)
			if maxMove then atLeastOne = true end
		end
		if atLeastOne then
			return maxMoves
		end
	end
	function Battle:getZMove(move, pokemon, skipChecks)
		local item = pokemon:getItem()
		if not skipChecks then			
			if (item.zMoveUser and not indexOf(item.zMoveUser, pokemon.species)) then return end			
			if not item.zMove then return end
			if item.zMoveUser and not indexOf(item.zMoveUser, pokemon.species) then return end
		end
		if item.zMoveFrom then
			if move.name == item.zMoveFrom then return item.zMove end
		elseif item.zMove == true then
			if move.type == item.zMoveType then
				if move.category == "Status" then
					return move.name
				else
					return self.zMoveTable[move.type]
				end	
			end
		end
	end
	function Battle:cheapDynamax(pokemon, maxraid)
		if maxraid then
			pokemon:addVolatile('maxraid') 
		else
			pokemon:addVolatile('dynamax')
		end
	end
	function Battle:canZMove(pokemon)
		--if pokemon.side.isTwoPlayerSide then 
		--	return
		--else
		--	if not pokemon.side.zmoveAdornment then return end
		--end
		if pokemon.side.zMoveUsed then return end
		local item = pokemon:getItem()
		if not item.zMove then return end

		if item.zMoveUser and type(item.zMoveUser) == 'table' then
			local allowed = false
			local zMoveUser = item.zMoveUser
			if zMoveUser['poke'] and type(zMoveUser['poke']) == 'table' then
				for _, pokes in pairs(zMoveUser['poke']) do
					if indexOf(pokes, pokemon.species) then
						allowed = true
					end --1
				end --2
			elseif indexOf(zMoveUser['poke'], pokemon.species) then
				allowed = true
			end --3
			if zMoveUser['poke'] and not allowed then return end
			allowed = false
			--poke_check bugged?
			if zMoveUser['forme'] and type(zMoveUser['forme']) == 'table' then
				for _, formes in pairs(zMoveUser['forme']) do
					if pokemon.set.forme == formes then
						allowed = true
					end --1
				end --2
			elseif pokemon.set.forme == zMoveUser['forme'] then
				allowed = true
			end --3
			if zMoveUser['forme'] and not allowed then return end	
		elseif (item.zMoveUser and not indexOf(item.zMoveUser, pokemon.species)) then return end --If not table normal check

		local atLeastOne = false
		local zMoves = {}
		for _, m in pairs(pokemon.moves) do
			local move = self:getMove(m)
			local zMoveName = self:getZMove(move, pokemon, true) or false
			if zMoveName then
				local zMove = self:getMove(zMoveName)
				if move.category == 'Status' then zMoveName = 'Z-'..zMoveName end
				table.insert(zMoves, {move = zMoveName, target = zMove.target})
				if zMove then 
					atLeastOne = true
				end
			else
				table.insert(zMoves, false)
			end
		end
		if atLeastOne then
			return zMoves
		end
	end
	function Battle:newBasePower(move, new)
		if new.ExlcusivePwr then return new.ExlcusivePwr end

		local basePower = move.basePower
		local pwr = 1
		if new.isZ then -- Should I add a check for status?
			if basePower < 56 then pwr = 100
			elseif basePower < 76 then pwr = 140 
			elseif basePower < 86 then pwr = 160 
			elseif basePower < 96 then pwr = 175 
			elseif basePower < 101 then pwr = 180 
			elseif basePower < 111 then pwr = 185 
			elseif basePower < 126 then pwr = 190 
			elseif basePower < 131 then pwr = 195 
			elseif basePower > 130 then pwr = 200 end
		elseif new.isMax then
			if move.type == 'Poison' or move.type == 'Fighting' then
				if basePower >= 150 then pwr = 100 
				elseif basePower >= 110 then pwr = 95
				elseif basePower >= 75 then pwr = 90
				elseif basePower >= 65 then pwr = 85
				elseif basePower >= 55 then pwr = 80 
				elseif basePower >= 45 then pwr = 75
				else pwr = 70
				end
			else
				--Normal maxMove Calc
				if basePower >= 150 then pwr = 150 
				elseif basePower >= 110 then pwr = 140
				elseif basePower >= 75 then pwr = 130
				elseif basePower >= 65 then pwr = 120
				elseif basePower >= 55 then pwr = 110 
				elseif basePower >= 45 then pwr = 100
				else pwr = 90
				end
			end
		end		
		return pwr
	end
	function Battle:runZMove(move, pokemon, target, sourceEffect)
		--pokemon.side.canZMove = false
		local zMove = self:getZMove(move, pokemon)

		self:add('-zmove', pokemon, 'zpower')

		self:runMove(move, pokemon, target, sourceEffect, zMove)
		pokemon.side.zMoveUsed = true

	end
	function Battle:getActiveZMove(move, pokemon)
		self:add('-zmove', pokemon, 'zpower')
		pokemon.side.zMoveUsed = true
		pokemon.side.canZMove = false
		if (pokemon) then
			local item = pokemon:getItem()
			if (move.name == item.zMoveFrom) then
				local zMove = self:getMove(item.zMove)
				zMove.isZOrMaxPowered = true
				zMove.basePower = self:newBasePower(move, zMove)
				return zMove;
			end
		end

		if (move.category == 'Status') then
			local zMove = self:getMove(move)
			zMove.isZ = 'Z-'..move.name
			zMove.isZOrMaxPowered = true
			return zMove
		end
		local zMove = self:getMove(self.zMoveTable[move.type])
		zMove.category = move.category
		zMove.priority = move.priority
		zMove.basePower = self:newBasePower(move, zMove)
		zMove.isZOrMaxPowered = true --Should I Merge BreaksProtect Under IsZorMaxPowered?
		zMove.breaksProtect = true
		return zMove
	end
	function Battle:runZPower(move, pokemon)
		local zPower = self:getEffect('zpower')
		local bonus = self:findIn(move.name)
		if (move.category == 'Status') then --Should I add a default Status boost if one can't be found? 
			self:attrLastMove('[zeffect]')
			if (bonus:sub(4, 4) == '1' or bonus:sub(4, 4) == '2' or bonus:sub(4, 4) == '3') then
				local atk, num = bonus:match("^(%a+)(%d-)$")
				self:boost({[atk] = tonumber(num)}, pokemon, pokemon, zPower);
				self:add('-boostFromZEffect', pokemon, atk, tonumber(num));		
			elseif (bonus == 'acc') then
				self:boost({accuracy = 1}, pokemon, pokemon, zPower);
				self:add('-boostFromZEffect', pokemon, 'accuracy', 1);
			elseif (bonus == 'all') then
				self:boost({atk = 1,def = 1,spa = 1,spd = 1,spe = 1}, pokemon, pokemon, zPower);
				self:add('-boostMultipleFromZEffect', pokemon);
			elseif not (bonus.boost) then
				if bonus == 'heal' then
					self:heal(pokemon.maxhp, pokemon, pokemon, zPower)
					self:add('-healFromZEffect', pokemon)				
				elseif bonus ==  'healreplacement' then
					move.self = {slotCondition = 'healingwish'}
					self:add('-healreplacement', pokemon)				
				elseif bonus == 'clearnegativeboost' then
					local boosts = {}
					for i in pairs(pokemon.boosts) do
						if pokemon.boosts[i] < 0 then
							pokemon.boosts[i] = 0
						end
					end
					pokemon:setBoost(boosts);
					self:add('-clearnegativeboost', pokemon, '[zeffect]');

				elseif bonus == 'redirect' then
					pokemon:addVolatile('followme', pokemon, zPower);				
				elseif bonus == 'crit2' then
					pokemon:addVolatile('focusenergy', pokemon, zPower);		
				elseif bonus ==  'curse' then
					if (pokemon.hasType('Ghost')) then
						self:heal(pokemon.maxhp, pokemon, pokemon, zPower);
						self:add('-heal', pokemon, pokemon.getHealth)
					else
						self:boost({atk = 1}, pokemon, pokemon, zPower);
					end
				end
			end
		end
	end
end