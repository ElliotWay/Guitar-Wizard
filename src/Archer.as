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
		private static const SKIRMISH_DISTANCE:Number = 300; //300 pixels
		private static const NO_RETREAT_DISTANCE:Number = 25;
		
		/**
		 * Amount of time the Archer estimates it will take for the arrow to hit its target,
		 * as the Archer attempt to lead the target. Expressed in milliseconds.
		 */
		private static const LEAD_TIME:Number = 600;
		
		private var timeToShoot:Number; //milliseconds
		private var range:Number; //Range should decrease below skirmish distance.
		
		public function Archer(isPlayerPiece:Boolean) 
		{
			super(isPlayerPiece,
					new	ArcherSprite((isPlayerPiece) ? (0x2020B0) : (0xB02020), isPlayerPiece),
					new SmallTriangleSprite((isPlayerPiece) ? (0x2020B0) : (0xB02020)));
			
			this.speed = 160;
			
			timeToShoot = 24 * 5 * 6;//400;
			range = 700;
		}
		
		override public function reactToTargets(others:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (status == Status.DYING) {
				return;
			}
			
			
			//Do other stuff.
			
			//If we're shooting, we need to finish shooting before doing anything else.
			if (status != Status.SHOOTING) {
				
				//Check whether any valid targets are available.
				var validOthers:Vector.<Actor> = 
					others.filter(function(actor:Actor, index:int, vector:Vector.<Actor>):Boolean {
						return actor.isValidTarget();
				});
				
				//Find the closest valid target.
				var closest : Actor = this.getClosest(validOthers, range);
				
				if (closest == null) {
					this.go();
				} else {
					//var closeDistance:Number = Math.abs(this.getPosition().x - closest.getPosition().x);
					var expectedDistance:Number = Math.abs(this.getPosition().x
							- closest.predictPosition(ArcherSprite.TIME_TO_SHOOT).x);
					
					if (expectedDistance < SKIRMISH_DISTANCE && canRetreat()) {
						if (status != Status.RETREATING) {
							status = Status.RETREATING;
							
							_sprite.animate(Status.RETREATING);
								
							this.retreat();
						}
					} else {
						halt();
						status = Status.SHOOTING;
						
						_sprite.animate(Status.SHOOTING, function():void { status = Status.STANDING;} );
						
						var shotFiredTimer:Timer = new Timer(ArcherSprite.TIME_UNTIL_FIRED, 1);
						shotFiredTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
							if (status == Status.DYING)
								return;
							
							var arrow:Projectile = new Projectile(
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
		
		private function canRetreat():Boolean {
			if (this.isPlayerPiece) {
				return (this.getPosition().x > NO_RETREAT_DISTANCE);
			} else {
				return (this.getPosition().x < (MainArea.ARENA_WIDTH - NO_RETREAT_DISTANCE));
			}
		}
	
		override public function get isDead():Boolean {
			return _isDead;
		}
		
		override public function isValidTarget():Boolean {
			return status != Status.DYING;
		}
	}
}