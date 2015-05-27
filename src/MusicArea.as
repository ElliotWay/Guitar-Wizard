package  src
{
	import com.greensock.easing.Power2;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
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
		
		private var background:Sprite;
		private var highToMid:Shape;
		private var highToLow:Shape;
		private var midToHigh:Shape;
		private var midToLow:Shape;
		private var lowToHigh:Shape;
		private var lowToMid:Shape;
		private static const GRADIENT_WIDTH:int = 400;
		private static const HIGH_COLOR:uint = 0xFF00FF;
		private static const MID_COLOR:uint = 0x00FF00;
		private static const LOW_COLOR:uint = 0xFF8000;
		private var currentTransition:Shape;
		private var transition:TweenLite;
		
		private var notesLayer:Sprite;
		private var scroll:TweenLite;
		
		private var gameUI:GameUI;
		
		public function MusicArea(gameUI:GameUI) 
		{
			this.gameUI = gameUI;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			
			//Create transition gradients.
			highToMid = createGradient(HIGH_COLOR, MID_COLOR);
			highToLow = createGradient(HIGH_COLOR, LOW_COLOR);
			midToHigh = createGradient(MID_COLOR, HIGH_COLOR);
			midToLow = createGradient(MID_COLOR, LOW_COLOR);
			lowToHigh = createGradient(LOW_COLOR, HIGH_COLOR);
			lowToMid = createGradient(LOW_COLOR, MID_COLOR);
			
			background = new Sprite();
			background.addChild(highToMid);
			highToMid.x = -GRADIENT_WIDTH;
			highToMid.visible = true;
			
			this.addChild(background);
			
			//Draw 4 lines.
			var lineLayer:Shape = new Shape();
			lineLayer.graphics.lineStyle(3);
			for (var i:int = 0; i < 4; i++) {
				lineLayer.graphics.moveTo(0, HEIGHT * ((i + 1) / 5));
				lineLayer.graphics.lineTo(WIDTH, HEIGHT * ((i + 1) / 5));
			}
			
			//Draw "hit here" region
			lineLayer.graphics.lineStyle(0, 0, 0.0);
			lineLayer.graphics.beginFill(0x0, 0.3);//0xFFA319, 0.7);
			lineLayer.graphics.drawRect(HIT_LINE - GameUI.HIT_TOLERANCE * POSITION_SCALE, 0,
								2 * GameUI.HIT_TOLERANCE * POSITION_SCALE, HEIGHT);
			lineLayer.graphics.endFill();
			
			this.addChild(lineLayer);
			
			NoteSprite.global_hit_line_position = this.localToGlobal(new Point(HIT_LINE, 0));
			
		}
		
		private function createGradient(LEFT_COLOR:uint, RIGHT_COLOR:uint):Shape {
			var gradientMat:Matrix = new Matrix();
			gradientMat.createGradientBox(GRADIENT_WIDTH, HEIGHT);
			
			var gradient:Shape = new Shape();
			gradient.graphics.beginGradientFill(GradientType.LINEAR,
					[LEFT_COLOR, RIGHT_COLOR], [1, 1], [0, 255], gradientMat);
					
			gradient.graphics.drawRect(0, 0, WIDTH + GRADIENT_WIDTH, HEIGHT);
			
			return gradient;
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
				
				doTransition(switchTime - currentTime, track);
				
			} else {
				
				//If we're too late to switch right away, and no switch was scheduled,
				//we still need to switch numbers around.
				if (switchTimer == null) {
					var currentBlockEnd:Number = blocks[currentBlock];
					
					switchTimer = new Timer(currentBlockEnd - currentTime, 1);
					
					switchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
						switchLater();
						doTransition(switchTime - currentBlockEnd, track);
					});
					switchTimer.start();
				} else {
					doTransition(switchTime - currentTime, track);
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
		
		private function musicSwitch(event:Event):void {
			(event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, musicSwitch);
			switchLater();
			gameUI.switchMusicNow(_currentTrack);
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
		 * Transition the color of the area to indicate the pending switch.
		 * @param	track the track to switch to
		 */
		private function doTransition(delay:Number, targetTrack:int):void {
			trace("transition from: " + _currentTrack + " to " + targetTrack);
			
			if (transition != null) {
				transition.kill();
			}
			if (currentTransition != null) {
				currentTransition.visible = false;
			}
			
			if (_currentTrack == targetTrack)
				return;
			
			if (_currentTrack == Main.HIGH) {
				if (targetTrack == Main.MID)
					currentTransition = highToMid;
				else // (targetTrack == Main.LOW)
					currentTransition = highToLow;
			} else if (_currentTrack == Main.MID) {
				if (targetTrack == Main.HIGH)
					currentTransition = midToHigh;
				else // (targetTrack == Main.LOW)
					currentTransition = midToLow;
			} else if (_currentTrack == Main.LOW) {
				if (targetTrack == Main.HIGH)
					currentTransition = lowToHigh;
				else // (targetTrack == Main.MID)
					currentTransition = lowToMid;
			}
			
			currentTransition.visible = true;
			background.addChild(currentTransition);
			
			currentTransition.x = WIDTH;
			
			transitionDelay = delay;
			
			//Move the transition background slightly onto the screen from the right.
			transition = new TweenLite(currentTransition,
					0.1, { x:WIDTH - 200, onComplete:nextTransitionStep } );
		}
		private var transitionDelay:Number;
		
		private function nextTransitionStep():void {
			transition.kill();
			//Fill the screen with the transition exactly when the track switches.
			transition = new TweenLite(currentTransition, (transitionDelay - 100) / 1000,
					{x: -GRADIENT_WIDTH, ease:Power2.easeIn, onComplete:stopTransition } );
		}
		
		private function stopTransition():void {
			currentTransition = null;
			if (transition != null) {
				transition.kill();
				transition = null;
			}
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
			
			background.addChild(highToMid); //Moves highToMid to front.
			highToMid.x = -GRADIENT_WIDTH;
			highToMid.visible = true;
			
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