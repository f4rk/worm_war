function TailSpawn(keys)
	local caster = keys.caster
	local unit = keys.unit
	local unitName = unit:GetUnitName()
	
	local numToSpawn = 0

	if unitName == "npc_dota_creature_sheep" then
		numToSpawn = 1
	elseif unitName == "npc_dota_creature_pig" then
		numToSpawn = 2
	elseif unitName == "npc_dota_creature_fire_elemental" then
		numToSpawn = 5
	elseif unitName == "npc_dota_hero_nyx_assassin_worm_war" then
		if unit:GetTeamNumber() ~= caster:GetTeamNumber() then
			numToSpawn = math.ceil(unit.tailLength*CWormWarGameMode.SEGMENT_PER_KILL/100); --Spawn 5% of enemies tail on kill.
		end		
	end

	if caster:IsAlive() then
		DoTailSpawn(caster,numToSpawn)
		PopupGrowth(caster,numToSpawn)
	end
end

function GetTeamColor(teamNumber)
	-- print(teamNumber)

	-- teal 	->	2
	-- yellow	->	3
	-- pink		-> 	6
	-- orange 	-> 	7
	-- blue		->	8
	-- green 	->  9
	-- brown 	-> 10

	if teamNumber == 2 then color = {61,210,150}			-- teal
	elseif teamNumber == 3 then color ={ 243, 201, 9 }		-- yellow	
	elseif teamNumber == 6 then color ={ 197, 77, 168 } 	-- pink
	elseif teamNumber == 7 then color ={ 255, 108, 0 }		-- orange
	elseif teamNumber == 8 then color ={ 52, 85, 255 }  	-- blue
	elseif teamNumber == 9 then color ={ 101, 212, 19 } 	-- green
	elseif teamNumber == 10 then color ={ 129, 83, 54 }		-- brown
	elseif teamNumber == 11 then color ={ 27, 192, 216 } 	-- cyan
	elseif teamNumber == 12 then color ={ 199, 228, 13 }	-- olive
	elseif teamNumber == 13 then color ={ 140, 42, 244 }	-- purple
	else color = {255,255,255}
	end

	return color
end

function DoTailSpawn(caster, numToSpawn)
	if numToSpawn <= 0 then
		return 1
	end

	if caster.tailLength == nil then
		caster.tailLength = 0
		caster.followUnits = {caster}
	end

	local toFollow = caster.followUnits[caster.tailLength+1]
	-- print(toFollow:GetUnitName())

	local headPos = toFollow:GetAbsOrigin()
	local dir = toFollow:GetForwardVector()

	local spawnPoint = headPos - (dir * 150)
	--print(spawnPoint)
	local success =
		CreateUnitByNameAsync(
			"npc_dota_creature_tail_bug", spawnPoint, true, caster, caster:GetOwner(), caster:GetTeamNumber(),
			function(hBug)
				local color = GetTeamColor(caster:GetTeamNumber())
				hBug:SetRenderColor(color[1],color[2],color[3])

				table.insert(caster.followUnits, hBug)
				caster.tailLength = caster.tailLength + 1

				hBug:SetForwardVector(dir)
				hBug:SetTeam(caster:GetTeamNumber())
				hBug:SetOwner( caster )


				local hBuff = caster:FindModifierByName( "modifier_tail_growth_datadriven" )
				if hBuff ~= nil then
					hBuff:SetStackCount( caster.tailLength )
				end

				-- local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
				-- ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
				-- ParticleManager:ReleaseParticleIndex( nFXIndex )

				--local playerID = caster:GetPlayerID()
				--caster:IncrementKills(playerID)

				ExecuteOrderFromTable({
					UnitIndex = hBug:GetEntityIndex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
					TargetIndex = toFollow:GetEntityIndex(),
					Queue = true})

				CWormWarGameMode.TailLengths[caster:GetTeamNumber()] = CWormWarGameMode.TailLengths[caster:GetTeamNumber()]  + 1
				local tail_growth_event =
				{
					tail_lengths = CWormWarGameMode.TailLengths,
				}
				CustomGameEventManager:Send_ServerToAllClients( "tail_growth_event", tail_growth_event )
				return DoTailSpawn(caster,numToSpawn-1)
			end )

	
	local playerLongestTail = PlayerResource:GetGold(caster:GetPlayerID())
	print("Tail length: ", caster.tailLength)
	print("longest: ", playerLongestTail)

		if caster.tailLength  > playerLongestTail then -- THere is a +1 oddity for taillength... same with win condition, need 61?
			caster:SetGold(caster.tailLength, true)
		end

end

function TailCleanup(keys)
	local caster = keys.caster
	if caster.tailLength ~= nil then
		caster:EmitSound("Hero_Broodmother.SpawnSpiderlings")
		for i=2,caster.tailLength+1 do
			-- local damage_table = {}
			-- local target = caster.followUnits[i]
			-- damage_table.attacker = caster
			-- damage_table.victim = target
			-- damage_table.damage_type = DAMAGE_TYPE_PURE
			-- damage_table.ability = keys.ability
			-- damage_table.damage = target:GetMaxHealth()
			-- ApplyDamage(damage_table)
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.followUnits[i] )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
			caster.followUnits[i]:ForceKill(true)
		end
		caster.followUnits = {caster}
		caster.tailLength = 0
		CWormWarGameMode.TailLengths[caster:GetTeamNumber()] = 0
	end
end

function PopupGrowth(caster, num)
	local pfxPath = "particles/msg_fx/msg_damage.vpcf"
	local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, caster)
	local colorTable = GetTeamColor(caster:GetTeamNumber())
	local color = Vector(colorTable[1],colorTable[2],colorTable[3])
	local lifetime = 3.0
	local digits = 1 + #tostring(num)

	ParticleManager:SetParticleControl(pidx, 1, Vector(0, num, 0))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end