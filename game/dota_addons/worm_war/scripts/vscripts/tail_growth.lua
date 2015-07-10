function TailSpawn(keys)
	local caster = keys.caster
	local ability = keys.ability

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
		end
end