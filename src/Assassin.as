package src 
{
	import com.greensock.easing.Linear;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	use namespace factory;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Assassin extends Actor
	{
		
		public static const MAX_JUMP_DISTANCE:int = 200;//pixels
		
		public static const MIN_JUMP_DISTANCE:int = 150;
		
		public static const APPROX_JUMPING_SPEED:int =
				((MAX_JUMP_DISTANCE + MIN_JUMP_DISTANCE) / 2) /
				1200; //Approx time to land
		
		public static const MELEE_DAMAGE:int = 3;
		public static const MELEE_RANGE:int = 30;
		
		private var jumping:TweenLite;
		
		private var landedTimer:Timer;
		private var jumpTarget:Number;
		
		public function Assassin() 
		{
			
			this.speed = 150;
			this.maxHitpoints = 10;
		}
		
		/*override src.factory function restore():void {
			super.restore();
		}*/
		
		override public function act(allies:Vector.<Actor>, enemies:Vector.<Actor>, repeater:Repeater):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (_status == Status.DYING) {
				return;
			}
			
			//Do other stuff.
			
			if (_status != Status.ASSASSINATING && _status != Status.FIGHTING) {
				
				
			
			//Find the closest valid target.
			var closest:Actor = this.getClosest(enemies, MAX_JUMP_DISTANCE * 2);
			
			if (closest != null && (_status == Status.MOVING || _status == Status.STANDING)) {
			
				var targetPositionAfterJump:Number =
						closest.predictPosition(AssassinSprite.timeToLand(repeater)).x;
				
				if (isPlayerPiece) {
					if (MainArea.opponentShieldIsUp) {
						targetPositionAfterJump = Math.min(
								targetPositionAfterJump,
								MainArea.ARENA_WIDTH - MainArea.SHIELD_POSITION);
					}
				} else {
					if (MainArea.playerShieldIsUp) {
						targetPositionAfterJump = Math.max(
								targetPositionAfterJump,
								MainArea.SHIELD_POSITION);
					}
				}
						
				var targetAfterJumpDistance:Number =
						Math.abs(targetPositionAfterJump - this.getPosition().x);
						
			if (closest != null)
				//Jump towards the target if they will be in range.
				if (MIN_JUMP_DISTANCE < targetAfterJumpDistance &&
						targetAfterJumpDistance < MAX_JUMP_DISTANCE &&
						!(closest is Assassin)) {
				
					this.halt();
					
					var landedX:Number = _sprite.x +
							(_facesRight ?
									targetAfterJumpDistance - MELEE_RANGE :
									-targetAfterJumpDistance + MELEE_RANGE);
						
					_status = Status.ASSASSINATING;
						
					_sprite.animate(Status.ASSASSINATING, repeater, function():void { 
						_status = Status.STANDING;
					} );
					
					landedTimer = new Timer(AssassinSprite.timeToLand(repeater), 1);
					landedTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
						if (withinRange(closest, MELEE_RANGE*1.1))//A little extra leeway on assassination.
							closest.hit(2 * MELEE_DAMAGE * (isPlayerPiece ? player_buff : 1.0)); //Double damage on assassination
						landedTimer = null;
					});
					landedTimer.start();
					
					jumping = new TweenLite(_sprite, AssassinSprite.timeToLand(repeater) / 1000,
							{ x:landedX, ease:Linear.easeInOut } );
				} else if (this.withinRange(closest, MELEE_RANGE)) {
					if (isPlayerActor)
						this.meleeAttack(closest, MELEE_RANGE,
								MELEE_DAMAGE * player_buff, AssassinSprite.timeBetweenStabs(repeater), repeater);
					else
						this.meleeAttack(closest, MELEE_RANGE,
								MELEE_DAMAGE, AssassinSprite.timeBetweenStabs(repeater), repeater);
					
				} else {
					if (_status != Status.MOVING) {
						this.go(repeater);
					}
				}
			}  else {
				if (_status != Status.MOVING)
					this.go(repeater);
			}
			
			
			
			}//End of check for ongoing status.
			
		}
		
		override public function predictPosition(time:Number):Point {
			if (_status == Status.ASSASSINATING) {
				
				if (landedTimer == null) {
					//landedTimer is null if we've landed but haven't finished assassinating yet
					return new Point(jumpTarget, _sprite.y);
				} else {
					if (_facesRight)
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
			
			if (landedTimer != null) {
				landedTimer.stop();
				landedTimer = null;
			}
			
			if (jumping != null) {
				jumping.kill();
				jumping = null;
			}
		}
	}

}