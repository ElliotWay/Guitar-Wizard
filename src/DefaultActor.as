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
		
		private var status : int = 0;
		private static const MOVING : int = 0;
		private static const FIGHTING : int = 1;
		private static const DYING : int = 2;
		
		protected var range : int;
		protected var damage : int;
		
		private var dying : TweenLite;
		
		private var _isDead : Boolean;
		
		public function DefaultActor(isPlayerPiece:Boolean) 
		{
			super(isPlayerPiece);
			
			status = MOVING;
			dying = null;
			_isDead = false;
			
			range = 10;
			damage = 1;
		}
		
		override public function createSprites(isPlayerPiece:Boolean):void {
			this._sprite = new ActorSprite((isPlayerPiece) ? (0x0000FF) : (0xFF0000));
			this._miniSprite = new SmallSquareSprite((isPlayerPiece) ? (0x0000FF) : (0xFF0000));
		}
		
		override public function reactToTargets(others:Vector.<Actor>):void {
			//Check if we're dead. If we're dead, we have to stop now.
			if (status == DYING) {
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
			
			if (closeDistance < range) {
				if (status != FIGHTING)
					this.halt();
					
				closest.hitpoints -= damage;
				status = FIGHTING;
			} else {
				if (status != MOVING)
					this.go();
					
				status = MOVING;
			}
			
			//Check if we're dying. Actors can interact while dying, otherwise player actors
			//would get an advantage.
			if (this._hitpoints <= 0) {
				status = DYING;
				this.halt();
				
				TweenPlugin.activate([TintPlugin]);
				this.dying = new TweenLite(sprite, 3, { tint : 0x000000 } );
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