package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class WizardMiniSprite extends MiniSprite 
	{
		
		public function WizardMiniSprite(isPlayerPiece:Boolean) 
		{
			this.graphics.beginFill(0x0);
			this.graphics.drawRect(0, 0, 4, 4);
			this.graphics.endFill();
		}
		
	}

}