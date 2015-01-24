package src {
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Actor 
	{
		protected var _sprite : ActorSprite;
		
		protected var status : int;
		protected var position : Number
		protected var hitpoints : int;
		
		protected var isPlayerPiece : Boolean;
		
		protected var speed : Number; // pxl/s
		
		protected var movement : TweenLite;
		
		public function Actor() 
		{
			//Defaults
			this.sprite = null;
			
			this.status = 0;
			this.hitpoints = 10;
			this.isPlayerPiece = false;
			this.speed = 10;
		}
		
		public function get sprite() : Sprite {
			return _sprite;
		}
		
		/**
		 * Override this method.
		 * @param	others target actor
		 */
		public function reactToTargets(others : Vector.<Actor>) {
			
		}
		
		/**
		 * Override this method.
		 */
		public function get isDead() : Boolean {
			return (hitpoints <= 0);
		}
		
		public function getPosition() : Number {
			return sprite.x;
		}
		
		public function go() : void {
			if (isPlayerPiece) {
				var distance : Number = sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : 0 } );
			} else {
				var distance : Number = MainArea.ARENA_WIDTH - sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : MainArea.ARENA_WIDTH } );
			}
		}
		
		public function halt() : void {
			movement.kill();
		}
	}

}