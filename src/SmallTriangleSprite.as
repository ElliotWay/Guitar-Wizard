package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class SmallTriangleSprite extends MiniSprite 
	{
		
		public function SmallTriangleSprite(color:uint) 
		{
			this.graphics.beginFill(color);
			this.graphics.moveTo(0, 5);
			this.graphics.lineTo(2.5, 0);
			this.graphics.lineTo(5, 5);
		}
		
	}

}