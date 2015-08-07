function TailSpawn(keys)
	local caster = keys.caster
	local unit = keys.unit
	local unitName = unit:GetUnitName()
	
	local numToSpawn = 0

	if unitName == "npc_dota_creature_sheep" then
		numToSpawn = 1
	elseif unitName == "npc_dota_creature_pig" then
		numToSpawn = 2
	elseif unitName == "npc_dota_creature_gold_sheep" then
		numToSpawn = 5
	else
		numToSpawn = 0
	end

	DoTailSpawn(caster,numToSpawn)
end


function DoTailSpawn(caster, numToSpawn)

	for i=1,numToSpawn do
		if caster.tailLength == nil then
			caster.tailLength = 0
			caster.followUnits = {caster}
		end
		
		local toFollow = caster.followUnits[caster.tailLength+1]
		local headPos = toFollow:GetAbsOrigin()
		local dir = toFollow:GetForwardVector()
		
		local spawnPoint = headPos - (dir * 150)
		--print(spawnPoint)
		local hBug = CreateUnitByName( "npc_dota_creature_tail_bug", spawnPoint, true, caster, caster:GetOwner(), caster:GetTeamNumber() )
		if hBug ~= nil then
			table.insert(caster.followUnits, hBug)
			caster.tailLength = caster.tailLength + 1

			hBug:SetForwardVector(dir)
			hBug:SetTeam(caster:GetTeamNumber())
			hBug:SetOwner( caster )
			
			ExecuteOrderFromTable({	
				UnitIndex = hBug:GetEntityIndex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
				TargetIndex = caster.followUnits[caster.tailLength]:GetEntityIndex(),
				Queue = true	})
			
			local hBuff = caster:FindModifierByName( "modifier_tail_growth_datadriven" )
			if hBuff ~= nil then
				hBuff:SetStackCount( caster.tailLength )
			end

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )

			--local playerID = caster:GetPlayerID()
			--caster:IncrementKills(playerID)
			CWormWarGameMode.TailLengths[caster:GetTeamNumber()] = CWormWarGameMode.TailLengths[caster:GetTeamNumber()]  + 1

		end
	end
end

function TailCleanup(keys)
	local caster = keys.caster
	if caster.tailLength ~= nil then
		for i=2,caster.tailLength+1 do
			-- local damage_table = {}
			-- local target = caster.followUnits[i]
			-- damage_table.attacker = caster
			-- damage_table.victim = target
			-- damage_table.damage_type = DAMAGE_TYPE_PURE
			-- damage_table.ability = keys.ability
			-- damage_table.damage = target:GetMaxHealth()
			-- ApplyDamage(damage_table)
			caster.followUnits[i]:ForceKill(true)
		end
		caster.followUnits = {caster}
		caster.tailLength = 0
		CWormWarGameMode.TailLengths[caster:GetTeamNumber()] = 0

		
	end
end