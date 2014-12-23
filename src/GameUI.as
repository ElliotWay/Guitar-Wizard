package  {
	import adobe.utils.CustomActions;
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
		public static const HIT_TOLERANCE:Number = 100; //how far from the actual note a hit can be
														//in milliseconds
		
		//GUI parts
		private var musicArea:MusicArea;
		//private var mainArea:MainArea;
		//private var minimapArea:MiniMapArea;
		//private var controlArea:ControlArea;
		
		//Other output parts
		private var musicPlayer:MusicPlayer;
		
		
		private var song:Song;
		private var currentTrack:int;
		
		private var expectingHold:Vector.<Boolean>;
		private var currentHolds:Vector.<Note>;
		
		private var highNotesRemaining:Vector.<Note>;
		private var nextHighNote:Note;
		private var midNotesRemaining:Vector.<Note>;
		private var nextMidNote:Note;
		private var lowNotesRemaining:Vector.<Note>;
		private var nextLowNote:Note;
		
		public function GameUI() 
		{
			super();
			
			musicArea = new MusicArea();
			this.addChild(musicArea);
			musicArea.x = 0; musicArea.y = 0;
			
			currentTrack = Main.MID;
			musicPlayer = new MusicPlayer(Main.MID);
			
			expectingHold = new <Boolean>[false, false, false, false];
			currentHolds = new <Note>[null, null, null, null];
		}
		
		public function loadSong(song:Song):void {
			this.song = song;
			musicArea.loadNotes(song);
			musicPlayer.loadMusic(song);
			
			highNotesRemaining = (Vector.<Note>(song.highPart)).reverse();
			nextHighNote = highNotesRemaining.pop();
			midNotesRemaining = (Vector.<Note>(song.midPart)).reverse();
			nextMidNote = midNotesRemaining.pop();
			lowNotesRemaining = (Vector.<Note>(song.lowPart)).reverse();
			nextLowNote = lowNotesRemaining.pop();
		}
		
		public function go():void {
			//Start listening to the keyboard
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyReleaseHandler);

			musicArea.go();
			musicPlayer.go();
			
			this.addEventListener(Event.ENTER_FRAME, missChecker);
		}
		
		/**
		 * Check the list of notes to see if any have been missed.
		 * Intended as an event listener to run every frame.
		 * @param	e enter frame event
		 */
		public function missChecker(e:Event):void {
			//TODO if slowdown occurs, make this function only every 5 or so frames
			var cutOffTime:Number = musicPlayer.getTime() - HIT_TOLERANCE - 100;
			
			while (nextHighNote != null && nextHighNote.time < cutOffTime) {
				if (currentTrack == Main.HIGH && !nextHighNote._isHit)
					nextHighNote.associatedSprite.miss();
				nextHighNote = (highNotesRemaining.length > 0) ? highNotesRemaining.pop() : null;
			}
			
			while (nextMidNote != null && nextMidNote.time < cutOffTime) {
				if (currentTrack == Main.MID && !nextMidNote._isHit)
					nextMidNote.associatedSprite.miss();
				nextMidNote = (midNotesRemaining.length > 0) ? midNotesRemaining.pop() : null;
			}
			
			while (nextLowNote != null && nextLowNote.time < cutOffTime) {
				if (currentTrack == Main.LOW && !nextLowNote._isHit)
					nextLowNote.associatedSprite.miss();
				nextLowNote = (lowNotesRemaining.length > 0) ? lowNotesRemaining.pop() : null;
			}
		}
		
		public function notePressHandler(noteLetter:int):void {
			//If we're currently in a hold, we can ignore these events.
			if (expectingHold[noteLetter])
				return;
			
			//TODO consider switching to binary search
			var notesToSearch:Vector.<Note>;
			if (currentTrack == Main.HIGH)
				notesToSearch = song.highPart;
			if (currentTrack == Main.MID)
				notesToSearch = song.midPart;
			if (currentTrack == Main.LOW)
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
			} else {
				if (note.isHold) {
					expectingHold[note.letter] = true;
					currentHolds[note.letter] = note;
				} else {
					expectingHold[note.letter] = false; //Shouldn't need this, but in case of unexpected behavior.
				}
			}
		}
		
		
		public function holdHandler(noteLetter:int):void {
			if (expectingHold[noteLetter]) {
				
				//Check for missing the end of the hold.
				if (Math.abs(currentHolds[noteLetter].endtime - musicPlayer.getTime()) > HIT_TOLERANCE) {
					currentHolds[noteLetter].associatedSprite.stopHolding();
				}
				//If it ended well, it will terminate on it's own.
				
				expectingHold[noteLetter] = false;
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
		
		public function keyReleaseHandler(e:KeyboardEvent):void {
			switch (e.keyCode) {
				//First the note keys.
				case Keyboard.F:
					holdHandler(Note.NOTE_F);
					break;
				case Keyboard.D:
					holdHandler(Note.NOTE_D);
					break;
				case Keyboard.S:
					holdHandler(Note.NOTE_S);
					break;
				case Keyboard.A:
					holdHandler(Note.NOTE_A);
					break;
			}
		}
		
	}

}