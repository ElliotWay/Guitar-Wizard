package src {
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
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
		
		/**
		 * Find the closest actor in a list of actor to this actor,
		 * within the maximum distance. Returns null if there are no actors in range.
		 * @param	others  the list of other actors to search
		 * @param	maxDistance  the maximum distance away the other actor can be
		 */
		public function getClosest(others:Vector.<Actor>, maxDistance:Number):Actor {
			if (others.length == 0)
				return null;
			
			var closest : Actor = others[0];
			var closeDistance : Number = Math.abs(closest.getPosition().x - this.getPosition().x);
			var distance : Number;
			
			for each(var other:Actor in others) {
				if (other.isValidTarget()) {
					distance = Math.abs(other.getPosition().x - this.getPosition().x);
					
					if (distance < closeDistance) {
						closest = other;
						closeDistance = distance;
					}
				}
			}
			
			if (closeDistance > maxDistance)
				closest = null;
			
			return closest;
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
		 * Gets the point at the center of the actor.
		 * @return the center of the actor
		 */
		public function getPosition():Point {
			return _sprite.center
		}
		
		/**
		 * TODO change this method
		 * @param	position
		 */
		public function setPosition(position:Number):void {
			_sprite.y = (Y_POSITION - _sprite.height);
			
			_sprite.x = position;
			
			updateMiniMap();
		}
		
		public function getHitBox():Rectangle {
			return _sprite.hitBox;
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