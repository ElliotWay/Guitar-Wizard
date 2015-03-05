package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class DefaultSprite extends ActorSprite 
	{
		
		public function DefaultSprite(color:uint) 
		{
			this.graphics.beginFill(color);
			this.graphics.drawRect(0, 0, 50, 50);
			this.graphics.endFill();
			
			super.defaultAnimation = new EmptyAnimation();
		}
		
	}

}