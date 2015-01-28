package src 
{
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class SmallSquareSprite extends MiniSprite 
	{
		
		public function SmallSquareSprite(color:uint) 
		{
			this.graphics.beginFill(color);
			this.graphics.drawRect(0, 0, 3, 3);
			this.graphics.endFill();
		}
		
	}

}