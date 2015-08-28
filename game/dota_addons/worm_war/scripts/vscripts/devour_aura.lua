function DevourAura( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_max_hp = target:GetMaxHealth()
	local aura_damage = target_max_hp
	local aura_damage_interval = ability:GetLevelSpecialValueFor("aura_damage_interval", (ability:GetLevel() - 1))

	local name = target:GetUnitName()
	print(name)
	if name ~= "npc_dota_creature_sheep" and name ~= "npc_dota_creature_pig" and name ~= "npc_dota_creature_gold_sheep" then
		if not (caster:HasModifier("modifier_fiery_jaw") and name == "npc_dota_creature_fire_elemental") then
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
end



--==============================================
--FLESH HEAP CODE will be used for tail length
--===============================================

--devour_aura = class({})
--LinkLuaModifier( "modifier_devour_aura", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

--function devour_aura:GetIntrinsicModifierName()
--	return "modifier_devour_aura"
--end

--------------------------------------------------------------------------------

--[[function devour_aura:OnHeroDiedNearby( hVictim, hKiller, kv )
	if hVictim == nil or hKiller == nil then
		return
	end

	if hVictim:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and self:GetCaster():IsAlive() then
		self.devour_aura_range = self:GetSpecialValueFor( "devour_aura_range" )
		local vToCaster = self:GetCaster():GetOrigin() - hVictim:GetOrigin()
		local flDistance = vToCaster:Length2D()
		if hKiller == self:GetCaster() or self.flesh_heap_range >= flDistance then
			if self.nKills == nil then
				self.nKills = 0
			end

			self.nKills = self.nKills + 1

			local hBuff = self:GetCaster():FindModifierByName( "modifier_pudge_flesh_heap_lua" )
			if hBuff ~= nil then
				hBuff:SetStackCount( self.nKills )
				self:GetCaster():CalculateStatBonus()
			end

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
end]]--

--------------------------------------------------------------------------------
-- function to set nKills to 0
--function devour_aura:OnOwnerDied() 

--function pudge_flesh_heap_lua:GetFleshHeapKills()
--	if self.nKills == nil then
--		self.nKills = 0
--	end
--	return self.nKills
--end
 
--------------------------------------------------------------------------------

