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
		private static const MOVEMENT_FRAMES:int = 4;
		
		private static const RETREAT_POSITION:int = FRAME_HEIGHT * 1;
		private static const RETREAT_FRAMES:int = 4;
		
		private static const SHOOTING_POSITION:int = FRAME_HEIGHT * 2;
		private static const SHOOTING_FRAMES:int = 6;
		
		public function ArcherSprite(color:uint) 
		{
			super();
			/*this.graphics.beginFill(color);
			this.graphics.moveTo(0, 20);
			this.graphics.lineTo(10, 0);
			this.graphics.lineTo(20, 20);
			this.graphics.endFill();*/
			
			var archerData:BitmapData = (new ArcherImage() as Bitmap).bitmapData;
			
			moveAnimation = new FrameAnimation(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 10);
					
			super.animations[Status.MOVING] = moveAnimation;
			this.addChild(moveAnimation);
			moveAnimation.visible = false;
			
			
			var retreatingAnimation:FrameAnimation = new FrameAnimation(archerData,
					new Point(0, RETREAT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, RETREAT_FRAMES, 10);
					
			super.animations[Status.RETREATING] = retreatingAnimation;
			this.addChild(retreatingAnimation);
			retreatingAnimation.visible = false;
			
			
			var shootingAnimation:FrameAnimation = new FrameAnimation(archerData,
					new Point(0, SHOOTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SHOOTING_FRAMES, 5);
					
			super.animations[Status.SHOOTING] = shootingAnimation;
			this.addChild(shootingAnimation);
			shootingAnimation.visible = false;
			
			
			var standingAnimation:FrameAnimation = new FrameAnimation(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1, 0xFFFFFFFF);
					
			super.animations[Status.STANDING] = standingAnimation;
			this.addChild(standingAnimation);
			standingAnimation.visible = true;
			currentAnimation = standingAnimation;
			
			super.defaultAnimation = standingAnimation;
		}
	}

}