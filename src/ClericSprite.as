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
		private static const CLERIC_DATA:BitmapData = (new ClericImage() as Bitmap).bitmapData;
		
		private static const FRAME_WIDTH:int = 20;
		private static const FRAME_HEIGHT:int = 24;
		
		private static const DYING_FRAME_WIDTH:int = 30;
		
		
		public static const ANIMATIONS:AnimationCollection =
		new AnimationCollection(CLERIC_DATA, FRAME_WIDTH, FRAME_HEIGHT,
		//status, 				yposition, num frames, frames per beat,	loops, (true, different width)
		Status.MOVING, 					0, 	8, FrameAnimation.FOUR_PER_BEAT, true,
		Status.SUMMONING, 	 FRAME_HEIGHT, 	6, FrameAnimation.TWO_PER_BEAT, false,
		Status.BLESSING, FRAME_HEIGHT * 2, 	12, FrameAnimation.FOUR_PER_BEAT, false, 
		Status.FIGHTING, FRAME_HEIGHT * 3, 	9, FrameAnimation.THREE_HALVES_PER_BEAT, true,
		Status.DYING, 	 FRAME_HEIGHT * 4, 	8, FrameAnimation.TWO_PER_BEAT, false, true, DYING_FRAME_WIDTH,
		Status.STANDING,				0,	1, FrameAnimation.ONE_THIRD_PER_BEAT, false);

		
		public static const CENTER:Point = new Point(16, 32);
		public static const HIT_BOX:Rectangle = new Rectangle(10, 10, 11, 30);
		
		private var relativeCenter:Point;
		private var relativeHitBox:Rectangle;
		
		public function ClericSprite(isPlayerUnit:Boolean, facesRight:Boolean) 
		{
			
			ANIMATIONS.initializeMap(super.animations,
					isPlayerUnit ? Actor.PLAYER : Actor.OPPONENT,
					facesRight ? Actor.RIGHT_FACING : Actor.LEFT_FACING);
					
			this.addChild(super.animations[Status.MOVING]);
			this.addChild(super.animations[Status.SUMMONING]);
			this.addChild(super.animations[Status.BLESSING]);			
			this.addChild(super.animations[Status.FIGHTING]);
			this.addChild(super.animations[Status.DYING]);
			this.addChild(super.animations[Status.STANDING]);
			
			var stand:FrameAnimation = super.animations[Status.STANDING];
			
			stand.visible = true;
			currentAnimation = stand;
			super.defaultAnimation = stand;
					
			if (facesRight) {
				
				relativeCenter = CENTER;
				relativeHitBox = HIT_BOX;
			} else {
				super.animations[Status.DYING].x = FrameAnimation.SCALE*(FRAME_WIDTH - DYING_FRAME_WIDTH); //Large animations need to be shifted.
				
				relativeCenter = new Point(
						FrameAnimation.SCALE*FRAME_WIDTH - CENTER.x, CENTER.y);
				relativeHitBox = new Rectangle(
						FrameAnimation.SCALE*FRAME_WIDTH - HIT_BOX.x - HIT_BOX.width, HIT_BOX.y,
						HIT_BOX.width, HIT_BOX.height);
			}
			
			alignEffects(relativeCenter);
		}
		
		public static function timeBetweenBlows(repeater:Repeater):Number {
			// (time/beat) * (beat/frame) * (3 frames)
			//		?	   *	(2/3)     *  3
			
			return repeater.getBeat() * 2;
		}
		
		public static function timeToBless(repeater:Repeater):Number {
			// (time/beat) * (beat/frame) * (3rd frame)
			//		?	   *	(2/3)     *  6
			
			return repeater.getBeat() * 4;
		}
		
		override public function get center():Point {
			return new Point(this.x + relativeCenter.x, this.y + relativeCenter.y);
		}
		
		override public function get hitBox():Rectangle {
			return new Rectangle(this.x + relativeHitBox.x, this.y + relativeHitBox.y, relativeHitBox.width, relativeHitBox.height);
		}
		
	}

}