-- Generated from template

if CWormWarGameMode == nil then
	_G.CWormWarGameMode = class({})
end

--require( "os" )
require( "events" )
require( "utility_functions")
require( "timers" )


function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	PrecacheResource( "particle", "particles/leader/leader_overhead.vpcf", context )
	
	PrecacheUnitByNameAsync( "npc_dota_creature_sheep", function(unit) end )
	PrecacheModel( "models/items/hex/sheep_hex/sheep_hex.vmdl", context)	 	-- Sheep Model
	--PrecacheScriptSound("Hero_ShadowShaman.SheepHex.Target")

	PrecacheUnitByNameAsync( "npc_dota_creature_pig", function(unit) end )
	PrecacheModel( "models/props_gameplay/pig.vmdl", context)	 				-- Pig Model
	--PrecacheScriptSound("General.Pig")

	
	PrecacheUnitByNameAsync( "npc_dota_creature_gold_sheep", function(unit) end )
	PrecacheModel( "models/items/hex/sheep_hex/sheep_hex_gold.vmdl", context) 	-- Golden Sheep Model
	--PrecacheScriptSound("Item.PickUpGemWorld")

	PrecacheUnitByNameAsync( "npc_dota_creature_tail_bug", function(unit) end )	
	PrecacheModel("models/items/broodmother/spiderling/thistle_crawler/thistle_crawler.vmdl", context) -- Tail Bug Model
	
	PrecacheUnitByNameAsync( "npc_dota_creature_fire_elemental", function(unit) end )
	PrecacheModel( "models/heroes/invoker/forge_spirit.vmdl", context) 	-- Forge Spirit model

	PrecacheResource( "particle", "particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_broodmother.vsndevts", context )


--	Power Up Precaching
	PrecacheResource( "particle", "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context )

	PrecacheResource( "particle", "particles/units/heroes/hero_vengeful/vengeful_nether_swap_b.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_vengeful/vengeful_nether_swap_pink.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_techies/techies_remote_mines_detonate_base.vpcf", context )

	PrecacheResource( "particle", "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", context )

	PrecacheResource( "particle", "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_battle_hunger.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context )

	PrecacheItemByNameSync( "item_powerup", context )
	PrecacheModel("models/props_gameplay/rune_goldxp.vmdl", context)
--
	

	PrecacheResource( "soundfile", "soundevents/wormwar_sounds.vsndevts", context )

	PrecacheResource( "particle", "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf", context )


	




end

-- Create the game mode when we activate
function Activate()
	GameRules.WormWar = CWormWarGameMode()
	GameRules.WormWar:InitGameMode()
end

function CWormWarGameMode:InitGameMode()
	print( "Worm War is loaded." )
	--math.randomseed( os.time() )
	local GameMode = GameRules:GetGameModeEntity()

	--TEAM COLOURS
	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }	--		Teal
	self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }		--		Yellow
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }		--		Orange
	self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }		--		Blue
	self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }	--		Green
	self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }		--		Brown
	self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }	--		Cyan
	self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }	--		Olive
	self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }	--		Purple


	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

	CWormWarGameMode.nSpawnedPowerUps = 0

	self.m_VictoryMessages = {}
	self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
	self.m_VictoryMessages[DOTA_TEAM_BADGUYS]  = "#VictoryMessage_BadGuys"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_2] = "#VictoryMessage_Custom2"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_3] = "#VictoryMessage_Custom3"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_4] = "#VictoryMessage_Custom4"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_5] = "#VictoryMessage_Custom5"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_6] = "#VictoryMessage_Custom6"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_7] = "#VictoryMessage_Custom7"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_8] = "#VictoryMessage_Custom8"

	self.m_GatheredShuffledTeams = {}
	self.SEGMENTS_TO_WIN = 60
	self.CLOSE_TO_VICTORY_THRESHOLD = 10
	self.SEGMENT_PER_KILL = 5 		--Percentage
	self.FOOD_LIMIT = 20
	self.NUM_CENTRE_FOOD = 5
	self.NUM_SUPER_FOOD = 3
	self.NUM_FIRE_ELEMENTAL = 3
	self.NUM_POWERUPS = 3

	self.leadingTeam = -1
	self.runnerupTeam = -1
	self.leadingTeamScore = 0
	self.runnerupTeamScore = 0
	self.isGameTied = true
	self.countdownEnabled = false

	self:GatherAndRegisterValidTeams()

	GameRules:GetGameModeEntity().CWormWarGameMode = self

	--------------------------------------------------------------------------
	-- Show the ending scoreboard immediately
	GameRules:SetCustomGameEndDelay( 0 )
	GameRules:SetCustomVictoryMessageDuration( 20 )
	GameRules:SetPreGameTime( 3 )
	GameMode:SetFixedRespawnTime( 3 )
	GameMode:SetFogOfWarDisabled(true)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHeroSelectionTime(10.0)
	GameRules:SetGoldPerTick(0)
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	GameRules:SetUseBaseGoldBountyOnHeroes(true)
	GameRules:SetFirstBloodActive(true)				--Weird, bool is whether first blood has been triggered

	GameMode:SetCustomHeroMaxLevel(1)
	GameMode:SetGoldSoundDisabled(true)
	GameMode:SetModifyGoldFilter( Dynamic_Wrap( self, "FilterModifyGold" ), self )
	GameMode:SetModifyExperienceFilter( Dynamic_Wrap( self, "FilterModifyXP" ), self )
	GameMode:SetAnnouncerDisabled(true)

	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( CWormWarGameMode, "ExecuteOrderFilter" ), self )
	
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CWormWarGameMode, 'OnGameRulesStateChange' ), self )
	spawnListener = ListenToGameEvent("npc_spawned", Dynamic_Wrap(CWormWarGameMode, "OnNPCSpawned"), self) 
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CWormWarGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent("tail_growth", Dynamic_Wrap( CWormWarGameMode, 'OnTailGrowth' ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( CWormWarGameMode, "OnItemPickUp"), self )
	-- ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( CWormWarGameMode, "OnNpcGoalReached" ), self )

	Convars:RegisterCommand( "wormwar_force_end_game", function(...) return self:EndGame( DOTA_TEAM_GOODGUYS ) end, "Force the game to end.", FCVAR_CHEAT )


	GameMode:SetThink( "OnThink", self, "GlobalThink", 1 )

	CWormWarGameMode.HeroSpawns = {}
	CWormWarGameMode.HeroSpawns = Entities:FindAllByClassname("info_player_start_dota") 

	--- Spawn initial Food
	for i = 1, self.FOOD_LIMIT do
		CWormWarGameMode:SpawnFoodEntity("npc_dota_creature_sheep", false )
	end

	-- Spawn inital food in centre
	for i = 1, self.NUM_CENTRE_FOOD do
		CWormWarGameMode:SpawnFoodEntity("npc_dota_creature_sheep", true )
	end

	-- Spawn inital pigs
	for i = 1, self.NUM_SUPER_FOOD do
		CWormWarGameMode:SpawnFoodEntity("npc_dota_creature_pig", false )
	end

	-- Spawn inital Fire Elementals
	for i = 1, self.NUM_FIRE_ELEMENTAL do
		CWormWarGameMode:SpawnFoodEntity("npc_dota_creature_fire_elemental", true )
	end

	CWormWarGameMode.TailLengths = {}

	for i = DOTA_TEAM_GOODGUYS, DOTA_TEAM_CUSTOM_8 do
   		CWormWarGameMode.TailLengths[i] = 0
	end


	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
   		CustomNetTables:SetTableValue( "segments_lost", "player_" .. tostring(nPlayerID), {value = 0} )
   		CustomNetTables:SetTableValue( "segments_killed", "player_" .. tostring(nPlayerID), {value = 0} )
   	end

end

-- Evaluate the state of the game
function CWormWarGameMode:OnThink()
	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		self:UpdatePlayerColor( nPlayerID )
	end

	self:UpdateScoreboard()

	-- Stop thinking if game is paused
	if GameRules:IsGamePaused() == true then
        return 1
    end

    if self.countdownEnabled == true then
		CountdownTimer()
		if nCOUNTDOWNTIMER == 30 then
			CustomGameEventManager:Send_ServerToAllClients( "timer_alert", {} )
		end
		if nCOUNTDOWNTIMER <= 0 then
			--Check to see if there's a tie
			if self.isGameTied == false then
				GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[self.leadingTeam] )
				CWormWarGameMode:EndGame( self.leadingTeam )
				self.countdownEnabled = false
			--[[else
				self.TEAM_KILLS_TO_WIN = self.leadingTeamScore + 1
				local broadcast_killcount = 
				{
					killcount = self.TEAM_KILLS_TO_WIN
				}
				CustomGameEventManager:Send_ServerToAllClients( "overtime_alert", broadcast_killcount )]]--
			end
       	end
	end

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local gameTime = GameRules:GetGameTime()

		--print(gameTime)
		if math.floor(gameTime) % 60 == 0 and math.floor(gameTime) ~= 0 then
			CWormWarGameMode:SpawnFoodEntity("npc_dota_creature_sheep", false )
			--print("Spawning extra food")
		end

		if math.floor(gameTime) > 30 then
			if CWormWarGameMode:SpawnPowerUp() then
				CWormWarGameMode.nSpawnedPowerUps = CWormWarGameMode.nSpawnedPowerUps + 1
			end
		end

		-- Check for disconnects
		local allHeroes = HeroList:GetAllHeroes()

		for _,entity in pairs( allHeroes) do
			local connectionState = PlayerResource:GetConnectionState(entity:GetPlayerID())
			if connectionState == DOTA_CONNECTION_STATE_DISCONNECTED or connectionState == DOTA_CONNECTION_STATE_ABANDONED then
				if entity:IsAlive() then
					entity:ForceKill(true)
				end
				entity:SetTimeUntilRespawn(5)
				print("hero is out of the game")
			end
		end

		return 1
	end


	return 1
end

function CWormWarGameMode:MovementThink()
	local allHeroes = HeroList:GetAllHeroes()

	for _,entity in pairs( allHeroes) do
		local do_move = false
		local origin = entity:GetAbsOrigin()
		local forwardVector = entity:GetForwardVector()
		
		if (origin.x > 4000 or origin.x < -4000) or (origin.y > 4000 or origin.y < -4000) then
			entity:ForceKill(true)
			-- moved to OnEntityKilled event  
			--EmitGlobalSound("WormWar.Noob01")
		end

		if entity.lastOrigin == nil or entity.lastForwardVector == nil then
			do_move = true
		else
			local displacement = origin - entity.lastOrigin
			local distance = displacement:Length2D()
			if distance <= 0.0001 and entity.lastForwardVector:Cross(forwardVector):Length() < 0.0001  then
				do_move = true
			end
		end

		entity.lastOrigin = origin
		entity.lastForwardVector = forwardVector

		if do_move then
			local forwardVector = entity:GetForwardVector()
			local newMoveLocation = origin + (forwardVector * 500)
			
			entity.dest = newMoveLocation
			entity:MoveToPosition(newMoveLocation)
		end
	end
	return 0.01
end

function CWormWarGameMode:RoamingThink()
	local units = FindUnitsInRadius( DOTA_TEAM_NEUTRALS, Vector(0, 0, 0), nil, 6000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	if units ~= nil then
		for _, entity in pairs(units) do
			if entity:GetUnitName() == "npc_dota_creature_fire_elemental" then
				--print(entity:GetUnitName())
				--print(entity:GetAbsOrigin())
				entity:Stop()
				local curPos = entity:GetAbsOrigin() 
				local rAngle = RandomInt(0, 359)
				local newPos = curPos + Vector(1250*math.cos(math.rad(rAngle)), 1250*math.sin(math.rad(rAngle)), 0)

				for i = 1, 4 do
					if math.abs(newPos.x) > 4000 or math.abs(newPos.y) > 4000 then
						rAngle = rAngle + 90
						newPos = curPos + Vector(1250*math.cos(math.rad(rAngle)), 1250*math.sin(math.rad(rAngle)), 0)
					else
						break
					end
				end
				entity:MoveToPosition(newPos)
			end
		end
	end

	return RandomInt( 4, 6 )
end

function CWormWarGameMode:ItemThink()
	local numItems = GameRules:NumDroppedItems()
	-- print("Num dropped items",numItems)

	for x = 0,numItems-1 do
		local item = GameRules:GetDroppedItem(x)
		-- print("item",item)
		local origin = item:GetAbsOrigin()
		local heroes = FindUnitsInRadius(0,origin,nil,50.0,DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)

		for _,hero in ipairs(heroes) do
			if hero ~= nil and 
					not (hero:FindAbilityByName("fiery_jaw") or
							hero:FindAbilityByName("crypt_craving") or
							hero:FindAbilityByName("reverse_worm") or
							hero:FindAbilityByName("goo_bomb") or
							hero:FindAbilityByName("segment_bomb")) then
				hero:PickupDroppedItem(item)
			end
		end
	end

	return 0.1
end

---------------------------------------------------------------------------
-- Get the color associated with a given teamID
---------------------------------------------------------------------------
function CWormWarGameMode:ColorForTeam( teamID )
	local color = self.m_TeamColors[ teamID ]
	if color == nil then
		color = { 255, 255, 255 } -- default to white
	end
	return color
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function CWormWarGameMode:EndGame( victoryTeam )
	GameRules:SetGameWinner( victoryTeam )
end

function CWormWarGameMode:UpdatePlayerColor( nPlayerID )
	if not PlayerResource:HasSelectedHero( nPlayerID ) then
		return
	end

	local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
	if hero == nil then
		return
	end

	local teamID = PlayerResource:GetTeam( nPlayerID )
	local color = self:ColorForTeam( teamID )
	PlayerResource:SetCustomPlayerColor( nPlayerID, color[1], color[2], color[3] )
end

function CWormWarGameMode:UpdateScoreboard()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		local tScore = 0
		if CWormWarGameMode.TailLengths[team] ~= nil then
			tScore = CWormWarGameMode.TailLengths[team]
		end
		table.insert( sortedTeams, { teamID = team, teamScore = tScore } )
	end

	-- reverse-sort by score
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	for _, t in pairs( sortedTeams ) do
		local clr = self:ColorForTeam( t.teamID )

		-- Scaleform UI Scoreboard
		local score = 
		{
			team_id = t.teamID,
			team_score = t.teamScore
		}
		FireGameEvent( "score_board", score )
	end
	-- Leader effects (moved from OnTeamKillCredit)
	local leader = sortedTeams[1].teamID
	--print("Leader = " .. leader)
	self.leadingTeam = leader
	self.runnerupTeam = sortedTeams[2].teamID
	self.leadingTeamScore = sortedTeams[1].teamScore
	self.runnerupTeamScore = sortedTeams[2].teamScore

	if sortedTeams[1].teamScore == sortedTeams[2].teamScore then
		self.isGameTied = true
	else
		self.isGameTied = false
	end
	local allHeroes = HeroList:GetAllHeroes()
	for _,entity in pairs( allHeroes) do
		if entity:GetTeamNumber() == leader and sortedTeams[1].teamScore ~= sortedTeams[2].teamScore then
			if entity:IsAlive() == true then
				-- Attaching a particle to the leading team heroes
				local existingParticle = entity:Attribute_GetIntValue( "particleID", -1 )
       			if existingParticle == -1 then
       				local particleLeader = ParticleManager:CreateParticle( "particles/leader/leader_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, entity )
					ParticleManager:SetParticleControlEnt( particleLeader, PATTACH_OVERHEAD_FOLLOW, entity, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", entity:GetAbsOrigin(), true )
					entity:Attribute_SetIntValue( "particleID", particleLeader )
				end
			else
				local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
				if particleLeader ~= -1 then
					ParticleManager:DestroyParticle( particleLeader, true )
					entity:DeleteAttribute( "particleID" )
				end
			end
		else
			local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
			if particleLeader ~= -1 then
				ParticleManager:DestroyParticle( particleLeader, true )
				entity:DeleteAttribute( "particleID" )
			end
		end
	end
end

---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function CWormWarGameMode:GatherAndRegisterValidTeams()
--	print( "GatherValidTeams:" )

	local foundTeams = {}
	for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
		foundTeams[  playerStart:GetTeam() ] = true
	end

	local numTeams = TableCount(foundTeams)
	print( "GatherValidTeams - Found spawns for a total of " .. numTeams .. " teams" )
	
	local foundTeamsList = {}
	for t, _ in pairs( foundTeams ) do
		table.insert( foundTeamsList, t )
	end

	if numTeams == 0 then
		print( "GatherValidTeams - NO team spawns detected, defaulting to GOOD/BAD" )
		table.insert( foundTeamsList, DOTA_TEAM_GOODGUYS )
		table.insert( foundTeamsList, DOTA_TEAM_BADGUYS )
		numTeams = 2
	end

	local maxPlayersPerValidTeam = math.floor( 10 / numTeams )

	self.m_GatheredShuffledTeams = ShuffledList( foundTeamsList )

	print( "Final shuffled team list:" )
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " )" )
	end

	print( "Setting up teams:" )
	for team = 0, (DOTA_TEAM_COUNT-1) do
		local maxPlayers = 0
		if ( nil ~= TableFindKey( foundTeamsList, team ) ) then
			maxPlayers = maxPlayersPerValidTeam
		end
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " ) -> max players = " .. tostring(maxPlayers) )
		GameRules:SetCustomGameTeamMaxPlayers( team, maxPlayers )
	end
end

---------------------------------------------------------------------------
-- Event: Spawn Sheep
---------------------------------------------------------------------------
function CWormWarGameMode:SpawnFoodLocation(centre)
	local goodSpawn = false

	while goodSpawn == false do
		
		goodSpawn = true

		local r1 = RandomInt( -40, 40 )
		local r2 = RandomInt( -40, 40 )
		local xpos = 0
		local ypos = 0
	
		if centre then
			xpos = r1*50; -- Coordinates within centre of arena
			ypos = r2*50;
		else
			xpos = r1*100; -- Coordinates within arena (depends on map size)
			ypos = r2*100;
		end

		local spawnPoint = Vector(xpos, ypos, 0)

		for i = 1, #CWormWarGameMode.HeroSpawns do
			local heroSpawn = CWormWarGameMode.HeroSpawns[i]:GetAbsOrigin()
			local dist = spawnPoint - heroSpawn

			if dist:Length2D() < 450 then
				goodSpawn = false
				print("BAD SHEEP SPAWN: ", dist:Length2D())
				break
			end
		end
		print("Good sheep pos")
		if goodSpawn then
			return spawnPoint
		end	
	end
end

function CWormWarGameMode:SpawnFoodEntity(foodType, centre)
	
	local spawnPoint = CWormWarGameMode:SpawnFoodLocation(centre)
	local hFood = CreateUnitByName( foodType, spawnPoint, true, nil, nil, DOTA_TEAM_NEUTRALS )
	
	--print(hFood:GetUnitName())
	if centre and hFood ~= nil then
		--print("respawning centre food")
		hFood.centreFlag = true
	else
		hFood.centreFlag = false
	end
end

function CWormWarGameMode:SpawnPowerUp()
	--print(CWormWarGameMode.nSpawnedPowerUps)
	--print(self.NUM_POWERUPS)
	if 	CWormWarGameMode.nSpawnedPowerUps < 3 then
		local spawnPoint = CWormWarGameMode:SpawnFoodLocation(false)
		print("PowerUp location: ", spawnPoint)
		local newItem = CreateItem( "item_powerup", nil, nil )
		local item = CreateItemOnPositionSync(spawnPoint, newItem)
		local minimapUnit = CreateUnitByName("npc_powerup_icon", spawnPoint, false, nil, nil, DOTA_TEAM_NEUTRALS)

		return true
	else
		return false
	end

end

function CWormWarGameMode:ExecuteOrderFilter( filterTable )
	
	local orderType = filterTable["order_type"]

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		filterTable["order_type"] = DOTA_UNIT_ORDER_NONE
	end
	
	if orderType == DOTA_UNIT_ORDER_ATTACK_TARGET then
		local unit = EntIndexToHScript( filterTable["entindex_target"] )

		if unit ~= nil then
			print("Moving to target instead")

				local position = unit:GetAbsOrigin()
				filterTable["position_x"] = position.x
				filterTable["position_y"] = position.y
				filterTable["position_z"] = position.z
				filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
		end
		return true
	elseif orderType == DOTA_UNIT_ORDER_ATTACK_MOVE then
		filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION

	elseif orderType == DOTA_UNIT_ORDER_HOLD_POSITION or orderType == DOTA_UNIT_ORDER_STOP or orderType == DOTA_UNIT_ORDER_TAUNT then
		filterTable["order_type"] = DOTA_UNIT_ORDER_NONE

	elseif ( orderType ~= DOTA_UNIT_ORDER_PICKUP_ITEM or filterTable["issuer_player_id_const"] == -1 ) then
		return true
	
	else
		print("Order filter")
		local item = EntIndexToHScript( filterTable["entindex_target"] )
		if item == nil then
			return true
		end
		local pickedItem = item:GetContainedItem()
		--print(pickedItem:GetAbilityName())
		if pickedItem == nil then
			return true
		end
		if pickedItem:GetAbilityName() == "item_powerup" then
			local player = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
			local hero = player:GetAssignedHero()
			
			if hero:FindAbilityByName("fiery_jaw") or hero:FindAbilityByName("crypt_craving") or hero:FindAbilityByName("reverse_worm") or hero:FindAbilityByName("goo_bomb") or hero:FindAbilityByName("segment_bomb") then
				print("Moving to target instead")

				local position = item:GetAbsOrigin()
				filterTable["position_x"] = position.x
				filterTable["position_y"] = position.y
				filterTable["position_z"] = position.z
				filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				return true
			else
				print("has no ability")
				return true
			end
		end
	end
	return true
end

function CWormWarGameMode:FilterModifyGold( filterTable )

	--print("[addon_game_mode.lua] ModifyGoldFilter")
	--for k, v in pairs( filterTable ) do
	--	print("Key: ", k)
	--		print("Value: ", v)
	--	end
	--Disable gold gain from hero kills
	if filterTable["reason_const"] == DOTA_ModifyGold_HeroKill then
		filterTable["gold"] = 0
		return true
	elseif filterTable["gold"] > 10 then
		filterTable["gold"] = 0
		return true
	end

	--Otherwise use normal logic
	return false

end

function CWormWarGameMode:FilterModifyXP( filterTable )

	--print("[addon_game_mode.lua] ModifyGoldFilter")
	
	--Disable xp gain from hero kills
	if filterTable["experience"] > 0 then
		filterTable["experience"] = 0
		return true
	end

	--Otherwise use normal logic
	return false

end
