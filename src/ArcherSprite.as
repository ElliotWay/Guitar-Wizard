package src 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class ArcherSprite extends ActorSprite 
	{
		private var moveAnimation:FrameAnimation;
		
		[Embed(source="../assets/archer.png")]
		private static const ArcherImage:Class;
		
		private static const FRAME_WIDTH:int = 72;
		private static const FRAME_HEIGHT:int = 96;
		
		private static const MOVEMENT_POSITION:int = 0;
		private static const MOVEMENT_FRAMES:int = 2;
		
		public function ArcherSprite(color:uint) 
		{
			/*this.graphics.beginFill(color);
			this.graphics.moveTo(0, 20);
			this.graphics.lineTo(10, 0);
			this.graphics.lineTo(20, 20);
			this.graphics.endFill();*/
			
			var archerData:BitmapData = (new ArcherImage() as Bitmap).bitmapData;
			
			moveAnimation = new FrameAnimation(archerData,
					new Point(MOVEMENT_POSITION, 0), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 20);
					
			this.addChild(moveAnimation);
			
			moveAnimation.visible = true;
		}
		
		private var once:Boolean = false;
		
		public function animateMoving():void {
			if (once)
				return;
			once = true;
			
			moveAnimation.visible = true;
			
			trace("go");
			moveAnimation.go();
		}
	}

}