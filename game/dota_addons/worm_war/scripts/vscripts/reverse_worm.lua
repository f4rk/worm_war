function ReverseWorm(keys)
	local caster = keys.caster

	if caster.tailLength == nil then
		caster.tailLength = 0
		caster.followUnits = {caster}
	end

	hero = caster.followUnits[1]
	local length = #caster.followUnits

	local swaps = 0
	if length % 2 == 1 then
		swaps = (length + 1) / 2
	else
		swaps = length / 2
	end

	for s = 1,swaps do
		local ent1 = caster.followUnits[s]
		local ent2 = caster.followUnits[length+1-s]
		ReverseSwap(ent1,ent2)
	end

	caster:EmitSound("Hero_VengefulSpirit.NetherSwap")

	for i = 1,length do
		local unit = caster.followUnits[i]

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end

	local forwardVector = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local newMoveLocation = origin + (forwardVector * 50)

	caster.lastForwardVector = forwardVector
	caster.lastOrigin = origin

	caster.dest = newMoveLocation
	caster:MoveToPosition(newMoveLocation)

	local playerID = caster:GetPlayerID()
	PlayerResource:SetCameraTarget(playerID, caster)
	Timers:CreateTimer(0.5, function()
    	PlayerResource:SetCameraTarget(playerID, nil)
    	return nil
	end)

	caster:RemoveAbility("reverse_worm")
    
end

function ReverseSwap(entity1, entity2)
	local pos1 = entity1:GetAbsOrigin()
	local pos2 = entity2:GetAbsOrigin()

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap_pink.vpcf", PATTACH_ABSORIGIN_FOLLOW, entity1 )
	ParticleManager:SetParticleControl( nFXIndex, 1, pos2 )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	entity1:SetAbsOrigin(pos2)
	entity2:SetAbsOrigin(pos1)

	local dir1 = entity1:GetForwardVector()
	local dir2 = entity2:GetForwardVector()

	entity1:SetForwardVector(-dir2)
	entity2:SetForwardVector(-dir1)
end