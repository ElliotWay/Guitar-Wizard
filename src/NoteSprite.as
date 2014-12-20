package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class NoteSprite extends Sprite 
	{
		public static const NOTE_SIZE:int = 20; //radius of the note circle. scales the size of the letter and the hold rectangle
		public static const F_COLOR:uint = 0xFF0000;
		public static const D_COLOR:uint = 0x0000FF;
		public static const S_COLOR:uint = 0xFFFF00;
		public static const A_COLOR:uint = 0x00C000;
		
		public static var global_hit_line_position:Point = null;
		
		private var associatedNote:Note;
		
		private var holdEndPoint:Number;
		
		public function NoteSprite(noteLetter:int, note:Note) 
		{
			note.setSprite(this);
			associatedNote = note;
			
			var noteColor:uint = 0x0;
			if (note.letter == Note.NOTE_F)
				noteColor = F_COLOR;
			if (note.letter == Note.NOTE_D)
				noteColor = D_COLOR;
			if (note.letter == Note.NOTE_S)
				noteColor = S_COLOR;
			if (note.letter == Note.NOTE_A)
				noteColor = A_COLOR;
			
			//create the image for this note
			this.graphics.beginFill(noteColor);
			this.graphics.drawCircle(0, 0, NOTE_SIZE);
			this.graphics.endFill();
			//and the hold rectangle, if applicable
			if (note.isHold) {
				this.graphics.beginFill(noteColor);
				holdEndPoint = (note.endtime - note.time) * MusicArea.POSITION_SCALE;
				this.graphics.drawRect(0, -NOTE_SIZE * .25, holdEndPoint, NOTE_SIZE * .5);
				this.graphics.endFill();
			}
			//and the letter
			var letter:TextField = new TextField();
			letter.text = "?";
			if (note.letter == Note.NOTE_F)
				letter.text = "F";
			if (note.letter == Note.NOTE_D)
				letter.text = "D";
			if (note.letter == Note.NOTE_S)
				letter.text = "S";
			if (note.letter == Note.NOTE_A)
				letter.text = "A";
			letter.setTextFormat(new TextFormat("Arial", NOTE_SIZE * .9, 0xFFFFFF - noteColor, true));
			this.addChild(letter);
			letter.x = -NOTE_SIZE * .35;
			letter.y = -NOTE_SIZE * .6;
		}
		
		public function hit():void {
			this.graphics.lineStyle(4, 0x00FF00);
			this.graphics.drawCircle(0, 0, NOTE_SIZE + 3);
			
			if (associatedNote.isHold) {
				this.addEventListener(Event.ENTER_FRAME, continueHold);
			}
		}
		
		public function continueHold(e:Event):void {
			this.graphics.lineStyle(4, 0x00FF00);
			
			trace(global_hit_line_position);
			trace(this.globalToLocal(global_hit_line_position));
			
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
				stopHolding();
			}
		}
		
		public function stopHolding():void {
			this.removeEventListener(Event.ENTER_FRAME, continueHold);
		}
		
		public function miss():void {
			//TODO add this functionality
		}
		
	}

}