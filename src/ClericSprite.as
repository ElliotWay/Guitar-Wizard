package src 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author ...
	 */
	public class ClericSprite extends ActorSprite
	{
		[Embed(source="../assets/cleric.png")]
		private static const ClericImage:Class;
		
		private static const FRAME_WIDTH:int = 80;
		private static const FRAME_HEIGHT:int = 96;
		
		private static const MOVEMENT_POSITION:int = 0;
		private static const MOVEMENT_FRAMES:int = 4;
		private static var movementAnimation:FrameAnimation;
		private static var retreatingAnimation:FrameAnimation;
		
		private static var standingAnimation:FrameAnimation;
		private static var standingAnimationReversed:FrameAnimation;
		
		public static const CENTER:Point = new Point(FRAME_WIDTH / 2, FRAME_HEIGHT / 2);
		public static const HIT_BOX:Rectangle = new Rectangle(20, 20, 23, 60);
		
		private var relativeCenter:Point;
		private var relativeHitBox:Rectangle;
		
		public static function initializeAnimations():void {
			var clericData:BitmapData = (new ClericImage() as Bitmap).bitmapData;
			
			movementAnimation = FrameAnimation.create(clericData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 5);
					
			retreatingAnimation = FrameAnimation.flip(movementAnimation);
			
			standingAnimation = FrameAnimation.create(clericData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1, 0xFFFFFFF);
			standingAnimationReversed = FrameAnimation.flip(standingAnimation);
		}
		
		public function ClericSprite(facesRight:Boolean) 
		{
			super();
			
			var move:FrameAnimation;
			if (facesRight)
				move = movementAnimation.copy();
			else 
				move = retreatingAnimation.copy();
				
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
			
			
			if (facesRight)
				relativeCenter = CENTER;
			else
				relativeCenter = new Point(FRAME_WIDTH - CENTER.x, CENTER.y);
				
			if (facesRight) {
				relativeHitBox = HIT_BOX;
			} else {
				relativeHitBox = new Rectangle(FRAME_WIDTH - HIT_BOX.x - HIT_BOX.width, HIT_BOX.y,
						HIT_BOX.width, HIT_BOX.height);
			}
		}
		
		override public function get center():Point {
			return new Point(this.x + relativeCenter.x, this.y + relativeCenter.y);
		}
		
		override public function get hitBox():Rectangle {
			return new Rectangle(this.x + relativeHitBox.x, this.y + relativeHitBox.y, relativeHitBox.width, relativeHitBox.height);
		}
		
	}

}