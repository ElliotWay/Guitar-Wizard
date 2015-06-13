package  src
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class NoteSprite extends Sprite
	{
		public static const F_COLOR:uint = 0xC00000;
		public static const D_COLOR:uint = 0x0000FF;
		public static const S_COLOR:uint = 0xFFFF00;
		public static const A_COLOR:uint = 0x009000;
		
		private static const F_PULSE:FrameAnimation = 
				NoteSpriteAnimationCreator.pulseAnimation(F_COLOR, "F");
		private static const F_HIT:FrameAnimation = 
				NoteSpriteAnimationCreator.hitAnimation(F_COLOR, "F");
		private static const F_MISS:FrameAnimation =
				NoteSpriteAnimationCreator.missAnimation(F_COLOR, "F");
					
		private static const D_PULSE:FrameAnimation =
				NoteSpriteAnimationCreator.pulseAnimation(D_COLOR, "D");
		private static const D_HIT:FrameAnimation = 
				NoteSpriteAnimationCreator.hitAnimation(D_COLOR, "D");
		private static const D_MISS:FrameAnimation =
				NoteSpriteAnimationCreator.missAnimation(D_COLOR, "D");
		
		private static const S_PULSE:FrameAnimation =
				NoteSpriteAnimationCreator.pulseAnimation(S_COLOR, "S");
		private static const S_HIT:FrameAnimation = 
				NoteSpriteAnimationCreator.hitAnimation(S_COLOR, "S");
		private static const S_MISS:FrameAnimation =
				NoteSpriteAnimationCreator.missAnimation(S_COLOR, "S");
		
		private static const A_PULSE:FrameAnimation =
				NoteSpriteAnimationCreator.pulseAnimation(A_COLOR, "A");
		private static const A_HIT:FrameAnimation = 
				NoteSpriteAnimationCreator.hitAnimation(A_COLOR, "A");
		private static const A_MISS:FrameAnimation =
				NoteSpriteAnimationCreator.missAnimation(A_COLOR, "A");
				
		public static const NOTE_RADIUS:int = 20;
		
		
		
		public static const HIT_COLOR:uint = 0xFFFFFF;
		public static const MISS_COLOR:uint = 0x0;
		
		/*private static const LETTER_POSITION:Matrix = new Matrix();
		LETTER_POSITION.translate( -NOTE_RADIUS * .35, -NOTE_RADIUS * .6);
		
		private static const F_TEXT_FIELD:TextField = new TextField();
		F_TEXT_FIELD.text = "F";
		F_TEXT_FIELD.setTextFormat(new TextFormat("Arial", NOTE_RADIUS * .9, 0xFFFFFF - F_COLOR, true));
		private static const F_TEXT:BitmapData = new BitmapData(F_TEXT_FIELD.width, F_TEXT_FIELD.height, true, 0x0);
		F_TEXT.draw(F_TEXT_FIELD);

		private static const D_TEXT_FIELD:TextField = new TextField();
		D_TEXT_FIELD.text = "D";
		D_TEXT_FIELD.setTextFormat(new TextFormat("Arial", NOTE_RADIUS * .9, 0xFFFFFF - D_COLOR, true));
		private static const D_TEXT:BitmapData = new BitmapData(D_TEXT_FIELD.width, D_TEXT_FIELD.height, true, 0x0);
		D_TEXT.draw(D_TEXT_FIELD);
		
		private static const S_TEXT_FIELD:TextField = new TextField();
		S_TEXT_FIELD.text = "S";
		S_TEXT_FIELD.setTextFormat(new TextFormat("Arial", NOTE_RADIUS * .9, 0xFFFFFF - S_COLOR, true));
		private static const S_TEXT:BitmapData = new BitmapData(S_TEXT_FIELD.width, S_TEXT_FIELD.height, true, 0x0);
		S_TEXT.draw(S_TEXT_FIELD);
		
		private static const A_TEXT_FIELD:TextField = new TextField();
		A_TEXT_FIELD.text = "A";
		A_TEXT_FIELD.setTextFormat(new TextFormat("Arial", NOTE_RADIUS * .9, 0xFFFFFF - A_COLOR, true));
		private static const A_TEXT:BitmapData = new BitmapData(A_TEXT_FIELD.width, A_TEXT_FIELD.height, true, 0x0);
		A_TEXT.draw(A_TEXT_FIELD);*/
		
		
		/**
		 * Tells NoteSprite where the hit line is. Affects hold behavior,
		 * so this should be set before doing anything with holds, or preferably
		 * before doing anything with NoteSprites. The constructor does not require it, though.
		 */
		public static var global_hit_line_position:Point = null;
		
		private var associatedNote:Note;
		private var _letter:int;
		
		private var holdEndPoint:Number;
		private var holdFinished:Boolean;
		
		private var animation:FrameAnimation;
		private var hitAnimation:FrameAnimation;
		private var missAnimation:FrameAnimation;
		
		/**
		 * 0 represents neither hit nor miss, 1 represents hit, -1 represents miss.
		 */
		private var _isHit:int;
		
		public function get letter():int 
		{
			return _letter;
		}
		
		/**
		 * Construct the sprite for this note. Creates an image for this
		 * note with the associated letter and a bar extending to the right
		 * if it's a hold. Also associates the note with this sprite.
		 * 
		 * Remember to set global_hit_line_position at some point.
		 * @param	note the associated note object
		 */
		public function NoteSprite(letter:int) 
		{
			_letter = letter;
			
			switch (_letter) {
				case Note.NOTE_F:
					animation = F_PULSE.copy();
					hitAnimation = F_HIT.copy();
					missAnimation = F_MISS.copy();
					break;
				case Note.NOTE_D:
					animation = D_PULSE.copy();
					hitAnimation = D_HIT.copy();
					missAnimation = D_MISS.copy();
					break;
				case Note.NOTE_S:
					animation = S_PULSE.copy();
					hitAnimation = S_HIT.copy();
					missAnimation = S_MISS.copy();
					break;
				case Note.NOTE_A:
					animation = A_PULSE.copy();
					hitAnimation = A_HIT.copy();
					missAnimation = A_MISS.copy();
					break;
			}
			
			this.addChild(animation);
			animation.x = -(animation.width) / 2;
			animation.y = -(animation.height) / 2;
			
			this.addChild(hitAnimation);
			hitAnimation.x = -(hitAnimation.width) / 2;
			hitAnimation.y = -(hitAnimation.height) / 2;
			
			this.addChild(missAnimation);
			missAnimation.x = -(missAnimation.width) / 2;
			missAnimation.y = -(missAnimation.height) / 2;
		}
		
		/**
		 * Reset the note sprite its starting state.
		 */
		factory function restore(repeater:Repeater):void {
			missAnimation.visible = false;
			hitAnimation.visible = false;
			
			animation.visible = true;
			createHoldRectangle();
			
			_isHit = 0;
			
			animation.go(repeater);
		}
		
		factory function setAssociatedNote(note:Note):void {
			if (note.letter != _letter) {
				throw new GWError("Can't associate note with sprite of different letter.");
			}
			associatedNote = note;
			note.setSprite(this);
		}
		
		/**
		 * Currently only creates the hold rectangle,
		 * as the rest of the note sprites have become animated sprites.
		 */
		private function createHoldRectangle():void {
			if (associatedNote == null)
				return;
				
			this.graphics.clear();
			
			//Determine which letter this is.
			var noteColor:uint = 0x0;
			if (associatedNote.letter == Note.NOTE_F) {
				noteColor = F_COLOR;
			} else if (associatedNote.letter == Note.NOTE_D) {
				noteColor = D_COLOR;
			} else if (associatedNote.letter == Note.NOTE_S) {
				noteColor = S_COLOR;
			} else {// (associatedNote.letter == Note.NOTE_A)
				noteColor = A_COLOR;
			}
			
			//And the hold rectangle, if applicable.
			if (associatedNote.isHold) {
				this.graphics.beginFill(noteColor);
				holdEndPoint = (associatedNote.endtime - associatedNote.time) * MusicArea.POSITION_SCALE;
				this.graphics.drawRect(0, -NOTE_RADIUS * .25, holdEndPoint, NOTE_RADIUS * .5);
				this.graphics.endFill();
				
				holdFinished = false;
			}
		}
		
		public function refresh():void {
			createHoldRectangle();
		}
		
		/**
		 * Returns whether hit has been called.
		 */
		public function isHit():Boolean {
			return (_isHit > 0);
		}
		
		/**
		 * Changes the sprite to indicate that it was hit. Also starts
		 * doing the same with the hold: this will end on its own, but
		 * call stopHolding() to end prematurely.
		 * The public static field "global_hit_line_position" should be set
		 * before calling this method.
		 * Does nothing if this note has already been hit or missed.
		 */
		public function hit(repeater:Repeater):void {
			if (_isHit == 0) {
				animation.visible = false;
				hitAnimation.visible = true;
				hitAnimation.go(repeater);
					
				if (associatedNote.isHold) {
					repeater.runConsistentlyEveryFrame(continueHold);
				}
				
				_isHit = 1;
			}
		}
		
		/**
		 * Enter frame event listener for updating the successful hold image.
		 * Finishes the hold if we're the hold is entirely through the hit line.
		 * @param	e enter frame event
		 */
		private function continueHold():void {
			if (!holdFinished) {
				this.graphics.lineStyle(4, HIT_COLOR);
				
				var targetX:Number = this.globalToLocal(global_hit_line_position).x;
				
				//make sure we're passed the hit line
				if (NOTE_RADIUS < targetX) {
					
					//Check if we're at the end of the hold
					if (targetX < holdEndPoint) {
						this.graphics.moveTo(NOTE_RADIUS, NOTE_RADIUS * .25 + 1);
						this.graphics.lineTo(targetX, NOTE_RADIUS * .25 + 1);
						
						this.graphics.moveTo(NOTE_RADIUS, -(NOTE_RADIUS * .25 + 1));
						this.graphics.lineTo(targetX, -(NOTE_RADIUS * .25 + 1));
					} else {
						//close off the hold
						this.graphics.moveTo(NOTE_RADIUS, NOTE_RADIUS * .25 + 1);
						this.graphics.lineTo(holdEndPoint, NOTE_RADIUS * .25 + 1);
						this.graphics.lineTo(holdEndPoint, -(NOTE_RADIUS * .25 + 1));
						this.graphics.lineTo(NOTE_RADIUS, -(NOTE_RADIUS * .25 + 1));
						
						holdFinished = true;
					}
				} else if (targetX > holdEndPoint) {
					//Weird hold, as it's smaller than the radius of the note.
					//For robustness's sake, stop the animation here.
					trace("Unusually small hold.");
					
					holdFinished;
				}
			}
		}
		
		/**
		 * Ceases the animation displaying a successful hold.
		 */
		public function stopHolding(repeater:Repeater):void {
			repeater.stopRunningConsistentlyEveryFrame(continueHold);
		}
		
		/**
		 * Changes the sprite to indicate the note was missed. Does nothing
		 * different if the note is a hold.
		 * Does nothing if this note has already been hit or missed.
		 */
		public function miss(repeater:Repeater):void {
			if (_isHit == 0) {
				animation.visible = false;
				missAnimation.visible = true;
				missAnimation.go(repeater);
				
				_isHit = -1;
			}
		}
		
		/**
		 * Removes the association with a note, and its association with this sprite.
		 * Stops any running animations.
		 */
		public function stop(repeater:Repeater):void {
			associatedNote.dissociate();
			associatedNote = null;
			
			stopHolding(repeater);
			
			animation.stop(repeater);
			hitAnimation.stop(repeater);
			missAnimation.stop(repeater);
		}
		
	}

}