package src 
{
	import util.LinkedList;
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
		
		override public function act(allies:LinkedList, enemies:LinkedList):void {
			throw new Error("Error: wizards shouldn't be in the acting list");
		}
		
		public function play():void {
			if (_status == Status.PLAY_MID) {
				_sprite.step();
			}
		}
		
		public function playTrack(track:int):void {
			if (!this.isDead) {
				switch(track) {
					case Main.HIGH:
						_status = Status.PLAY_HIGH;
						break;
					case Main.MID:
						_status = Status.PLAY_MID;
						break;
					case Main.LOW:
						_status = Status.PLAY_LOW;
				}
				
				_sprite.animate(_status);
			}
		}
		
	}

}