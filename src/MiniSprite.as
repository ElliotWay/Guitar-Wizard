package src 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class MiniSprite extends Sprite 
	{
		
		public function MiniSprite() 
		{
			this.graphics.beginFill(0xFFFF00);
			this.graphics.drawRect(0, 0, 2, 2);
			this.graphics.endFill();
		}
		
	}

}