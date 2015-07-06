--[[ events.lua ]]
---------------------------------------------------------------------------
-- Event: Determine animal to spawn
---------------------------------------------------------------------------
function CWormWarGameMode:DetermineAnimalSpawn()
	local r = RandomInt( 1, 100 )
	if r > 25 then
		CWormWarGameMode:SpawnFoodLocation(1) -- Regular Sheep
	elseif r > 5 and r <=25 then
		CWormWarGameMode:SpawnFoodLocation(2) -- Pig
	else
		CWormWarGameMode:SpawnFoodLocation(3) -- Golden Sheep
	end
end

---------------------------------------------------------------------------
-- Event: Spawn Sheep
---------------------------------------------------------------------------
function CWormWarGameMode:SpawnFoodLocation(foodType)
	local r1 = RandomInt( 0, 100 )
	local r2 = RandomInt( 0, 100 )
	local xpos = (r1-50)*10; --convert random coords to map coords
	local ypos = (r2-50)*10;
	--print("sheep position: " .. xpos..", ".. ypos)
	CWormWarGameMode:SpawnFoodEntity(foodType, Vector( xpos, ypos, 0 ) )
end

function CWormWarGameMode:SpawnFoodEntity(foodType, spawnPoint)
	if foodType == 1 then
		EmitGlobalSound("Hero_ShadowShaman.SheepHex.Target")
		local sheep = CreateUnitByName( "npc_dota_creature_sheep", spawnPoint, true, nil, nil, DOTA_TEAM_NEUTRALS )
	elseif foodType == 2 then
		EmitGlobalSound("General.Pig")
		local sheep = CreateUnitByName( "npc_dota_creature_pig", spawnPoint, true, nil, nil, DOTA_TEAM_NEUTRALS )
	elseif foodType == 3 then
		EmitGlobalSound("Item.PickUpGemWorld")
		local sheep = CreateUnitByName( "npc_dota_creature_gold_sheep", spawnPoint, true, nil, nil, DOTA_TEAM_NEUTRALS )
	end
	
end