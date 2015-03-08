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
		
		private static const MELEE_RANGE:int = 20;
		
		private static const DAMAGE:int = 3;
		
		private var fightingTimer:Timer;
		
		public function Cleric(isPlayerPiece:Boolean) 
		{
			super(isPlayerPiece,
					new ClericSprite(isPlayerPiece),
					new SmallCircleSprite(isPlayerPiece ? 0x0040FF : 0xFF4000));
			
			this.speed = 45;
			this._hitpoints = 30;
			
		}
		
		override public function act(allies:Vector.<Actor>, enemies:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (_status == Status.DYING) {
				return;
			}
			
			if (_status != Status.FIGHTING) {
				
				//Find the closest valid target.
				var closest : Actor = this.getClosest(enemies, MELEE_RANGE);
				
				if (closest != null) {
					this.meleeAttack(closest, MELEE_RANGE, DAMAGE, ClericSprite.TIME_BETWEEN_BLOWS);

				} else {
					if (_status != Status.MOVING) {
						this.go();
					}
				}
			}
			
			
			this.checkIfDead();
		}
	}

}