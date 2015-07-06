-- Generated from template

if CWormWarGameMode == nil then
	_G.CWormWarGameMode = class({})
end


--package.path = package.path .. "../?.lua"
--print(package.path)


require( "events" )

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheUnitByNameAsync( "npc_dota_creature_sheep", function(unit) end )
	PrecacheModel( "models/items/hex/sheep_hex/sheep_hex.vmdl", context)	 	-- Sheep Model
	--PrecacheScriptSound("Hero_ShadowShaman.SheepHex.Target")

	PrecacheUnitByNameAsync( "npc_dota_creature_pig", function(unit) end )
	PrecacheModel( "models/props_gameplay/pig.vmdl", context)	 				-- Pig Model
	--PrecacheScriptSound("General.Pig")

	
	PrecacheUnitByNameAsync( "npc_dota_creature_gold_sheep", function(unit) end )
	PrecacheModel( "models/items/hex/sheep_hex/sheep_hex_gold.vmdl", context) 	-- Golden Sheep Model
	--PrecacheScriptSound("Item.PickUpGemWorld")


end

-- Create the game mode when we activate
function Activate()
	GameRules.WormWar = CWormWarGameMode()
	GameRules.WormWar:InitGameMode()
end

function CWormWarGameMode:InitGameMode()
	print( "Worm War is loaded." )
	local GameMode = GameRules:GetGameModeEntity()

	GameRules:SetPreGameTime( 10 )
	GameMode:SetFixedRespawnTime( 5 )
	GameMode:SetFogOfWarDisabled(true)
	

	GameMode:SetThink( "OnThink", self, "GlobalThink", 2 )
end

-- Evaluate the state of the game
function CWormWarGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
		CWormWarGameMode:DetermineAnimalSpawn()

	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end