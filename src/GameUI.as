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
		
		private var expectingHold:Vector.<Boolean>;
		private var currentHolds:Vector.<Note>;
		
		private var combo:int;
		
		private var highSummonAmount:Number = 8;
		private var midSummonAmount:Number = 8;
		private var lowSummonAmount:Number = 8;
		
		private static const HOLD_AMOUNT:Number = 20;
		
		private var opponent:OpponentStrategy;
		private var opponentTimer:Timer;
		
		private var recentQuitAttempt:Boolean;
		private var quitTimer:Timer;
		
		private var songIsFinished:Boolean;
		private var opponentIsDefeated:Boolean;
		
		private var _repeater:Repeater;
		
		private var _actorFactory:ActorFactory;
		
		public function get repeater():Repeater {
			return _repeater;
		}
		
		public function get actorFactory():ActorFactory {
			return _actorFactory;
		}
		
		public function GameUI(repeater:Repeater) 
		{
			this._repeater = repeater;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			_actorFactory = new ActorFactory();
			
			musicArea = new MusicArea(this);
			this.addChild(musicArea);
			musicArea.x = 0; musicArea.y = 0;
			
			musicPlayer = new MusicPlayer(Main.MID, this);
			
			expectingHold = new <Boolean>[false, false, false, false];
			currentHolds = new <Note>[null, null, null, null];
			
			mainArea = MainArea.create(this);
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
		}
		
		public function go():void {
			//Start listening to the keyboard
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyReleaseHandler);
			
			victoryScreen.visible = false;
			losingScreen.visible = false;
			
			recentQuitAttempt = false;
			
			summoningMeter.reset();

			mainArea.go(_actorFactory.create(ActorFactory.WIZARD, Actor.PLAYER, Actor.RIGHT_FACING) as Wizard,
					_actorFactory.create(ActorFactory.WIZARD, Actor.OPPONENT, Actor.LEFT_FACING) as Wizard,
					_actorFactory.create(ActorFactory.SHIELD, Actor.PLAYER, Actor.RIGHT_FACING) as Shield,
					_actorFactory.create(ActorFactory.SHIELD, Actor.OPPONENT, Actor.LEFT_FACING) as Shield);
			
			combo = 0;
			
			songIsFinished = false;
			opponentIsDefeated = false;
			
			//Let the opponent start summoning.
			opponentTimer = new Timer(opponent.timeToAct, 0); //0 repeats indefinitely.
			opponentTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				var opponentSummon:Vector.<Actor> = opponent.act(actorFactory);
				for each(var actor:Actor in opponentSummon) {
					mainArea.opponentSummon(actor);
				}
			});
			opponentTimer.start();
			
			musicArea.go();
			musicPlayer.go();
			
			_repeater.runEveryFrame(missChecker);
			
			_repeater.runEveryQuarterBeat(checkCombo);
			
			infoArea.displayText("Text Test");
		}
		
		public function stop():void {
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, keyReleaseHandler);
			
			mainArea.stop();
			opponentTimer.stop();
			
			musicArea.stop();
			musicPlayer.stop();
			
			song.dissociate();
			
			if (quitTimer != null)
				quitTimer.stop();
			
			_repeater.stopRunningEveryFrame(missChecker);
			
			_repeater.stopRunningEveryQuarterBeat(checkCombo);
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
				
				if (combo >= MIN_LIGHTNING_COMBO) {
					mainArea.doLightning(true);
				}
				
				comboCounter = 0;
			}
		}
		
		/**
		 * Check the list of notes to see if any have been missed.
		 * Also removes already hit elements from the queue.
		 * Intended as an event listener to run every frame.
		 * @param	e enter frame event
		 */
		public function missChecker():void {
			
			var rightNow:Number = musicPlayer.getTime();
						
			var noteMissed:Boolean = musicArea.missNotes(rightNow);
			
			if (noteMissed) {
				combo = 0;
				musicPlayer.stopTrack();
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
				
			mainArea.updateWizard();
			
			//If the song is over, the play can mash buttons to buff their units.
			if (songIsFinished) {
				Actor.buffPlayers();
				return;
			}
				
			var rightNow:Number = musicPlayer.getTime();
			
			var note:Note = musicArea.hitNote(noteLetter, rightNow);
			
			if (note != null) {
				combo++;
				
				musicPlayer.resumeTrack();
				
				//If the note was a hold, we need to start hitting the hold.
				if (note.isHold) {
					expectingHold[note.letter] = true;
					currentHolds[note.letter] = note;
					summoningMeter.increaseRate(HOLD_AMOUNT);
				} else {
					//If it isn't a hold, we can summon now, otherwise
					//wait until the hold is done.
					if (musicArea.currentTrack == Main.HIGH) {
						summoningMeter.increase(highSummonAmount);
					} else if (musicArea.currentTrack == Main.MID) {
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
		 * Summon a new actor for the player.
		 */
		public function preparePlayerSummon():void {
			
			var actor:Actor;
			
			if (musicArea.currentTrack == Main.HIGH)
				actor = _actorFactory.create(ActorFactory.ASSASSIN, Actor.PLAYER, Actor.RIGHT_FACING);
			else if (musicArea.currentTrack == Main.MID)
				actor = _actorFactory.create(ActorFactory.ARCHER, Actor.PLAYER, Actor.RIGHT_FACING);
			else
				actor = _actorFactory.create(ActorFactory.CLERIC, Actor.PLAYER, Actor.RIGHT_FACING);
				
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
					goodEnd = false;
				}
				//If it ended well, the sprite will stop holding on its own.
				
				var summonBaseAmount:Number;
				if (musicArea.currentTrack == Main.HIGH)
					summonBaseAmount = highSummonAmount;
				else if (musicArea.currentTrack == Main.MID)
					summonBaseAmount = midSummonAmount;
				else
					summonBaseAmount = lowSummonAmount;
				
				if (goodEnd) {
					summoningMeter.increase(summonBaseAmount);
					combo++;
				}
				
				summoningMeter.decreaseRate(HOLD_AMOUNT);
				
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
			musicArea.switchNotes(track, musicPlayer.getTime());
		}
		
		/**
		 * Immediatly switch the playing music track.
		 * Intended for use by MusicArea.
		 * @param	track the track to switch to
		 */
		public function switchMusicNow(track:int):void {
			musicPlayer.switchTrack(track);
		}
		
		public function quitHandler():void {
			if (recentQuitAttempt) {
				
				recentQuitAttempt = false;
				Main.switchToMenu();
			} else {
				
				infoArea.displayText("Quit to menu? Press Q again to confirm.");
				recentQuitAttempt = true;
				
				quitTimer = new Timer(InfoArea.CLEAR_TIME, 1);
				quitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetQuitAttempt);
				quitTimer.start();
			}
		}
		
		private function resetQuitAttempt(event:Event):void {
			recentQuitAttempt = false;
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