package test 
{
	import src.Actor;
	import src.ActorSprite;
	import src.MiniSprite;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Extension_Actor extends Actor 
	{
		
		public function Extension_Actor(playerPiece:Boolean, facesRight:Boolean, sprite:ActorSprite, miniSprite:MiniSprite) 
		{
			super(playerPiece, facesRight, sprite, miniSprite);
			
		}
		
	}

}