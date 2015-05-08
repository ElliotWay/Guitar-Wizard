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
	public class ArcherSprite extends ActorSprite 
	{
		
		[Embed(source="../assets/archer.png")]
		private static const ArcherImage:Class;
		private static const ARCHER_DATA:BitmapData = (new ArcherImage() as Bitmap).bitmapData;
		
		
		private static const FRAME_WIDTH:int = 18;
		private static const FRAME_HEIGHT:int = 24;
		
		private static const DYING_FRAME_WIDTH:int = 35;
		
		
		public static const ANIMATIONS:AnimationCollection =
		new AnimationCollection(ARCHER_DATA, FRAME_WIDTH, FRAME_HEIGHT,
		//status, 				yposition, num frames, frames per beat,	loops, (true, different width)
		Status.MOVING, 					0, 	8, FrameAnimation.FOUR_PER_BEAT, true,
		Status.SUMMONING, 	 FRAME_HEIGHT, 	7, FrameAnimation.TWO_PER_BEAT, false,
		Status.SHOOTING, FRAME_HEIGHT * 2, 	12, FrameAnimation.THREE_PER_BEAT, true,
		Status.FIGHTING, FRAME_HEIGHT * 3, 	8, FrameAnimation.FOUR_PER_BEAT, true,
		Status.DYING, 	 FRAME_HEIGHT * 4, 	9, FrameAnimation.TWO_PER_BEAT, false, true, DYING_FRAME_WIDTH,
		Status.STANDING,				0,	1, FrameAnimation.ONE_THIRD_PER_BEAT, false);
		
		public static const ARROW_TIME:Number = 6000;
		public static const ARROW_POSITION:Point = new Point(30, 12);
		
		public static const CENTER:Point = new Point(16, 24);
		public static const HIT_BOX:Rectangle = new Rectangle(10, 10, 11, 30);
		
		private var relativeCenter:Point;
		private var relativeArrowPosition:Point;
		
		public function ArcherSprite(isPlayerUnit:Boolean, facesRight:Boolean) 
		{
			
			ANIMATIONS.initializeMap(super.animations,
					isPlayerUnit ? ActorSprite.PLAYER : ActorSprite.OPPONENT,
					facesRight ? ActorSprite.RIGHT_FACING : ActorSprite.LEFT_FACING);
					
			//Retreating is special because it doesn't have a dedicated animation;
			//it's just the movement animation facing the other direction.
			super.animations[Status.RETREATING] = ANIMATIONS.find(Status.MOVING,
					isPlayerUnit ? ActorSprite.PLAYER : ActorSprite.OPPONENT,
					facesRight ? ActorSprite.LEFT_FACING : ActorSprite.RIGHT_FACING).copy();
			
			this.addChild(super.animations[Status.MOVING]);
			this.addChild(super.animations[Status.RETREATING]);
			this.addChild(super.animations[Status.SUMMONING]);
			this.addChild(super.animations[Status.SHOOTING]);			
			this.addChild(super.animations[Status.FIGHTING]);
			this.addChild(super.animations[Status.DYING]);
			this.addChild(super.animations[Status.STANDING]);
			
			var stand:FrameAnimation = super.animations[Status.STANDING];
			
			stand.visible = true;
			currentAnimation = stand;
			super.defaultAnimation = stand;
			
			if (facesRight) {
				relativeCenter = CENTER;
				relativeArrowPosition = ARROW_POSITION;
			} else {
				super.animations[Status.DYING].x = FrameAnimation.SCALE * (FRAME_WIDTH - DYING_FRAME_WIDTH); //Large animations need to be shifted.
				
				relativeCenter = new Point(
						FrameAnimation.SCALE*FRAME_WIDTH - CENTER.x, CENTER.y);
				relativeArrowPosition = new Point(
						FrameAnimation.SCALE*FRAME_WIDTH - ARROW_POSITION.x, ARROW_POSITION.y);
			}
			
			alignEffects(relativeCenter);
		}
		
		public static function timeUntilFired(repeater:Repeater):Number {
			// (time/beat) * (beat/frame) * (5th frame)
			//		?	   *	(2/3)     *  5
			
			return repeater.getBeat() * (10.0 / 3.0);
		}
		
		public static function timeBetweenBlows(repeater:Repeater):Number {
			// (time/beat) * (beat/frame) * (4 frames)
			//		?	   *	(1/2)     *  4
			
			return repeater.getBeat() * (2.0);
		}
			
		override public function get center():Point {
			return new Point(this.x + relativeCenter.x, this.y + relativeCenter.y);
		}
		
		override public function get hitBox():Rectangle {
			return new Rectangle(this.x + HIT_BOX.x, this.y + HIT_BOX.y, HIT_BOX.width, HIT_BOX.height);
		}
		
		public function get arrowPosition():Point {
			return new Point(this.x + relativeArrowPosition.x, this.y + relativeArrowPosition.y);
		}
	}


}