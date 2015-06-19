package src 
{
	/**
	 * Groups together a tempo and the number of the beat on which to make the change.
	 */
	public class TempoChange 
	{
		/**
		 * The tempo to change to in milliseconds per beat.
		 */
		public var millisecondsPerBeat:int;
		
		/**
		 * The beat on which to change the tempo. Beats after and including this beat
		 * should have this tempo.
		 */
		public var beatNumber:int;
		
		public function TempoChange(millisecondsPerBeat:int, beatNumber:int) 
		{
			this.millisecondsPerBeat = millisecondsPerBeat;
			this.beatNumber = beatNumber;
		}
		
	}

}