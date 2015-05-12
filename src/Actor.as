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
	
	
	TweenPlugin.activate([TintPlugin]);
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Actor
	{
		public static const PLAYER:int = 0;
		public static const OPPONENT:int = 1;
		
		public static const RIGHT_FACING:int = 0;
		public static const LEFT_FACING:int = 1;
		
		
		protected static var player_buff:Number = 1.0;
		private static var buff_change:Number = 0.0125;
		
		public static const Y_POSITION:int = 357;
		
		public static const MINI_Y_POSITION:int = 35;
		
		public static const BLESS_FRAMES:int = 300;
		public static const BLESS_FACTOR:Number = .30;
		
		/**
		 * If an actor is this close, they are already past.
		 */
		public static const TOO_CLOSE:int = 10;
		
		protected var _sprite : ActorSprite;
		protected var _miniSprite : MiniSprite;
		
		protected var _status:int;
		protected var _hitpoints:Number;
		
		protected var isPlayerPiece : Boolean;
		protected var _facesRight:Boolean;
		
		protected var speed : Number; // pxl/s
		
		protected var movement : TweenLite;
		
		private var fightingTimer:Timer;
		
		protected var fading:TweenLite;
		protected var _isDead:Boolean;
		
		protected var willBeBlessed:Boolean;
		protected var blessCounter:int;
		
		public static function resetPlayerBuff():void {
			player_buff = 1.0;
		}
		public static function buffPlayers():void {
			player_buff += buff_change;
			trace("current buff: " + player_buff);
		}
		
		
		public function Actor(playerPiece:Boolean, facesRight:Boolean, sprite:ActorSprite, miniSprite:MiniSprite) 
		{
			_sprite = sprite;
			_miniSprite = miniSprite;
			
			_hitpoints = 10;
			isPlayerPiece = playerPiece;
			this._facesRight = facesRight;
			speed = 50;
			
			_status = Status.STANDING;
			
			_isDead = false;
			
			blessCounter = 0;
			willBeBlessed = false;
		}
		
		/**
		 * Return the actor to it's original state, ie alive, with hitpoint, etc.
		 * Extend this method to set hitpoint to a number besides 10.
		 */
		factory function restore():void {
			_isDead = false;
			
			blessCounter = 0;
			willBeBlessed = false;
		}
		
		factory function setOrientation(owner:int, facing:int):void {
			isPlayerPiece = (owner == PLAYER);
			_facesRight = (facing == RIGHT_FACING);
		}
		
		factory function set sprite(sprite:ActorSprite):void {
			_sprite = sprite;
		}
		
		factory function set miniSprite(miniSprite:MiniSprite):void {
			_miniSprite = miniSprite;
		}
		
		public function get sprite():ActorSprite {
			return _sprite;
		}
		
		public function get miniSprite():MiniSprite {
			return _miniSprite;
		}
		
		public function get isPlayerActor():Boolean {
			return isPlayerPiece;
		}
		
		public function get facesRight():Boolean {
			return _facesRight;
		}
		
		public function get isBlessed():Boolean {
			return blessCounter > 0 || willBeBlessed;
		}
		
		public function get status():int {
			return _status;
		}
		
		/**
		 * Whether the actor has started dying and shoud not act.
		 * Override this method if necessary.
		 */
		public function get isDead() : Boolean {
			return _isDead;
		}
		
		/**
		 * Override this method.
		 * @param	allies friendly actors to help or ignore
		 * @param   enemies hostile actors to attack
		 */
		public function act(allies:Vector.<Actor>, enemies:Vector.<Actor>, repeater:Repeater):void {
			throw new GWError("Unimplemented abstract method.");
		}
		
		/**
		 * Returns false if the target is dying, or in the wrong direction.
		 */
		public function isValidTarget(other:Actor) : Boolean {
			if (other._status == Status.DYING)
				return false;
			
			if (facesRight) {
				return other.getPosition().x - this.getPosition().x > TOO_CLOSE;
			} else {
				return this.getPosition().x - other.getPosition().x > TOO_CLOSE;
			}
		}
		
		/**
		 * Find the closest <b>valid target</b> in a list of actors to this actor,
		 * within the maximum distance. Returns null if there are no actors in range.
		 * @param	others  the list of other actors to search
		 * @param	maxDistance  the maximum distance away the other actor can be
		 */
		public function getClosest(others:Vector.<Actor>, maxDistance:Number):Actor {
			if (others.length <= 0)
				return null;
			
			var closest:Actor = null;
			var closeDistance : Number = maxDistance;
			var distance : Number;
			
			var other:Actor;
			for each (other in others) {
				
				if (isValidTarget(other)) {
					distance = Math.abs(other.getPosition().x - this.getPosition().x);
					
					if (distance <= closeDistance) {
						closest = other;
						closeDistance = distance;
					}
				}
			}
			
			return closest;
		}
		
		public function hit(damage:Number):void {
			if (blessCounter > 0) {
				_hitpoints -= damage * (1 - BLESS_FACTOR);
			} else {
				_hitpoints -= damage;
			}
		}
		
		public function preBless():void {
			willBeBlessed = true;
		}
		
		public function bless():void {
			_sprite.showBlessed();
			blessCounter = BLESS_FRAMES;
			willBeBlessed = false;
		}
		
		
		/**
		 * Gets the point at the center of the actor.
		 * @return the center of the actor
		 */
		public function getPosition():Point {
			return _sprite.center;
		}
		
		/**
		 * Change the position of this actor.
		 * TODO change this function
		 * @param	position where to move the actor's sprite
		 */
		public function setPosition(position:Point):void {
			_sprite.y = position.y;
			
			_sprite.x = position.x;
			
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
			if (_status == Status.MOVING) {
				if (_facesRight) {
					return new Point(
							Math.min(position.x + (time * speed / 1000), MainArea.ARENA_WIDTH),
							position.y);
				} else {
					return new Point(
							Math.max(position.x - (time * speed / 1000), 0),
							position.y);
				}
			} else if (_status == Status.RETREATING) {
				if (_facesRight) {
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
		public function withinRange(other:Actor, range:Number):Boolean {
			return Math.abs(getPosition().x - other.getPosition().x) < range;
		}
		
		/**
		 * Stops moving and starts attacking the other actor.
		 * Attacks immediately, then may repeatedly if the actor is within range and a valid target when the next blow occurs.
		 * @param	other the actor to attack
		 * @param	range the melee range for this attack
		 * @param	damage the damage after buff to the other's hitpoints each blow should do
		 * @param	timeBetweenBlows time before the next range comparison and attack
		 */
		public function meleeAttack(other:Actor, range:Number, damage:Number, timeBetweenBlows:Number, repeater:Repeater):void {
			halt();
			_status = Status.FIGHTING;
			_sprite.animate(Status.FIGHTING, repeater);
			
			other.hit(damage);
			
			fightingTimer = new Timer(timeBetweenBlows, 0);
			fightingTimer.addEventListener(TimerEvent.TIMER, function():void {
				//Check if we're still in range, and the target is still valid.
				if (withinRange(other, range) && isValidTarget(other)) {
					other.hit(damage);
				} else {
					_status = Status.STANDING;
					
					fightingTimer.stop();
					fightingTimer = null;
					
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
		public function go(repeater:Repeater) : void {
			halt();
			
			var realSpeed:Number = speed;
			if (isPlayerActor)
				realSpeed *= player_buff;
			
			_status = Status.MOVING;
			_sprite.animate(Status.MOVING, repeater);
			
			var distance:Number;
			if (_facesRight) {
				distance = MainArea.ARENA_WIDTH - _sprite.x;
				movement = new TweenLite(sprite, distance / realSpeed, { x:MainArea.ARENA_WIDTH, ease:Linear.easeInOut } );
			} else {
				distance = _sprite.x + 30;
				movement = new TweenLite(sprite, distance / realSpeed, { x:-30, ease:Linear.easeInOut} );
			}
		}
		
		/**
		 * Starts the sprite moving in the opposite direction.
		 * Updates status and animation to RETREATING.
		 */
		public function retreat(repeater:Repeater):void {
			halt();
			
			var realSpeed:Number = speed;
			if (isPlayerActor)
				realSpeed *= player_buff;
				
			_status = Status.RETREATING;
			_sprite.animate(Status.RETREATING, repeater);
			
			var distance:Number;
			if (!_facesRight) {
				distance = MainArea.ARENA_WIDTH - _sprite.x;
				movement = new TweenLite(sprite, distance / realSpeed, { x : MainArea.ARENA_WIDTH, ease:Linear.easeInOut } );
			} else {
				distance = _sprite.x;
				movement = new TweenLite(sprite, distance / realSpeed, { x : 0, ease:Linear.easeInOut} );
			}
		}
		
		/**
		 * Checks if hitpoints is below 0.
		 * If we're dead, sets status and animation to DYING.
		 * 
		 * @param	repeater timing control for potential dying animation.
		 * @param	remove function to call once the actor has finished dying, if necessary.
		 * 		This function should take the actor as an argument.
		 */
		public function checkIfDead(repeater:Repeater, afterDead:Function):void {
			//TODO put this somewhere else
			blessCounter--;
			if (blessCounter == 0) {
				_sprite.hideBlessed();
			}
			
			
			if (_hitpoints <= 0) {
				halt();
				clean();
				
				_sprite.moveToBottom();
				
				_status = Status.DYING;
				_isDead = true;
				_sprite.animate(Status.DYING, repeater, afterDead, [this]);
			}
		}
		
		/**
		 * Stop moving.
		 */
		public function halt() : void {
			if (movement != null)
				movement.kill();
		}
		
		/**
		 * Stops all animations, so they're not leaking memory somewhere.
		 * Override this method if an actor has its own animations.
		 * Use unload to completely stop this actor.
		 */
		public function clean():void {
			if (movement != null)
				movement.kill();
			if (fading != null)
				fading.kill();
				
			if (fightingTimer != null)
				fightingTimer.stop();
				
			//TODO needed?
			//_sprite.freeze();
		}
		
		/**
		 * Dereferences the sprites of this actor, but otherwise leaves them untouched.
		 * Calls clean() first (so you don't have to call clean as well).
		 * Don't use the actor after calling this method.
		 */
		public function dispose():void {
			clean();
			
			_miniSprite = null;
			_sprite = null;
		}
	}

}