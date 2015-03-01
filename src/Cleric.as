package src 
{
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
	public class Cleric extends Actor 
	{
		
		private static const MELEE_RANGE:int = 40;
		
		private static const DAMAGE:int = 3;
		
		private var fightingTimer:Timer;
		
		public function Cleric(isPlayerPiece:Boolean) 
		{
			super(isPlayerPiece,
					new ClericSprite(isPlayerPiece),
					new SmallCircleSprite(isPlayerPiece ? 0x0040FF : 0xFF4000));
			
			this.speed = 90;
			this._hitpoints = 30;
			
		}
		
		override public function reactToTargets(others:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (status == Status.DYING) {
				return;
			}
			
			if (status != Status.FIGHTING) {
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
				var closest : Actor = this.getClosest(validOthers, MELEE_RANGE);
				
				if (closest != null) {
					this.meleeAttack(closest, MELEE_RANGE, DAMAGE, ClericSprite.TIME_BETWEEN_BLOWS);

				} else {
					if (status != Status.MOVING) {
						this.go();
					}
				}
			}
			
			
			this.checkIfDead();
		}
	}

}