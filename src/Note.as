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
		private var _time:Number;	//TODO make these private again later
		private var _isHold:Boolean;
		private var _endtime:Number;
		
		public var associatedSprite:NoteSprite;
		public var _isHit:Boolean; //TODO consider removing _isHit later. Remove this reference, then check for errors.
		
		
		public function Note() {
			letter = -1;
			time = 0.0;
			isHold = false;
			endtime = 0.0;
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
		
		public function set endtime(value:Number):void 
		{
			_endtime = value;
		}
		
		public function set isHold(value:Boolean):void 
		{
			_isHold = value;
		}
		
		public function set time(value:Number):void 
		{
			_time = value;
		}
		
		public function set letter(value:int):void 
		{
			_letter = value;
		}
	
	}

}