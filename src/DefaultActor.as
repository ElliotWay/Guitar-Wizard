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
		
		protected var status : int = Status.STANDING;
		
		protected var range : int;
		protected var damage : int;
		
		protected var dying : TweenLite;
		
		protected var _isDead : Boolean;
		
		public function DefaultActor(isPlayerPiece:Boolean) 
		{
			super(isPlayerPiece);
			
			status = Status.MOVING;
			dying = null;
			_isDead = false;
			
			range = 10;
			damage = 1;
		}
		
		override public function createSprites(isPlayerPiece:Boolean):void {
			this._sprite = new DefaultSprite((isPlayerPiece) ? (0x0000FF) : (0xFF0000));
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
			
			//Check whether any valid targest are available.
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
			var closest:Actor = this.getClosest(validOthers, range);
			
			if (closest != null) {
				if (status != Status.FIGHTING)
					this.halt();
					
				closest.hitpoints -= damage;
				status = Status.FIGHTING;
				_sprite.animate(Status.FIGHTING);
			} else {
				if (status != Status.MOVING)
					this.go();
					
				status = Status.MOVING;
				_sprite.animate(Status.MOVING);
			}
			
			//Check if we're dying. Actors can interact while dying, otherwise player actors
			//would get an advantage.
			if (this._hitpoints <= 0) {
				status = Status.DYING;
				_sprite.animate(Status.DYING);
				this.halt();
				
				TweenPlugin.activate([TintPlugin]);
				this.dying = new TweenLite(sprite, 3, { tint : 0x000000 } );
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