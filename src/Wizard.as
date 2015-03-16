package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class Wizard extends Actor 
	{
		public static function create(isPlayerPiece:Boolean):Wizard {
			return new Wizard(isPlayerPiece,
					new WizardSprite(isPlayerPiece),
					new SmallTriangleSprite(0x000060));
		}
		
		public function Wizard(playerPiece:Boolean, sprite:ActorSprite, miniSprite:MiniSprite) 
		{
			super(playerPiece, playerPiece, sprite, miniSprite);
					
					
			this._hitpoints = 1;
		}
		
		override public function act(allies:Vector.<Actor>, enemies:Vector.<Actor>):void {
			throw new Error("Error: wizards shouldn't be in the acting list");
		}
		
		public function play():void {
			(_sprite as SteppedActorSprite).step();
		}
		
	}

}