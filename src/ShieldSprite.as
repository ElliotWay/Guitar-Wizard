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
		
		public static const FRAME_WIDTH:int = 56;
		public static const FRAME_HEIGHT:int = 150;
		
		private static var standingAnimation:FrameAnimation;
		private static var standingAnimationReversed:FrameAnimation;
		
		public static const CENTER:Point = new Point(43, 57);
		
		private var relativeCenter:Point;
		
		public static function initializeAnimations():void {
			var shieldData:BitmapData = (new ShieldData() as Bitmap).bitmapData;
			
			standingAnimation = FrameAnimation.create(shieldData,
					new Point(0, 0), FRAME_WIDTH, FRAME_HEIGHT, 1, 0xFFFFFFF);
			standingAnimationReversed = FrameAnimation.flip(standingAnimation);
		}
		
		public function ShieldSprite(isPlayerPiece:Boolean) 
		{
			super();
			
			var stand:FrameAnimation;
			
			if (isPlayerPiece) {
				stand = standingAnimation.copy();
				
				relativeCenter = CENTER;
			} else {
				stand = standingAnimationReversed.copy();
				
				relativeCenter = new Point(FRAME_WIDTH - CENTER.x, CENTER.y);
			}
			
			this.addChild(stand);
			stand.visible = true;
			super.animations[Status.STANDING] = stand;
			
			super.defaultAnimation = stand;
		}
		
		override public function get center():Point {
			return new Point(this.x + relativeCenter.x, this.y + relativeCenter.y);
		}
		
		override public function get hitBox():Rectangle {
			return this.getBounds(this.parent);
		}
		
	}

}