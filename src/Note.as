package src
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
		public var _time:Number;	//TODO make these private again later
		private var _isHold:Boolean;
		public var _endtime:Number;
		
		public var associatedSprite:NoteSprite;
		public var _isHit:Boolean; //TODO consider removing _isHit later. Remove this reference, then check for errors.
		
		public function Note(letter:int, time:Number, isHold:Boolean = false, endtime:Number = 0.0)
		{
			_letter = letter;
			_time = time;
			_isHold = isHold;
			_endtime = endtime;
		}
		
		public function setSprite(sprite:NoteSprite):void {
			associatedSprite = sprite;
			_isHit = false; //Wrong place to put this, but whenever the sprite is being set,
							//that also means the note hasn't been hit yet.
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