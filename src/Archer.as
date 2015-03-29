package src 
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.TintPlugin;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Archer extends Actor 
	{
		
		private static const NO_RETREAT_DISTANCE:Number = 50;
		
		private static const BASE_SKIRMISH_DISTANCE:Number = 200;
		private static const SKIRMISH_VARIABILITY:Number = 100;
		
		private static const ARROW_DAMAGE:int = 3;
		
		private static const BASE_RANGE:Number = Projectile.TRAJECTORY_CONSTANT - 50;
		private static const RANGE_VARIABILITY:Number = 75;
		
		private static const MELEE_RANGE:int = 15;
		private static const MELEE_DAMAGE:int = 1;
		
		/**
		 * Amount of time the Archer estimates it will take for the arrow to hit its target,
		 * as the Archer attempt to lead the target. Expressed in milliseconds.
		 */
		private static const LEAD_TIME:Number = 600;
		
		private var range:Number; //Range should decrease below skirmish distance.
		private var skirmishDistance:Number;
		
		public function Archer(isPlayerPiece:Boolean, facesRight:Boolean) 
		{
				
			super(isPlayerPiece, facesRight,
					new	ArcherSprite(isPlayerPiece, facesRight),
					new SmallTriangleSprite((isPlayerPiece) ? (0x2020B0) : (0xB02020)));
			
			this.speed = 70;
			this._hitpoints = 5;
			
			range = BASE_RANGE + (Math.random() * RANGE_VARIABILITY) - (RANGE_VARIABILITY / 2);
			
			skirmishDistance = BASE_SKIRMISH_DISTANCE + (Math.random() * SKIRMISH_VARIABILITY) - (SKIRMISH_VARIABILITY / 2);
		}
		
		override public function act(allies:Vector.<Actor>, enemies:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (_status == Status.DYING) {
				return;
			}
			
			//Do other stuff.
			
			//If we're shooting, we need to finish shooting before doing anything else.
			if (_status != Status.SHOOTING && _status != Status.FIGHTING) {
				
				//Find the closest valid target.
				var closest:Actor = this.getClosest(enemies, range);
				
				if (closest == null) {
					if (_status != Status.MOVING)
						go();
						
				} else if (withinRange(closest, MELEE_RANGE)) {
					if (isPlayerPiece)
						this.meleeAttack(closest, MELEE_RANGE,
								MELEE_DAMAGE * player_buff, ArcherSprite.timeBetweenBlows());
					else
						this.meleeAttack(closest, MELEE_RANGE,
								MELEE_DAMAGE, ArcherSprite.timeBetweenBlows());
				} else if (this.isBehindShield()) {
					if (_status != Status.MOVING)
						go();
				} else {
					var expectedDistance:Number = Math.abs(this.getPosition().x
							- closest.predictPosition(ArcherSprite.ARROW_TIME).x);
					
					var behindShield:Boolean = this.isBehindShield();
					
					if (expectedDistance < skirmishDistance && canRetreat()) {
						if (_status != Status.RETREATING) {
							this.retreat();
						}
					} else {	
								
						halt();
						_status = Status.SHOOTING;
						
						_sprite.animate(Status.SHOOTING, function():void { _status = Status.STANDING;} );
						
						var shotFiredTimer:Timer = new Timer(ArcherSprite.timeUntilFired(), 1);
						shotFiredTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
							
							var arrow:Projectile = new Projectile(
									ARROW_DAMAGE * (isPlayerActor ? player_buff : 1.0),
									(isPlayerPiece ? MainArea.OPPONENT_ACTORS : MainArea.PLAYER_ACTORS),
									closest.predictPosition(LEAD_TIME));
						
							var arrowPosition:Point = (_sprite as ArcherSprite).arrowPosition;
							
							arrow.x = arrowPosition.x;
							arrow.y = arrowPosition.y;
							
							MainArea.mainArea.addProjectile(arrow);
						});
						
						
						shotFiredTimer.start();
					}
				}
			}
			
			checkIfDead();
		}
		
		private function isBehindShield():Boolean {
			if (this.isPlayerPiece) {
				if (MainArea.playerShieldIsUp) {
					return this.getPosition().x < MainArea.SHIELD_POSITION + 25;
				}
			} else {
				if (MainArea.opponentShieldIsUp) {
					return this.getPosition().x > MainArea.ARENA_WIDTH - MainArea.SHIELD_POSITION - 25;
				}
			}
			
			return false;
		}
		
		private function canRetreat():Boolean {
			if (this.isPlayerPiece) {
				if (MainArea.playerShieldIsUp) {
					return this.getPosition().x > MainArea.SHIELD_POSITION + 50;
				} else {
					return (this.getPosition().x > NO_RETREAT_DISTANCE);
				}
			} else {
				if (MainArea.opponentShieldIsUp) {
					return this.getPosition().x < MainArea.ARENA_WIDTH - MainArea.SHIELD_POSITION - 50;
				} else {
					return (this.getPosition().x < (MainArea.ARENA_WIDTH - NO_RETREAT_DISTANCE));
				}
			}
		}
	}
}