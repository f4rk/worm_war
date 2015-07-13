function DeathAura( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_max_hp = target:GetMaxHealth()
	local aura_damage = target_max_hp
	local aura_damage_interval = ability:GetLevelSpecialValueFor("aura_damage_interval", (ability:GetLevel() - 1))

	local visibility_modifier = keys.visibility_modifier
	if target:CanEntityBeSeenByMyTeam(caster) then
		ability:ApplyDataDrivenModifier(caster, target, visibility_modifier, {})
	else
		target:RemoveModifierByName(visibility_modifier)
	end

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = aura_damage;

	ApplyDamage(damage_table)
end