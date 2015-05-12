package src 
{
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class SmallSquareSprite extends MiniSprite 
	{
		
		public function SmallSquareSprite(isPlayerPiece:Boolean) 
		{
			this.graphics.beginFill(isPlayerPiece ? 0x0000FF : 0xFF0000);
			this.graphics.drawRect(0, 0, 4, 4);
			this.graphics.endFill();
		}
		
	}

}