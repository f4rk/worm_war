"use strict";

var g_ScoreboardHandle = null;

function UpdateScoreboard(event)
{
	ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true, event.tail_lengths );

	//$.Schedule( 0.2, UpdateScoreboard );
}

(function()
{
	var shouldSort = true;

	if ( GameUI.CustomUIConfig().multiteam_top_scoreboard )
	{
		var cfg = GameUI.CustomUIConfig().multiteam_top_scoreboard;
		if ( cfg.LeftInjectXMLFile )
		{
			$( "#LeftInjectXMLFile" ).BLoadLayout( cfg.LeftInjectXMLFile, false, false );
		}
		if ( cfg.RightInjectXMLFile )
		{
			$( "#RightInjectXMLFile" ).BLoadLayout( cfg.RightInjectXMLFile, false, false );
		}

		if ( typeof(cfg.shouldSort) !== 'undefined')
		{
			shouldSort = cfg.shouldSort;
		}
	}
	
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_player.xml",
		"shouldSort" : shouldSort
	};

	var initTailLengths = [0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#MultiteamScoreboard" ), initTailLengths );

	GameEvents.Subscribe( "tail_growth_event", UpdateScoreboard );
	GameEvents.Subscribe( "hero_death_event", UpdateScoreboard );
	//UpdateScoreboard();
})();

