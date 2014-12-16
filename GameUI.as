package  {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class GameUI extends Sprite
	{	
		//GUI parts
		private var musicArea:MusicArea;
		//private var mainArea:MainArea;
		//private var minimapArea:MiniMapArea;
		//private var controlArea:ControlArea;
		
		//Other output parts
		private var musicPlayer:MusicPlayer;
		
		public function GameUI() 
		{
			super();
			
			musicArea = new MusicArea();
			this.addChild(musicArea);
			musicArea.x = 0; musicArea.y = 0;
			
			musicPlayer = new MusicPlayer(Main.MID);
		}
		
		public function loadSong(song:Song):void {
			musicArea.loadNotes(song);
			musicPlayer.loadMusic(song);
		}
		
		public function go():void {
			//Start listening to the keyboard
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);

			musicArea.go();
			musicPlayer.go()
		}
		
		public function keyboardHandler(e:KeyboardEvent):void {
			switch (e.keyCode) {
				//First the note keys.
				case Keyboard.F:
				case Keyboard.D:
				case Keyboard.S:
				case Keyboard.A:
					break;
			}
		}
		
	}

}