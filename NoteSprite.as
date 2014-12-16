package  
{
	import flash.display.Sprite;
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
		public static const A_COLOR:uint = 0x00FF00;
		
		private var associatedNote:Note;		
		
		public function NoteSprite(noteLetter:int, note:Note) 
		{
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
				this.graphics.drawRect(0, -NOTE_SIZE * .25, (note.endtime - note.time) * MusicArea.POSITION_SCALE, NOTE_SIZE * .5);
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
		
	}

}