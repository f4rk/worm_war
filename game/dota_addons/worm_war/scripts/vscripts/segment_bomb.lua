function SegmentBomb (keys)
	local caster = keys.caster

	for i = DOTA_TEAM_GOODGUYS, DOTA_TEAM_CUSTOM_8 do
		if i ~= caster:GetTeamNumber()
				 local playerID = PlayerResource:GetNthPlayerIDOnTeam(i, 1)
				 if PlayerResource:IsValidPlayerID(playerID) then
				 	local hero = PlayerResource:GetSelectedHeroEntity(playerID)

				 	local segmentsToRemove = math.ceil(hero.tailLength/10)
				 	local newLength = hero.tailLength - segmentsToRemove

				 	print("tail length: ", hero.tailLength)
				 	print("newLength: ", newLength)

				 	if hero.tailLength ~= nil and hero.tailLength > 0 then
				 		for i= hero.tailLength+1, newLength+2, -1 do
				 			hero:EmitSound("Hero_Techies.RemoteMine.Detonate")
				 			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_remote_mines_detonate_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero.followUnits[i] )
							ParticleManager:SetParticleControl( nFXIndex, 0, hero.followUnits[i]:GetAbsOrigin() )
							ParticleManager:ReleaseParticleIndex( nFXIndex )
							hero.followUnits[i]:ForceKill(true)
							table.remove(hero.followUnits)
						end
							hero.tailLength = newLength
							CWormWarGameMode.TailLengths[hero:GetTeamNumber()] = newLength

							PopupLoss(hero, segmentsToRemove)
				 	end
				 end
		end
	end
	
	local tail_growth_event =
	{
		tail_lengths = CWormWarGameMode.TailLengths,
	}
	CustomGameEventManager:Send_ServerToAllClients( "tail_growth_event", tail_growth_event )

end

function PopupLoss(hero, num)
	local pfxPath = "particles/msg_fx/msg_damage.vpcf"
	local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, hero)
	local color = Vector(240,14,14)
	local lifetime = 3.0
	local digits = 1 + #tostring(num)

	ParticleManager:SetParticleControl(pidx, 1, Vector(1, num, 0))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end