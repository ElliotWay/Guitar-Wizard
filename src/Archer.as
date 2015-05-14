package src 
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.TintPlugin;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Archer extends Actor 
	{
		public static const SPEED:int = 70;
		public static const MAX_HP:int = 5;
		
		public static const MELEE_RANGE:int = 15;
		public static const BASE_MELEE_DAMAGE:int = 1;
		
		public static const NO_RETREAT_DISTANCE:Number = 50;
		
		public static const BASE_SKIRMISH_DISTANCE:Number = 200;
		private static const SKIRMISH_VARIABILITY:Number = 75;
		
		private static const ARROW_DAMAGE:int = 3;
		
		public static const BASE_RANGE:Number = Projectile.TRAJECTORY_CONSTANT - 50;
		private static const RANGE_VARIABILITY:Number = 50;
		
		trace("min range/skirmish diff " + ((BASE_RANGE - RANGE_VARIABILITY) - (BASE_SKIRMISH_DISTANCE + 75)));
		
		private static const WIZARD_RANGE:Number = 130;
		
		
		/**
		 * Amount of time the Archer estimates it will take for the arrow to hit its target,
		 * as the Archer attempt to lead the target. Expressed in milliseconds.
		 */
		private static const LEAD_TIME:Number = 600;
		
		private var range:Number; //Range should decrease below skirmish distance.
		private var skirmishDistance:Number;
		
		private var shotFiredTimer:Timer;
		
		private var currentShootingTarget:Actor;
		
		public function Archer() 
		{	
			super();
			
			range = BASE_RANGE + (Math.random() * RANGE_VARIABILITY) - (RANGE_VARIABILITY / 2);
			
			skirmishDistance = BASE_SKIRMISH_DISTANCE + (Math.random() * SKIRMISH_VARIABILITY) - (SKIRMISH_VARIABILITY / 2);
		}
		
		override protected function get speed():int {
			return SPEED;
		}
		
		override protected function get maxHP():int {
			return MAX_HP;
		}
		
		override protected function get meleeRange():int {
			return MELEE_RANGE;
		}
		
		override protected function get baseMeleeDamage():int {
			return BASE_MELEE_DAMAGE;
		}
		
		override public function act(allies:Vector.<Actor>, enemies:Vector.<Actor>, repeater:Repeater):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (_status == Status.DYING) {
				return;
			}
			
			//Do other stuff.
			
			//If we're busy, we need to finish before doing anything else.
			if (_status != Status.SHOOTING && _status != Status.FIGHTING) {
				
				//Find the closest valid target.
				var closest:Actor = this.getClosest(enemies, range);
				
				if (closest == null ||
						(closest is Wizard && !withinRange(closest, WIZARD_RANGE))) {
					if (_status != Status.MOVING)
						go(repeater);
						
				} else if (withinRange(closest, MELEE_RANGE)) {
					this.meleeAttack(closest, ArcherSprite.timeBetweenBlows(repeater), repeater);
					
				} else if (isBehindShield()) {
					if (_status != Status.MOVING)
						go(repeater);
						
				} else {
					var expectedDistance:Number = Math.abs(this.getPosition().x
							- closest.predictPosition(ArcherSprite.ARROW_TIME).x);
					
					if (expectedDistance < skirmishDistance && canRetreat() && !(closest is Wizard)) {
						if (_status != Status.RETREATING) {
							this.retreat(repeater);
						}
					} else {	
						halt();
						_status = Status.SHOOTING;
						
						currentShootingTarget = closest;
						
						_sprite.animate(Status.SHOOTING, repeater, finishShooting);
						
						shotFiredTimer = new Timer(ArcherSprite.timeUntilFired(repeater), 1);
						shotFiredTimer.addEventListener(TimerEvent.TIMER_COMPLETE, spawnArrow);
						
						shotFiredTimer.start();
					}
				}
			}
		}
		
		private function finishShooting():void {
			_status = Status.STANDING;
		}
		
		private function spawnArrow(event:Event):void {
			var arrow:Projectile = new Projectile(
					ARROW_DAMAGE * (isPlayerActor ? player_buff : 1.0),
					(isPlayerPiece ? MainArea.OPPONENT_ACTORS : MainArea.PLAYER_ACTORS),
					currentShootingTarget.predictPosition(LEAD_TIME));
			
			var arrowPosition:Point = (_sprite as ArcherSprite).arrowPosition;
			
			arrow.x = arrowPosition.x;
			arrow.y = arrowPosition.y;
			
			MainArea.mainArea.addProjectile(arrow);
			
			shotFiredTimer = null;
			currentShootingTarget = null;
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
		
		override public function clean():void {
			super.clean();
			
			if (shotFiredTimer != null) {
				shotFiredTimer.stop();
				shotFiredTimer = null;
			}
			currentShootingTarget = null;
		}
	}
}