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
		public static const POSITION_SCALE:Number = 0.6; //0.6
		public static var position_offset:Number = 40;
		
		private var highNotes:Vector.<NoteBlock>;
		private var midNotes:Vector.<NoteBlock>;
		private var lowNotes:Vector.<NoteBlock>;
		
		private var lateMostTime:int;
		
		private var blockQueue:Vector.<NoteBlock>;
		
		private var currentBlock:int;
		private var blocks:Vector.<Number>;
		
		private var lastRenderingBlock:int;
		private var currentlyRenderingBlocks:Vector.<NoteBlock>;
		
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
		public static const HIGH_COLOR:uint = 0xFF00FF;
		public static const MID_COLOR:uint = 0x00FF00;
		public static const LOW_COLOR:uint = 0xFF8000;
		private var currentTransition:Shape;
		private var transition:TweenLite;
		
		private var notesLayer:Sprite;
		private var scroll:TweenLite;
		
		private var noteSpriteFactory:NoteSpriteFactory;
		
		private var gameUI:GameUI;
		private var repeater:Repeater;
		private var summoningMeterFill:SummoningMeterFill;
		
		public function get currentTrack():int 
		{
			return _currentTrack;
		}
		
		public function MusicArea(gameUI:GameUI, summoningMeterFill:SummoningMeterFill) 
		{
			this.gameUI = gameUI;
			this.repeater = gameUI.repeater;
			this.summoningMeterFill = summoningMeterFill;
			noteSpriteFactory = new NoteSpriteFactory(repeater);
			
			currentlyRenderingBlocks = new Vector.<NoteBlock>();
			
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
		
		public function continueSplitActions():void {
			var index:int = currentlyRenderingBlocks.length - 1;
			while (index >= 0) {
				currentlyRenderingBlocks[index].continueSplitActions();
				
				if (!currentlyRenderingBlocks[index].isMidRender) {
					currentlyRenderingBlocks.splice(index, 1);
				}
				
				index--;
			}
		}
		
		/**
		 * Make sure the upcoming notes are rendered, and notes already past are not.
		 * @param	currentTime notes close to this time will be rendered.
		 */
		public function checkRendering(currentTime:Number):void {
			//We need to do 3 things: derender blocks that are 2 blocks before,
			//render all blocks coming up, and derender current blocks of other tracks.
			//The blocks look like this:
			//        0 0 0 D R 0        (high)
			//    ... 0 D 1 1 R 0 ...    (mid)
			//        0 0 0 D R 0        (low)
			//            | |
			//            | - currentBlock
			//            - lastRenderingBlock (hopefully)
			// Where 1 means currently rendered, 0 means currently not rendered, R means
			// render now, and D means derender now.
			// If lag has occured, we may need to derender more blocks.
			
			updateCurrentBlock(currentTime);
			
			if (lastRenderingBlock < currentBlock) {
				
				var blockIndex:int, block:NoteBlock;
				var alreadyRendering:Boolean;
				
				//Derender old blocks.
				for (blockIndex = Math.max(0, lastRenderingBlock - 1);
											blockIndex < currentBlock - 1; blockIndex++) {
					derenderBlock(blockQueue[blockIndex]);
				}
				
				//Derender blocks of different tracks that aren't needed.
				for (blockIndex = lastRenderingBlock + 1; blockIndex < currentBlock + 1; blockIndex++ ) {
					
					//We don't want to derender blocks that are still in the queue,
					//they will be / are already being derendered in the step above.
					var queueBlock:NoteBlock = blockQueue[blockIndex];
					
					if (highNotes[blockIndex] != queueBlock) {
						derenderBlock(highNotes[blockIndex]);
					}
					
					if (midNotes[blockIndex] != queueBlock) {
						derenderBlock(midNotes[blockIndex]);
					}
					
					if (lowNotes[blockIndex] != queueBlock) {
						derenderBlock(lowNotes[blockIndex]);
					}
					
				}
				
				//Render the upcoming blocks.
				//(If the current one isn't rendered, it's too late; oh, well.)
				if (currentBlock + 1 < blockQueue.length) {
					renderBlock(highNotes[currentBlock + 1]);
					renderBlock(midNotes[currentBlock + 1]);
					renderBlock(lowNotes[currentBlock + 1]);
				}
				
				lastRenderingBlock = currentBlock;
			}
		}
		
		//TODO Inline these later.
		/**
		 * Call derender on the block, and add it to the currentlyRenderingBlocks list
		 * if it wasn't already rendering.
		 * @param	block
		 */
		[Inline]
		private final function derenderBlock(block:NoteBlock):void {
			var alreadyRendering:Boolean = block.isMidRender;
			block.derender();
			if (!alreadyRendering)
				currentlyRenderingBlocks.push(block);
		}
		/**
		 * Call render on the block, and add it to the currentlyRenderingBlocks list
		 * if it wasn't already rendering.
		 * @param	block
		 */
		[Inline]
		private final function renderBlock(block:NoteBlock):void {
			var alreadyRendering:Boolean = block.isMidRender;
			block.render();
			if (!alreadyRendering)
				currentlyRenderingBlocks.push(block);
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
			
			var note:Note = blockQueue[currentBlock].findHit(noteLetter, currentTime, repeater);
			if (note == null && currentBlock + 1 < blockQueue.length)
				note = blockQueue[currentBlock + 1].findHit(noteLetter, currentTime, repeater);
				
			return note;
		}
		
		/**
		 * Misses notes that are too late to hit.
		 * @param	currentTime the current time to compare notes to
		 * @return  whether a note was missed
		 */
		public function missNotes(currentTime:Number):Boolean {
			updateCurrentBlock(currentTime);
			
			var noteMissed:Boolean = blockQueue[currentBlock].missUntil(currentTime, repeater);
			if (currentBlock + 1 < blockQueue.length)
				noteMissed ||= blockQueue[currentBlock + 1].missUntil(currentTime, repeater);
				
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
			
			if (targetTrack == Main.HIGH) {
				if (_currentTrack == Main.MID)
					currentTransition = midToHigh;
				else
					currentTransition = lowToHigh;
				
				summoningMeterFill.changeColor(HIGH_COLOR, delay);
				
			} else if (targetTrack == Main.MID) {
				if (_currentTrack == Main.HIGH)
					currentTransition = highToMid;
				else
					currentTransition = lowToMid;
					
				summoningMeterFill.changeColor(MID_COLOR, delay);
			} else {
				if (_currentTrack == Main.HIGH)
					currentTransition = highToLow;
				else
					currentTransition = midToLow;
					
				summoningMeterFill.changeColor(LOW_COLOR, delay);
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
			
			//Determine which note is the latest, so we know where to move the notesLayer later.
			lateMostTime = 0;
			var note:Note;
			var lastIndex:int = song.lowPart.length - 1;
			for each (note in song.lowPart[lastIndex]) {
				if (note.isHold) {
					if (note.endtime > lateMostTime)
						lateMostTime = note.endtime;
				} else {
					if (note.time > lateMostTime)
						lateMostTime = note.time;
				}
			}
			
			//Create the groups of note blocks.
			lowNotes = createNotesImage(song.lowPart, song.blocks);
			midNotes = createNotesImage(song.midPart, song.blocks);
			highNotes = createNotesImage(song.highPart, song.blocks);
			
			blocks = song.blocks;
			
			var noteBlock:NoteBlock;
			
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
			
			//Render intial blocks.
			renderBlock(midNotes[0]);
			if (blocks.length >= 1) {
				renderBlock(lowNotes[1]);
				renderBlock(midNotes[1]);
				renderBlock(highNotes[1]);
			}
			
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
		private function createNotesImage(notes:Vector.<Vector.<Note>>, blocks:Vector.<Number>):Vector.<NoteBlock> {
			var noteBlocks:Vector.<NoteBlock> = new Vector.<NoteBlock>();

			var notesImage:NoteBlock;
			for (var index:int = 0; index < notes.length; index++)
			{
				if (index == blocks.length)
					notesImage = new NoteBlock(notes[index], Number.MAX_VALUE, noteSpriteFactory);
				else
					notesImage = new NoteBlock(notes[index], blocks[index], noteSpriteFactory);
				
				noteBlocks.push(notesImage);
			}
			
			return noteBlocks;
		}
		
		/**
		 * Starts scrolling the notes leftwards.
		 */
		public function go():void {
			var maxTime:Number = lateMostTime + 1000; //Add an extra second to be sure we're past it.
			
			scroll = new TweenLite(notesLayer, maxTime / 1000, { x: -(maxTime * POSITION_SCALE) + notesLayer.x, ease: Linear.easeOut } );
			
			background.addChild(highToMid); //Moves highToMid to front.
			highToMid.x = -GRADIENT_WIDTH;
			highToMid.visible = true;
			
			_currentTrack = Main.MID;
			nextTrack = Main.MID;
			nextNextTrack = Main.MID;
			lastRenderingBlock = 0;
			
			switchTimer = null;
			advanceTimer = null;
		}
		
		/**
		 * Stops motion of the notes, and unloads the notes.
		 */
		public function stop():void {
			scroll.kill();
			
			this.removeChild(notesLayer);
			//Make sure all the notes are derendered.
			var noteBlock:NoteBlock;
			for each (noteBlock in lowNotes)
				derenderBlock(noteBlock);
			for each (noteBlock in midNotes)
				derenderBlock(noteBlock);
			for each (noteBlock in highNotes)
				derenderBlock(noteBlock);
				
			lowNotes.splice(0, lowNotes.length);
			lowNotes = null;
			midNotes.splice(0, midNotes.length);
			midNotes = null;
			highNotes.splice(0, highNotes.length);
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
	}

}