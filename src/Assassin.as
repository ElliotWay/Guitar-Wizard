package src 
{
	import com.greensock.easing.Linear;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author ...
	 */
	public class Assassin extends Actor
	{
		//pixels
		public static const MAX_JUMP_DISTANCE:int = 400;
		
		public static const MIN_JUMP_DISTANCE:int = 300;
		
		public static const APPROX_JUMPING_SPEED:int =
				((MAX_JUMP_DISTANCE + MIN_JUMP_DISTANCE) / 2) /
				AssassinSprite.TIME_TO_LAND;
		
		public static const MELEE_RANGE:int = 30;
		
		private var jumping:TweenLite;
		
		private var fightingTimer:Timer;
		
		private var landedTimer:Timer;
		private var jumpTarget:Number;
		
		private var damage:Number;
		
		public function Assassin(isPlayerPiece:Boolean) 
		{
			super(isPlayerPiece,
					new AssassinSprite(isPlayerPiece),
					new SmallSquareSprite(isPlayerPiece ? 0x0000FF : 0xFF0000));
			
			this.speed = 300;
			this.damage = 3; //5
		}
		
		override public function reactToTargets(others:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (status == Status.DYING) {
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
				}
				return;
			}
			
			//Find the closest valid target.
			var closest:Actor = this.getClosest(validOthers, MAX_JUMP_DISTANCE * 2);
			
			var self:Assassin = this; //For use inside enclosures.
			
			if (closest != null && (status == Status.MOVING || status == Status.STANDING)) {
					
				var targetPositionAfterJump:Number =
						closest.predictPosition(AssassinSprite.TIME_TO_LAND).x;
						
				var targetAfterJumpDistance:Number =
						Math.abs(targetPositionAfterJump - this.getPosition().x);
						
				//Jump towards the target if they will be in range.
				if (MIN_JUMP_DISTANCE < targetAfterJumpDistance &&
						targetAfterJumpDistance < MAX_JUMP_DISTANCE &&
						!(closest is Assassin)) {
				
					this.halt();
					
					var targetPosition:Number = closest.predictPosition(AssassinSprite.TIME_TO_LAND).x;
					var landedX:Number = targetPosition +
							(isPlayerPiece ? -30 : 30) -
							AssassinSprite.CENTER.x;
							
					jumpTarget = landedX;
						
					status = Status.ASSASSINATING;
						
					_sprite.animate(Status.ASSASSINATING, function():void { 
						status = Status.STANDING;
					} );
					
					landedTimer = new Timer(AssassinSprite.TIME_TO_LAND, 1);
					landedTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
						if (Math.abs(self.getPosition().x - closest.getPosition().x)
								< MELEE_RANGE)
							closest.hitpoints -= damage;
							
						landedTimer = null;
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
					}
				}
			}  else {
				if (status != Status.MOVING)
					this.go();
			}
			
			
			
			}//End of check for ongoing status.
			
			this.checkIfDead();
		}
		
		override public function isValidTarget():Boolean {
			return status != Status.DYING;
		}
		
		override public function predictPosition(time:Number):Point {
			if (status == Status.ASSASSINATING) {
				if ((1 - jumping.progress()) * AssassinSprite.TIME_TO_LAND < time) {
					return new Point(jumpTarget, _sprite.y);
				} else {
					if (isPlayerPiece)
						return new Point(_sprite.x + time * APPROX_JUMPING_SPEED, _sprite.y);
					else {
						return new Point(_sprite.x - time * APPROX_JUMPING_SPEED, _sprite.y);
					}
				}
			} else {
				return super.predictPosition(time);
			}
		}
		
		
		override public function clean():void {
			super.clean();
			
			if (jumping != null)
				jumping.kill();
				
			if (fightingTimer != null)
				fightingTimer.stop();
		}
	}

}