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
		
		private static const BLESS_RANGE:int = 200;
		
		private static const BLESS_COOLDOWN:int = 3000; //milliseconds
		
		private static const MIN_UNBLESSED:int = 3;
		
		private var blessIsReady:Boolean;
		private var blessTimer:Timer;
		private var blessCooldownTimer:Timer;
		
		public function Cleric(isPlayerPiece:Boolean, facesRight:Boolean) 
		{
			super(isPlayerPiece, facesRight,
					new ClericSprite(isPlayerPiece, facesRight),
					new SmallCircleSprite(isPlayerPiece ? 0x0040FF : 0xFF4000));
			
			this.speed = 45;
			this._hitpoints = 20; //30
			
			blessIsReady = true;
		}
		
		override public function act(allies:Vector.<Actor>, enemies:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (_status == Status.DYING) {
				return;
			}
			
			if (_status != Status.FIGHTING && status != Status.BLESSING) {
				
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
					for each(ally in nearbyAllies) {
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
						_sprite.animate(Status.BLESSING, function():void {
							_status = Status.STANDING;
						});
						
						//Do bless at the "peak" of the animation.
						blessTimer = new Timer(ClericSprite.timeToBless(), 1);
						blessTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
							for each (var actor:Actor in nearbyAllies) {
								if (!actor.isDead)
									actor.bless();
							}
							
							blessTimer = null;
						});
						blessTimer.start();
						
						//Start cooldown timer for the next bless.
						blessIsReady = false;
						blessCooldownTimer = new Timer(BLESS_COOLDOWN, 1);
						blessCooldownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
							blessIsReady = true;
							
							blessCooldownTimer = null;
						});
						blessCooldownTimer.start();
						
						finished = true;
					}
				}
				
				if (!finished) {
					//Find the closest valid target.
					var closest : Actor = this.getClosest(enemies, MELEE_RANGE);
				
					if (closest != null) {
						if (isPlayerActor)
							this.meleeAttack(closest, MELEE_RANGE,
									DAMAGE * player_buff, ClericSprite.timeBetweenBlows());
						else
							this.meleeAttack(closest, MELEE_RANGE,
									DAMAGE, ClericSprite.timeBetweenBlows());
						

					} else {
						if (_status != Status.MOVING) {
							this.go();
						}
					}
				}
			}
			
			
			this.checkIfDead();
		}
		
		override public function clean():void {
			super.clean();
			
			if (blessTimer != null) {
				//Bless anyone that this cleric was about to bless.
				blessTimer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
				//The event handler also removes the timer.
			}
			
			if (blessCooldownTimer != null) {
				blessCooldownTimer.stop();
				blessCooldownTimer = null;
			}
		}
	}

}