package  
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
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
		
		public static const HIT_LINE:int = 75;
		
		public static const POSITION_SCALE:Number = 0.3; //position of letter in pixels per milliseconds of music
		public static var position_offset:Number = 40;
		
		private var highNotes:Sprite;
		private var midNotes:Sprite;
		private var lowNotes:Sprite;
		private var notesLayer:Sprite;
		
		public function MusicArea() 
		{
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
								HIT_LINE + GameUI.HIT_TOLERANCE * POSITION_SCALE, HEIGHT);
			graphics.endFill();
			
			NoteSprite.global_hit_line_position = this.localToGlobal(new Point(HIT_LINE, 0));
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
			
			notesLayer.x = HIT_LINE + Main.VIDEO_LAG * POSITION_SCALE + position_offset;
			this.addChild(notesLayer);
		}
		
		public static function createNotesImage(notes:Vector.<Note>):Sprite {
			var notesImage:Sprite = new Sprite();
			
			for each(var note:Note in notes) {
				
				//Create note image
				var noteSprite:NoteSprite = new NoteSprite(note.letter, note);
				
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
		
		public function getNotesX():Number {
			return (-notesLayer.x + HIT_LINE) / POSITION_SCALE;
		}
		
		public function go():void {
			TweenLite.to(notesLayer, ((notesLayer.width * 2) / POSITION_SCALE) / 1000, { x: -notesLayer.width * 2 + notesLayer.x, ease: Linear.easeOut } );
		}
	}

}