function FieryJaw(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:EmitSound("Hero_Axe.Battle_Hunger")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fiery_jaw", {fiery_jaw_duration = 10.0})
	local fjParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_battle_hunger.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	--ParticleManager:SetParticleControl( fjParticle, 0, caster:GetAbsOrigin() )
	Timers:CreateTimer( 10.0, function()
		ParticleManager:DestroyParticle( fjParticle, false )
		ParticleManager:ReleaseParticleIndex( fjParticle )
		return nil
	end)

	caster:RemoveAbility("fiery_jaw")
end