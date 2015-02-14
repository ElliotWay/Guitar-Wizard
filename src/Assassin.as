package src 
{
	import com.greensock.easing.Linear;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author ...
	 */
	public class Assassin extends DefaultActor 
	{
		public static const JUMP_DISTANCE:int = 400;
		
		private var jumping:TweenLite;
		
		public function Assassin(isPlayerPiece:Boolean) 
		{
			super(isPlayerPiece);
			
			this.speed = 300;
			this.damage = 100;
		}
		
		override public function createSprites(isPlayerPiece:Boolean):void {
			this._sprite = new AssassinSprite(isPlayerPiece ? true : false);
			this._miniSprite = new SmallSquareSprite((isPlayerPiece) ? (0x0000FF) : (0xFF0000));
		}
		
		override public function reactToTargets(others:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (status == Status.DYING) {
				if (dying.progress() == 1)
					_isDead = true;
				return;
			}
			
			
			//Do other stuff.
			
			if (status != Status.ASSASSINATING) {
			//Check whether any valid targest are available.
			var validOthers:Vector.<Actor> = 
				others.filter(function(actor:Actor, index:int, vector:Vector.<Actor>):Boolean {
					return actor.isValidTarget();
			});
			if (validOthers.length == 0) {
				if (status != Status.MOVING) {
					this.go();
					status = Status.MOVING;
					_sprite.animate(Status.MOVING);
				}
				return;
			}
			
			//Find the closest valid target.
			var closest:Actor = this.getClosest(validOthers, JUMP_DISTANCE);
			
			if (closest != null) {
				if (status == Status.MOVING || status == Status.STANDING) {
					
					//TODO don't assassinate if other assassin
					this.halt();
					
					var targetPosition:Number = closest.predictPosition(AssassinSprite.TIME_TO_LAND);
					var landedX:Number = targetPosition +
							(isPlayerPiece ? -30 : 30) -
							AssassinSprite.CENTER.x;

					status = Status.ASSASSINATING;
					var self:Assassin = this;
					
					trace("predicted: " + targetPosition);
					
					_sprite.animate(Status.ASSASSINATING, function():void { status = Status.STANDING; } );
					
					var landedTimer:Timer = new Timer(AssassinSprite.TIME_TO_LAND, 1);
					landedTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
						closest.hitpoints -= damage;
						trace("actual: " + closest.getPosition());
						trace(self.getPosition());
					});
					landedTimer.start();
					
					jumping = new TweenLite(_sprite, AssassinSprite.TIME_TO_LAND / 1000,
							{ x:landedX, ease:Linear.easeInOut } );
				}
			} else {
				if (status != Status.MOVING)
					this.go();
					
				status = Status.MOVING;
				_sprite.animate(Status.MOVING);
			}
			}
			
			//Check if we're dying. Actors can interact while dying, otherwise player actors
			//would get an advantage.
			if (this._hitpoints <= 0) {
				status = Status.DYING;
				_sprite.animate(Status.DYING);
				this.halt();
				
				TweenPlugin.activate([TintPlugin]);
				this.dying = new TweenLite(sprite, 10, { tint : 0x000000 } );
			}
		}
		
		
		override public function clean():void {
			super.clean();
			
			if (jumping != null)
				jumping.kill();
		}
	}

}