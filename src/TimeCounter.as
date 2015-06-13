package src 
{
	import flash.utils.getTimer;
	/**
	 * A wrapper for the getTimer() function.
	 * I'm using this to make testing easier, as it's hard to test with a static function.
	 */
	public class TimeCounter 
	{
		
		public function TimeCounter() 
		{
			;
		}
		
		/**
		 * Get the current time, in milliseconds.
		 */
		public function getTime():uint {
			return getTimer();
		}
		
	}

}