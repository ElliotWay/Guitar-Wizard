package src {
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class GameUI extends Sprite
	{	
		/**
		 * In milliseconds, how far from an actual note a hit can be.
		 */
		public static const HIT_TOLERANCE:Number = 150; // 150
		
		//All the fields are protected to make testing easier,
		//which is important because this is a complicated and fiddly class.
		
		//GUI parts
		protected var musicArea:MusicArea;
		protected var mainArea:MainArea;
		protected var summoningMeter:SummoningMeter;
		protected var infoArea:InfoArea;
		//protected var controlArea:ControlArea;
		
		//Other output parts
		protected var musicPlayer:MusicPlayer;
		
		
		private var song:Song;
		
		protected var currentTrack:int;
		private var nextTrack:int;
		
		protected var switchTimer:Timer;
		private var switchTime:Number;
		protected var advanceSwitchTimer:Timer;
		private var advanceSwitchTime:Number
		
		private var expectingHold:Vector.<Boolean>;
		private var currentHolds:Vector.<Note>;
		
		private var highNotesRemaining:Vector.<Note>;
		private var midNotesRemaining:Vector.<Note>;
		private var lowNotesRemaining:Vector.<Note>;
		
		private var highSummonAmount:Number = 8;
		private var midSummonAmount:Number = 9;
		private var lowSummonAmount:Number = 9;
		
		private var highActorType:Class;
		private var midActorType:Class;
		private var lowActorType:Class;
		
		private var opponent:OpponentStrategy;
		private var opponentTimer:Timer;
		
		private var recentQuitAttempt:Boolean;
		private var quitTimer:Timer;
		
		public function GameUI() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			musicArea = new MusicArea();
			this.addChild(musicArea);
			musicArea.x = 0; musicArea.y = 0;
			
			currentTrack = Main.MID;
			nextTrack = -1;
			
			switchTimer = null;
			switchTime = -1;
			advanceSwitchTimer = null;
			advanceSwitchTime = -1;
			
			musicPlayer = new MusicPlayer(Main.MID);
			
			expectingHold = new <Boolean>[false, false, false, false];
			currentHolds = new <Note>[null, null, null, null];
			
			mainArea = new MainArea();
			this.addChild(mainArea);
			mainArea.x = 0; mainArea.y = MusicArea.HEIGHT;
			
			summoningMeter = new SummoningMeter(this);
			this.addChild(summoningMeter);
			summoningMeter.x = MainArea.WIDTH;
			summoningMeter.y = MusicArea.HEIGHT + MainArea.MINIMAP_HEIGHT;
			
			infoArea = new InfoArea();
			this.addChild(infoArea);
			infoArea.x = MainArea.WIDTH;
			infoArea.y = MusicArea.HEIGHT + MainArea.MINIMAP_HEIGHT + SummoningMeter.HEIGHT;
			
			highActorType = Assassin;
			midActorType = Archer;
			lowActorType = Cleric;
			
			opponent = new DefaultOpponent();
			
			recentQuitAttempt = false;
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
			musicPlayer.loadMusic(song);
			
			highNotesRemaining = (Vector.<Note>(song.highPart)).reverse();
			midNotesRemaining = (Vector.<Note>(song.midPart)).reverse();
			lowNotesRemaining = (Vector.<Note>(song.lowPart)).reverse();
		}
		
		public function go():void {
			//Start listening to the keyboard
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyReleaseHandler);

			mainArea.go();
			
			//Let the opponent start summoning.
			opponentTimer = new Timer(opponent.timeToAct, 0); //0 repeates indefinitely.
			opponentTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				var opponentSummon:Vector.<Actor> = opponent.act();
				for each(var actor:Actor in opponentSummon) {
					mainArea.opponentSummon(actor);
				}
			});
			opponentTimer.start();
			
			musicArea.go();
			musicPlayer.go();
			
			this.addEventListener(Event.ENTER_FRAME, missChecker);
			
			infoArea.displayText("Text Test");
		}
		
		public function stop():void {
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, keyReleaseHandler);
			
			mainArea.stop();
			opponentTimer.stop();
			
			musicArea.stop();
			musicPlayer.stop();
			
			song.unload();
			
			if (quitTimer != null)
				quitTimer.stop();
			
			this.removeEventListener(Event.ENTER_FRAME, missChecker);
		}
		
		private var frames:int = 0;
		
		/**
		 * Check the list of notes to see if any have been missed.
		 * Also removes already hit elements from the queue.
		 * Intended as an event listener to run every frame.
		 * @param	e enter frame event
		 */
		public function missChecker(e:Event):void {
			/*frames++;
			if (frames >= 100) {
				frames = 0;
//				var time:Number = musicPlayer.getTime();
//				var position:Number = - musicArea.getPosition() / MusicArea.POSITION_SCALE;
//				trace("time = " + time + ", position/Scale = " + position
//						+ ", difference = " + (position - time));
//				var mainTime:Number = musicPlayer.getTime();
//				var trackTime:Number = musicPlayer.getTrackTime();
//				trace("base : " + mainTime + ", track : " + trackTime + ", difference : " + (mainTime - trackTime));
			}*/
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
			
			var notesToSearch:Vector.<Note>;
			
			if (currentTrack == Main.HIGH)
				notesToSearch = highNotesRemaining;
			if (currentTrack == Main.MID)
				notesToSearch = midNotesRemaining;
			if (currentTrack == Main.LOW)
				notesToSearch = lowNotesRemaining;
				
				
			var rightNow:Number = musicPlayer.getTime();
			
			var note:Note = findFirstHit(notesToSearch, noteLetter, rightNow);
			
			if (note != null) {
				note.hit();
				
				musicPlayer.resumeTrack();
				
				//If the note was a hold, we need to start hitting the hold.
				if (note.isHold) {
					expectingHold[note.letter] = true;
					currentHolds[note.letter] = note;
				} else {
					//If it isn't a hold, we can summon now, otherwise
					//wait until the hold is done.
					if (currentTrack == Main.HIGH) {
						summoningMeter.increase(highSummonAmount);
					} else if (currentTrack == Main.MID) {
						summoningMeter.increase(midSummonAmount);
					} else {
						summoningMeter.increase(lowSummonAmount);
					}
				}
				
			} else {
				
				musicPlayer.stopTrack();
				musicPlayer.playMissSound();
			}
		}
		
		/**
		 * Searches the list from the end to find a note with the correct letter
		 * and a time sufficiently close to the given time. Ignores notes
		 * that have already been hit.
		 * The vector <i>must</i> be sorted descending.
		 * @param	noteList the list of notes to search
		 * @param	noteLetter the letter constant of note to search for
		 * @param	time the time to compare note times for
		 * @return the first note, starting from the end of the list, that matches these parameters,
		 * 	or null if none do.
		 */
		public static function findFirstHit(noteList:Vector.<Note>, noteLetter:int, time:Number):Note {
			//trace("--------------------");
			//trace(noteList);
			//trace("--------------------");
			//Search from the end.
			for (var i:int = noteList.length - 1; i >= 0; i--) {
				var note:Note = noteList[i];
				
				if (note.letter == noteLetter && !note.isHit()
						&& Math.abs(note.time - time) < HIT_TOLERANCE) {
					
					return note;
					
					//Skip the rest once we're clearly past where a hit might be.
				} else if (note.time - time > HIT_TOLERANCE) {
					return null;
				}
			}
			
			//There were no matches, so return null.
			return null;
		}
		
		/**
		 * Summon a new actor for the player.
		 */
		public function preparePlayerSummon():void {
			var actor:Actor;
			
			if (currentTrack == Main.HIGH)
				actor = new highActorType(true);
			else if (currentTrack == Main.MID)
				actor = new midActorType(true);
			else
				actor = new lowActorType(true);
				
			mainArea.playerSummon(actor);
		}
		
		/**
		 * Handler for released note letters. If we're in the middle of a hold for
		 * that letter, check to see if it was a clean ending.
		 * @param	noteLetter
		 */
		public function holdHandler(noteLetter:int):void {
			if (expectingHold[noteLetter]) {
				
				var goodEnd:Boolean = true;
				
				var currentHold:Note = currentHolds[noteLetter];
				
				var time:Number = musicPlayer.getTime();
				
				//Check if we've missed the end of the hold.
				if (Math.abs(currentHold.endtime - time) > HIT_TOLERANCE) {
					currentHold.sprite.stopHolding();
					goodEnd = true;
				}
				//If it ended well, the sprite will stop holding on its own.
				
				var summonBaseAmount:Number;
				if (currentTrack == Main.HIGH)
					summonBaseAmount = highSummonAmount;
				else if (currentTrack == Main.MID)
					summonBaseAmount = midSummonAmount;
				else
					summonBaseAmount = lowSummonAmount;
				
				summoningMeter.increase(.6 * summonBaseAmount +
						(goodEnd ? .6 * summonBaseAmount : 0) +
						(.002 * ((Math.min(time, currentHold.endtime)) - currentHold.time) * summonBaseAmount));
				
				expectingHold[noteLetter] = false;
			}
		}
		
		public function scrollHandler(isRight:Boolean):void {
			mainArea.scroll(isRight);
		}
		
		public function stopScrolling():void {
			mainArea.stopScrolling();
		}
		
		/**
		 * Prepares to switch to another track.
		 * Visibility of notes from the new track are changed immediately,
		 * changing the track and the music playback are set on a timer to change
		 * at the time that musicArea.switchNotes requests.
		 * 
		 * This method uses switchTimer and advanceSwitchTimer;
		 * if it is too late to switch to a different track, the switch is placed in
		 * advanceSwitchTimer and then moved to switchTimer when the first switch occurs.
		 * 
		 * Requesting a switch to the track that is already pending does nothing.
		 * @param	track the track to prepare to switch to, in Main constants
		 */
		public function switchTrack(track:int):void {
			if (nextTrack == track)
				return;
				
			nextTrack = track;
				
			var rightNow:Number, switchPoint:Number;
			
			rightNow = musicPlayer.getTime();
			switchPoint = musicArea.switchNotes(rightNow, track);
			
			if (switchTimer == null) {
				switchTimer = new Timer(switchPoint - rightNow, 1);
				switchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					switchLater(track);
				});
				switchTimer.start();
				
				switchTime = switchPoint;
				
			} else {
				//var error:Error = new Error();
				//trace(error.getStackTrace());
				//switch time is the time of the existing switch.
				if (switchTime - rightNow < MusicArea.SWITCH_ADVANCE_TIME) {
					
					//We're in the space where it's too late to switch the next block,
					//but we haven't switched yet.
					if (advanceSwitchTimer != null) {
						advanceSwitchTimer.stop();
					}
					
					advanceSwitchTimer = new Timer(switchPoint - rightNow, 1);
					advanceSwitchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
						switchLater(track);
					});
					advanceSwitchTimer.start();
					
					advanceSwitchTime = switchPoint;
				} else {
					
					switchTimer.stop();
					switchTimer = new Timer(switchPoint - rightNow, 1);
					switchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
						switchLater(track);
					});
					switchTimer.start();
					
					switchTime = switchPoint;
				}
			}
		}
		
		private function switchLater(track:int):void {
			musicPlayer.switchTrack(track);
			currentTrack = track;
			
			switchTimer = advanceSwitchTimer;
			advanceSwitchTimer = null;
			
			switchTime = advanceSwitchTime;
			advanceSwitchTime = -1;
		}
		
		public function quitHandler():void {
			if (recentQuitAttempt) {
				
				recentQuitAttempt = false;
				Main.switchToMenu();
			} else {
				
				infoArea.displayText("Quit to menu? Press Q again to confirm.");
				recentQuitAttempt = true;
				
				quitTimer = new Timer(InfoArea.CLEAR_TIME, 1);
				quitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					recentQuitAttempt = false;
				});
				quitTimer.start();
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
					
				//Now the arrow keys.
				case Keyboard.UP:
					//TODO create up & down handler
					break;
				case Keyboard.DOWN:
					break;
				case Keyboard.LEFT:
					scrollHandler(false);
					break;
				case Keyboard.RIGHT:
					scrollHandler(true);
					break;
					
				//And the switch track keys.
				case Keyboard.J:
					switchTrack(Main.HIGH);
					break;
				case Keyboard.K:
					switchTrack(Main.MID);
					break;
				case Keyboard.L:
					switchTrack(Main.LOW);
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
					
				//Q to quit to menu.
				case Keyboard.Q:
					quitHandler()
					break;
			}
		}
		
	}

}