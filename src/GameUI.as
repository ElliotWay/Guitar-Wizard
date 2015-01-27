package src {
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
		public static const HIT_TOLERANCE:Number = 150; //how far from the actual note a hit can be
														//in milliseconds
		
		//All the fields are protected to make testing easier,
		//which is important because this is a complicated and fiddly class.
		
		//GUI parts
		protected var musicArea:MusicArea;
		protected var mainArea:MainArea;
		//protected var minimapArea:MiniMapArea;
		//protected var controlArea:ControlArea;
		
		//Other output parts
		protected var musicPlayer:MusicPlayer;
		
		
		protected var song:Song;
		protected var currentTrack:int;
		
		protected var expectingHold:Vector.<Boolean>;
		protected var currentHolds:Vector.<Note>;
		
		protected var highNotesRemaining:Vector.<Note>;
		protected var nextHighNote:Note;
		protected var midNotesRemaining:Vector.<Note>;
		protected var nextMidNote:Note;
		protected var lowNotesRemaining:Vector.<Note>;
		protected var nextLowNote:Note;
		
		public function GameUI() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			musicArea = new MusicArea();
			this.addChild(musicArea);
			musicArea.x = 0; musicArea.y = 0;
			
			currentTrack = Main.MID;
			musicPlayer = new MusicPlayer(Main.MID);
			
			expectingHold = new <Boolean>[false, false, false, false];
			currentHolds = new <Note>[null, null, null, null];
			
			mainArea = new MainArea();
			this.addChild(mainArea);
			mainArea.x = 0; mainArea.y = MusicArea.HEIGHT;
		}
		
		/**
		 * Loads a song into the music area to create the note sprites,
		 * loads the music into the music player,
		 * and prepares a list of notes to move through as the player misses them.
		 * @param	song the song to load
		 */
		public function loadSong(song:Song):void {
			this.song = song;
			musicArea.loadNotes(song);
			musicArea.setMidNotes();
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

			mainArea.hardCode();
			
			//musicArea.go();
			musicPlayer.go();
			
			//this.addEventListener(Event.ENTER_FRAME, missChecker);
		}
		
		/**
		 * Check the list of notes to see if any have been missed.
		 * Also removes already hit elements from the queue.
		 * Intended as an event listener to run every frame.
		 * @param	e enter frame event
		 */
		public function missChecker(e:Event):void {
			//TODO if slowdown occurs, make this function only every 5 or so frames
			var cutOffTime:Number = musicPlayer.getTime() - HIT_TOLERANCE - 200;
			
			if (currentTrack == Main.HIGH) {
				missNotesUntil(highNotesRemaining, cutOffTime);
				
				clearNotesUntil(midNotesRemaining, cutOffTime);
				clearNotesUntil(lowNotesRemaining, cutOffTime);
			} else if (currentTrack == Main.MID) {
				missNotesUntil(midNotesRemaining, cutOffTime);
				
				clearNotesUntil(highNotesRemaining, cutOffTime);
				clearNotesUntil(lowNotesRemaining, cutOffTime);
			} else {
				missNotesUntil(lowNotesRemaining, cutOffTime);
				
				clearNotesUntil(highNotesRemaining, cutOffTime);
				clearNotesUntil(midNotesRemaining, cutOffTime);
			}
		}
		
		/**
		 * Checks notes in the list, starting with the last, popping them off as we go
		 * and missing each note until we reach a note past, or at, the cut off time.
		 * Notes that have already been hit will not be missed.
		 * The noteList <i>must</i> be sorted descending for this method to work.
		 * @param	noteList vector of notes to parse through
		 * @param	cutoffTime time after which to stop missing notes
		 */
		public static function missNotesUntil(noteList:Vector.<Note>, cutOff:Number):void {
			//I wish there was a Vector.peek method. Indexing to length - 1 is ugly.
			while (noteList.length > 0 &&
					noteList[noteList.length - 1].time < cutOff) {
				var nextNote:Note = noteList.pop();
				
				if (!nextNote.isHit())
					nextNote.miss();
			}
		}
		
		/**
		 * Removes notes from the list, starting with the last,
		 * until we reach a note past, or at, the cut off time.
		 * The noteList <i>must</i> be sorted descending for this method to work.
		 * @param	noteList vector of notes to parse through
		 * @param	cutoffTime time after which to stop removing notes
		 */
		public static function clearNotesUntil(noteList:Vector.<Note>, cutOff:Number):void {
			//I wish there was a Vector.peek method. Indexing to length - 1 is ugly.
			while (noteList.length > 0 &&
					noteList[noteList.length - 1].time < cutOff) {
				var nextNote:Note = noteList.pop();
			}
		}
		
		/**
		 * Handler for pressing A, S, D, or F. Checks if a note is there, then hits it or
		 * causes a missed note.
		 * TODO I could plausibly make this faster with separate lists for A - F. Is that
		 * really necessary though? Only if a song doesn't use a letter for some time could
		 * it become really inefficient.
		 * @param	noteLetter the letter using Note constants. _NOT_ KeyboardEvent constants.
		 */
		public function notePressHandler(noteLetter:int):void {
			//If we're currently in a hold, we can ignore these events.
			if (expectingHold[noteLetter])
				return;
			trace("check hit", musicPlayer.getTime());
			var notesToSearch:Vector.<Note>;
			if (currentTrack == Main.HIGH)
				notesToSearch = highNotesRemaining;
			if (currentTrack == Main.MID)
				notesToSearch = midNotesRemaining;
			if (currentTrack == Main.LOW)
				notesToSearch = lowNotesRemaining;
				
				
			var rightNow:Number = musicPlayer.getTime();
			
			var note:Note = null;
			//Search the array from the back.
			for (var i:int = notesToSearch.length - 1; i >= 0; i--) {
				note = notesToSearch[i];
				if (!note.isHit() && note.letter == noteLetter && Math.abs(note.time - rightNow) < HIT_TOLERANCE) {
					note.hit();
					musicPlayer.resumeTrack();
					break;
				}
			}
			
			if (note == null || !note.isHit()) {
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
					currentHolds[noteLetter].sprite.stopHolding();
				}
				//If it ended well, it will terminate on it's own.
				
				expectingHold[noteLetter] = false;
			}
		}
		
		public function scrollHandler(isRight:Boolean):void {
			mainArea.scroll(isRight);
		}
		
		public function stopScrolling():void {
			mainArea.stopScrolling();
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
					
				//Now the arrow keys.
				case Keyboard.UP:
					//TODO create up & down handler
					break;
				case Keyboard.DOWN:
					//lkj
					break;
				case Keyboard.LEFT:
					scrollHandler(false);
					break;
				case Keyboard.RIGHT:
					scrollHandler(true);
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
					
				//Now the arrow keys.
				case Keyboard.UP:
					//TODO create up & down handler
					break;
				case Keyboard.DOWN:
					//lkj
					break;
				case Keyboard.LEFT:
					stopScrolling();
					break;
				case Keyboard.RIGHT:
					stopScrolling();
					break;
			}
		}
		
	}

}