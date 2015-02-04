package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class ArcherSprite extends ActorSprite 
	{
		
		public function ArcherSprite(color:uint) 
		{
			this.graphics.beginFill(color);
			this.graphics.moveTo(0, 20);
			this.graphics.lineTo(10, 0);
			this.graphics.lineTo(20, 20);
			this.graphics.endFill();
		}
		
	}

}