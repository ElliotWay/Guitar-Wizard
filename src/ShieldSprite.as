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
	public class ShieldSprite extends ActorSprite 
	{
		[Embed(source = "../assets/shield.png")]
		private static const ShieldData:Class;
		private static const SHIELD_DATA:BitmapData = (new ShieldData() as Bitmap).bitmapData;
		
		public static const FRAME_WIDTH:int = 56;
		public static const FRAME_HEIGHT:int = 150;
		
		private static const ANIMATIONS:AnimationCollection =
		new AnimationCollection(SHIELD_DATA, FRAME_WIDTH, FRAME_HEIGHT,
		//status, 		yposition, num frames, frames per beat, loops,
		Status.DYING, 			0,			5, FrameAnimation.FOUR_PER_BEAT, false,
		Status.STANDING,		0,			1, FrameAnimation.ONE_THIRD_PER_BEAT, false);
		
		public static const CENTER:Point = new Point(86, 114);
		
		private var relativeCenter:Point;
		
		public function ShieldSprite(isPlayerUnit:Boolean, facesRight:Boolean) 
		{
			ANIMATIONS.initializeMap(super.animations,
					isPlayerUnit ? ActorSprite.PLAYER : ActorSprite.OPPONENT,
					facesRight ? ActorSprite.RIGHT_FACING : ActorSprite.LEFT_FACING);
			
			this.addChild(super.animations[Status.DYING]);
			this.addChild(super.animations[Status.STANDING]);
			
			var stand:FrameAnimation = super.animations[Status.STANDING];
			
			stand.visible = true;
			currentAnimation = stand;
			super.defaultAnimation = stand;
					
			if (facesRight) {
				relativeCenter = CENTER;
			} else {
				relativeCenter = new Point(FRAME_WIDTH * FrameAnimation.SCALE - CENTER.x, CENTER.y);
			}
		}
		
		override public function get center():Point {
			return new Point(this.x + relativeCenter.x, this.y + relativeCenter.y);
		}
		
		override public function get hitBox():Rectangle {
			return this.getBounds(this.parent);
		}
		
	}

}