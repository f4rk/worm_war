
require( "timers" )

function CryptCraving( keys )
	local caster = keys.caster
	local centerPos = caster:GetAbsOrigin()
	local ability = keys.ability

	-- Ability variables
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")

	if caster.initialrun == nil then
		caster.initialrun = true
		caster.crypt_start_time =  GameRules:GetGameTime()
	else
		caster.initialrun = false
	end

	local remaining_duration = duration - (GameRules:GetGameTime() - caster.crypt_start_time)

	print("Initial run: ", caster.initialrun)	
	--local vacuum_modifier = keys.vacuum_modifier
	

	-- Targeting variables
	local target_teams = ability:GetAbilityTargetTeam() 
	local target_types = ability:GetAbilityTargetType() 
	--local target_flags = ability:GetAbilityTargetFlags() 

	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, centerPos, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

	
	-- Calculate the position of each found unit
	for _,unit in ipairs(units) do
		
		if unit:GetUnitName() ~= "npc_dota_creature_fire_elemental" then
			
			--Attach lion mana drain particles
			if caster.initialrun == true then
				local cryptParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf", DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, unit)
				ParticleManager:SetParticleControl(cryptParticle, 1, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(cryptParticle, 0, unit:GetAbsOrigin())
				
				Timers:CreateTimer( 1.0, function()
				ParticleManager:DestroyParticle( cryptParticle, false )
			   		ParticleManager:ReleaseParticleIndex( cryptParticle )
			   		return nil
			   	end)
			    			
			end

			local unit_location = unit:GetAbsOrigin()
			local vector_distance = centerPos - unit_location
			local distance = (vector_distance):Length2D()
			local direction = (vector_distance):Normalized()

			-- Check if its a new vacuum cast
			-- Set the new pull speed if it is
			if unit.crypt_caster ~= caster then
				unit.crypt_caster = caster
				unit.crypt_caster.pull_speed = distance * 1/duration * 1/10
			end
			-- Apply the stun and no collision modifier then set the new location
			unit:SetAbsOrigin(unit_location + direction * unit.crypt_caster.pull_speed)
		end
	end

	--Smaller than Thinker step size (0.05), should be on last step
	if remaining_duration < 0.03 then
		caster.initialrun = nil
	end

end