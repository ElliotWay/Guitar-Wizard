package src
{
	import flash.display.NativeMenu;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import test.TestRunner;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Main extends Sprite 
	{
		
		public static const WIDTH:int = 800;
		public static const HEIGHT:int = 600;
		
		public static const VIDEO_LAG:int = 70; //milliseconds
		
		public static const HIGH:int = 0;
		public static const MID:int = 1;
		public static const LOW:int = 2;
		
		private static var menu:Menu;
		private static var gameUI:GameUI;
		
		private static var song:Song;
		
		private static var songLoader:SongLoader;
		
		public function Main():void 
		{
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			var repeater:Repeater = new Repeater(this);
			repeater.prepareRegularRuns();
			
			songLoader = new SongLoader();
			
			menu = new Menu();
			this.addChild(menu);
			menu.visible = false;//TODO true
			
			gameUI = new GameUI(repeater);
			this.addChild(gameUI);
			gameUI.visible = false;
			
			switchToGame("../assets/FurElise.gws");
		}
		
		public static function fileLoaded():void {
			gameUI.loadSong(song);
			
			songLoader.load();
		}
		
		public static function switchToGame(songFile:String):void {
			song = new Song();
			song.loadFile(songFile);
			
			menu.visible = false;
			gameUI.visible = true;
		}
		
		public static function go():void {
			gameUI.go();
		}
		
		public static function switchToMenu():void {
			gameUI.stop();
			gameUI.visible = false;
			menu.visible = true;
		}
		
		/**
		 * Passes the parameters to the song loader to load.
		 * @param	song song to load the music into
		 * @param	url url of the mp3 file
		 */
		public static function loadSong(song:Sound, url:String):void {
			songLoader.addSong(song, url);
		}
		
		public static function showError(errorMessage:String):void {
			var errorSprite:Sprite = new Sprite();
			
			errorSprite.graphics.beginFill(0xFF0000);
			errorSprite.graphics.drawRect(0, 0, gameUI.width, gameUI.height);
			errorSprite.graphics.endFill();
			
			var error:TextField = new TextField();
			error.width = gameUI.width;
			error.text = errorMessage;
			
			errorSprite.addChild(error);
			
			gameUI.addChild(errorSprite);
		}
		
	}
	
}