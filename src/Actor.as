package src {
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Actor 
	{
		
		public static const Y_POSITION:int = 200;
		
		protected var _sprite : ActorSprite;
		
		protected var position : Number
		protected var _hitpoints : int;
		
		protected var isPlayerPiece : Boolean;
		
		protected var speed : Number; // pxl/s
		
		protected var movement : TweenLite;
		
		public function Actor() 
		{
			//Defaults
			_sprite = null;
			
			_hitpoints = 10;
			isPlayerPiece = false;
			speed = 30;
			
		}
		
		public function get sprite() : Sprite {
			return _sprite;
		}
		
		/**
		 * Override this method.
		 * @param	others target actor
		 */
		public function reactToTargets(others : Vector.<Actor>):void {
			
		}
		
		/**
		 * Override this method if necessary.
		 */
		public function get isDead() : Boolean {
			return (_hitpoints <= 0);
		}
		
		/**
		 * And this one.
		 */
		public function isValidTarget() : Boolean {
			return true;
		}
		
		public function get hitpoints():int 
		{
			return _hitpoints;
		}
		
		public function set hitpoints(value:int):void 
		{
			_hitpoints = value;
		}
		
		public function getPosition() : Number {
			return _sprite.x;
		}
		
		public function setPosition(position:Number):void {
			_sprite.y = Y_POSITION;
			_sprite.x = position;
		}
		
		public function go() : void {
			var distance:Number;
			if (isPlayerPiece) {
				distance = MainArea.ARENA_WIDTH - _sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : MainArea.ARENA_WIDTH, ease:Linear.easeInOut } );
			} else {
				distance = _sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : 0, ease:Linear.easeInOut} );
			}
		}
		
		public function halt() : void {
			movement.kill();
		}
	}

}