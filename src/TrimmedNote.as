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
		
		public function trim():void {
			if (!staysHold) {
				note.isHold = false;
			}
			
			note.endtime = newEndTime;
			
			note.sprite.refresh();
		}
		
		public function unTrim():void {
			note.isHold = true;
			
			note.endtime = oldEndTime;
			
			note.sprite.refresh();
		}
		
	}

}