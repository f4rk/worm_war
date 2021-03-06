
require( "timers" )

function CryptCraving( keys )
	local caster = keys.caster
	
	local ability = keys.ability
	local centerPos = caster:GetAbsOrigin()


	-- Ability variables
	local duration = ability:GetSpecialValueFor("duration")

	if caster.initialrun == nil then
		caster.initialrun = true
	else
		caster.initialrun = false
	end

	local remaining_duration = duration - (GameRules:GetGameTime() - caster.crypt_start_time)

	
	-- Calculate the position of each found unit
	for _,unit in ipairs(caster.units) do
		
		if unit:GetUnitName() ~= "npc_dota_creature_fire_elemental" and unit:GetUnitName() ~= "npc_powerup_icon" then
			
			--Attach lion mana drain particles
			if caster.initialrun == true then
				caster:EmitSound("Hero_Dark_Seer.Vacuum")
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
	
end

function CryptCravingStart(keys)
	local caster = keys.caster
	local centerPos = caster:GetAbsOrigin()
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")

	caster.units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, centerPos, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

	caster.crypt_start_time =  GameRules:GetGameTime()
	caster.initialrun = nil
end

function CryptCravingCleanUp(keys)
	local caster = keys.caster
	caster:RemoveAbility("crypt_craving")
	caster.units = nil
end

