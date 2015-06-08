package src 
{
	/**
	 * Note that can be adjusted to be smaller.
	 * WARNING: this class expects the initial note to be a hold.
	 */
	public class TrimmedNote 
	{
		private var note:Note;
		private var staysHold:Boolean;
		
		private var newEndTime:Number;
		private var oldEndTime:Number;
		
		/**
		 * Create a trimmable note.
		 * @param	note The note to trim. This MUST be a hold.
		 * @param	staysHold Whether the note should stay a hold when trimmed, or become just a note.
		 * @param	newEndTime If the note stays a hold, the end time to trim to.
		 */
		public function TrimmedNote(note:Note, staysHold:Boolean, newEndTime:Number = 0.0) 
		{
			this.note = note;
			this.staysHold = staysHold;
			
			if (staysHold)
				this.newEndTime = newEndTime;
			else
				this.newEndTime = note.time;
				
			this.oldEndTime = note.endtime;
		}
		
		/**
		 * Trims the hold. If the hold becomes a note, the end time will be set
		 * to the same as the start time.
		 */
		public function trim():void {
			if (!staysHold) {
				note.isHold = false;
			}
			
			note.endtime = newEndTime;
			
			if (note.sprite != null)
				note.sprite.refresh();
		}
		
		/**
		 * Restore the hold to its orginal state.
		 */
		public function unTrim():void {
			note.isHold = true;
			
			note.endtime = oldEndTime;
			
			if (note.sprite != null)
				note.sprite.refresh();
		}
		
	}

}