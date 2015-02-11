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
		
		private static const DYING_POSITION:int = FRAME_HEIGHT * 3;
		private static const DYING_FRAMES:int = 9;
		private static const DYING_FRAME_WIDTH:int = 140;
		
												//24FPS, 4th frame, 5 frames/frame
		public static const TIME_UNTIL_FIRED:Number = 1000 * (1.0/24.0) * 5 * 4;
		public static const TIME_TO_SHOOT:Number = 1000 * (1.0 / 24.0) * 5 * SHOOTING_FRAMES;
		public static const ARROW_POSITION:Point = new Point(60, 25);
		
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
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 5);
					
			super.animations[Status.MOVING] = moveAnimation;
			this.addChild(moveAnimation);
			moveAnimation.visible = false;
			
			
			var retreatingAnimation:FrameAnimation = new FrameAnimation(archerData,
					new Point(0, RETREAT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, RETREAT_FRAMES, 5);
					
			super.animations[Status.RETREATING] = retreatingAnimation;
			this.addChild(retreatingAnimation);
			retreatingAnimation.visible = false;
			
			
			var shootingAnimation:FrameAnimation = new FrameAnimation(archerData,
					new Point(0, SHOOTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SHOOTING_FRAMES, 5);
					
			super.animations[Status.SHOOTING] = shootingAnimation;
			this.addChild(shootingAnimation);
			shootingAnimation.visible = false;
			
			var dyingAnimation:FrameAnimation = new FrameAnimation(archerData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES, 5);
			
			super.animations[Status.DYING] = dyingAnimation;
			this.addChild(dyingAnimation);
			dyingAnimation.visible = false;
			
			
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