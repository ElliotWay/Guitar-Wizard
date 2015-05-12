package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class ThinLineSprite extends MiniSprite 
	{
		
		public function ThinLineSprite(isPlayerPiece:Boolean) 
		{
			this.graphics.beginFill(0x00FFFF);
			this.graphics.drawRect(0, 0, 2, 10);
			this.graphics.endFill();
		}
		
	}

}