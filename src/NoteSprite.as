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
		[Embed(source = "../assets/notes.png")]
		private static const NoteImage:Class;
		private static const NOTE_DATA:BitmapData = (new NoteImage() as Bitmap).bitmapData;
		
		
		public static const NOTE_SIZE:int = 20; //radius of the note circle. scales the size of the letter and the hold rectangle
		
		public static const F_COLOR:uint = 0xC00000;
		public static const D_COLOR:uint = 0x0000FF;
		public static const S_COLOR:uint = 0xFFFF00;
		public static const A_COLOR:uint = 0x009000;
		
		public static const HIT_COLOR:uint = 0x30FF30;
		public static const MISS_COLOR:uint = 0xFF0000;
		
		private static const LETTER_POSITION:Matrix = new Matrix();
		LETTER_POSITION.translate( -NOTE_SIZE * .35, -NOTE_SIZE * .6);
		
		private static const F_TEXT_FIELD:TextField = new TextField();
		F_TEXT_FIELD.text = "F";
		F_TEXT_FIELD.setTextFormat(new TextFormat("Arial", NOTE_SIZE * .9, 0xFFFFFF - F_COLOR, true));
		private static const F_TEXT:BitmapData = new BitmapData(F_TEXT_FIELD.width, F_TEXT_FIELD.height, true, 0x0);
		F_TEXT.draw(F_TEXT_FIELD);

		private static const D_TEXT_FIELD:TextField = new TextField();
		D_TEXT_FIELD.text = "D";
		D_TEXT_FIELD.setTextFormat(new TextFormat("Arial", NOTE_SIZE * .9, 0xFFFFFF - D_COLOR, true));
		private static const D_TEXT:BitmapData = new BitmapData(D_TEXT_FIELD.width, D_TEXT_FIELD.height, true, 0x0);
		D_TEXT.draw(D_TEXT_FIELD);
		
		private static const S_TEXT_FIELD:TextField = new TextField();
		S_TEXT_FIELD.text = "S";
		S_TEXT_FIELD.setTextFormat(new TextFormat("Arial", NOTE_SIZE * .9, 0xFFFFFF - S_COLOR, true));
		private static const S_TEXT:BitmapData = new BitmapData(S_TEXT_FIELD.width, S_TEXT_FIELD.height, true, 0x0);
		S_TEXT.draw(S_TEXT_FIELD);
		
		private static const A_TEXT_FIELD:TextField = new TextField();
		A_TEXT_FIELD.text = "A";
		A_TEXT_FIELD.setTextFormat(new TextFormat("Arial", NOTE_SIZE * .9, 0xFFFFFF - A_COLOR, true));
		private static const A_TEXT:BitmapData = new BitmapData(A_TEXT_FIELD.width, A_TEXT_FIELD.height, true, 0x0);
		A_TEXT.draw(A_TEXT_FIELD);
		
		
		/**
		 * Tells NoteSprite where the hit line is. Affects hold behavior,
		 * so this should be set before doing anything with holds, or preferably
		 * before doing anything with NoteSprites. The constructor does not require it, though.
		 */
		public static var global_hit_line_position:Point = null;
		
		private var associatedNote:Note;
		
		private var holdEndPoint:Number;
		
		/**
		 * 0 represents neither hit nor miss, 1 represents hit, -1 represents miss.
		 */
		private var _isHit:int;
		
		/**
		 * Construct the sprite for this note. Creates an image for this
		 * note with the associated letter and a bar extending to the right
		 * if it's a hold. Also associates the note with this sprite.
		 * 
		 * Remember to set global_hit_line_position at some point.
		 * @param	note the associated note object
		 */
		public function NoteSprite(note:Note) 
		{
			associatedNote = note;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event):void {
			associatedNote.setSprite(this);
			
			createImage();
			
			_isHit = 0;
		}
		
		private function createImage():void {
			if (associatedNote.letter == Note.NOTE_F) {
				var animation:FrameAnimation = FrameAnimation.create(NOTE_DATA, new Point(0, 0),
					50, 50, 4, FrameAnimation.FOUR_PER_BEAT, FrameAnimation.FLAG_COLOR,
					false, true, false);
					
				this.addChild(animation);
				animation.visible = true;
				animation.x = -(animation.width / 2);
				animation.y = -(animation.height / 2);
				animation.go(GameUI.REPEATER);
				return;
			}
			
			//Determine which letter this is.
			var noteColor:uint = 0x0;
			var letterData:BitmapData = null;
			if (associatedNote.letter == Note.NOTE_F) {
				noteColor = F_COLOR;
				letterData = F_TEXT;
			} else if (associatedNote.letter == Note.NOTE_D) {
				noteColor = D_COLOR;
				letterData = D_TEXT;
			} else if (associatedNote.letter == Note.NOTE_S) {
				noteColor = S_COLOR;
				letterData = S_TEXT;
			} else {// (associatedNote.letter == Note.NOTE_A)
				noteColor = A_COLOR;
				letterData = A_TEXT;
			}
			
			//Create the circle for this note.
			this.graphics.beginFill(noteColor);
			this.graphics.drawCircle(0, 0, NOTE_SIZE);
			this.graphics.endFill();
			
			//And the hold rectangle, if applicable.
			if (associatedNote.isHold) {
				this.graphics.beginFill(noteColor);
				holdEndPoint = (associatedNote.endtime - associatedNote.time) * MusicArea.POSITION_SCALE;
				this.graphics.drawRect(0, -NOTE_SIZE * .25, holdEndPoint, NOTE_SIZE * .5);
				this.graphics.endFill();
			}
			
			//The letter is drawn on top.
			graphics.beginBitmapFill(letterData, LETTER_POSITION, false);
			graphics.drawRect(-50, -50, letterData.width, letterData.height);
			graphics.endFill();
		}
		
		public function refresh():void {
			this.graphics.clear();
			
			createImage();
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
		public function hit():void {
			if (_isHit == 0) {
				this.graphics.lineStyle(4, HIT_COLOR);
				this.graphics.drawCircle(0, 0, NOTE_SIZE + 2);//3
				
				if (associatedNote.isHold) {
					this.addEventListener(Event.ENTER_FRAME, continueHold);
				}
				
				_isHit = 1;
			}
		}
		
		/**
		 * Enter frame event listener for updating the successful hold image.
		 * Finishes the hold if we're the hold is entirely through the hit line.
		 * @param	e enter frame event
		 */
		private function continueHold(e:Event):void {
			this.graphics.lineStyle(4, HIT_COLOR);
						
			var targetX:Number = this.globalToLocal(global_hit_line_position).x;
			
			//make sure we're passed the hit line
			if (NOTE_SIZE < targetX) {
				
				//Check if we're at the end of the hold
				if (targetX < holdEndPoint) {
					this.graphics.moveTo(NOTE_SIZE, NOTE_SIZE * .25 + 1);
					this.graphics.lineTo(targetX, NOTE_SIZE * .25 + 1);
					
					this.graphics.moveTo(NOTE_SIZE, -(NOTE_SIZE * .25 + 1));
					this.graphics.lineTo(targetX, -(NOTE_SIZE * .25 + 1));
				} else {
					//close off the hold
					this.graphics.moveTo(NOTE_SIZE, NOTE_SIZE * .25 + 1);
					this.graphics.lineTo(holdEndPoint, NOTE_SIZE * .25 + 1);
					this.graphics.lineTo(holdEndPoint, -(NOTE_SIZE * .25 + 1));
					this.graphics.lineTo(NOTE_SIZE, -(NOTE_SIZE * .25 + 1));
					stopHolding();
				}
			} else if (targetX > holdEndPoint) {
				//Weird hold, as it's smaller than the radius of the note.
				//For robustness's sake, stop the animation here.
				trace("Unusually small hold.");
				stopHolding();
			}
		}
		
		/**
		 * Ceases the animation displaying a successful hold.
		 */
		public function stopHolding():void {
			this.removeEventListener(Event.ENTER_FRAME, continueHold);
		}
		
		/**
		 * Changes the sprite to indicate the note was missed. Does nothing
		 * different if the note is a hold.
		 * Does nothing if this note has already been hit or missed.
		 */
		public function miss():void {
			if (_isHit == 0) {
				this.graphics.lineStyle(4, MISS_COLOR);
				this.graphics.drawCircle(0, 0, NOTE_SIZE + 3);
				
				_isHit = -1;
			}
		}
		
		/**
		 * Removes the association with a note for easier garbage collecting.
		 */
		public function dissociate():void {
			associatedNote = null;
		}
		
	}

}