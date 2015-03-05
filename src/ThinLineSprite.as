package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class ThinLineSprite extends MiniSprite 
	{
		
		public function ThinLineSprite(color:uint) 
		{
			this.graphics.beginFill(color);
			this.graphics.drawRect(0, 0, 2, 10);
			this.graphics.endFill();
		}
		
	}

}