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
		
		[Embed(source="../assets/archer.png")]
		private static const ArcherImage:Class;
		
		private static const FRAME_WIDTH:int = 72;
		private static const FRAME_HEIGHT:int = 96;
		
		private static const MOVEMENT_POSITION:int = 0;
		private static const MOVEMENT_FRAMES:int = 4;
		private static var movementAnimation:FrameAnimation;
		
		private static const RETREAT_POSITION:int = FRAME_HEIGHT * 1;
		private static const RETREAT_FRAMES:int = 4;
		private static var retreatingAnimation:FrameAnimation;
		
		private static const SHOOTING_POSITION:int = FRAME_HEIGHT * 2;
		private static const SHOOTING_FRAMES:int = 6;
		private static var shootingAnimation:FrameAnimation;
		private static var shootingAnimationReversed:FrameAnimation;
		
		private static const DYING_POSITION:int = FRAME_HEIGHT * 3;
		private static const DYING_FRAMES:int = 9;
		private static const DYING_FRAME_WIDTH:int = 140;
		private static var dyingAnimation:FrameAnimation;
		private static var dyingAnimationReversed:FrameAnimation;
		
		private static var standingAnimation:FrameAnimation;
		private static var standingAnimationReversed:FrameAnimation;
		
												//24FPS, 4th frame, 5 frames/frame
		public static const TIME_UNTIL_FIRED:Number = 1000 * (1.0/24.0) * 5 * 4;
		public static const TIME_TO_SHOOT:Number = 1000 * (1.0 / 24.0) * 5 * SHOOTING_FRAMES;
		public static const ARROW_POSITION:Point = new Point(60, 25);
		
		public static function initializeAnimations():void {
			var archerData:BitmapData = (new ArcherImage() as Bitmap).bitmapData;
			
			movementAnimation = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 5);
					
			//retreatingAnimation = FrameAnimation.create(archerData,
			//		new Point(0, RETREAT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, RETREAT_FRAMES, 5);
			retreatingAnimation = FrameAnimation.flip(movementAnimation);
					
			shootingAnimation = FrameAnimation.create(archerData,
					new Point(0, SHOOTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SHOOTING_FRAMES, 5);
			shootingAnimationReversed = FrameAnimation.flip(shootingAnimation);
			
			dyingAnimation = FrameAnimation.create(archerData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES, 5);
			dyingAnimationReversed = FrameAnimation.flip(dyingAnimation);
			
			standingAnimation = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1, 0xFFFFFFFF);
			standingAnimationReversed = FrameAnimation.flip(standingAnimation);
		}
		
		public function ArcherSprite(color:uint, facesRight:Boolean) 
		{
			super();
			/*this.graphics.beginFill(color);
			this.graphics.moveTo(0, 20);
			this.graphics.lineTo(10, 0);
			this.graphics.lineTo(20, 20);
			this.graphics.endFill();*/
			
			
			//Copy these animations instead of using the animations themselves.
			//This way there's only one copy of each bitmap frame.
			
			var move:FrameAnimation;
			if (facesRight)
				move = movementAnimation.copy();
			else 
				move = FrameAnimation.flip(movementAnimation);
				
			super.animations[Status.MOVING] = move;
			this.addChild(move);
			move.visible = false;
			
			var retreat:FrameAnimation;
			if (facesRight)
				retreat = retreatingAnimation.copy();
			else
				retreat = movementAnimation.copy();
				
			super.animations[Status.RETREATING] = retreat;
			this.addChild(retreat);
			retreat.visible = false;
			
			var shoot:FrameAnimation;
			if (facesRight)
				shoot = shootingAnimation.copy();
			else
				shoot = shootingAnimationReversed.copy();
				
			super.animations[Status.SHOOTING] = shoot;
			this.addChild(shoot);
			shoot.visible = false;
			
			var die:FrameAnimation;
			if (facesRight)
				die = dyingAnimation.copy();
			else
				die = dyingAnimationReversed.copy();
				
			super.animations[Status.DYING] = die;
			this.addChild(die);
			die.visible = false;
			
			var stand:FrameAnimation;
			if (facesRight) 
				stand = standingAnimation.copy();
			else
				stand = standingAnimationReversed.copy();
				
			super.animations[Status.STANDING] = stand;
			this.addChild(stand);
			stand.visible = true;
			currentAnimation = stand;
			
			super.defaultAnimation = stand;
		}
	}

}