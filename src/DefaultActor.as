package src 
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.TintPlugin;
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class DefaultActor extends Actor 
	{
		private static const RANGE : int = 10;
		private static const DAMAGE : int = 5;
		
		private var status : int = 0;
		private static const MOVING : int = 0;
		private static const FIGHTING : int = 1;
		private static const DYING : int = 2;
		
		private var dying : TweenLite;
		
		private var _isDead : Boolean;
		
		public function DefaultActor(isPlayerPiece:Boolean) 
		{
			super();
			
			this.isPlayerPiece = isPlayerPiece;
			
			this._sprite = new ActorSprite((isPlayerPiece) ? (0x0000FF) : (0xFF0000));
			this._miniSprite = new SmallSquareSprite((isPlayerPiece) ? (0x0000FF) : (0xFF0000));
			
			status = MOVING;
			dying = null;
			_isDead = false;
		}
		
		override public function reactToTargets(others:Vector.<Actor>):void {
			//Check if we're dead.
			if (status == DYING) {
				if (dying.progress() == 1)
					_isDead = true;
				return;
			}
			
			//Check if we're dying.
			if (this._hitpoints <= 0) {
				status = DYING;
				this.halt();
				
				TweenPlugin.activate([TintPlugin]);
				this.dying = new TweenLite(sprite, 3, { tint : 0x000000 } );
				
				return;
			}
			
			//Do other stuff.
			
			//Check whether any valid targest are available.
			var validOthers:Vector.<Actor> = 
				others.filter(function(actor:Actor, index:int, vector:Vector.<Actor>):Boolean {
					return actor.isValidTarget();
			});
			if (validOthers.length == 0) {
				if (status != MOVING)
					this.go();
				status = MOVING;
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
			
			if (closeDistance < RANGE) {
				if (status != FIGHTING)
					this.halt();
					
				closest.hitpoints -= DAMAGE;
				status = FIGHTING;
			} else {
				if (status != MOVING)
					this.go();
					
				status = MOVING;
			}
		}
		
		override public function get isDead():Boolean {
			return _isDead;
		}
		
		override public function isValidTarget():Boolean {
			return status != DYING;
		}
		
		override public function clean():void {
			super.clean();
			
			if (dying != null)
				dying.kill();
		}
	}

}