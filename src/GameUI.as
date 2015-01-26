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
			
			while (nextHighNote != null && nextHighNote.time < cutOffTime) {
				if (currentTrack == Main.HIGH && !nextHighNote._isHit)
					nextHighNote.associatedSprite.miss();
				nextHighNote = (highNotesRemaining.length > 0) ? highNotesRemaining.pop() : null;
			}
			
			while (nextMidNote != null && nextMidNote.time < cutOffTime) {
				if (currentTrack == Main.MID && !nextMidNote._isHit)
					nextMidNote.associatedSprite.miss();
				trace("miss: ", musicPlayer.getTime(), " ", nextMidNote.letter);
				nextMidNote = (midNotesRemaining.length > 0) ? midNotesRemaining.pop() : null;
			}
			
			while (nextLowNote != null && nextLowNote.time < cutOffTime) {
				if (currentTrack == Main.LOW && !nextLowNote._isHit)
					nextLowNote.associatedSprite.miss();
				nextLowNote = (lowNotesRemaining.length > 0) ? lowNotesRemaining.pop() : null;
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
		
		public function scrollHandler(isRight:Boolean):void {
			trace("scroll: right? : " + isRight);
			mainArea.scroll(isRight);
		}
		
		public function stopScrolling():void {
			trace("stop scrolling");
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