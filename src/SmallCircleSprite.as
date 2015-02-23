package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class SmallCircleSprite extends MiniSprite 
	{
		
		public function SmallCircleSprite(color:uint) 
		{
			graphics.beginFill(color);
			graphics.drawCircle(2, 2, 2);
		}
		
	}

}