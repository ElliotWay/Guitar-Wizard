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
		public static const HIT_TOLERANCE:Number = 150; //how far from the actual note a hit can be
														//in milliseconds
		
		//GUI parts
		private var musicArea:MusicArea;
		//private var mainArea:MainArea;
		//private var minimapArea:MiniMapArea;
		//private var controlArea:ControlArea;
		
		//Other output parts
		private var musicPlayer:MusicPlayer;
		
		
		private var song:Song;
		private var track:int;
		
		public function GameUI() 
		{
			super();
			
			musicArea = new MusicArea();
			this.addChild(musicArea);
			musicArea.x = 0; musicArea.y = 0;
			
			track = Main.MID;
			musicPlayer = new MusicPlayer(Main.MID);
		}
		
		public function loadSong(song:Song):void {
			this.song = song;
			musicArea.loadNotes(song);
			musicPlayer.loadMusic(song);
		}
		
		public function go():void {
			//Start listening to the keyboard
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);

			musicArea.go();
			musicPlayer.go()
		}
		
		public function notePressHandler(noteLetter:int):void {
			//TODO consider switching to binary search
			var notesToSearch:Vector.<Note>;
			if (track == Main.HIGH)
				notesToSearch = song.highPart;
			if (track == Main.MID)
				notesToSearch = song.midPart;
			if (track == Main.LOW)
				notesToSearch = song.lowPart;
				
			var rightNow:Number = musicPlayer.getTime();
			
			var note:Note = null;
			for each(note in notesToSearch) {
				if (!note._isHit && note.letter == noteLetter && Math.abs(note.time - rightNow) < HIT_TOLERANCE) {
					note._isHit = true;
					note.associatedSprite.hit();
					musicPlayer.resumeTrack();
					break;
				}
			}
			
			if (note == null || !note._isHit) {
				musicPlayer.stopTrack();
				musicPlayer.playMissSound();
			}
		}
		
		public function keyboardHandler(e:KeyboardEvent):void {
			switch (e.keyCode) {
				//First the note keys.
				case Keyboard.F:
					notePressHandler(Note.NOTE_F);
					break;
				case Keyboard.D:
					notePressHandler(Note.NOTE_D);
					break;
				case Keyboard.S:
					notePressHandler(Note.NOTE_S);
					break;
				case Keyboard.A:
					notePressHandler(Note.NOTE_A);
					break;
			}
		}
		
	}

}