package src 
{
	import flash.display.Sprite;
	
	/**
	 * A block of notes, both visually and numerically,
	 * so the appearance of notes can be more easily changed at the same time as
	 * their underlying model.
	 */
	public class NoteBlock extends Sprite 
	{
		private var _notes:Vector.<Note>;
		private var index:int;

		private var trimmable:Vector.<TrimmedNote>;
		
		/**
		 * Create a block of notes from a vector of notes.
		 * @param	notes  the notes to use to create this block
		 * @param	blockEnd the time of the end of this block
		 */
		public function NoteBlock(notes:Vector.<Note>, blockEnd:Number) 
		{
			super();
			
			_notes = notes.concat();
			index = 0;
			
			var lastF:Note = null;
			var lastD:Note = null;
			var lastS:Note = null;
			var lastA:Note = null;
			
			for each(var note:Note in notes) {
					
				//Create note image
				var noteSprite:NoteSprite = new NoteSprite(note);
				
				//Choose which line
				var yPosition:int = 0;
				if (note.letter == Note.NOTE_F) {
					yPosition = (1 / 5) * MusicArea.HEIGHT;
					lastF = note;
				}
				if (note.letter == Note.NOTE_D) {
					yPosition = (2 / 5) * MusicArea.HEIGHT;
					lastD = note;
				}
				if (note.letter == Note.NOTE_S) {
					yPosition = (3 / 5) * MusicArea.HEIGHT;
					lastS = note;
				}
				if (note.letter == Note.NOTE_A) {
					yPosition = (4 / 5) * MusicArea.HEIGHT;
					lastA = note;
				}
				
				//Place the note
				this.addChild(noteSprite);
				noteSprite.x = note.time * MusicArea.POSITION_SCALE;
				noteSprite.y = yPosition;
			}
			
			//The notes at the very end may be candidates for trimming.
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
		
		/**
		 * Searches for a matching note, and hits it if one is found.
		 * @param	letter the letter to search for
		 * @param	time the approximate time to search for
		 * @return  the hit note, or null if none was found
		 */
		public function findHit(letter:int, time:Number):Note {
			for (var i:int = index; i < _notes.length; i++) {
				var note:Note = _notes[i];
				
				if (note.letter == letter && !note.isHit()
						&& Math.abs(note.time - time) < GameUI.HIT_TOLERANCE) {
							
					note.hit();
					
					return note;
					
					//Skip the rest once we're clearly past where a hit might be.
				} else if (note.time - time > GameUI.HIT_TOLERANCE) {
					return null;
				}
			}
			
			//There were no matches, so return null.
			return null;
		}
		
		/**
		 * Miss notes that are too late to be hit.
		 * @param	time the current time, the actual cutoff time is slightly less
		 * @return  whether a note was missed
		 */
		public function missUntil(time:Number):Boolean {
			var noteMissed:Boolean = false;
			
			var cutOffTime:Number = time - GameUI.HIT_TOLERANCE - 50; //Extra, just to be sure.
			
			while (index < _notes.length && _notes[index].time < cutOffTime) {
				var note:Note = _notes[index];
				
				if (!note.isHit()) {
					note.miss();
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