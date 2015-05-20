package src {
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Cleric extends Actor {
		public static const SPEED:int = 45;
		public static const MAX_HP:int = 30; //20?
		
		public static const MELEE_RANGE:int = 20;
		public static const BASE_MELEE_DAMAGE:int = 3;
		
		public static const BLESS_RANGE:int = 200;
		
		public static const BLESS_COOLDOWN:int = 3000; //milliseconds
		
		public static const MIN_UNBLESSED:int = 3;
		
		private var blessIsReady:Boolean;
		private var blessTimer:Timer;
		private var blessCooldownTimer:Timer;
		
		private var currentBlessTargets:Vector.<Actor>;
		
		public function Cleric() {
			super();
			
			blessIsReady = true;
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
			
			var finished:Boolean = false;
			
			if (blessIsReady) {
				//Find allies withing bless range.
				var nearbyAllies:Vector.<Actor> = new Vector.<Actor>();
				var ally:Actor;
				
				for each (ally in allies) {
					if (withinRange(ally, BLESS_RANGE) && !(ally is Shield))
						nearbyAllies.push(ally);
				}
				
				//Count how many aren't already blessed.
				var unblessed:int = 0;
				for each (ally in nearbyAllies) {
					if (!ally.isBlessed)
						unblessed++;
				}
				
				//Bless if there are enough.
				if (unblessed >= MIN_UNBLESSED) {
					
					for each (ally in nearbyAllies) {
						ally.preBless();
					}
					
					//Start bless animation.
					this.halt();
					
					_status = Status.BLESSING;
					_sprite.animate(Status.BLESSING, repeater, resetToStanding);
					
					//Do bless at the "peak" of the animation.
					currentBlessTargets = nearbyAllies;
					
					blessTimer = new Timer(ClericSprite.timeToBless(repeater), 1);
					blessTimer.addEventListener(TimerEvent.TIMER_COMPLETE, blessAllies);
					blessTimer.start();
					
					//Start cooldown timer for the next bless.
					blessIsReady = false;
					blessCooldownTimer = new Timer(BLESS_COOLDOWN, 1);
					blessCooldownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, readyBless);
					blessCooldownTimer.start();
					
					finished = true;
					
				} else {
					//Make sure references to the actors don't pile up.
					nearbyAllies.splice(0, nearbyAllies.length);
				}
			}
			
			if (!finished) {
				//Find the closest valid target.
				var closest:Actor = this.getClosest(enemies, MELEE_RANGE);
				
				if (closest != null) {
					this.meleeAttack(closest, ClericSprite.timeBetweenBlows(repeater), repeater);
					
				} else {
					if (_status != Status.MOVING) {
						this.go(repeater);
					}
				}
			}
		}
		
		private function blessAllies(event:Event):void {
			for each (var actor:Actor in currentBlessTargets) {
				if (!actor.isDead)
					actor.bless();
			}
			
			blessTimer = null;
			currentBlessTargets.splice(0, currentBlessTargets.length);
			currentBlessTargets = null;
		}
		
		private function readyBless(event:Event):void {
			blessIsReady = true;
			
			blessCooldownTimer = null;
		}
		
		override public function clean():void {
			super.clean();
			
			if (blessTimer != null) {
				blessTimer.stop();
				blessTimer = null;
			}
			if (currentBlessTargets != null) {
				currentBlessTargets.splice(0, currentBlessTargets.length);
				currentBlessTargets = null;
			}
			
			if (blessCooldownTimer != null) {
				blessCooldownTimer.stop();
				blessCooldownTimer = null;
			}
			
			blessIsReady = true;
		}
	}

}