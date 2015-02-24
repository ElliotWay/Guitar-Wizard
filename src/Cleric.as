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
		private var status:int;
		
		private static const MELEE_RANGE:int = 40;
		
		private static const DAMAGE:int = 3;
		
		private var fightingTimer:Timer;
		
		private var _isDead:Boolean;
		
		private var dying:TweenLite;
		
		public function Cleric(playerPiece:Boolean) 
		{
			super(playerPiece);
			status = Status.MOVING;
			
			dying = null;
			_isDead = false;
			
			this.speed = 90;
			this._hitpoints = 30;
			
		}
		
		override public function createSprites(isPlayerPiece:Boolean):void {
			this._sprite = new ClericSprite(isPlayerPiece);
			this._miniSprite = new SmallCircleSprite(isPlayerPiece ? 0x0040FF : 0xFF4000);
		}
		
		override public function reactToTargets(others:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (status == Status.DYING) {
				if (dying.progress() == 1)
					_isDead = true;
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
						status = Status.MOVING;
						
						_sprite.animate(Status.MOVING);
					}
						
					return;
				}
				
				//Find the closest valid target.
				var closest : Actor = this.getClosest(validOthers, MELEE_RANGE);
				
				if (closest != null) {
					halt();
			
					status = Status.FIGHTING;
					_sprite.animate(Status.FIGHTING);
					
					closest.hitpoints -= DAMAGE;
					
					//For use in enclosures.
					var self:Cleric = this;
					
					fightingTimer = new Timer(AssassinSprite.TIME_BETWEEN_STABS, 0);
					fightingTimer.addEventListener(TimerEvent.TIMER, function():void {
						//Check if we're still in range, and the target is still valid.
						if (Math.abs(self.getPosition().x - closest.getPosition().x) < MELEE_RANGE &&
									closest.isValidTarget()) {
							closest.hitpoints -= DAMAGE;
						} else {
							status = Status.STANDING;
							
							fightingTimer.stop();
							
							//The fighting animation ideally continues smoothly if there
							//ia another target in range.
						}
					});
					
					fightingTimer.start();
				} else {
					if (status != Status.MOVING) {
						this.go();
						status = Status.MOVING;
					}
					_sprite.animate(Status.MOVING);
				}
			}
			
			
			//Check if we're dying. Actors can act in their first frame while dying,
			//otherwise player actors would get an advantage.
			if (this._hitpoints <= 0) {
				status = Status.DYING;
				_sprite.animate(Status.DYING, function():void { _sprite.freeze();} );
				
				this.halt();
				
				TweenPlugin.activate([TintPlugin]);
				this.dying = new TweenLite(sprite, 10, { tint : 0x000000 } );
			}
		}
		
		override public function predictPosition(time:Number):Point {
			var position:Point = this.getPosition();
			if (status == Status.MOVING) {
				if (isPlayerPiece) {
					return new Point(
							Math.min(position.x + (time * speed / 1000), MainArea.ARENA_WIDTH),
							position.y);
				} else {
					return new Point(
							Math.max(position.x - (time * speed / 1000), 0),
							position.y);
				}
			} else {
				return position;
			}
		}
		
		override public function get isDead():Boolean {
			return _isDead;
		}
		
		override public function isValidTarget():Boolean {
			return status != Status.DYING;
		}
		
		override public function clean():void {
			super.clean();
			
			if (dying != null)
				dying.kill();
		}
	}

}