package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class SmallCircleSprite extends MiniSprite 
	{
		
		public function SmallCircleSprite(isPlayerPiece:Boolean) 
		{
			graphics.beginFill(isPlayerPiece ? 0x0040FF : 0xFF4000);
			graphics.drawCircle(2, 2, 2);
		}
		
	}

}