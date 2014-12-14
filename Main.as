package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Main extends Sprite 
	{
		private var gameUI:GameUI;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			gameUI = new GameUI();
			this.addChild(gameUI);
			gameUI.visible = true;
			
			var song:Song = new Song();
			song.hardcode();
			
			gameUI.loadSong(song);
			
			var songSound:Sound = new Sound();
			songSound.addEventListener(IOErrorEvent.IO_ERROR, songError);
			songSound.addEventListener(Event.COMPLETE, songComplete);
			
			songSound.load(new URLRequest("../assets/Fur_Elise_Adapted_-_Baseline.mp3"));
			//gameUI.go();
		}
		
		public function songError(e:Event):void {
			trace("load error");
		}
		public function songComplete(e:Event):void {
			var song:Sound = (e.target as Sound);
			gameUI.go();
			song.play();
		}
		
	}
	
}