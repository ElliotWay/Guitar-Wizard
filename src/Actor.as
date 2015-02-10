package src {
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Actor implements AbstractActor
	{
		
		public static const Y_POSITION:int = 200;
		
		public static const MINI_Y_POSITION:int = 35;
		
		protected var _sprite : ActorSprite;
		protected var _miniSprite : MiniSprite;
		
		protected var position : Number
		protected var _hitpoints : int;
		
		protected var isPlayerPiece : Boolean;
		
		protected var speed : Number; // pxl/s
		
		protected var movement : TweenLite;
		
		public function Actor(playerPiece:Boolean) 
		{
			createSprites(playerPiece);
			
			_hitpoints = 10;
			isPlayerPiece = playerPiece;
			speed = 50;
			
		}
		
		/**
		 * Creates the sprite and the minisprite.
		 * Override this function.
		 * @param	isPlayerPiece
		 */
		public function createSprites(isPlayerPiece:Boolean):void {
			throw new Error("Unimplemented abstract method");
		}
		
		public function get sprite() : Sprite {
			return _sprite;
		}
		
		public function get miniSprite():Sprite {
			return _miniSprite;
		}
		
		/**
		 * Override this method.
		 * @param	others target actor
		 */
		public function reactToTargets(others : Vector.<Actor>):void {
			//TODO create new error class
			throw new Error("Unimplemented abstract method.");
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
		
		/**
		 * Gets the x coordinate in the center of the actor.
		 * @return the center of the actor
		 */
		public function getPosition() : Number {
			return _sprite.x + (_sprite.width / 2);
		}
		
		public function setPosition(position:Number):void {
			_sprite.y = (Y_POSITION - _sprite.height);
			
			_sprite.x = position;
			
			updateMiniMap();
		}
		
		public function updateMiniMap():void {
			//Convert the sprites position to a position on the minimap.
			_miniSprite.y = (MINI_Y_POSITION - _miniSprite.height);
			_miniSprite.x = (_sprite.x / MainArea.ARENA_WIDTH) * MainArea.MINIMAP_WIDTH;
		}
		
		/**
		 * Starts the sprite moving, direction depending on ownership.
		 */
		public function go() : void {
			halt();
			
			var distance:Number;
			if (isPlayerPiece) {
				distance = MainArea.ARENA_WIDTH - _sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : MainArea.ARENA_WIDTH, ease:Linear.easeInOut } );
			} else {
				distance = _sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : 0, ease:Linear.easeInOut} );
			}
		}
		
		/**
		 * Starts the sprite moving in the opposite direction.
		 */
		public function retreat():void {
			halt();
			
			var distance:Number;
			if (!isPlayerPiece) {
				distance = MainArea.ARENA_WIDTH - _sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : MainArea.ARENA_WIDTH, ease:Linear.easeInOut } );
			} else {
				distance = _sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : 0, ease:Linear.easeInOut} );
			}
		}
		
		/**
		 * Stop moving. Also clears the animation for GC.
		 */
		public function halt() : void {
			if (movement != null)
				movement.kill();
		}
		
		/**
		 * Stops all animations, so they're not leaking memory somewhere.
		 * Override this method if an actor has its own animations
		 * (it probably does).
		 */
		public function clean():void {
			halt();
		}
	}

}