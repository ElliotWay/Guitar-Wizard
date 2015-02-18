package src 
{
	import com.greensock.easing.Linear;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author ...
	 */
	public class Assassin extends DefaultActor 
	{
		//pixels
		public static const MAX_JUMP_DISTANCE:int = 400;
		
		public static const MIN_JUMP_DISTANCE:int = 300;
		
		public static const MELEE_RANGE:int = 30;
		
		private var jumping:TweenLite;
		
		private var fightingTimer:Timer;
		
		public function Assassin(isPlayerPiece:Boolean) 
		{
			super(isPlayerPiece);
			
			this.speed = 300;
			this.damage = 0; //5
		}
		
		override public function createSprites(isPlayerPiece:Boolean):void {
			this._sprite = new AssassinSprite(isPlayerPiece ? true : false);
			this._miniSprite = new SmallSquareSprite((isPlayerPiece) ? (0x0000FF) : (0xFF0000));
		}
		
		override public function reactToTargets(others:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (status == Status.DYING) {
				if (dying.progress() == 1)
					_isDead = true;
				return;
			}
			
			
			//Do other stuff.
			
			if (status != Status.ASSASSINATING && status != Status.FIGHTING) {
				
				
				
			//Check whether any valid targets are available.
			var validOthers:Vector.<Actor> = 
				others.filter(function(actor:Actor, index:int, vector:Vector.<Actor>):Boolean {
					return actor.isValidTarget();
			});
			
			if (validOthers.length == 0) {
				if (status != Status.MOVING) {
					this.go();
					status = Status.MOVING;
					_sprite.animate(Status.MOVING);
				}
				return;
			}
			
			//Find the closest valid target.
			var closest:Actor = this.getClosest(validOthers, MAX_JUMP_DISTANCE * 2);
			
			var self:Assassin = this; //For use inside enclosures.
			
			if (closest != null && (status == Status.MOVING || status == Status.STANDING)) {
					
				var targetPositionAfterJump:Number =
						closest.predictPosition(AssassinSprite.TIME_TO_LAND);
						
				var targetAfterJumpDistance:Number =
						Math.abs(targetPositionAfterJump - this.getPosition().x);
						
				//Jump towards the target if they will be in range.
				if (MIN_JUMP_DISTANCE < targetAfterJumpDistance &&
						targetAfterJumpDistance < MAX_JUMP_DISTANCE &&
						!(closest is Assassin)) {
				
					this.halt();
					
					var targetPosition:Number = closest.predictPosition(AssassinSprite.TIME_TO_LAND);
					var landedX:Number = targetPosition +
							(isPlayerPiece ? -30 : 30) -
							AssassinSprite.CENTER.x;
						
					status = Status.ASSASSINATING;
						
					_sprite.animate(Status.ASSASSINATING, function():void { 
						status = Status.STANDING;
					} );
					
					var landedTimer:Timer = new Timer(AssassinSprite.TIME_TO_LAND, 1);
					landedTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
						if (Math.abs(self.getPosition().x - closest.getPosition().x)
								< MELEE_RANGE)
							closest.hitpoints -= damage;
					});
					landedTimer.start();
					
					jumping = new TweenLite(_sprite, AssassinSprite.TIME_TO_LAND / 1000,
							{ x:landedX, ease:Linear.easeInOut } );
				} else if (Math.abs(this.getPosition().x - closest.getPosition().x)	< MELEE_RANGE) {
					halt();
			
					status = Status.FIGHTING;
					_sprite.animate(Status.FIGHTING);
					
					closest.hitpoints -= damage;
					
					fightingTimer = new Timer(AssassinSprite.TIME_BETWEEN_STABS, 0);
					fightingTimer.addEventListener(TimerEvent.TIMER, function():void {
						//Check if we're still in range, and the target is still valid.
						if (Math.abs(self.getPosition().x - closest.getPosition().x) < MELEE_RANGE &&
									closest.isValidTarget()) {
							closest.hitpoints -= damage;
						} else {
							status = Status.STANDING;
							
							fightingTimer.stop();
							
							//The fighting animation ideally continues smoothly if there
							//ia another target in range.
						}
					});
					
					fightingTimer.start();
				} else {
					if (status != Status.MOVING) {
						this.go();
						status = Status.MOVING;
						_sprite.animate(Status.MOVING);
					}
				}
			}  else {
				if (status != Status.MOVING)
					this.go();
					
				status = Status.MOVING;
				_sprite.animate(Status.MOVING);
			}
			
			
			
			}//End of check for ongoing status.
			
			//Check if we're dying. Actors can interact while dying, otherwise player actors
			//would get an advantage.
			if (this._hitpoints <= 0) {
				status = Status.DYING;
				_sprite.animate(Status.DYING);
				this.halt();
				
				TweenPlugin.activate([TintPlugin]);
				this.dying = new TweenLite(sprite, 10, { tint : 0x000000 } );
			}
		}
		
		
		override public function clean():void {
			super.clean();
			
			if (jumping != null)
				jumping.kill();
		}
	}

}