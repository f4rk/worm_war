package {
	import flash.display.MovieClip;

	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class FlashUtil extends MovieClip{
		
		//these three variables are required by the engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		
		var streams:Object;
		
		//Constructor - not used, onLoaded() instead
		public function FlashUtil() : void {
		}
			
		//this function is called when the UI is loaded
		public function onLoaded() : void {		
			//initialise streams collection
			if (streams != null) {
				for each(var t:Timer in streams){
					t.stop();
				}
			}
			streams = new Object();
			
			//start listening for requests
			this.gameAPI.SubscribeToGameEvent("FlashUtil_request", this.onRequest);
			this.gameAPI.SubscribeToGameEvent("FlashUtil_request_stream", this.onStreamRequest);
			this.gameAPI.SubscribeToGameEvent("FlashUtil_stop_stream", this.onStreamStop);
			
			trace("FlashUtil UI loaded");
		}
		
		//Handle single requests from lua
		private function onRequest( args:Object ) {
			//check if the request was aimed at this UI
			if (globals.Players.GetLocalPlayer() == args.target_player || args.target_player == -1){				
				sendResponse(args);
			}
		}
		
		//A stream has been requested from lua, start sending requests every time a timer fires
		private function onStreamRequest( args:Object ) {
			//send the first response immediately
			if (globals.Players.GetLocalPlayer() == args.target_player || args.target_player == -1){
				sendResponse( args );
				
				//make a timer and save it under it's ID in an associative array
				var timer:Timer = new Timer(1000/args.requests_per_second);
				trace('timer delay:'+1/args.requests_per_second);
				this.streams[args.request_id] = timer;
				
				//bind a function to the firing of a timer
				timer.addEventListener(TimerEvent.TIMER, function( e:TimerEvent ) {
					//send a response to lua
					sendResponse( args ); 	
				});
				
				//start our timer
				timer.start();
			}
		}
		
		//Lua has requested a data stream to be stopped
		private function onStreamStop( args:Object ) {
			//stop and delete the timer
			this.streams[args.stream_id].stop();
			delete streams[args.stream_id];
		}
		
		//Send a response to lua
		private function sendResponse( args:Object ) {
			//build a return string
			var returnStr:String = "FlashUtil_return " + args.request_id + ";";
			returnStr += globals.Players.GetLocalPlayer()+";";
			
			//handle different data requests
			if (args.data_name == 'player_name') {
				//player name
				returnStr += 'String;' + globals.Players.GetPlayerName(globals.Players.GetLocalPlayer());
				
			} else if (args.data_name == 'cursor_position') {
				//cursor position in screen coordinates
				returnStr += 'Vector2;' + stage.mouseX + "," + stage.mouseY;
				
			} else if (args.data_name == 'cursor_position_world') {
				//cursor position in world coordinates
				var pos:Array = globals.Game.ScreenXYToWorld(stage.mouseX, stage.mouseY);
				returnStr += 'Vector3;' + pos[0] + "," + pos[1] + "," + pos[2];
			}
			
			trace('Returning: "'+returnStr+'"');
			this.gameAPI.SendServerCommand(returnStr);
		}
	}
}