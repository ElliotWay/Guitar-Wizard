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
			_timeToAct = 3000; //milliseconds 400
		}
		
		public function get timeToAct():Number 
		{
			return _timeToAct;
		}
		
		public function act():Vector.<Actor> 
		{
			//Basic strategy of summon one DefaultActor.
			
			var out:Vector.<Actor> = new Vector.<Actor>();
			
			if (Math.random() * 4 < 3)
				out[0] = new DefaultActor(false);
			else {
				var newScale:Number = 1.2 + Math.random() * 2;
				var actor:DefaultScalableActor = new DefaultScalableActor(false);
				actor.setScale(newScale);
				out[0] = actor;
			}
			
			return out;
		}
		
	}

}