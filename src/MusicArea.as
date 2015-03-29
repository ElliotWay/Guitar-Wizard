package  src
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.DisplayObject;
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
		
		private var highNotes:Vector.<Sprite>;
		private var midNotes:Vector.<Sprite>;
		private var lowNotes:Vector.<Sprite>;
		
		private var blocks:Vector.<Number>;
		
		private var notesLayer:Sprite;
		
		private var scroll:TweenLite;
		
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
								2 * GameUI.HIT_TOLERANCE * POSITION_SCALE, HEIGHT);
			graphics.endFill();
			
			NoteSprite.global_hit_line_position = this.localToGlobal(new Point(HIT_LINE, 0));
		}
		
		/**
		 * Change the visibility of note blocks.
		 * @param	track the track to switch to
		 * @param   blockIndex the index of the block including and after which to change block visibility
		 * @return  time of the next block switch
		 */
		public function switchNotes(track:int, blockIndex:int):void {
			
			switch (track) {
				case Main.HIGH:
					setHighNotes(blockIndex);
					break;
				case Main.MID:
					setMidNotes(blockIndex);
					break;
				case Main.LOW:
					setLowNotes(blockIndex);
					break;
			}
		}
		
		/**
		 * Switches the visible notes after and including the index.
		 */
		public function setLowNotes(index:int):void {
			for (index; index < lowNotes.length; index++) {
				lowNotes[index].visible = true;
				midNotes[index].visible = false;
				highNotes[index].visible = false;
			}
		}
		
		/**
		 * Switches the visible notes after and including the index.
		 */
		public function setMidNotes(index:int):void {
			for (index; index < midNotes.length; index++) {
				lowNotes[index].visible = false;
				midNotes[index].visible = true;
				highNotes[index].visible = false;
			}
		}
		
		/**
		 * Switches the visible notes after and including the index.
		 */
		public function setHighNotes(index:int):void {
			for (index; index < highNotes.length; index++) {
				lowNotes[index].visible = false;
				midNotes[index].visible = false;
				highNotes[index].visible = true;
			}
		}
		
		/**
		 * Creates sprites for the high, mid, and low notes
		 * from a song.
		 * @param	song the song containing the notes
		 */
		public function loadNotes(song:Song):void {
			notesLayer = new Sprite();
			
			lowNotes = createNotesImage(song.lowPart);
			midNotes = createNotesImage(song.midPart);
			highNotes = createNotesImage(song.highPart);
			
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
			
			notesLayer.x = HIT_LINE + Main.VIDEO_LAG * POSITION_SCALE + position_offset;
			this.addChild(notesLayer);
		}
		
		/**
		 * Creates noteSprites arranged based on notes from a vector
		 * @param	notes a vector of notes to convert to an image
		 * @param   blocks a vector of times about which to separate the notes into blocks
		 * @return the image of notes
		 */
		public static function createNotesImage(notes:Vector.<Vector.<Note>>):Vector.<Sprite> {
			var noteBlocks:Vector.<Sprite> = new Vector.<Sprite>();

			var notesImage:Sprite;
			
			for each (var block:Vector.<Note> in notes) 
			{
				notesImage = new Sprite();
				
				for each(var note:Note in block) {
					
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
				
				noteBlocks.push(notesImage);
			}
			
			return noteBlocks;
		}
		
		/**
		 * Starts scrolling the notes leftwards.
		 */
		public function go():void {
			scroll = new TweenLite(notesLayer, ((notesLayer.width * 2) / POSITION_SCALE) / 1000, { x: -notesLayer.width * 2 + notesLayer.x, ease: Linear.easeOut } );
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
	}

}