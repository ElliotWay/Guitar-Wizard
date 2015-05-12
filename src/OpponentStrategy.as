package src 
{
	
	/**
	 * Interface for how an opponent should act.
	 * @author Elliot Way
	 */
	public interface OpponentStrategy 
	{
		/**
		 * Time to delay before allowing the opponent to act again.
		 */
		function get timeToAct():Number;
		
		/**
		 * Proceed with whatever the opponent is going to do.
		 * @return a vector contain the actors to summon.
		 */
		function act(actorFactory:ActorFactory):Vector.<Actor>;
	}
	
}