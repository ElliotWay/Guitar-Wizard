package src {
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Archer extends Actor {
		public static const SPEED:int = 70;
		public static const MAX_HP:int = 5;
		
		public static const MELEE_RANGE:int = 15;
		public static const ALMOST_MELEE_RANGE:int = Math.max(Cleric.MELEE_RANGE, Assassin.MELEE_RANGE);
		public static const BASE_MELEE_DAMAGE:int = 1;
		
		public static const NO_RETREAT_DISTANCE:Number = 50;
		
		public static const BASE_SKIRMISH_DISTANCE:Number = 300;//200;
		private static const SKIRMISH_VARIABILITY:Number = 50;
		
		private static const ARROW_DAMAGE:int = 5;
		
		public static const BASE_RANGE:Number = Projectile.TRAJECTORY_CONSTANT + 100;
		private static const RANGE_VARIABILITY:Number = 50;
		
		trace("min range/skirmish diff " + ((BASE_RANGE - RANGE_VARIABILITY) - (BASE_SKIRMISH_DISTANCE + SKIRMISH_VARIABILITY)));
		
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
		
		public function Archer() {
			super();
			
			range = BASE_RANGE + (Math.random() * RANGE_VARIABILITY) - (RANGE_VARIABILITY / 2);
			
			skirmishDistance = BASE_SKIRMISH_DISTANCE + (Math.random() * SKIRMISH_VARIABILITY) - (SKIRMISH_VARIABILITY / 2);
			
			if (range < skirmishDistance)
				trace("Warning: bad archer configuration");
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
			if (this.isPreoccupied)
				return;
			
			//Find the closest valid target(s).
			var closestRanged:Actor = this.getClosest(enemies, range, false);
			var closestMelee:Actor;
			if (closestRanged != null && closestRanged.isAttackLocked) //We need an unlocked target for melee, but not for ranged.
				closestMelee = this.getClosest(enemies, range, true);
			else
				closestMelee = closestRanged;
				
			if (closestMelee == null || (closestMelee is Wizard && !withinRange(closestMelee, WIZARD_RANGE))) {
				if (_status != Status.MOVING)
					go(repeater);
				
			} else if (withinRange(closestMelee, MELEE_RANGE)) {
				this.meleeAttack(closestMelee, ArcherSprite.timeBetweenBlows(repeater), repeater);
				
			} else if (isBehindShield() || (nearEdge(this) && nearEdge(closestMelee))) {
				if (_status != Status.MOVING)
					go(repeater);
				
			} else if (withinRange(closestMelee, skirmishDistance) && canRetreat() && !(closestMelee is Wizard)) {
				if (_status != Status.RETREATING) {
					this.retreat(repeater);
				}
			} else {
				
				var expectedDistance:Number = Math.abs(this.getPosition().x - closestRanged.predictPosition(ArcherSprite.ARROW_TIME).x);
				
				/*if (expectedDistance < skirmishDistance && canRetreat() && !(closestRanged is Wizard)) {
				   if (_status != Status.RETREATING) {
				   this.retreat(repeater);
				   }
				 } else {*/
				halt();
				_status = Status.SHOOTING;
				
				currentShootingTarget = closestRanged;
				
				_sprite.animate(Status.SHOOTING, repeater, resetToStanding);
				
				shotFiredTimer = new Timer(ArcherSprite.timeUntilFired(repeater), 1);
				shotFiredTimer.addEventListener(TimerEvent.TIMER_COMPLETE, spawnArrow);
				
				shotFiredTimer.start();
					//}
			}
		}
		
		private function spawnArrow(event:Event):void {
			(event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, spawnArrow);
			
			var targetPosition:Point/*
			if (Math.abs(getPosition().x - currentShootingTarget.getPosition().x) < skirmishDistance) {
				targetPosition = isPlayerPiece ? Projectile.SHOOT_RIGHT : Projectile.SHOOT_LEFT;
			} else {
				targetPosition*/ = currentShootingTarget.predictPosition(LEAD_TIME);
//			}
			
			
			var arrow:Projectile = new Projectile(ARROW_DAMAGE * (isPlayerActor ? player_buff : 1.0),
					(isPlayerPiece ? MainArea.OPPONENT_ACTORS : MainArea.PLAYER_ACTORS),
					targetPosition);
			
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
		
		private function nearEdge(actor:Actor):Boolean {
			if (this.isPlayerPiece) {
				if (MainArea.playerShieldIsUp) {
					return actor.getPosition().x < MainArea.SHIELD_POSITION + 25 + skirmishDistance;
				} else {
					return (actor.getPosition().x < NO_RETREAT_DISTANCE + skirmishDistance);
				}
			} else {
				if (MainArea.opponentShieldIsUp) {
					return actor.getPosition().x > MainArea.ARENA_WIDTH - MainArea.SHIELD_POSITION - 25 - skirmishDistance;
				} else {
					return (actor.getPosition().x > (MainArea.ARENA_WIDTH - NO_RETREAT_DISTANCE - skirmishDistance));
				}
			}
		}
		
		private function canRetreat():Boolean {
			if (this.isPlayerPiece) {
				if (MainArea.playerShieldIsUp) {
					return this.getPosition().x > MainArea.SHIELD_POSITION + 25;
				} else {
					return (this.getPosition().x > NO_RETREAT_DISTANCE);
				}
			} else {
				if (MainArea.opponentShieldIsUp) {
					return this.getPosition().x < MainArea.ARENA_WIDTH - MainArea.SHIELD_POSITION - 25;
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