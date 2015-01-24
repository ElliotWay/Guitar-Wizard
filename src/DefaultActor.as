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
			
			this._sprite = new ActorSprite((isPlayerPiece) ? (0xFF0000) : (0x0000FF));
			
			status = MOVING;
			dying = null;
			_isDead = false;
		}
		
		public function reactToTargets(others:Vector.<Actor>) {
			//Check if we're dead.
			if (status == DYING) {
				if (dying.progress() == 1)
					isDead = true;
				return;
			}
			
			//Check if we're dying.
			if (this.hitpoints <= 0) {
				status = DYING;
				this.halt();
				
				TweenPlugin.activate([TintPlugin]);
				this.dying = new TweenLite(sprite, 3, { tint : 0x000000 } );
				
				return;
			}
			
			//Do other stuff.
			if (others.length < 0)
				return;
			
			var closest : Actor = others[0];
			var closeDistance : Number = Math.abs(closest.getPosition() - this.getPosition());
			var distance : Number;
			
			for each(var other:Actor in others) {
				distance = Math.abs(other.getPosition() - this.getPosition());
				if (distance < closeDistance) {
					closest = other;
					closeDistance = distance;
				}
			}
			
			if (closeDistance < RANGE) {
				if (status != FIGHTING)
					this.halt();
				
				other.hitpoints -= DAMAGE;
				status = FIGHTING;
			} else {
				if (status != MOVING)
					this.go();
					
				status = MOVING;
			}
		}
		
		public function get isDead() {
			return _isDead;
		}
		
	}

}