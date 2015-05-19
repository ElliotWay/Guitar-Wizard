package src {
	import com.greensock.easing.Linear;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
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
		
		public static const DEFUALT_SPEED:int = 50; //pxl/s
		public static const DEFAULT_MAX_HP:int = 10;
		public static const DEFAULT_MELEE_RANGE:int = 15; //pxl
		public static const DEFAULT_BASE_MELEE_DAMAGE:int = 2;
		
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
		
		protected var maxHitpoints:int;
		
		protected var isPlayerPiece : Boolean;
		protected var _facesRight:Boolean;
		
		
		private var _hitpoints:Number;
		
		private var _isDead:Boolean;
		
		private var movement : TweenLite;
		
		private var fightingTimer:Timer;
		private var meleeTarget:Actor;
		private var attackLocked:Boolean;
		
		private var willBeBlessed:Boolean;
		private var blessCounter:int;
		
		private var fading:TweenLite;
		private var deathCallback:Function;
		
		public static function resetPlayerBuff():void {
			player_buff = 1.0;
		}
		public static function buffPlayers():void {
			player_buff += buff_change;
			trace("current buff: " + player_buff);
		}
		
		/**
		 * Don't use this constructor; use ActorFactory instead.
		 */
		public function Actor() 
		{
			maxHitpoints = 10;
		}
		
		/**
		 * Return the actor to it's original state, ie alive, with hitpoints, etc.
		 * Extend this method to set hitpoints to a number besides 10.
		 */
		factory function restore():void {
			_status = Status.STANDING;
			
			_isDead = false;
			
			blessCounter = 0;
			willBeBlessed = false;
			
			_hitpoints = maxHP;
			
			attackLocked = false;
		}
		
		factory function setOrientation(owner:int, facing:int):void {
			isPlayerPiece = (owner == PLAYER);
			_facesRight = (facing == RIGHT_FACING);
		}
		
		factory function setSprite(sprite:ActorSprite):void {
			_sprite = sprite;
		}
		
		factory function setMiniSprite(miniSprite:MiniSprite):void {
			_miniSprite = miniSprite;
		}
		
		/**
		 * Override this to set a different speed.
		 */
		protected function get speed():int {
			return DEFUALT_SPEED;
		}
		
		/**
		 * Override this to set a different amount of hitpoints at full health.
		 */
		protected function get maxHP():int {
			return DEFAULT_MAX_HP;
		}
		
		/**
		 * Override this to set a different default range at which melee will continue.
		 */
		protected function get meleeRange():int {
			return DEFAULT_MELEE_RANGE;
		}
		
		/**
		 * Override this to set a different amount of damage each melee attack.
		 * This value is before multiplying by the current player_buff.
		 */
		protected function get baseMeleeDamage():int {
			return DEFAULT_BASE_MELEE_DAMAGE;
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
		public function get isDead():Boolean {
			return _isDead;
		}
		
		/**
		 * Override this to handle attack locking differently.
		 */
		public function get isAttackLocked():Boolean {
			return attackLocked;
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
		public function isValidTarget(other:Actor):Boolean {
			if (other.status == Status.DYING)
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
		 * @param   unlockedForMelee if the other actor must be unlocked for melee
		 */
		public function getClosest(others:Vector.<Actor>, maxDistance:Number,
				unlockedForMelee:Boolean = true):Actor {
			
			if (others.length <= 0)
				return null;
			
			var closest:Actor = null;
			var closeDistance:Number = maxDistance;
			var distance:Number;
			
			var other:Actor;
			for each (other in others) {
				
				if (isValidTarget(other) && (unlockedForMelee ? !other.isAttackLocked : true)) {
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
		
		/** TODO change this so more value are set by constants instead of passed as arguments?
		 * Stops moving and starts attacking the other actor.
		 * Attacks immediately, then may repeatedly if the actor is within range and a valid target when the next blow occurs.
		 * @param	other the actor to attack
		 * @param	damage the damage after buff to the other's hitpoints each blow should do
		 * @param	timeBetweenBlows time before the next range comparison and attack
		 */
		public function meleeAttack(other:Actor, timeBetweenBlows:Number, repeater:Repeater):void {
			halt();
			_status = Status.FIGHTING;
			_sprite.animate(Status.FIGHTING, repeater);
			
			meleeTarget = other;
			meleeTarget.lockAttack();
			meleeTarget.hit(isPlayerPiece ? baseMeleeDamage * player_buff : baseMeleeDamage);
			
			fightingTimer = new Timer(timeBetweenBlows, 0);
			fightingTimer.addEventListener(TimerEvent.TIMER, continueMelee);
					
			fightingTimer.start();
			
			if (other is Shield) {
				trace("attack shield: time between blows: " + timeBetweenBlows);
			}
		}
		
		private function continueMelee(event:Event):void {
			if (withinRange(meleeTarget, meleeRange) && isValidTarget(meleeTarget)) {
				meleeTarget.hit(isPlayerPiece ? baseMeleeDamage * player_buff : baseMeleeDamage);
			} else {
				_status = Status.STANDING;
				
				fightingTimer.stop();
				fightingTimer = null;
				
				meleeTarget.unlockAttack();
				meleeTarget = null;
					
				//The fighting animation ideally continues smoothly if there
				//is another target in range.
			}
		}
		
		protected function lockAttack():void {
			if (attackLocked) {
				throw new GWError("Attack already locked.");
			} else {
				attackLocked = true;
			}
		}
		
		protected function unlockAttack():void {
			attackLocked = false;
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
		 * @param	remove function to call once the actor has finished dying, should the actor die.
		 * 		This function should take the actor as an argument.
		 */
		public function checkIfDead(repeater:Repeater, afterDead:Function = null):void {
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
				deathCallback = afterDead;
				_sprite.animate(Status.DYING, repeater, fadeOut);
			}
		}
		
		private function fadeOut():void {
			//It's possible that we needed to quit in the middle of the dying animation,
			//in which case this actor no longer has the sprite.
			if (_sprite != null)
				fading = new TweenLite(_sprite, 5, { tint : 0xB0D090,
						onComplete:finishDying});
		}
		
		private function finishDying():void {
			fading.kill();
			fading = null;
			
			deathCallback.call(null, this);
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
			
			if (movement != null) {
				movement.kill();
				movement = null;
			}
				
			if (fightingTimer != null) {
				fightingTimer.stop();
				fightingTimer = null;
			}
				
			if (fading != null) {
				fading.restart(); //Restore the sprite to unfaded.
				fading.kill();
				fading = null;
			}
			
			deathCallback = null;
			meleeTarget = null;
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