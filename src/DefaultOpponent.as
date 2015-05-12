package src 
{
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class DefaultOpponent implements OpponentStrategy 
	{
		
		private var _timeToAct:Number;
		
		public function DefaultOpponent() 
		{
			_timeToAct = 3700;
		}
		
		public function get timeToAct():Number 
		{
			return _timeToAct;
		}
		
		public function act(actorFactory:ActorFactory):Vector.<Actor> 
		{
			//Basic strategy of summon one DefaultActor.
			
			var out:Vector.<Actor> = new Vector.<Actor>();
			return out;
			
			var type:Number = Math.random() * 3;
			
			if (type < 1)
				out.push(actorFactory.create(ActorFactory.ARCHER, Actor.OPPONENT, Actor.LEFT_FACING));
			else if (type < 2)
				out.push(actorFactory.create(ActorFactory.ASSASSIN, Actor.OPPONENT, Actor.LEFT_FACING));
			else
				out.push(actorFactory.create(ActorFactory.CLERIC, Actor.OPPONENT, Actor.LEFT_FACING));
			
			return out;
		}
		
	}

}