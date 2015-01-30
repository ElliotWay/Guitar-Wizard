package  src
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
		
		/**
		 * Ratio between space on the screen and time, in pixels per millisecond.
		 */
		public static const POSITION_SCALE:Number = 0.3;
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
		
		/**
		 * Switches the visible note panel to the low notes.
		 */
		public function setLowNotes():void {
			lowNotes.visible = true;
			midNotes.visible = false;
			highNotes.visible = false;
		}
		
		/**
		 * Switches the visible note panel to the mid notes.
		 */
		public function setMidNotes():void {
			lowNotes.visible = false;
			midNotes.visible = true;
			highNotes.visible = false;
		}
		
		/**
		 * Switches the visible note panel to the high notes.
		 */
		public function setHighNotes():void {
			lowNotes.visible = false;
			midNotes.visible = false;
			highNotes.visible = true;
		}
		
		/**
		 * Creates panels for the high, mid, and low notes
		 * from a song.
		 * @param	song the song containing the notes
		 */
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
		
		/**
		 * Creates noteSprites arranged based on notes from a vector
		 * @param	notes a vector of notes to convert to an image
		 * @return the image of notes
		 */
		public static function createNotesImage(notes:Vector.<Note>):Sprite {
			var notesImage:Sprite = new Sprite();
			
			for each(var note:Note in notes) {
				
				//Create note image
				var noteSprite:NoteSprite = new NoteSprite(note);
				
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
		
		/**
		 * Starts scrolling the notes leftwards.
		 */
		public function go():void {
			TweenLite.to(notesLayer, ((notesLayer.width * 2) / POSITION_SCALE) / 1000, { x: -notesLayer.width * 2 + notesLayer.x, ease: Linear.easeOut } );
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