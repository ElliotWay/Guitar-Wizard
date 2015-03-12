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
		
		public function act():Vector.<Actor> 
		{
			//Basic strategy of summon one DefaultActor.
			
			var out:Vector.<Actor> = new Vector.<Actor>();
			return out;
			
			var type:Number = Math.random() * 3;
			
			if (type < 1)
				out.push(new Assassin(false));
			else if (type < 2)
				out.push(new Archer(false));
			else
				out.push(new Cleric(false));
			
			return out;
		}
		
	}

}