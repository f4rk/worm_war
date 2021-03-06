function TailSpawn(hero, unit, killedTail)
	--local caster = keys.caster
	--local unit = keys.unit
	local unitName = unit:GetUnitName()
	
	local numToSpawn = 0

	if unitName == "npc_dota_creature_sheep" then
		numToSpawn = 1
	elseif unitName == "npc_dota_creature_pig" then
		numToSpawn = 2
	elseif unitName == "npc_dota_creature_fire_elemental" then
		numToSpawn = 5
	elseif unitName == "npc_dota_hero_nyx_assassin" then
		print("Killed Hero!!")
		if unit:GetTeamNumber() ~= hero:GetTeamNumber() then
			numToSpawn = math.ceil(killedTail*0.05 + 1); --Spawn 5% of enemies tail on kill.
		end		
	end

	if hero:IsAlive() then
		CWormWarGameMode.TailLengths[hero:GetTeamNumber()] = CWormWarGameMode.TailLengths[hero:GetTeamNumber()]  + numToSpawn

		local playerLongestTail = PlayerResource:GetGold(hero:GetPlayerID())
				
				if CWormWarGameMode.TailLengths[hero:GetTeamNumber()]  > playerLongestTail then
					hero:SetGold(CWormWarGameMode.TailLengths[hero:GetTeamNumber()], true)
				end

		if CWormWarGameMode.TailLengths[hero:GetTeamNumber()] >= 60 then
			EmitGlobalSound("WormWar.Wormtastic01")
		end

		DoTailSpawn(hero,numToSpawn,false)
		PopupGrowth(hero,numToSpawn)
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

function DoTailSpawn(caster,numToSpawn,remove)
	--print("START of DoTailSpawn")
	--print(GetSystemTime())


	if caster.isSpawning == nil or caster.isSpawning == false then	
		--print("before1",caster.numToSpawn)
		caster.isSpawning = true
		if remove == true then
			-- print("not spawning: remove")
			caster.numToRemove = caster.numToRemove + numToSpawn
			SegmentBombWorker(caster)
			PopupLoss(caster,numToSpawn)
			caster.numToRemove = 0
			if caster.numToSpawn == 0 then
				caster.isSpawning = false
				return 1
			end
		else
			-- print("not spawning: add")
			caster.numToSpawn = caster.numToSpawn + numToSpawn
		end
		--print("after1",caster.numToSpawn)
	elseif numToSpawn ~= 0 then
		--print("before2",caster.numToSpawn)
		if remove == true then
			-- print("spawning: remove")
			caster.numToRemove = caster.numToRemove + numToSpawn
			PopupLoss(caster,numToSpawn)
		else
			-- print("not spawning: add")
			caster.numToSpawn = caster.numToSpawn + numToSpawn
		end
		--print("after2",caster.numToSpawn)
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
			"npc_dota_creature_tail_bug", spawnPoint, false, caster, caster:GetOwner(), caster:GetTeamNumber(),
			function(hBug)
				--caster.tailLength = caster.tailLength + 1
				--CWormWarGameMode.TailLengths[caster:GetTeamNumber()] = CWormWarGameMode.TailLengths[caster:GetTeamNumber()]  + 1

				local color = GetTeamColor(caster:GetTeamNumber())
				hBug:SetRenderColor(color[1],color[2],color[3])

				table.insert(caster.followUnits, hBug)
				
				caster.tailLength = caster.tailLength + 1

				headPos = toFollow:GetAbsOrigin()
				dir = toFollow:GetForwardVector()
				spawnPoint = headPos - (dir * 150)
				hBug:SetAbsOrigin(spawnPoint)

				hBug:SetForwardVector(dir)
				hBug:SetTeam(caster:GetTeamNumber())
				hBug:SetOwner( caster )
				hBug:SetAcquisitionRange(0)

				if caster.numToRemove ~= 0 then
					SegmentBombWorker(caster,numToSpawn)
					caster.numToRemove = 0
				end


				ExecuteOrderFromTable({
					UnitIndex = hBug:GetEntityIndex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
					TargetIndex = toFollow:GetEntityIndex(),
					Queue = true})

				local hBuff = caster:FindModifierByName( "modifier_tail_growth_datadriven" )
				if hBuff ~= nil then
					hBuff:SetStackCount( caster.tailLength )
				end

				local tail_growth_event =
				{
					tail_lengths = CWormWarGameMode.TailLengths,
				}
				CustomGameEventManager:Send_ServerToAllClients( "tail_growth_event", tail_growth_event )

				caster.numToSpawn = caster.numToSpawn - 1

				if caster.numToSpawn <= 0 then
					caster.isSpawning = false
					return 1
				else
					return DoTailSpawn(caster,0,false)
				end
			end )

end

function TailCleanup(killedHero)
	--local caster = keys.caster
	print("START TailCleanUp")
	if killedHero.tailLength ~= nil then
		print("Entered CleanUP, taiLength:", killedHero.tailLength)
		if killedHero.tailLength >=50 then
			EmitGlobalSound("WormWar.Denied01") 
		end

		killedHero:EmitSound("Hero_Broodmother.SpawnSpiderlings")

		local toCleanup = killedHero.followUnits
		local tailLength = killedHero.tailLength

		killedHero.followUnits = {killedHero}
		killedHero.tailLength = 0
		CWormWarGameMode.TailLengths[killedHero:GetTeamNumber()] = 0

		for i=2,tailLength+1 do
			print("entered loop")
			-- local damage_table = {}
			-- local target = caster.followUnits[i]
			-- damage_table.attacker = caster
			-- damage_table.victim = target
			-- damage_table.damage_type = DAMAGE_TYPE_PURE
			-- damage_table.ability = keys.ability
			-- damage_table.damage = target:GetMaxHealth()
			-- ApplyDamage(damage_table)
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, toCleanup[i] )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
			toCleanup[i]:ForceKill(true)
		end

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

function SegmentBombWorker (hero)
	local newLength = hero.tailLength - hero.numToRemove

 	print("tail length: ", hero.tailLength)
 	print("newLength: ", newLength)

 	if hero.tailLength ~= nil and hero.tailLength > 0 then
 		for i= hero.tailLength+1, newLength+2, -1 do
 			hero:EmitSound("Hero_Techies.RemoteMine.Detonate")
 			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_remote_mines_detonate_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.followUnits[i] )
			ParticleManager:SetParticleControl( nFXIndex, 0, hero.followUnits[i]:GetAbsOrigin() )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
			hero.followUnits[i]:ForceKill(true)
			table.remove(hero.followUnits)
			newLength = hero.tailLength - hero.numToRemove
		end
		hero.tailLength = newLength
		CWormWarGameMode.TailLengths[hero:GetTeamNumber()] = newLength

		local hBuff = hero:FindModifierByName( "modifier_tail_growth_datadriven" )
		if hBuff ~= nil then
			hBuff:SetStackCount( hero.tailLength )
		end

		local tail_growth_event =
		{
			tail_lengths = CWormWarGameMode.TailLengths,
		}
		CustomGameEventManager:Send_ServerToAllClients( "tail_growth_event", tail_growth_event )
 	end	
end


function PopupLoss(hero, num)
	local pfxPath = "particles/msg_fx/msg_damage.vpcf"
	local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, hero)
	local color = Vector(240,14,14)
	local lifetime = 3.0
	local digits = 1 + #tostring(num)

	ParticleManager:SetParticleControl(pidx, 1, Vector(1, num, 0))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end