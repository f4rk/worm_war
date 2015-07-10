
function TailSpawn(keys)
	local caster = keys.caster
	local ability = keys.ability

	local headPos = caster:GetAbsOrigin()
	local dir = caster:GetForwardVector()

	local spawnPoint = headPos - (dir * 150)
	--print(spawnPoint)
	local hBug = CreateUnitByName( "npc_dota_creature_tail_bug", spawnPoint, true, caster, caster:GetOwner(), caster:GetTeamNumber() )
		if hBug ~= nil then
			hBug:SetForwardVector(dir)
			hBug:SetControllableByPlayer( caster:GetPlayerID(), false )
			hBug:SetTeam(caster:GetTeamNumber())
			hBug:SetOwner( caster )
			hBug:MoveToPosition(caster:GetAbsOrigin())
		end
end