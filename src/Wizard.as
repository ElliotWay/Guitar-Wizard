package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class Wizard extends Actor 
	{
		
		public function Wizard(playerPiece:Boolean) 
		{
			super(playerPiece,
					new WizardSprite(playerPiece),
					new SmallTriangleSprite(0x000060));
					
					
			this.hitpoints = 1;
		}
		
		override public function act(others:Vector.<Actor>):void {
			throw new Error("Error: wizards shouldn't be in the acting list");
		}
		
		public function play():void {
			(_sprite as SteppedActorSprite).step();
		}
		
	}

}