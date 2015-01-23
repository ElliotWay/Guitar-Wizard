package src {
	import com.greensock.TweenLite;
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Actor 
	{
		private var sprite : ActorSprite;
		
		private var status : int;
		private var position : Number
		private var hitpoints : int;
		
		private var isPlayerPiece : Boolean;
		
		private var speed : Number; // pxl/s
		
		private var movement : TweenLite;
		
		public function Actor() 
		{
			
		}
		
		public function act(others : Vector.<Actor>) {
			for each (var other : Actor in others) {
				reactToTarget(other);
			}
		}
		
		/**
		 * extend this method
		 * @param	other target actor
		 */
		public function reactToTarget(other : Actor) {
			
		}
		
		public function go() {
			if (isPlayerPiece) {
				var distance : Number = sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : 0 } );
			} else {
				var distance : Number = MainArea.ARENA_WIDTH - sprite.x;
				movement = new TweenLite(sprite, distance / speed, { x : MainArea.ARENA_WIDTH } );
			}
		}
		
	}

}