require( "tail_growth" )

function SegmentBomb (keys)
	local caster = keys.caster

	caster:EmitSound("Hero_Techies.RemoteMine.Detonate")
	for i = DOTA_TEAM_GOODGUYS, DOTA_TEAM_CUSTOM_8 do
		if i ~= caster:GetTeamNumber() then
				 local playerID = PlayerResource:GetNthPlayerIDOnTeam(i, 1)
				 if PlayerResource:IsValidPlayerID(playerID) then
				 	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				 	local segmentsToRemove = math.ceil(hero.tailLength/10)


				 	DoTailSpawn(hero,segmentsToRemove,true)
				 end
		end
	end
	
	-- local tail_growth_event =
	-- {
	-- 	tail_lengths = CWormWarGameMode.TailLengths,
	-- }
	-- CustomGameEventManager:Send_ServerToAllClients( "tail_growth_event", tail_growth_event )

	caster:RemoveAbility("segment_bomb")

end
