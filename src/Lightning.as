package src 
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author 
	 */
	public class Lightning extends Sprite
	{
		[Embed(source = "../assets/lightning.png")]
		private static const LightningImage:Class;
		private static const LIGHTNING_DATA:BitmapData = (new LightningImage() as Bitmap).bitmapData;

		[Embed(source = "../assets/lightning2.png")]
		private static const Lightning2Image:Class;
		private static const LIGHTNING_DATA_2:BitmapData = (new Lightning2Image() as Bitmap).bitmapData;

		
		private static const FRAME_WIDTH:int = 48;
		private static const FRAME_HEIGHT:int = 144;
		
		private static const LIGHTNING_ANIMATION:FrameAnimation =
		FrameAnimation.create(LIGHTNING_DATA, new Point(0, 0), FRAME_WIDTH, FRAME_HEIGHT,
		5, FrameAnimation.EVERY_FRAME, 0x0, false, false);
		
		private static const LIGHTNING_ANIMATION_2:FrameAnimation = 
		FrameAnimation.create(LIGHTNING_DATA_2, new Point(0, 0), 38, 133,
		5, FrameAnimation.EVERY_FRAME, 0x0, false, false);
		
		private var animation:FrameAnimation;
		
		public function Lightning(source:Point, target:Point) 
		{
			var choice:int = Math.random() * 2;
			
			if (choice == 0)
				animation = LIGHTNING_ANIMATION.copy();
			else 
				animation = LIGHTNING_ANIMATION_2.copy();
			
			this.addChild(animation);
			animation.visible = true;
			
			var angle:Number = Math.atan2(target.y - source.y,
					target.x - source.x);
					
			//Rotate the position of the top left corner.
			//Supposing the the image starts facing right,
			//we want the point to be at (0, Y) where Y is half the width of the this image.
			//[0] [cosA  -sinA]  = 0cosA - YsinA = (-YsinA, YcosA)
			// Y   sinA   cosA     0sinA + YcosA
			this.x = source.x - (this.width / 2) * Math.sin(angle);
			this.y = source.y + (this.width / 2) * Math.cos(angle);
			
			this.scaleY = (Math.sqrt((source.x - target.x) * (source.x - target.x)
					+ (source.y - target.y) * (source.y - target.y))) /
					this.height;
					
			this.rotation = angle * (180 / Math.PI) - 90;
			this.cacheAsBitmap = true;
		}
		
		public function go(repeater:Repeater):void {
			var lightningFadeTimer:Timer = new Timer(100, 1);
			var self:Lightning = this;
			lightningFadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
				self.parent.removeChild(self);
			});
			
			animation.setOnComplete(function():void {
				lightningFadeTimer.start();
				
				animation.stop(repeater);
			});
			
			animation.go(repeater);
		}
		
	}

}