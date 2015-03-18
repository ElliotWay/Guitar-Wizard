package src 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class WizardSprite extends ActorSprite
	{
		
		[Embed(source = "../assets/wizard.png")]
		private static const WizardImage:Class;
		private static const WIZARD_DATA:BitmapData = (new WizardImage() as Bitmap).bitmapData;
		
		private static const FRAME_WIDTH:int = 25;
		private static const FRAME_HEIGHT:int = 25;
		
		private static const DYING_FRAME_WIDTH:int = 40;
		
		public static const ANIMATIONS:AnimationCollection =
		new AnimationCollection(WIZARD_DATA, FRAME_WIDTH, FRAME_HEIGHT,
		//status, 				yposition, num frames, frames per beat,	(true, different width)
		Status.PLAY_HIGH,				0,  14, FrameAnimation.ONE_PER_BEAT,
		Status.PLAY_MID,				0,  14, FrameAnimation.ONE_PER_BEAT,
		Status.DYING,		  FRAME_WIDTH,	11, FrameAnimation.TWO_PER_BEAT, true, DYING_FRAME_WIDTH,
		Status.STANDING,                0,   1, FrameAnimation.ONE_THIRD_PER_BEAT);
		
		ANIMATIONS.find(Status.PLAY_MID, ActorSprite.PLAYER, ActorSprite.RIGHT_FACING)
				.setFramesPerBeat(FrameAnimation.ON_STEP);
		
		public function WizardSprite(isPlayerPiece:Boolean) 
		{
			
			ANIMATIONS.initializeMap(super.animations,
					isPlayerPiece ? ActorSprite.PLAYER : ActorSprite.OPPONENT,
					isPlayerPiece ? ActorSprite.RIGHT_FACING : ActorSprite.LEFT_FACING);
			
			this.addChild(super.animations[Status.PLAY_MID]);
			this.addChild(super.animations[Status.PLAY_HIGH]);
			this.addChild(super.animations[Status.DYING]);
			this.addChild(super.animations[Status.STANDING]);
			
			var mid:FrameAnimation = super.animations[Status.PLAY_MID];
			
			mid.visible = true;
			
			super.defaultAnimation = super.animations[Status.STANDING];
			
			if (isPlayerPiece) {
				//This branch included for similarity to other sprite classes.
			} else {
				super.animations[Status.DYING].x = FrameAnimation.SCALE * (FRAME_WIDTH - DYING_FRAME_WIDTH); //Large animations need to be shifted.
			}
			
			//No effects on wizards.
		}
		
	}

}