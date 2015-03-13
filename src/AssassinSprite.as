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
	public class AssassinSprite extends ActorSprite 
	{
		[Embed(source="../assets/assassin.png")]
		private static const AssassinImage:Class;
		private static const ASSASSIN_DATA:BitmapData = (new AssassinImage() as Bitmap).bitmapData;
		
		private static const FRAME_WIDTH:int = 24;
		private static const FRAME_HEIGHT:int = 24;
		private static const DYING_FRAME_WIDTH:int = 30;
		
		public static const ANIMATIONS:AnimationCollection =
		new AnimationCollection(ASSASSIN_DATA, FRAME_WIDTH, FRAME_HEIGHT,
		//status, 					yposition, num frames, frames per beat,	(true, different width)
		Status.MOVING, 						0, 	4, FrameAnimation.FOUR_PER_BEAT,
		Status.SUMMONING, 		 FRAME_HEIGHT, 	5, FrameAnimation.TWO_PER_BEAT,
		Status.ASSASSINATING,FRAME_HEIGHT * 2, 	11, FrameAnimation.FOUR_PER_BEAT,
		Status.FIGHTING, 	 FRAME_HEIGHT * 3, 	9, FrameAnimation.THREE_PER_BEAT,
		Status.DYING, 		 FRAME_HEIGHT * 4, 	8, FrameAnimation.TWO_PER_BEAT, true, DYING_FRAME_WIDTH,
		Status.STANDING,					0,	1, FrameAnimation.ONE_THIRD_PER_BEAT);
		
		public static const CENTER:Point = new Point(30, 22);
		public static const HIT_BOX:Rectangle = new Rectangle(22, 5, 15, 32);
		
		private var relativeCenter:Point;
		private var relativeHitBox:Rectangle;
		
		public function AssassinSprite(isPlayerUnit:Boolean, facesRight:Boolean) 
		{
			
			ANIMATIONS.initializeMap(super.animations,
					isPlayerUnit ? ActorSprite.PLAYER : ActorSprite.OPPONENT,
					facesRight ? ActorSprite.RIGHT_FACING : ActorSprite.LEFT_FACING);
					
			this.addChild(super.animations[Status.MOVING]);
			this.addChild(super.animations[Status.SUMMONING]);
			this.addChild(super.animations[Status.ASSASSINATING]);			
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
				super.animations[Status.DYING].x = FrameAnimation.SCALE * (FRAME_WIDTH - DYING_FRAME_WIDTH); //Large animations need to be shifted.
				
				relativeCenter = new Point(
						FrameAnimation.SCALE*FRAME_WIDTH - CENTER.x, CENTER.y);
				relativeHitBox = new Rectangle(
						FrameAnimation.SCALE*FRAME_WIDTH - HIT_BOX.x - HIT_BOX.width, HIT_BOX.y,
						HIT_BOX.width, HIT_BOX.height);
			}
			
			alignEffects(relativeCenter);
		}
		
		public static function timeToLand():Number {
			// (time/beat) * (beat/frame) * (7th frame)
			//		?	   *	(1/3)     *  7
			
			return Main.getBeat() * (7.0 / 3.0);
		}
		
		public static function timeBetweenStabs():Number {
			// (time/beat) * (beat/frame) * (3 frames)
			//		?	   *	(1/3)     *  3
			
			return Main.getBeat();
		}
		
		override public function get center():Point {
			return new Point(this.x + relativeCenter.x, this.y + relativeCenter.y);
		}
		
		override public function get hitBox():Rectangle {
			return new Rectangle(this.x + relativeHitBox.x, this.y + relativeHitBox.y, relativeHitBox.width, relativeHitBox.height);
		}
		
	}

}