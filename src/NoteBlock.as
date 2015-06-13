package src 
{
	import flash.concurrent.Mutex;
	import flash.display.Sprite;
	
	/**
	 * A block of notes, both visually and numerically, so the appearance of notes
	 * can be more easily changed at the same time as their underlying model.
	 */
	public class NoteBlock extends Sprite 
	{
		private var _notes:Vector.<Note>;
		private var index:int;

		private var trimmable:Vector.<TrimmedNote>;
		
		private var rendered:Boolean;
		
		private var noteSpriteFactory:NoteSpriteFactory;
		
		private var renderAction:ActionSplitter;
		private var derenderAction:ActionSplitter;
		
		/**
		 * Whether the block is currently rendering or derendering.
		 */
		public function get isMidRender():Boolean {
			return (renderAction.processing || derenderAction.processing);
		}
		
		/**
		 * Create a block of notes from a vector of notes.
		 * @param	notes  the notes to use to create this block
		 * @param	blockEnd the time of the end of this block
		 */
		public function NoteBlock(notes:Vector.<Note>, blockEnd:Number, noteSpriteFactory:NoteSpriteFactory) 
		{
			super();
			
			_notes = notes.concat();
			index = 0;
			this.noteSpriteFactory = noteSpriteFactory;
			
			rendered = false;
			
			renderAction = new ActionSplitter(continueRender);
			derenderAction = new ActionSplitter(continueDerender);
			
			//The notes at the very end may be candidates for trimming.
			
			var lastF:Note = null;
			var lastD:Note = null;
			var lastS:Note = null;
			var lastA:Note = null;
			
			for each(var note:Note in notes) {
					
				//Choose which line
				var yPosition:int = 0;
				if (note.letter == Note.NOTE_F) {
					lastF = note;
				}
				if (note.letter == Note.NOTE_D) {
					lastD = note;
				}
				if (note.letter == Note.NOTE_S) {
					lastS = note;
				}
				if (note.letter == Note.NOTE_A) {
					lastA = note;
				}
			}
			
			trimmable = new Vector.<TrimmedNote>();
			
			checkIfTrimmable(lastF, blockEnd);
			checkIfTrimmable(lastD, blockEnd);
			checkIfTrimmable(lastS, blockEnd);
			checkIfTrimmable(lastA, blockEnd);
		}
		
		private function checkIfTrimmable(note:Note, blockEnd:Number):void {
			const MIN_HOLD_SIZE:Number = 300;
			
			if (note == null)
				return;
			
			if (note.isHold && note.endtime > blockEnd) {
				var betterEndTime:Number = blockEnd - GameUI.HIT_TOLERANCE;
				if (betterEndTime - note.time < MIN_HOLD_SIZE) {
					trimmable.push(new TrimmedNote(note, false));
				} else {
					trimmable.push(new TrimmedNote(note, true, betterEndTime));
				}
			}
		}
		
		public function continueSplitActions():void {
			if (renderAction.processing)
				renderAction.doAction();
			else if (derenderAction.processing)
				derenderAction.doAction();
		}
		
		/**
		 * Add the note sprites to this block.
		 * @param	noteSpriteFactory
		 */
		public function render():void {
			if (rendered)
				return;
			rendered = true;
			renderAction.start(_notes.length / 10);
			derenderAction.stop();
		}
		
		private function continueRender(startIndex:int, endIndex:int):Boolean {
			var index:int;
			for (index = startIndex; index < endIndex && index < _notes.length; index++) {
				
				var note:Note = _notes[index];
				
				//If the sprite isn't null, it's already rendered.
				//This can happen if a rendering call is made mid-derender.
				if (note.sprite == null) {
					
					//Create note image
					var noteSprite:NoteSprite = noteSpriteFactory.create(note);
					
					//Choose which line
					var yPosition:int = 0;
					if (note.letter == Note.NOTE_F) {
						yPosition = (1 / 5) * MusicArea.HEIGHT;
					}
					if (note.letter == Note.NOTE_D) {
						yPosition = (2 / 5) * MusicArea.HEIGHT;
					}
					if (note.letter == Note.NOTE_S) {
						yPosition = (3 / 5) * MusicArea.HEIGHT;
					}
					if (note.letter == Note.NOTE_A) {
						yPosition = (4 / 5) * MusicArea.HEIGHT;
					}
					
					//Place the note
					this.addChild(noteSprite);
					noteSprite.x = note.time * MusicArea.POSITION_SCALE;
					noteSprite.y = yPosition;
				}
			}
			if (index >= _notes.length)
				return false;
			else
				return true;
		}
		
		/**
		 * Remove the note sprites from this block.
		 * @param	noteSpriteFactory
		 */
		public function derender():void {
			if (!rendered)
				return;
			rendered = false;
			derenderAction.start(_notes.length / 10);
			renderAction.stop();
		}
		
		private function continueDerender(startIndex:int, endIndex:int):Boolean {
			
			var index:int;
			for (index = startIndex; index < endIndex && index < _notes.length; index++) {
				var sprite:NoteSprite = _notes[index].sprite;
				
				//If sprite is null, it wasn't rendered.
				//This can happen if a derendering call was made mid-render.
				if (sprite != null) {
					this.removeChild(sprite);
					noteSpriteFactory.destroy(sprite);
				}
			}
			if (index >= _notes.length)
				return false;
			else
				return true;
		}
		
		/**
		 * Searches for a matching note, and hits it if one is found.
		 * @param	letter the letter to search for
		 * @param	time the approximate time to search for
		 * @return  the hit note, or null if none was found
		 */
		public function findHit(letter:int, time:Number, repeater:Repeater):Note {
			var out:Note = null;
			
			for (var i:int = index; i < _notes.length; i++) {
				var note:Note = _notes[i];
				
				if (note.letter == letter && !note.isHit()
						&& Math.abs(note.time - time) < GameUI.HIT_TOLERANCE) {
							
					note.hit(repeater);
					
					out = note;
					
					break;
					
					//Skip the rest once we're clearly past where a hit might be.
				} else if (note.time - time > GameUI.HIT_TOLERANCE) {
					break;
				}
			}
			
			return out;
		}
		
		/**
		 * Miss notes that are too late to be hit.
		 * @param	time the current time, the actual cutoff time is slightly less
		 * @return  whether a note was missed
		 */
		public function missUntil(time:Number, repeater:Repeater):Boolean {
			var noteMissed:Boolean = false;
			
			var cutOffTime:Number = time - GameUI.HIT_TOLERANCE - 50; //Extra, just to be sure.
			
			while (index < _notes.length && _notes[index].time < cutOffTime) {
				var note:Note = _notes[index];
				
				if (!note.isHit()) {
					note.miss(repeater);
					noteMissed = true;
				}
				
				index++;
			}
			
			return noteMissed;
		}
		
		/**
		 * Cut trailing holds from the end of this block.
		 */
		public function cut():void {
			for each (var note:TrimmedNote in trimmable) {
				note.trim();
			}
		}
		
		/**
		 * Reextend trailing holds over the end of this block.
		 */
		public function uncut():void {
			for each (var note:TrimmedNote in trimmable) {
				note.unTrim();
			}
		}
		
	}

}