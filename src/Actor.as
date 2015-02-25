package src {
	import com.greensock.easing.Linear;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Actor
	{
		
		public static const Y_POSITION:int = 300;
		
		public static const MINI_Y_POSITION:int = 35;
		
		protected var _sprite : ActorSprite;
		protected var _miniSprite : MiniSprite;
		
		protected var status:int;
		protected var _hitpoints : int;
		
		protected var isPlayerPiece : Boolean;
		
		protected var speed : Number; // pxl/s
		
		protected var movement : TweenLite;
		
		private var fightingTimer:Timer;
		
		protected var fading:TweenLite;
		
		protected var _isDead:Boolean;
		
		public function Actor(playerPiece:Boolean, sprite:ActorSprite, miniSprite:MiniSprite) 
		{
			_sprite = sprite;
			_miniSprite = miniSprite;
			
			_hitpoints = 10;
			isPlayerPiece = playerPiece;
			speed = 50;
			
			status = Status.STANDING;
			sprite.animate(Status.STANDING);
			
			_isDead = false;
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
			return _isDead;
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
		
		/**
		 * Estimate the position of this actor an amount of time into the future.
		 * Predicts based on speed if status is MOVING or RETREATING, or assumes no motion otherwise.
		 * Override if a new status involves motion.
		 * @param	time the number of milliseconds from now to estimate the postion
		 */
		public function predictPosition(time:Number):Point {
			var position:Point = this.getPosition();
			if (status == Status.MOVING) {
				if (isPlayerPiece) {
					return new Point(
							Math.min(position.x + (time * speed / 1000), MainArea.ARENA_WIDTH),
							position.y);
				} else {
					return new Point(
							Math.max(position.x - (time * speed / 1000), 0),
							position.y);
				}
			} else if (status == Status.RETREATING) {
				if (isPlayerPiece) {
					return new Point(
							Math.max(position.x - (time * speed / 1000), 0),
							position.y);
				} else {
					return new Point(
							Math.min(position.x + (time * speed / 1000), MainArea.ARENA_WIDTH),
							position.y);
				}
			} else {
				return position;
			}
		}
		
		/**
		 * Checks if another actor is within a given range.
		 * Only considers x coordinates; if an actor is flying, this may not be accurate.
		 * @param	other the other actor to check
		 * @param	range the range within which to check for the actor
		 * @return  whether the other actor was within the range
		 */
		protected function withinRange(other:Actor, range:Number):Boolean {
			return Math.abs(getPosition().x - other.getPosition().x) < range;
		}
		
		/**
		 * Stops moving and starts attacking the other actor.
		 * Attacks immediately, then may repeatedly if the actor is within range and a valid target when the next blow occurs.
		 * @param	other the actor to attack
		 * @param	range the melee range for this attack
		 * @param	damage the damage to the other's hitpoints each blow should do
		 * @param	timeBetweenBlows time before the next range comparison and attack
		 */
		protected function meleeAttack(other:Actor, range:Number, damage:Number, timeBetweenBlows:Number):void {
			halt();
			
			status = Status.FIGHTING;
			_sprite.animate(Status.FIGHTING);
			
			other.hitpoints -= damage;
			
			fightingTimer = new Timer(timeBetweenBlows, 0);
			fightingTimer.addEventListener(TimerEvent.TIMER, function():void {
				//Check if we're still in range, and the target is still valid.
				if (withinRange(other, range) && other.isValidTarget()) {
					other.hitpoints -= damage;
				} else {
					status = Status.STANDING;
					
					fightingTimer.stop();
					
					//The fighting animation ideally continues smoothly if there
					//is another target in range.
				}
			});
					
			fightingTimer.start();
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
		 * Updates status and animation to MOVING.
		 */
		public function go() : void {
			halt();
			
			status = Status.MOVING;
			_sprite.animate(Status.MOVING);
			
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
		 * Updates status and animation to RETREATING.
		 */
		public function retreat():void {
			halt();
			
			status = Status.RETREATING;
			_sprite.animate(Status.RETREATING);
			
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
		 * Checks if hitpoints is below 0.
		 * If we're dead, sets status and animation to DYING.
		 */ 
		public function checkIfDead():void {
			if (_hitpoints <= 0) {
				halt();
				clean();
				
				status = Status.DYING;
				_sprite.animate(Status.DYING, function():void { _sprite.freeze(); } );
				
				TweenPlugin.activate([TintPlugin]);
				this.fading = new TweenLite(sprite, 10, { tint : 0x000000,
						onComplete:function():void { _isDead = true; } } );
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
			if (movement != null)
				movement.kill();
			if (fading != null)
				fading.kill();
				
			if (fightingTimer != null)
				fightingTimer.stop();
		}
	}

}