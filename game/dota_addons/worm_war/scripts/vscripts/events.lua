--[[ events.lua ]]

require("tail_growth")
---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function CWormWarGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then

	end

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		
		EmitGlobalSound("WormWar.WelcometoWormWar01")
		local numberOfPlayers = PlayerResource:GetPlayerCount()
		nCOUNTDOWNTIMER = 1201
		--[[if numberOfPlayers > 7 then
			--self.TEAM_KILLS_TO_WIN = 25
			nCOUNTDOWNTIMER = 901
		elseif numberOfPlayers > 4 and numberOfPlayers <= 7 then
			--self.TEAM_KILLS_TO_WIN = 20
			nCOUNTDOWNTIMER = 721
		else
			--self.TEAM_KILLS_TO_WIN = 15
			nCOUNTDOWNTIMER = 601
		end
		if GetMapName() == "forest_solo" then
			self.TEAM_KILLS_TO_WIN = 20
		elseif GetMapName() == "desert_duo" then
			self.TEAM_KILLS_TO_WIN = 25
		else
			self.TEAM_KILLS_TO_WIN = 30
		end]]--
		--print( "Kills to win = " .. tostring(self.TEAM_KILLS_TO_WIN) )

		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.SEGMENTS_TO_WIN } );

		self._fPreGameStartTime = GameRules:GetGameTime()
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local GameMode = GameRules:GetGameModeEntity()
		GameMode:SetThink( "MovementThink", self, "MovementThink")
		GameMode:SetThink( "RoamingThink", self, "RoamingThink")
		GameMode:SetThink( "ItemThink", self, "ItemThink")

		--print( "OnGameRulesStateChange: Game In Progress" )
		if self.spawnListener then
			local innateSpells = StopListeningToGameEvent(self.spawnListener) 
		end

		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		--DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )
	end

end

function CWormWarGameMode:OnNPCSpawned(keys)
    local hero = EntIndexToHScript(keys.entindex)
    
    if hero:IsHero() then
    	TailCleanup(hero)
    	local player = hero:GetOwnerEntity()
	    local teamN = player:GetTeamNumber()

	    --Team 4 and 5 are neutrals and no team, offset by 2 for direction on spawn
	    if teamN > 5 then 
	    	teamN = teamN - 2
	    end

    	local direction = Vector (math.cos((90 - (teamN-2)*36)*math.pi/180), math.sin((90 - (teamN-2)*36)*math.pi/180), 0)
    	direction = direction:Normalized()
    	hero:SetForwardVector(direction) 

    	hero:SetAbilityPoints(0)
    	hero:FindAbilityByName("devour_aura"):SetLevel(1)
    	hero:FindAbilityByName("tail_growth"):SetLevel(1)
		hero:FindAbilityByName("worm_war_phase"):SetLevel(1)
	
		if 	hero:FindAbilityByName("fiery_jaw") then
			hero:RemoveAbility("fiery_jaw")
		end

		if 	hero:FindAbilityByName("crypt_craving") then
			hero:RemoveAbility("crypt_craving")
		end

		if 	hero:FindAbilityByName("reverse_worm") then
			hero:RemoveAbility("reverse_worm")
		end

		if 	hero:FindAbilityByName("goo_bomb") then
			hero:RemoveAbility("goo_bomb")
		end

		if 	hero:FindAbilityByName("segment_bomb") then
			hero:RemoveAbility("segment_bomb")
		end
	
		--hero:FindAbilityByName("reverse_worm"):SetLevel(1)
--		hero:FindAbilityByName("goo_bomb"):SetLevel(1)
  --  	hero:FindAbilityByName("crypt_craving"):SetLevel(1)
	--   	hero:FindAbilityByName("segment_bomb"):SetLevel(1)

	   	hero:AddNewModifier(hero, self, "modifier_magic_immune", {duration = 3.0})
	   	local repelParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	   	Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( repelParticle, false )
			ParticleManager:ReleaseParticleIndex( repelParticle )
			return nil
		end)

		hero:SetAcquisitionRange(0)

	   	if hero:GetDeaths() == 0 then
	   		print("gold should be 0")
	   		hero:SetGold(0, false)		-- Set starting gold to 0, will be used to track longest tail achieved 
	   		hero:SetMaximumGoldBounty(0)
	   		hero:SetMinimumGoldBounty(0)
	   	end

    end

	hero.dest = nil
	hero.numToSpawn = 0
end


---------------------------------------------------------------------------
-- Event: OnTeamKillCredit, see if anyone won
---------------------------------------------------------------------------
function CWormWarGameMode:OnTeamKillCredit( event )
--	print( "OnKillCredit" )
--	DeepPrint( event )

	local nKillerID = event.killer_userid
	local nTeamID = event.teamnumber
	--local nTeamKills = event.herokills
	--local nKillsRemaining = self.TEAM_KILLS_TO_WIN - nTeamKills
	
	--[[local broadcast_kill_event =
	{
		killer_id = event.killer_userid,
		team_id = event.teamnumber,
		--team_kills = nTeamKills,
		--kills_remaining = nKillsRemaining,
		victory = 0,
		close_to_victory = 0,
		very_close_to_victory = 0,
	}--]]

	--[[if nKillsRemaining <= 0 then
		GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[nTeamID] )
		GameRules:SetGameWinner( nTeamID )
		broadcast_kill_event.victory = 1
	elseif nKillsRemaining == 1 then
		EmitGlobalSound( "ui.npe_objective_complete" )
		broadcast_kill_event.very_close_to_victory = 1
	elseif nKillsRemaining <= self.CLOSE_TO_VICTORY_THRESHOLD then
		EmitGlobalSound( "ui.npe_objective_given" )
		broadcast_kill_event.close_to_victory = 1
	end]]--

	--CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

function CWormWarGameMode:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	
	local r = RandomInt(1, 9)
	local powerUp = ""
	
	print("Random num: ", r)
	if event.itemname == "item_powerup" then
		if r == 1 then
			powerUp = "segment_bomb"
		elseif r == 2 or r == 3 then
			powerUp = "fiery_jaw"
		elseif r == 4 or r == 5 then
			powerUp = "crypt_craving"
		elseif r == 6 or r == 7 then
			powerUp = "goo_bomb"
		elseif r == 8 or r == 9 then
			powerUp = "reverse_worm"
		end
		print("Power up picked up: ", powerUp )
		owner:AddAbility(powerUp)
		owner:FindAbilityByName(powerUp):SetLevel(1)
		--SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, r, nil )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	end

	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, owner:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	
	for _,unit in ipairs(units) do
		if unit:GetUnitName() == "npc_powerup_icon" then
			unit:ForceKill(false)
			break
		end
	end

	CWormWarGameMode.nSpawnedPowerUps = CWormWarGameMode.nSpawnedPowerUps - 1
	print("PowerUps Spawned: ", CWormWarGameMode.nSpawnedPowerUps)

end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function CWormWarGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local attacker = EntIndexToHScript( event.entindex_attacker )
	local nAttackerID = attacker:GetPlayerOwnerID() 
	local hero = PlayerResource:GetSelectedHeroEntity(nAttackerID)
	local heroTeam = attacker:GetTeam()

	if killedUnit:IsRealHero() then
		--print("Killed unit: ", killedUnit)
		print("Killed team: ", GetTeamName(killedTeam))
		--print("hero: ", hero)
		print("heroTeam: ", GetTeamName(heroTeam))

		if(killedUnit.totalSegLost == nil) then
			killedUnit.totalSegLost = 0
		end

		if hero ~= nil then
			if(hero.totalSegKilled == nil) then
				killedUnit.totalSegKilled = 0
			end
		end

		local killedTail = killedUnit.tailLength
		TailCleanup(killedUnit)
		self.allSpawned = true
		killedUnit.dest = nil
		--print("Hero has been killed")
		
		-- For End Screen stats
		killedUnit.totalSegLost = killedUnit.totalSegLost + killedTail
		CustomNetTables:SetTableValue( "segments_lost", "player_" .. tostring(killedUnit:GetPlayerOwnerID()), {value = killedUnit.totalSegLost} )

		

		if heroTeam ~= killedTeam and heroTeam ~= DOTA_TEAM_NEUTRALS then
			EmitGlobalSound("WormWar.Squish01")
			TailSpawn(hero, killedUnit, killedTail)
			
			hero.totalSegKilled = hero.totalSegKilled + killedTail
			CustomNetTables:SetTableValue( "segments_killed", "player_" .. tostring(hero:GetPlayerOwnerID()), {value = hero.totalSegKilled} )

			
		elseif heroTeam == killedTeam then
			print("Suicide")
			print(killedUnit:GetUnitName())
			local origin = hero:GetAbsOrigin()
			if (origin.x > 4000 or origin.x < -4000) or (origin.y > 4000 or origin.y < -4000) then
				EmitGlobalSound("WormWar.Noob01")
				local playerID = killedUnit:GetPlayerOwnerID()
				local playerName = PlayerResource:GetPlayerName(playerID)
				local color = self.m_TeamColors[ killedTeam ]
				--print("color1: ", color[1])
				--print("color1 hex: "..string.format("%X", color[1]))
				--print(color)
				GameRules:SendCustomMessage("<font color='#"..string.format("%02X", color[1])..string.format("%02X", color[2])..string.format("%02X", color[3]).."'>" .. playerName .. " (Nyx Assassin) </font> just electrocuted himself!", 0, 0)
			else
				PlayerResource:IncrementDenies(hero:GetPlayerOwnerID()) 
				EmitGlobalSound("WormWar.Humiliation01")
			end

		elseif heroTeam == DOTA_TEAM_NEUTRALS then
			print("FE death")
			EmitGlobalSound("WormWar.Whoopsie01") 
		end
	else
		-- Unit deaths (food, fire elementals etc.)
		-- HANDLE LENGTH addition + win condition
		
		if killedUnit:GetUnitName() ~= "npc_dota_creature_tail_bug" and killedUnit:GetUnitName() ~= "npc_powerup_icon" then
			TailSpawn(hero, killedUnit, 0)
			CWormWarGameMode:SpawnFoodEntity(killedUnit:GetUnitName(), killedUnit.centreFlag)
		end
	end

	if killedUnit:GetUnitName() ~= "npc_dota_creature_tail_bug" and killedUnit:GetUnitName() ~= "npc_powerup_icon" then
		local nSegments = 0
		if hero.tailLength ~= nil then
			nSegments = CWormWarGameMode.TailLengths[hero:GetTeamNumber()]
			print("nSegments: ", nSegments)
		end
		
		local nSegmentsRemaining = self.SEGMENTS_TO_WIN - nSegments
			--print("nSegments: ", nSegments)
			--print("nSegments Remaining: ", nSegmentsRemaining)

		local on_kill_event =
		{
			killer_id = event.killer_userid,
			team_id = event.teamnumber,
			tail_lengths = CWormWarGameMode.TailLengths,
			kills_remaining = nSegmentsRemaining,
			victory = 0,
			close_to_victory = 0,
			very_close_to_victory = 0,
		}


		if nSegmentsRemaining <= 0 then
			GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[heroTeam] )
			GameRules:SetGameWinner(heroTeam)
			on_kill_event.victory = 1
		elseif nSegmentsRemaining == 1 then
			EmitGlobalSound( "ui.npe_objective_complete" )
			on_kill_event.very_close_to_victory = 1
		elseif nSegmentsRemaining == self.CLOSE_TO_VICTORY_THRESHOLD then
			EmitGlobalSound( "WormWar.Warning10SegmentsRemaining01")
			on_kill_event.close_to_victory = 1
		elseif nSegmentsRemaining < self.CLOSE_TO_VICTORY_THRESHOLD then
			EmitGlobalSound("ui.npe_objective_given")
			on_kill_event.close_to_victory = 1
		end
			
		CustomGameEventManager:Send_ServerToAllClients( "on_kill_event", on_kill_event )
		--end)
	end
end