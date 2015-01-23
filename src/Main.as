package src
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import org.flexunit.runner.FlexUnitCore;
	import test.TestRunner;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Main extends Sprite 
	{
		public static const DO_TEST:Boolean = true;
		
		public static const VIDEO_LAG:int = 70; //milliseconds
		
		public static const HIGH:int = 0;
		public static const MID:int = 1;
		public static const LOW:int = 2;
		
		private static var gameUI:GameUI;
		
		private static var songLoader:SongLoader;
		
		public function Main():void 
		{
			//If testing mode is on, run the tests, then stop.
			if (DO_TEST) {
				TestRunner.runTests();
				return;
			}
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			songLoader = new SongLoader();
			
			gameUI = new GameUI();
			this.addChild(gameUI);
			gameUI.visible = true;
			
			var song:Song = new Song();
			song.hardcode();
			
			gameUI.loadSong(song);
			
			songLoader.load();
		}
		
		public static function go():void {
			gameUI.go();
		}
		
		public static function loadSong(song:Sound, url:String):void {
			songLoader.addSong(song, url);
		}
		
		
		
	}
	
}