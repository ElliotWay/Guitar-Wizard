package src
{
	import flash.display.NativeMenu;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import org.flexunit.runner.FlexUnitCore;
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
		
		
		private static var everyFrameRun:Dictionary;
		
		private static var millisecondsPerBeat:int = 500;
		
		private static var quarterBeatRun:Dictionary;
		private static var quarterBeatTimer:Timer;
		private static var thirdBeatRun:Dictionary;
		private static var thirdBeatTimer:Timer;
		
		public function Main():void 
		{
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			prepareRegularRuns();
			
			this.addEventListener(Event.ENTER_FRAME, frameRunner);
			
			songLoader = new SongLoader();
			
			menu = new Menu();
			this.addChild(menu);
			menu.visible = false;//TODO true
			
			gameUI = new GameUI();
			this.addChild(gameUI);
			gameUI.visible = false;
			
			switchToGame("../assets/FurElise.gws");
		}
		
		public static function prepareRegularRuns():void {
			everyFrameRun = new Dictionary(true);
			
			quarterBeatRun = new Dictionary(true);
			quarterBeatTimer = null;
			thirdBeatRun = new Dictionary(true);
			thirdBeatTimer = null;
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
		
		public static function setBeat(millisPerBeat:int):void {
			
			millisecondsPerBeat = millisPerBeat;
			
			if (quarterBeatTimer != null) {
				quarterBeatTimer.stop();
			}
			//Remember that repeating 0 times mean repeat indefinitely.
			quarterBeatTimer = new Timer(millisPerBeat / 4, 0);
			quarterBeatTimer.addEventListener(TimerEvent.TIMER, quarterBeatRunner);
			
			if (thirdBeatTimer != null) {
				thirdBeatTimer.stop();
			}
			thirdBeatTimer = new Timer(millisPerBeat / 3, 0);
			thirdBeatTimer.addEventListener(TimerEvent.TIMER, thirdBeatRunner);
			
			quarterBeatTimer.start();
			thirdBeatTimer.start();
		}
		
		/**
		 * Get the current beat, in milliseconds per beat. If the beat has not been set, this returns 500.
		 * This beat drives the functions running every quarter and every third beat.
		 * @return the current beat, in milliseconds per beat
		 */
		public static function getBeat():int {
			return millisecondsPerBeat;
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
		
		/**
		 * Run a given function every frame. The function should take no arguments.
		 * @param	func the function to run every frame
		 */
		public static function runEveryFrame(func:Function):void {
			everyFrameRun[func] = func;
		}
		
		/**
		 * Stop running the function every frame.
		 * @param   func the function to stop running
		 */
		public static function stopRunningEveryFrame(func:Function):void {
			delete everyFrameRun[func];
		}
		
		public static function runEveryQuarterBeat(func:Function):void {
			quarterBeatRun[func] = func;
		}
		
		public static function stopRunningEveryQuarterBeat(func:Function):void {
			delete quarterBeatRun[func];
		}
		
		public static function runEveryThirdBeat(func:Function):void {
			thirdBeatRun[func] = func;
		}
		
		public static function stopRunningEveryThirdBeat(func:Function):void {
			delete thirdBeatRun[func];
		}
		
		private static function frameRunner(e:Event):void {
			for (var func:Object in everyFrameRun) {
				
				(func as Function).call();
			}
		}
		
		private static function quarterBeatRunner(e:Event):void {
			for (var func:Object in quarterBeatRun) {
				(func as Function).call();
			}
		}
		
		private static function thirdBeatRunner(e:Event):void {
			for (var func:Object in thirdBeatRun) {
				
				(func as Function).call();
			}
		}
		
	}
	
}