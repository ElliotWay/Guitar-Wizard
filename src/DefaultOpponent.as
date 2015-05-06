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
			//return out;
			
			var type:Number = Math.random() * 3;
			
			if (type < 1)
				out.push(Assassin.create(false, false));
			else if (type < 2)
				out.push(Archer.create(false, false));
			else
				out.push(Cleric.create(false, false));
			
			return out;
		}
		
	}

}