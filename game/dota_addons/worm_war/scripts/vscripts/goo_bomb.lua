function GooBomb (keys)
	local caster = keys.caster
	local ability = keys.ability


	caster:EmitSound("Hero_Bristleback.ViscousGoo.Cast")
	for i = DOTA_TEAM_GOODGUYS, DOTA_TEAM_CUSTOM_8 do
		if i ~= caster:GetTeamNumber() then
				 local playerID = PlayerResource:GetNthPlayerIDOnTeam(i, 1)
				 if PlayerResource:IsValidPlayerID(playerID) then
				 	local hero = PlayerResource:GetSelectedHeroEntity(playerID)

				 	hero:EmitSound("Hero_Bristleback.ViscousGoo.Target")
					ability:ApplyDataDrivenModifier(caster, hero, "modifier_goo_bomb", {goo_duration = 4.0, goo_slow = -70})
	   				local gooParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf", PATTACH_POINT_FOLLOW, hero)
	   				Timers:CreateTimer( 4.0, function()
						ParticleManager:DestroyParticle( gooParticle, false )
			   			ParticleManager:ReleaseParticleIndex( gooParticle )
			   			return nil
			   		end)				
				 end
		end
	end

	caster:RemoveAbility("goo_bomb")

end