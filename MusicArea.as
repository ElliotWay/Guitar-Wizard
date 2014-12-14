package  
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class MusicArea extends Sprite 
	{
		public static const HEIGHT:int = 250;
		public static const WIDTH:int = 800;
		
		public static const POSITION_SCALE:Number = 0.3; //position of letter in pixels per milliseconds of music
		
		public static const NOTE_SIZE:int = 20; //radius of the note circle. scales the size of the letter and the hold rectangle
		
		private var highNotes:Sprite;
		private var midNotes:Sprite;
		private var lowNotes:Sprite;
		private var notesLayer:Sprite;
		
		public function MusicArea() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			
			//Change this if you change the stage background.
			//Draw Background (there remains no "background" property so far as I'm aware)
			graphics.lineStyle(0, 0, 0);
			graphics.beginFill(0xBB9999);
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
			graphics.drawRect(25, 0, 50, HEIGHT);
			graphics.endFill();
			
		}
		
		
		public function setLowNotes():void {
			lowNotes.visible = true;
			midNotes.visible = false;
			highNotes.visible = false;
		}
		
		public function setMidNotes():void {
			lowNotes.visible = false;
			midNotes.visible = true;
			highNotes.visible = false;
		}
		
		public function setHighNotes():void {
			lowNotes.visible = false;
			midNotes.visible = false;
			highNotes.visible = true;
		}
		
		public function loadNotes(song:Song):void {
			notesLayer = new Sprite();
			
			lowNotes = createNotesImage(song.lowPart);
			midNotes = createNotesImage(song.midPart);
			highNotes = createNotesImage(song.highPart);
			
			notesLayer.addChild(lowNotes);
			lowNotes.visible = false;
			notesLayer.addChild(midNotes);
			midNotes.visible = true;
			notesLayer.addChild(highNotes);
			highNotes.visible = false;
			
			this.addChild(notesLayer);
		}
		
		public static function createNotesImage(notes:Vector.<Note>):Sprite {
			var notesImage:Sprite = new Sprite();
			
			for each(var note:Note in notes) {
				
				//create the image for this note
				var noteSprite:Sprite = new Sprite();
				noteSprite.graphics.beginFill(0xFF0000);
				noteSprite.graphics.drawCircle(0, 0, NOTE_SIZE);
				noteSprite.graphics.endFill();
				//and the hold rectangle, if applicable
				if (note.isHold) {
					noteSprite.graphics.beginFill(0xFF0000);
					noteSprite.graphics.drawRect(0, -NOTE_SIZE * .25, (note.endtime - note.time) * POSITION_SCALE, NOTE_SIZE * .5);
					noteSprite.graphics.endFill();
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
				letter.setTextFormat(new TextFormat("Arial", NOTE_SIZE * .9, 0x000000, true));
				noteSprite.addChild(letter);
				letter.x = -NOTE_SIZE * .35;
				letter.y = -NOTE_SIZE * .6;
				
				
				//Choose which line
				var yPosition:int = 0;
				if (note.letter == Note.NOTE_F)
					yPosition = (1 / 5) * HEIGHT;
				if (note.letter == Note.NOTE_D)
					yPosition = (2 / 5) * HEIGHT;
				if (note.letter == Note.NOTE_S)
					yPosition = (3 / 5) * HEIGHT;
				if (note.letter == Note.NOTE_A)
					yPosition = (4 / 5) * HEIGHT;
				
				//Place the note
				notesImage.addChild(noteSprite);
				noteSprite.x = note.time * POSITION_SCALE;
				noteSprite.y = yPosition;
			}
			
			return notesImage;
		}
		
		
		private var stopwatch:uint;
		
		public function go():void {
			TweenLite.to(notesLayer, (notesLayer.width * 2 / POSITION_SCALE) / 1000, { x: -notesLayer.width * 2, ease: Linear.easeOut } );
			//this.addEventListener(Event.ENTER_FRAME, scrollLeft);
			//stopwatch = getTimer();
		}
		
		public function stop():void {
			this.removeEventListener(Event.ENTER_FRAME, scrollLeft);
		}
		
		public function scrollLeft(e:Event):void {
			var right_now:uint = getTimer();
			
			lowNotes.x -= (right_now - stopwatch) * POSITION_SCALE;
			midNotes.x -= (right_now - stopwatch) * POSITION_SCALE;
			highNotes.x -= (right_now - stopwatch) * POSITION_SCALE;
			
			stopwatch = right_now;
		}
	}

}