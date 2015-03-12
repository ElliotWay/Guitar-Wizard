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
		
		private static const FRAME_WIDTH:int = 20;
		private static const FRAME_HEIGHT:int = 24;
		
		private static const MOVEMENT_POSITION:int = 0;
		private static const MOVEMENT_FRAMES:int = 4;
		private static var movementAnimation:FrameAnimation;
		private static var movementAnimationReversed:FrameAnimation;
		
		private static const SUMMON_POSITION:int = FRAME_HEIGHT;
		private static const SUMMON_FRAMES:int = 6;
		private static var summonAnimation:FrameAnimation;
		private static var summonAnimationReversed:FrameAnimation;
		
		private static const BLESS_POSITION:int = FRAME_HEIGHT * 2;
		private static const BLESS_FRAMES:int = 10;
		private static var blessAnimation:FrameAnimation;
		private static var blessAnimationReversed:FrameAnimation;
		
		private static const FIGHTING_POSITION:int = FRAME_HEIGHT * 3;
		private static const FIGHTING_FRAMES:int = 9;
		private static var fightingAnimation:FrameAnimation;
		private static var fightingAnimationReversed:FrameAnimation;
		
		private static const DYING_POSITION:int = FRAME_HEIGHT * 4;
		private static const DYING_FRAMES:int = 8;
		private static const DYING_FRAME_WIDTH:int = 30;
		private static var dyingAnimation:FrameAnimation;
		private static var dyingAnimationReversed:FrameAnimation;
		
		private static var standingAnimation:FrameAnimation;
		private static var standingAnimationReversed:FrameAnimation;
		
		public static const CENTER:Point = new Point(FRAME_WIDTH / 2, FRAME_HEIGHT / 2);
		public static const HIT_BOX:Rectangle = new Rectangle(10, 10, 11, 30);
		
		private var relativeCenter:Point;
		private var relativeHitBox:Rectangle;
		
		public static function initializeAnimations():void {
			var clericData:BitmapData = (new ClericImage() as Bitmap).bitmapData;
			
			movementAnimation = FrameAnimation.create(clericData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, false);
			movementAnimationReversed = FrameAnimation.create(clericData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, true);
			
			summonAnimation = FrameAnimation.create(clericData,
					new Point(0, SUMMON_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SUMMON_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, false);
			summonAnimationReversed = FrameAnimation.create(clericData,
					new Point(0, SUMMON_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SUMMON_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, true);
					
			blessAnimation = FrameAnimation.create(clericData,
					new Point(0, BLESS_POSITION), FRAME_WIDTH, FRAME_HEIGHT, BLESS_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, false);
			blessAnimationReversed = FrameAnimation.create(clericData,
					new Point(0, BLESS_POSITION), FRAME_WIDTH, FRAME_HEIGHT, BLESS_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, true);
					
			fightingAnimation = FrameAnimation.create(clericData,
					new Point(0, FIGHTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, FIGHTING_FRAMES,
					FrameAnimation.THREE_HALVES_PER_BEAT, 0x0000FF, false);
			fightingAnimationReversed = FrameAnimation.create(clericData,
					new Point(0, FIGHTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, FIGHTING_FRAMES,
					FrameAnimation.THREE_HALVES_PER_BEAT, 0xFF0000, true);
			
			dyingAnimation = FrameAnimation.create(clericData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, false);
			dyingAnimationReversed = FrameAnimation.create(clericData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, true);
			
			standingAnimation = FrameAnimation.create(clericData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1,
					FrameAnimation.ONE_THIRD_PER_BEAT, 0x0000FF, false);
			standingAnimationReversed = FrameAnimation.create(clericData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1,
					FrameAnimation.ONE_THIRD_PER_BEAT, 0xFF0000, true);
		}
		
		public function ClericSprite(facesRight:Boolean) 
		{
			super();
			
			var move:FrameAnimation, summon:FrameAnimation;
			var bless:FrameAnimation, fight:FrameAnimation, die:FrameAnimation;
			var stand:FrameAnimation;
			
			if (facesRight) {
				move = movementAnimation.copy();
				summon = summonAnimation.copy();
				fight = fightingAnimation.copy();
				bless = blessAnimation.copy();
				die = dyingAnimation.copy();
				stand = standingAnimation.copy();
				
				relativeCenter = CENTER;
				relativeHitBox = HIT_BOX;
			} else {
				move = movementAnimationReversed.copy();
				summon = summonAnimationReversed.copy();
				fight = fightingAnimationReversed.copy();
				bless = blessAnimationReversed.copy();
				die = dyingAnimationReversed.copy();
				die.x = (FRAME_WIDTH - DYING_FRAME_WIDTH); //Large animations need to be shifted.
				stand = standingAnimationReversed.copy();
				
				relativeCenter = new Point(FRAME_WIDTH - CENTER.x, CENTER.y);
				relativeHitBox = new Rectangle(FRAME_WIDTH - HIT_BOX.x - HIT_BOX.width, HIT_BOX.y,
						HIT_BOX.width, HIT_BOX.height);
			}
				
			super.animations[Status.MOVING] = move;
			this.addChild(move);
			move.visible = false;
				
			super.animations[Status.SUMMONING] = summon;
			this.addChild(summon);
			summon.visible = false;
			
			super.animations[Status.BLESSING] = bless;
			this.addChild(bless);
			bless.visible = false;
				
			super.animations[Status.FIGHTING] = fight;
			this.addChild(fight);
			fight.visible = false;
				
			super.animations[Status.DYING] = die;
			this.addChild(die);
			die.visible = false;
			
			super.animations[Status.STANDING] = stand;
			this.addChild(stand);
			stand.visible = true;
			
			currentAnimation = stand;
			
			super.defaultAnimation = stand;
		}
		
		public static function timeBetweenBlows():Number {
			// (time/beat) * (beat/frame) * (3 frames)
			//		?	   *	(2/3)     *  3
			
			return Main.getBeat() * 2;
		}
		
		public static function timeToBless():Number {
			// (time/beat) * (beat/frame) * (3rd frame)
			//		?	   *	(2/3)     *  3
			
			return Main.getBeat() * 2;
		}
		
		override public function get center():Point {
			return new Point(this.x + relativeCenter.x, this.y + relativeCenter.y);
		}
		
		override public function get hitBox():Rectangle {
			return new Rectangle(this.x + relativeHitBox.x, this.y + relativeHitBox.y, relativeHitBox.width, relativeHitBox.height);
		}
		
	}

}