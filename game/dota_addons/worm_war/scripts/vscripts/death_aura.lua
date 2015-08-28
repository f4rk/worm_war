require("tail_growth")

function DeathAura( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_max_hp = target:GetMaxHealth()
	local aura_damage = target_max_hp
	local aura_damage_interval = ability:GetLevelSpecialValueFor("aura_damage_interval", (ability:GetLevel() - 1))


	-- Elementals don't kill hero if it has fiery jaw on
	if caster:GetUnitName() == "npc_dota_creature_fire_elemental" and target:IsHero() then
		if target:HasModifier("modifier_fiery_jaw") then
			return
		end
	end

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

	if target:IsHero() and target:IsAlive() then
		if target ~= caster:GetOwner() then
			DoTailSpawn(caster:GetOwner(),5)
			PopupGrowth(caster:GetOwner(),5)
		end
	end
end