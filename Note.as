package
{
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Note
	{
		public static const NOTE_A:int = 0;
		public static const NOTE_S:int = 1;
		public static const NOTE_D:int = 2;
		public static const NOTE_F:int = 3;
		
		private var _letter:int;
		private var _time:Number;
		private var _isHold:Boolean;
		private var _endtime:Number;
		
		public function Note(letter:int, time:Number, isHold:Boolean = false, endtime:Number = 0.0)
		{
			_letter = letter;
			_time = time;
			_isHold = isHold;
			_endtime = endtime;
		}
		
		public function get letter():int 
		{
			return _letter;
		}
		
		public function get time():Number 
		{
			return _time;
		}
		
		public function get isHold():Boolean 
		{
			return _isHold;
		}
		
		public function get endtime():Number 
		{
			return _endtime;
		}
	
	}

}