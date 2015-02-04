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
			this.graphics.moveTo(0, 3);
			this.graphics.lineTo(1.5, 0);
			this.graphics.lineTo(3, 3);
		}
		
	}

}