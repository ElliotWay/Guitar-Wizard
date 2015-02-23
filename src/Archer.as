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
		
		private var status:int;
		
		private var timeToShoot:Number; //milliseconds
		private var range:Number; //Range should decrease below skirmish distance.
		
		private var dying:TweenLite;
		private var _isDead:Boolean;
		
		public function Archer(playerPiece:Boolean) 
		{
			super(playerPiece);
			
			status = Status.MOVING;
			
			dying = null;
			_isDead = false;
			
			this.speed = 160;
			
			timeToShoot = 24 * 5 * 6;//400;
			range = 700;
		}
		
		override public function createSprites(isPlayerPiece:Boolean):void {
			this._sprite = new	ArcherSprite((isPlayerPiece) ? (0x2020B0) : (0xB02020), isPlayerPiece);
			this._miniSprite = new SmallTriangleSprite((isPlayerPiece) ? (0x2020B0) : (0xB02020));
		}
		
		override public function reactToTargets(others:Vector.<Actor>):void {
			//trace("status = " + status);
			//Check if we're dead. If we're dead, we have to stop now.
			if (status == Status.DYING) {
				if (dying.progress() == 1)
					_isDead = true;
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
				if (validOthers.length == 0) {
					if (status != Status.MOVING)
						this.go();
					status = Status.MOVING;
					
					_sprite.animate(Status.MOVING);
						
					return;
				}
				
				//Find the closest valid target.
				var closest : Actor = this.getClosest(validOthers, range);
				
				if (closest == null) {
					
					status = Status.MOVING;
					_sprite.animate(Status.MOVING);
					
					go();
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
			} else if (status == Status.RETREATING) {
				if (isPlayerPiece) {
					return new Point(
							Math.max(position.x - (time * speed / 1000), 0),
							position.y);
				} else {
					return new Point(
							Math.min(position.x + (time * speed / 1000), MainArea.ARENA_WIDTH),
							position.y);
				}
			} else {
				return position;
			}
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
		
		override public function clean():void {
			super.clean();
			
			if (dying != null)
				dying.kill();
		}
	}
}