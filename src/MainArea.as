package src 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class MainArea extends Sprite 
	{
		public static const ARENA_WIDTH = 5000;
		
		private var playerActors : Vector.<Actor>;
		private var opponentActors : Vector.<Actor>;

		private var playerHP : int;
		private var opponentHP : int;
		
		private var arena : Sprite;
		
		public function MainArea() 
		{
			super();
			
			playerActors = new Vector.<Actor>();
			opponentActors = new Vector.<Actor>();
			
			arena = new Sprite();
			this.addChild(arena);
		}
		
		public function setPlayerHP(hp : int) {
			playerHP = hp;
		}
		
		public function playerSummon(actor : Actor) {
			//TODO add to arena
			playerActors.push(actor);
		}
		
		public function opponentSummon(actor : Actor) {
			opponentActors.push(actor);
		}
		
		public function step() {
			for each (var actor : Actor in playerActors) {
				for each (var other : Actor in opponentActors) {
					actor.reactToTarget(other);
				}
			}
			
			for each (var actor : Actor in oppenentActors) {
				for each (var other : Actor in playerActors) {
					actor.reactToTarget(other);
				}
			}
		}
		
	}

}