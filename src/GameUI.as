package src {
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
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
		
		public static const MIN_LIGHTNING_COMBO:int = 15;
		
		
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
		
		protected var victoryScreen:Sprite;
		protected var losingScreen:Sprite;
		
		private var song:Song;
		
		protected var currentTrack:int;
		private var nextTrack:int;
		
		protected var switchTimer:Timer;
		private var switchTime:Number;
		protected var advanceSwitchTimer:Timer;
		private var advanceSwitchTime:Number;
		
		private var expectingHold:Vector.<Boolean>;
		private var currentHolds:Vector.<Note>;
		
		private var highNoteBlocks:Vector.<Vector.<Note>>;
		private var midNoteBlocks:Vector.<Vector.<Note>>;
		private var lowNoteBlocks:Vector.<Vector.<Note>>;
		private var blockQueue:Vector.<Vector.<Note>>;
		
		private var currentBlock:int;
		
		private var combo:int;
		
		private var highSummonAmount:Number = 8;
		private var midSummonAmount:Number = 8;
		private var lowSummonAmount:Number = 8;
		
		private var highActorType:Class;
		private var midActorType:Class;
		private var lowActorType:Class;
		
		private var opponent:OpponentStrategy;
		private var opponentTimer:Timer;
		
		private var recentQuitAttempt:Boolean;
		private var quitTimer:Timer;
		
		private var songIsFinished:Boolean;
		private var opponentIsDefeated:Boolean;
		
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
			
			musicPlayer = new MusicPlayer(Main.MID, this);
			
			expectingHold = new <Boolean>[false, false, false, false];
			currentHolds = new <Note>[null, null, null, null];
			
			mainArea = new MainArea(this);
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
			
			victoryScreen = new Sprite();
			this.addChild(victoryScreen);
			victoryScreen.graphics.beginFill(0x0);
			victoryScreen.graphics.drawRect(0, 0, Main.WIDTH, Main.HEIGHT);
			victoryScreen.graphics.endFill();
			var victory:TextField = new TextField();
			victory.text = "You won!\nQ to return to the menu.";
			victory.textColor = 0xFFFFFF;
			victoryScreen.addChild(victory);
			victoryScreen.visible = false;
			
			losingScreen = new Sprite();
			this.addChild(losingScreen);
			losingScreen.graphics.beginFill(0x0);
			losingScreen.graphics.drawRect(0, 0, Main.WIDTH, Main.HEIGHT);
			losingScreen.graphics.endFill();
			var losing:TextField = new TextField();
			losing.text = "You lost!\nQ to return to the menu.";
			losing.textColor = 0xFFFFFF;
			losingScreen.addChild(losing);
			losingScreen.visible = false;
			
			highActorType = Assassin;
			midActorType = Archer;
			lowActorType = Cleric;
			
			opponent = new DefaultOpponent();
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
			
			highNoteBlocks = new Vector.<Vector.<Note>>(song.numBlocks, true);
			midNoteBlocks = new Vector.<Vector.<Note>>(song.numBlocks, true);
			lowNoteBlocks = new Vector.<Vector.<Note>>(song.numBlocks, true);
			
			var index:int;
			for (index = 0; index < highNoteBlocks.length; index++) {
				highNoteBlocks[index] = song.highPart[index].reverse();
				midNoteBlocks[index] = song.midPart[index].reverse();
				lowNoteBlocks[index] = song.lowPart[index].reverse();
			}
			
			blockQueue = midNoteBlocks.concat(); //Concat without args creates a shallow copy.
			currentBlock = 0;
		}
		
		public function go():void {
			//Start listening to the keyboard
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyReleaseHandler);
			
			victoryScreen.visible = false;
			losingScreen.visible = false;
			
			recentQuitAttempt = false;
			
			summoningMeter.reset();

			mainArea.go(Wizard.create(true), Wizard.create(false));
			
			combo = 0;
			
			currentTrack = Main.MID;
			nextTrack = Main.MID;
			
			songIsFinished = false;
			opponentIsDefeated = false;
			
			//Let the opponent start summoning.
			opponentTimer = new Timer(opponent.timeToAct, 0); //0 repeats indefinitely.
			opponentTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				var opponentSummon:Vector.<Actor> = opponent.act();
				for each(var actor:Actor in opponentSummon) {
					mainArea.opponentSummon(actor);
				}
			});
			opponentTimer.start();
			
			musicArea.go();
			musicPlayer.go();
			
			Main.runEveryFrame(missChecker);
			
			Main.runEveryQuarterBeat(checkCombo);
			
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
			
			Main.stopRunningEveryFrame(missChecker);
			
			Main.stopRunningEveryQuarterBeat(checkCombo);
		}
		
		public function songFinished():void {
			if (opponentIsDefeated) {
				victoryScreen.visible = true;
			
				musicPlayer.stop();
			
				recentQuitAttempt = true;
			} else {
			
				infoArea.displayText("Uh-oh...");
				
				opponentTimer.stop();
				mainArea.killShields();
			
				var mashButtonsTimer:Timer = new Timer(1500, 1);
				mashButtonsTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					infoArea.displayText("Mash buttons!");
					songIsFinished = true;
				} );
			
				mashButtonsTimer.start();
			}
		}
		
		public function playerWizardDead():void {
			trace("Player dead.");
			infoArea.displayText("You died.");
			losingScreen.visible = true;
			
			musicPlayer.stop();
			
			recentQuitAttempt = true;
		}
		
		public function opponentWizardDead():void {
			trace("Opponent dead.");
			if (songIsFinished) {
				victoryScreen.visible = true;
			
				musicPlayer.stop();
			
				recentQuitAttempt = true;
			} else {
				infoArea.displayText("Victory! Press Q to finish, or finish the song.");
				recentQuitAttempt = true;
				
				opponentTimer.stop();
				
				opponentIsDefeated = true;
			}
		}
		
		private var comboCounter:int = 0;
		
		private function checkCombo():void {
			comboCounter++;
			
			if (comboCounter == 16) {//16 == 4 beats
				
				trace("check combo");
				if (combo >= MIN_LIGHTNING_COMBO) {
					mainArea.doLightning(true);
					trace("LIGHTNING!");
				}
				
				comboCounter = 0;
			}
		}
		
		private var frames:int = 0;
		
		/**
		 * Check the list of notes to see if any have been missed.
		 * Also removes already hit elements from the queue.
		 * Intended as an event listener to run every frame.
		 * @param	e enter frame event
		 */
		public function missChecker():void {
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
			var cutOffTime:Number = musicPlayer.getTime() - HIT_TOLERANCE - 50; //Extra, just to be sure.
			
			updateBlockIndex();
			
			missNotesUntil(blockQueue[currentBlock], cutOffTime);
			
			//It's possibly we're right on the boundary between blocks.
			if (currentBlock + 1 < blockQueue.length)
				missNotesUntil(blockQueue[currentBlock + 1], cutOffTime);
		}
		
		/**
		 * Checks notes in the list, starting with the last, popping them off as we go
		 * and missing each note until we reach a note past, or at, the cut off time.
		 * Notes that have already been hit will not be missed.
		 * The noteList <i>must</i> be sorted descending for this method to work.
		 * @param	noteList vector of notes to parse through
		 * @param	cutoffTime time after which to stop missing notes
		 */
		public function missNotesUntil(noteList:Vector.<Note>, cutOff:Number):void {
			//I wish there was a Vector.peek method. Indexing to length - 1 is ugly.
			while (noteList.length > 0 &&
					noteList[noteList.length - 1].time < cutOff) {
				var nextNote:Note = noteList.pop();
				
				if (!nextNote.isHit()) {
					nextNote.miss();
					combo = 0;
					musicPlayer.stopTrack();
				}
			}
		}
		
		/**
		 * Removes notes from the list, starting with the last,
		 * until we reach a note past, or at, the cut off time.
		 * The noteList <i>must</i> be sorted descending for this method to work.
		 * @param	noteList vector of notes to parse through
		 * @param	cutoffTime time after which to stop removing notes
		 */
		/*public static function clearNotesUntil(noteList:Vector.<Note>, cutOff:Number):void {
			while (noteList.length > 0 &&
					noteList[noteList.length - 1].time < cutOff) {
				var nextNote:Note = noteList.pop();
			}
		}*/
		
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
				
			mainArea.updateWizard();
			
			//If the song is over, the play can mash buttons to buff their units.
			if (songIsFinished) {
				Actor.buffPlayers();
				return;
			}
			
			updateBlockIndex();
				
			var rightNow:Number = musicPlayer.getTime();
			
			var note:Note = findFirstHit(blockQueue[currentBlock], noteLetter, rightNow);
			if (note == null && currentBlock + 1 < blockQueue.length)
				note = findFirstHit(blockQueue[currentBlock + 1], noteLetter, rightNow);
			
			if (note != null) {
				note.hit();
				
				combo++;
				
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
				summoningMeter.decrease(3);
				
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
				actor = new highActorType(true, true);
			else if (currentTrack == Main.MID)
				actor = new midActorType(true, true);
			else
				actor = new lowActorType(true, true);
				
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
					
					combo++;
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
			mainArea.forceScroll(isRight);
		}
		
		public function stopScrolling(isRight:Boolean):void {
			mainArea.stopScroll(isRight);
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
				
			trace("switching track");
				
			updateBlockIndex();
				
			nextTrack = track;
			
			var rightNow:Number = musicPlayer.getTime();
			
			var switchPoint:Number;
			var switchIndex:int;
			
			var earlySwitch:Boolean = true;
			
			//2 major situations can occur here:
			//we can switch in the next block OR
			//it's too late and we can switch in the block after that.
			//
			//In either case, we may already be at the end, and can't switch at all.
			
			if (currentBlock < song.numBlocks) {
				if (song.blocks[currentBlock] - rightNow > MusicArea.SWITCH_ADVANCE_TIME) {
					switchIndex = currentBlock + 1;
					switchPoint = song.blocks[currentBlock];
				}
			} else if (currentBlock + 1 < song.numBlocks) {
				//song.blocks[currentBlock + 1] - rightNow > MusicArea.SWITCH_ADVANCE_TIME
				//is necessarily true.
				
				switchIndex = currentBlock + 2;
				switchPoint = song.blocks[currentBlock + 1];
				
				earlySwitch = false;
			} else {
				switchIndex = currentBlock + 1;
				switchPoint = Number.MAX_VALUE;
			}
			
			
			musicArea.switchNotes(track, switchIndex);
			shiftBlocks(track, switchIndex);
			
			cutBlock(switchIndex - 1);
			
			
			//The music needs to be switched later, at the exact switch time.
			if (switchTimer == null || earlySwitch) {

				if (switchTimer != null)
					switchTimer.stop();
				
				switchTimer = new Timer(switchPoint - rightNow, 1);
				switchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					switchLater(track);
				});
				switchTimer.start();
				
				switchTime = switchPoint;
					
				trace("normal switch");
			} else {
					
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
				trace("advance switch");
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
		
		private function cutBlock(blockIndex:int):void {
			if (blockIndex == song.blocks.length || blockQueue[blockIndex].length == 0)
				return;
			
			var foundF:Boolean = false;
			var foundD:Boolean = false;
			var foundS:Boolean = false;
			var foundA:Boolean = false;
			
			var found:Boolean = false;
			
			var index:int = 0;
			var maxEndTime:Number = song.blocks[blockIndex];
			
			const MIN_HOLD_SIZE:int = 300;
			
			while (!(foundF && foundD && foundS && foundA) && index < blockQueue[blockIndex].length) {
				var note:Note = blockQueue[blockIndex][index];
				
				found = false;
				
				switch (note.letter) {
					case Note.NOTE_F:
						if (!foundF && note.endtime > maxEndTime) {
							foundF = true;
							
							found = true;
						}
						break;
					case Note.NOTE_D:
						if (!foundD && note.endtime > maxEndTime) {
							foundD = true;
							
							found = true;
						}
						break;
					case Note.NOTE_S:
						if (!foundS && note.endtime > maxEndTime) {
							foundS = true;
							
							found = true;
						}
						break;
					case Note.NOTE_A:
						if (!foundA && note.endtime > maxEndTime) {
							foundA = true;
							
							found = true;
						}
						break;
				}
				
				if (found) {
					var betterEndTime:Number = maxEndTime - HIT_TOLERANCE;
							
					if (betterEndTime - note.time < MIN_HOLD_SIZE) {
						note.isHold = false;
						note.endtime = note.time;
						
						note.sprite.refresh();
					} else {
						note.endtime = betterEndTime;
						
						note.sprite.refresh();
					}
				}
				
				
				index++;
			}
		}
		
		/**
		 * Shifts the blocks of notes that will be hit to the track, after the specified index.
		 * If the index is greater than index of the last block, nothing happens.
		 * @param	track the track to shift blocks to
		 * @param	index the index including and after which to switch blocks
		 */
		private function shiftBlocks(track:int, index:int):void {
			trace("blocks after and including " + index + " switched to " + track);
			
			if (track == Main.HIGH) {
				for (index; index < blockQueue.length; index++) {
					blockQueue[index] = highNoteBlocks[index];
				}
			} else if (track == Main.MID) {
				for (index; index < blockQueue.length; index++) {
					blockQueue[index] = midNoteBlocks[index];
				}
			} else {
				for (index; index < blockQueue.length; index++) {
					blockQueue[index] = lowNoteBlocks[index];
				}
			}
		}
		
		/**
		 * Makes sure that currentBlock refers to the correct block.
		 */
		private function updateBlockIndex():void {
			var blocks:Vector.<Number> = song.blocks;
			var rightNow:Number = musicPlayer.getTime();
			
			while (currentBlock < blocks.length && rightNow > blocks[currentBlock])
				currentBlock++;
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
					
				//Now the scrolling keys.
				case Keyboard.LEFT:
				case Keyboard.U:
					scrollHandler(false);
					break;
				case Keyboard.RIGHT:
				case Keyboard.O:
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
					
				case Keyboard.X:
					mainArea.doLightning(true, true);
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
				case Keyboard.LEFT:
				case Keyboard.U:
					stopScrolling(false);
					break;
				case Keyboard.RIGHT:
				case Keyboard.O:
					stopScrolling(true);
					break;
					
				//Q to quit to menu.
				case Keyboard.Q:
					quitHandler()
					break;
			}
		}
		
	}

}