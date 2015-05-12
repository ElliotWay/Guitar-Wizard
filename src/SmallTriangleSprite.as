package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class SmallTriangleSprite extends MiniSprite 
	{
		
		public function SmallTriangleSprite(isPlayerPiece:Boolean) 
		{
			this.graphics.beginFill(isPlayerPiece ? 0x2020B0 : 0xB02020);
			this.graphics.moveTo(0, 5);
			this.graphics.lineTo(2.5, 0);
			this.graphics.lineTo(5, 5);
		}
		
	}

}