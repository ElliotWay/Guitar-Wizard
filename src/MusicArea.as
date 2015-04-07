package  src
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class MusicArea extends Sprite 
	{
		public static const HEIGHT:int = 250;
		public static const WIDTH:int = 800;
		
		public static const HIT_LINE:int = 200;
		
		/**
		 * Time in milliseconds before the beginning of a block
		 * after which switching tracks will switch the following block.
		 */
		public static const SWITCH_ADVANCE_TIME:Number = (WIDTH - HIT_LINE) / POSITION_SCALE;
		
		/**
		 * Ratio between space on the screen and time, in pixels per millisecond.
		 */
		public static const POSITION_SCALE:Number = 0.6; //0.3
		public static var position_offset:Number = 40;
		
		private var highNotes:Vector.<NoteBlock>;
		private var midNotes:Vector.<NoteBlock>;
		private var lowNotes:Vector.<NoteBlock>;
		
		private var blockQueue:Vector.<NoteBlock>;
		
		private var currentBlock:int;
		private var blocks:Vector.<Number>;
		
		private var _currentTrack:int;
		private var nextTrack:int;
		private var nextNextTrack:int;
		
		private var switchTimer:Timer;
		private var advanceTimer:Timer;
		
		
		private var notesLayer:Sprite;
		private var scroll:TweenLite;
		
		private var gameUI:GameUI;
		
		public function MusicArea(gameUI:GameUI) 
		{
			this.gameUI = gameUI;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			
			//Draw Background (there remains no "background" property so far as I'm aware)
			graphics.lineStyle(0, 0, 0);
			graphics.beginFill(0xD17519);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
			
			//Draw 4 lines.
			graphics.lineStyle(3);
			for (var i:int = 0; i < 4; i++) {
				graphics.moveTo(0, HEIGHT * ((i + 1) / 5));
				graphics.lineTo(WIDTH, HEIGHT * ((i + 1) / 5));
			}
			
			//Draw "hit here" region
			graphics.lineStyle(0, 0, 0.0);
			graphics.beginFill(0xFFA319, 0.7);
			graphics.drawRect(HIT_LINE - GameUI.HIT_TOLERANCE * POSITION_SCALE, 0,
								2 * GameUI.HIT_TOLERANCE * POSITION_SCALE, HEIGHT);
			graphics.endFill();
			
			NoteSprite.global_hit_line_position = this.localToGlobal(new Point(HIT_LINE, 0));
		}
		
		/**
		 * Attemps to hit a note with the specified letter at the current time.
		 * Returns the hit note if one is found, or null otherwise.
		 * @param	noteLetter the letter of the note to search for
		 * @param	currentTime the approximate time of the note to search for
		 * @return  the hit note, or null if none is found
		 */
		public function hitNote(noteLetter:int, currentTime:Number):Note {
			updateCurrentBlock(currentTime);
			
			var note:Note = blockQueue[currentBlock].findHit(noteLetter, currentTime);
			if (note == null && currentBlock + 1 < blockQueue.length)
				note = blockQueue[currentBlock + 1].findHit(noteLetter, currentTime);
				
			return note;
		}
		
		/**
		 * Misses notes that are too late to hit.
		 * @param	currentTime the current time to compare notes to
		 * @return  whether a note was missed
		 */
		public function missNotes(currentTime:Number):Boolean {
			updateCurrentBlock(currentTime);
			
			var noteMissed:Boolean = blockQueue[currentBlock].missUntil(currentTime);
			if (currentBlock + 1 < blockQueue.length)
				noteMissed ||= blockQueue[currentBlock + 1].missUntil(currentTime);
				
			return noteMissed;
		}
		
		/**
		 * Change the visibility of note blocks.
		 * @param	track the track to switch to
		 * @param   currentTime the current time
		 * @param   the current track
		 * @param   what the next track currently is
		 * @return  time of the next block switch
		 */
		public function switchNotes(track:int, currentTime:Number):void {
			updateCurrentBlock(currentTime);
			
			var isEarlySwitch:Boolean = true;
			var switchTime:Number;
			var switchIndex:int;

			
			//2 major situations can occur here:
			//we can switch in the next block or
			//it's too late and we can switch in the block after that.
			//
			//In either case, we may already be at the end, and can't switch at all.
			
			if (currentBlock < blocks.length && blocks[currentBlock] - currentTime > SWITCH_ADVANCE_TIME) {
				switchIndex = currentBlock + 1;
				switchTime = blocks[currentBlock];
			} else if (currentBlock + 1 < blocks.length) {
				//blocks[currentBlock + 1] - rightNow > SWITCH_ADVANCE_TIME
				//is necessarily true.
				
				switchIndex = currentBlock + 2;
				switchTime = blocks[currentBlock + 1];
				
				isEarlySwitch = false;
			} else {
				//It's too late to switch, so just return.
				return;
			}
			
			//If it's the same track, don't switch.
			if ((isEarlySwitch && track == nextTrack) ||
					(!isEarlySwitch && track == nextNextTrack))
				return;
			
			if (isEarlySwitch)
				trace("switching from " + _currentTrack + " to " + track + " after and including " + switchIndex);
			else
				trace("will switch from " + nextTrack + " to " + track + " after and including " + switchIndex);
			
			//Swap in the correct note blocks.
			var trackList:Vector.<NoteBlock>;
			switch (track) {
				case Main.HIGH:
					trackList = highNotes;
					break;
				case Main.MID:
					trackList = midNotes;
					break;
				case Main.LOW:
					trackList = lowNotes;
					break;
			}
			for (var index:int = switchIndex; index < blockQueue.length; index++) {
				blockQueue[index].visible = false;
				trackList[index].visible = true;
				blockQueue[index] = trackList[index];
			}
			
			//Trim the trailing holds from the block before, or undo that if
			//we're switching back.
			if ((track == _currentTrack && isEarlySwitch) ||
					(track == nextTrack && !isEarlySwitch)) {
				trace("uncut " + (switchIndex - 1));
				blockQueue[switchIndex - 1].uncut();
			} else {
				trace("cut " + (switchIndex - 1));
				blockQueue[switchIndex - 1].cut();
			}
			
			//At the right time, ask the gameUI to switch music playback.
			if (isEarlySwitch) {
				
				if (switchTimer != null)
					switchTimer.stop();
				
				switchTimer = new Timer(switchTime - currentTime, 1);
				switchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					switchLater();
					gameUI.switchMusicNow(track);
				});
				switchTimer.start();
				
				nextTrack = track;
				nextNextTrack = track;
				
			} else {
				
				//If we're too late to switch right away, and no switch was scheduled,
				//we still need to switch numbers around.
				if (switchTimer == null) {
					switchTimer = new Timer(blocks[currentBlock] - currentTime, 1);
					switchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
						switchLater();
					});
					switchTimer.start();
				}
				
				if (advanceTimer != null)
					advanceTimer.stop();
				
				advanceTimer = new Timer(switchTime - currentTime, 1);
				advanceTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					switchLater();
					gameUI.switchMusicNow(track);
				});
				advanceTimer.start();
				
				nextNextTrack = track;
			}
		}
		
		/**
		 * Move the advance switch into the current switch.
		 */
		private function switchLater():void {
			_currentTrack = nextTrack;
			nextTrack = nextNextTrack;
			
			switchTimer = advanceTimer;
			advanceTimer = null;
		}
		
		/**
		 * Creates sprites for the high, mid, and low notes
		 * from a song.
		 * @param	song the song containing the notes
		 */
		public function loadNotes(song:Song):void {
			notesLayer = new Sprite();
			
			lowNotes = createNotesImage(song.lowPart, song.blocks);
			midNotes = createNotesImage(song.midPart, song.blocks);
			highNotes = createNotesImage(song.highPart, song.blocks);
			
			blocks = song.blocks;
			
			var noteBlock:Sprite;
			
			for each (noteBlock in lowNotes) {
				notesLayer.addChild(noteBlock);
				noteBlock.visible = false;
			}
			
			for each (noteBlock in midNotes) {
				notesLayer.addChild(noteBlock);
				noteBlock.visible = true;
			}
			
			for each (noteBlock in highNotes) {
				notesLayer.addChild(noteBlock);
				noteBlock.visible = false;
			}
			
			blockQueue = midNotes.concat(); //Concat without args creates a shallow copy.
			currentBlock = 0;
			
			notesLayer.x = HIT_LINE + Main.VIDEO_LAG * POSITION_SCALE + position_offset;
			this.addChild(notesLayer);
		}
		
		private function updateCurrentBlock(currentTime:Number):void {
			while (currentBlock < blocks.length && currentTime > blocks[currentBlock])
				currentBlock++;
		}
		
		/**
		 * Creates noteSprites arranged based on notes from a vector
		 * @param	notes a vector of notes to convert to an image
		 * @param   blocks a vector of times about which to separate the notes into blocks
		 * @return the image of notes
		 */
		public static function createNotesImage(notes:Vector.<Vector.<Note>>, blocks:Vector.<Number>):Vector.<NoteBlock> {
			var noteBlocks:Vector.<NoteBlock> = new Vector.<NoteBlock>();

			var notesImage:NoteBlock;
			for (var index:int = 0; index < notes.length; index++)
			{
				if (index == blocks.length)
					notesImage = new NoteBlock(notes[index], Number.MAX_VALUE);
				else
					notesImage = new NoteBlock(notes[index], blocks[index]);
				
				noteBlocks.push(notesImage);
			}
			
			return noteBlocks;
		}
		
		/**
		 * Starts scrolling the notes leftwards.
		 */
		public function go():void {
			scroll = new TweenLite(notesLayer, ((notesLayer.width * 2) / POSITION_SCALE) / 1000, { x: -notesLayer.width * 2 + notesLayer.x, ease: Linear.easeOut } );
			
			_currentTrack = Main.MID;
			nextTrack = Main.MID;
			nextNextTrack = Main.MID;
			
			switchTimer = null;
			advanceTimer = null;
		}
		
		/**
		 * Stops motion of the notes, and unloads the notes.
		 */
		public function stop():void {
			scroll.kill();
			
			var block:Sprite;
			var thing:DisplayObject;
			
			this.removeChild(notesLayer);
			
			lowNotes = null;
			midNotes = null;
			highNotes = null;
			
			notesLayer = null;
		}
		
		/**
		 * Gets the horizontal position of the notes layer.
		 * @return the x position of the notes layer
		 */
		public function getPosition():Number {
			return notesLayer.x;
		}
		
		public function get currentTrack():int 
		{
			return _currentTrack;
		}
	}

}