package src {
	import flash.display.Sprite;
	
	/**
	 * write this later
	 * @author Elliot Way
	 */
	public class ActorSprite extends Sprite 
	{
		
		public function ActorSprite(color:uint) 
		{
			this.graphics.beginFill(color);
			this.graphics.drawRect(0, 0, 20, 20);
			this.graphics.endFill();
		}
		
	}

}