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
			_timeToAct = 350; //milliseconds
		}
		
		public function get timeToAct():Number 
		{
			return _timeToAct;
		}
		
		public function act():Vector.<Actor> 
		{
			//Basic strategy of summon one DefaultActor.
			
			var out:Vector.<Actor> = new Vector.<Actor>();
			out[0] = new DefaultActor(false);
			
			return out;
		}
		
	}

}