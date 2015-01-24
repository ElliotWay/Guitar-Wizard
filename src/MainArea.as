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
			
			//TODO remove these later.
			
		}
		
		public function setPlayerHP(hp : int) {
			playerHP = hp;
		}
		
		public function playerSummon(actor : Actor) {
			var position : Number = Math.random() * 100;
			playerActors.push(actor);
		}
		
		public function opponentSummon(actor : Actor) {
			opponentActors.push(actor);
		}
		
		public function step() {
			for each (var actor : Actor in playerActors) {
				actor.reactToTargets(opponentActors);
			}
			
			for each (var actor : Actor in oppenentActors) {
				actor.reactToTargets(playerActors);
			}
			
			//Collect the dead.
			playerActors.filter(checkDead, this);
			
			opponentActors.filter(checkDead, this);
		}
		
		private function checkDead(actor : Actor , index : int, vector : Vector.<Actor>) : Boolean {
			return actor.isDead;
		}
		
	}

}