package src 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	/**
	 * Default animation for an ActorSprite that handles its animations
	 * a different way.
	 * @author Elliot Way
	 */
	public class EmptyAnimation extends FrameAnimation 
	{
		
		public function EmptyAnimation() 
		{
			super(null, null, 0, 0, 0, 0);
		}
		
		override public function go():void {
			//do nothing
		}
		
		override public function stop():void {
			//do nothing
		}
		
	}

}