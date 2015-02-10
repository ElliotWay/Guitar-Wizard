package src 
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.TintPlugin;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Archer extends Actor 
	{
		private static const SKIRMISH_DISTANCE:Number = 75; //pixels
		private static const NO_RETREAT_DISTANCE:Number = 25;
		
		private var status:int;
		
		private var timeToShoot:Number; //milliseconds
		private var range:Number;
		
		private var dying:TweenLite;
		private var _isDead:Boolean;
		
		public function Archer(playerPiece:Boolean) 
		{
			super(playerPiece);
			
			status = Status.MOVING;
			
			dying = null;
			_isDead = false;
			
			this.speed = 80;
			
			timeToShoot = 24 * 5 * 6;//400;
			range = 400;
		}
		
		override public function createSprites(isPlayerPiece:Boolean):void {
			this._sprite = new	ArcherSprite((isPlayerPiece) ? (0x2020B0) : (0xB02020), function():void {
				stand();
			});
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
			
			//Check whether any valid targest are available.
			var validOthers:Vector.<Actor> = 
				others.filter(function(actor:Actor, index:int, vector:Vector.<Actor>):Boolean {
					return actor.isValidTarget();
			});
			if (validOthers.length == 0) {
				if (status != Status.MOVING)
					this.go();
				status = Status.MOVING;
				
				if (isPlayerPiece)
					_sprite.animate(Status.MOVING);
				else
					_sprite.animate(Status.RETREATING);
					
				return;
			}
			
			//Find the closest valid target.
			var closest : Actor = validOthers[0];
			var closeDistance : Number = Math.abs(closest.getPosition() - this.getPosition());
			var distance : Number;
			
			for each(var other:Actor in validOthers) {
				if (other.isValidTarget()) {
					distance = Math.abs(other.getPosition() - this.getPosition());
					
					if (distance < closeDistance) {
						closest = other;
						closeDistance = distance;
					}
				}
			}

			if (status != Status.SHOOTING) {
				if (closeDistance < SKIRMISH_DISTANCE && canRetreat()) {
					if (status != Status.RETREATING) {
						status = Status.RETREATING;
						
						if (isPlayerPiece)
							_sprite.animate(Status.RETREATING);
						else
							_sprite.animate(Status.MOVING);
							
						this.retreat();
					}
				} else if (closeDistance < range) {
					halt();
					status = Status.SHOOTING;
					
					_sprite.animate(Status.SHOOTING);
					
					var shotFiredTimer:Timer = new Timer(ArcherSprite.TIME_UNTIL_FIRED, 1);
					shotFiredTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
																			//Ideally, "closest" here still refers
																			//to the closest target, and we can use
																			//it's current position, not the position
																			//when we stopped to fire.
						var arrow:Projectile = new Projectile(MainArea.OPPONENT_ACTORS, closest.getPosition());
					
						arrow.x = _sprite.x + ArcherSprite.ARROW_POSITION.x;
						arrow.y = _sprite.y + ArcherSprite.ARROW_POSITION.y;
						
						trace("arrow: " + arrow.x + ", " + arrow.y);
						
						MainArea.mainArea.addProjectile(arrow);
					});
					
					
					shotFiredTimer.start();
				} else {
					status = Status.MOVING;
					if (isPlayerPiece)
						_sprite.animate(Status.MOVING);
					else
						_sprite.animate(Status.RETREATING);
					
					go();
				}
			}
			
			//Check if we're dying. Actors can act in their first frame while dying,
			//otherwise player actors would get an advantage.
			if (this._hitpoints <= 0) {
				status = Status.DYING;
				_sprite.animate(Status.DYING);
				
				this.halt();
				
				TweenPlugin.activate([TintPlugin]);
				this.dying = new TweenLite(sprite, 3, { tint : 0x000000 } );
			}
		}
		
		public function stand():void {
			this.status = Status.STANDING;
		}
		
		private function canRetreat():Boolean {
			if (this.isPlayerPiece) {
				return (this.getPosition() > NO_RETREAT_DISTANCE);
			} else {
				return (this.getPosition() < (MainArea.ARENA_WIDTH - NO_RETREAT_DISTANCE));
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