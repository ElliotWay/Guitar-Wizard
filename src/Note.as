package src
{
	import flash.display.Sprite;
	
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
		
		public function Note() {
			letter = -1;
			time = 0.0;
			isHold = false;
			endtime = 0.0;
		}
		
		public function setSprite(sprite:NoteSprite):void {
			associatedSprite = sprite;
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
		
		public function get sprite():NoteSprite {
			return associatedSprite;
		}
		
		//The following methods weren't originally intended to exist;
		//the user was supposed to call sprite and use that,
		//but, as a result of refactoring, these became more convenient.
		
		/**
		 * Notes themselves aren't hit, but the sprites can be.
		 * This forwards the method to the associated sprite,
		 * or does nothing if this note has none.
		 */
		public function hit():void {
			if (associatedSprite != null)
				associatedSprite.hit();
		}
		
		/**
		 * Notes themselves aren't missed, but the sprites can be.
		 * This forwards the method to the associated sprite,
		 * or does nothing if this note has none.
		 */
		public function miss():void {
			if (associatedSprite != null)
				associatedSprite.miss();
		}
		
		/**
		 * Notes themselves aren't hit, but the sprites can be.
		 * This checks whether the sprite associated with this note was hit,
		 * or returns false if this note has no associate sprite.
		 */
		public function isHit():Boolean {
			if (associatedSprite != null)
				return associatedSprite.isHit();
			return false;
		}
	
	}

}