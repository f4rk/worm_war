require( "tail_growth" )

function SegmentBomb (keys)
	local caster = keys.caster

	caster:EmitSound("Hero_Techies.RemoteMine.Detonate")
	caster:RemoveAbility("segment_bomb")
	
	for i = DOTA_TEAM_GOODGUYS, DOTA_TEAM_CUSTOM_8 do
		if i ~= caster:GetTeamNumber() then
				 local playerID = PlayerResource:GetNthPlayerIDOnTeam(i, 1)
				 if PlayerResource:IsValidPlayerID(playerID) then
				 	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				 	local segmentsToRemove = math.ceil(hero.tailLength/10)

				 	hero.totalSegLost = hero.totalSegLost + segmentsToRemove
				 	caster.totalSegKilled = hero.totalSegKilled + segmentsToRemove
				 	DoTailSpawn(hero,segmentsToRemove,true)

				 	CustomNetTables:SetTableValue( "segments_lost", "player_" .. tostring(hero:GetPlayerOwnerID()), {value = hero.totalSegLost} )

				 end
		end
	end
	
	CustomNetTables:SetTableValue( "segments_killed", "player_" .. tostring(caster:GetPlayerOwnerID()), {value = caster.totalSegKilled} )
	-- local tail_growth_event =
	-- {
	-- 	tail_lengths = CWormWarGameMode.TailLengths,
	-- }
	-- CustomGameEventManager:Send_ServerToAllClients( "tail_growth_event", tail_growth_event )
end
