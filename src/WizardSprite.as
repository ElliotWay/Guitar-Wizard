package src 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class WizardSprite extends SteppedActorSprite 
	{
		
		[Embed(source = "../assets/wizard.png")]
		private static const WizardImage:Class;
		
		private static const FRAME_WIDTH:int = 50;
		private static const FRAME_HEIGHT:int = 50;
		
		private static const MID_POSITION:int = 0;
		private static const MID_FRAMES:int = 14;
		private static var midAnimation:FrameAnimation;
		private static var midAnimationReversed:FrameAnimation;
		
		public static function initializeAnimations():void {
			var wizardData:BitmapData = (new WizardImage() as Bitmap).bitmapData;
			
			midAnimation = FrameAnimation.create(wizardData,
					new Point(0, MID_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MID_FRAMES, 5);
			midAnimationReversed = FrameAnimation.create(wizardData,
					new Point(0, MID_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MID_FRAMES, 5,
					0xFF0000, true);
		}
		
		public function WizardSprite(isPlayerPiece:Boolean) 
		{
			super();
			
			var playMid:FrameAnimation;
			
			if (isPlayerPiece) {
				playMid = midAnimation;
			} else {
				playMid = midAnimationReversed;
			}
			
			this.addChild(playMid);
			playMid.visible = true;
			super.animations[Status.PLAY_MID] = playMid;
			
			super.currentAnimation = playMid;
			super.defaultAnimation = playMid;
		}
		
	}

}