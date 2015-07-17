--[[ events.lua ]]
---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function CWormWarGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	--print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then

	end

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		local numberOfPlayers = PlayerResource:GetPlayerCount()
		nCOUNTDOWNTIMER = 601
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

		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.SEGMENT_TO_WIN } );

		self._fPreGameStartTime = GameRules:GetGameTime()
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
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
    	hero:SetAbilityPoints(0)
        local Ability1 = hero:FindAbilityByName("devour_aura")
        local Ability2 = hero:FindAbilityByName("tail_growth")
		local Ability3 = hero:FindAbilityByName("worm_war_phase")
		-- local Ability4 = hero:FindAbilityByName("worm_war_movement")
		--local Ability4 = hero:FindAbilityByName("lina_dragon_slave")
        if Ability1 and Ability2 and Ability3 then
            print('hero Spawned leveling spells')
            Ability1:SetLevel(1)
            Ability2:SetLevel(1)
			Ability3:SetLevel(1)
			-- Ability4:SetLevel(1)
			--Ability4:SetLevel(1)

        end

		hero.dest = nil
    end
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
	
	local broadcast_kill_event =
	{
		killer_id = event.killer_userid,
		team_id = event.teamnumber,
		--team_kills = nTeamKills,
		--kills_remaining = nKillsRemaining,
		victory = 0,
		close_to_victory = 0,
		very_close_to_victory = 0,
	}

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

	CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function CWormWarGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local hero = EntIndexToHScript( event.entindex_attacker )
	local heroTeam = hero:GetTeam()

	--Need to change hero killing code
	if killedUnit:IsRealHero() then
		self.allSpawned = true
		killedUnit.dest = nil
		--print("Hero has been killed")
		if hero:IsRealHero() and heroTeam ~= killedTeam then
			--print("Granting killer xp")
			if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false then
				local memberID = hero:GetPlayerID()
				PlayerResource:ModifyGold( memberID, 500, true, 0 )
				hero:AddExperience( 100, 0, false, false )
				local name = hero:GetClassname()
				local victim = killedUnit:GetClassname()
				local kill_alert =
					{
						hero_id = hero:GetClassname()
					}
				CustomGameEventManager:Send_ServerToAllClients( "kill_alert", kill_alert )
			else
				hero:AddExperience( 50, 0, false, false )
			end
		end
	else
		-- Unit deaths (food, fire elementals etc.)
		-- HANDLE LENGTH addition + win condition
		local nSegments = 0
		if hero.tailLength ~= null then
			nSegments = hero.tailLength
		end
		local nSegmentsRemaining = self.SEGMENTS_TO_WIN - nSegments
		print("Current Segments: ".. nSegments)
		print("Segments Remaining: ".. nSegmentsRemaining)
		if nSegmentsRemaining <= 0 then
			GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[nTeamID] )
			GameRules:SetGameWinner( nTeamID )
			--broadcast_kill_event.victory = 1
		elseif nSegmentsRemaining == 1 then
			EmitGlobalSound( "ui.npe_objective_complete" )
			--broadcast_kill_event.very_close_to_victory = 1
		elseif nSegmentsRemaining <= self.CLOSE_TO_VICTORY_THRESHOLD then
			EmitGlobalSound( "ui.npe_objective_given" )
			--broadcast_kill_event.close_to_victory = 1
		end

		--Respawn food in appropriate area, dont respawn when tail bug dies
		if killedUnit:GetUnitName() ~= "npc_dota_creature_tail_bug" then
			CWormWarGameMode:SpawnFoodEntity(killedUnit:GetUnitName(), killedUnit.centreFlag)
		end
	end
end