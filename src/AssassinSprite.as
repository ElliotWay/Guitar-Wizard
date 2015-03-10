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
		
		private static const FRAME_WIDTH:int = 48;
		private static const FRAME_HEIGHT:int = 48;
		
		private static const MOVEMENT_POSITION:int = 0;
		private static const MOVEMENT_FRAMES:int = 4;
		private static var movementAnimation:FrameAnimation;
		private static var movementAnimationReversed:FrameAnimation;
		
		private static const SUMMON_POSITION:int = FRAME_HEIGHT;
		private static const SUMMON_FRAMES:int = 5;
		private static var summonAnimation:FrameAnimation;
		private static var summonAnimationReversed:FrameAnimation;
		
		private static const ASSASSINATE_POSITION:int = FRAME_HEIGHT * 2;
		private static const ASSASSINATE_FRAMES:int = 11;
		private static var assassinateAnimation:FrameAnimation;
		private static var assassinateAnimationReversed:FrameAnimation;
		
		private static const FIGHTING_POSITION:int = FRAME_HEIGHT * 3;
		private static const FIGHTING_FRAMES:int = 9;
		private static var fightingAnimation:FrameAnimation;
		private static var fightingAnimationReversed:FrameAnimation;
		
		private static const DYING_POSITION:int = FRAME_HEIGHT * 4;
		private static const DYING_FRAMES:int = 8;
		private static const DYING_FRAME_WIDTH:int = 60;
		private static var dyingAnimation:FrameAnimation;
		private static var dyingAnimationReversed:FrameAnimation;
		
		private static var standingAnimation:FrameAnimation;
		private static var standingAnimationReversed:FrameAnimation;
		
		public static const CENTER:Point = new Point(30, 22);
		public static const HIT_BOX:Rectangle = new Rectangle(22, 5, 15, 32);
		
		private var relativeCenter:Point;
		private var relativeHitBox:Rectangle;
		
		public static function initializeAnimations():void {
			var assassinData:BitmapData = (new AssassinImage() as Bitmap).bitmapData;
			
			movementAnimation = FrameAnimation.create(assassinData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES,
					FrameAnimation.FOUR_PER_BEAT, 0x0000FF, false);
			movementAnimationReversed = FrameAnimation.create(assassinData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES,
					FrameAnimation.FOUR_PER_BEAT, 0xFF0000, true);
			
			summonAnimation = FrameAnimation.create(assassinData,
					new Point(0, SUMMON_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SUMMON_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, false);
			summonAnimationReversed = FrameAnimation.create(assassinData,
					new Point(0, SUMMON_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SUMMON_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, true);
					
			fightingAnimation = FrameAnimation.create(assassinData,
					new Point(0, FIGHTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, FIGHTING_FRAMES,
					FrameAnimation.THREE_PER_BEAT, 0x0000FF, false);
			fightingAnimationReversed = FrameAnimation.create(assassinData,
					new Point(0, FIGHTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, FIGHTING_FRAMES,
					FrameAnimation.THREE_PER_BEAT, 0xFF0000, true);
					
			assassinateAnimation = FrameAnimation.create(assassinData,
					new Point(0, ASSASSINATE_POSITION), FRAME_WIDTH, FRAME_HEIGHT, ASSASSINATE_FRAMES,
					FrameAnimation.FOUR_PER_BEAT, 0x0000FF, false);
			assassinateAnimationReversed = FrameAnimation.create(assassinData,
					new Point(0, ASSASSINATE_POSITION), FRAME_WIDTH, FRAME_HEIGHT, ASSASSINATE_FRAMES,
					FrameAnimation.FOUR_PER_BEAT, 0xFF0000, true);
			
			dyingAnimation = FrameAnimation.create(assassinData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES,
					FrameAnimation.FOUR_PER_BEAT, 0x0000FF, false);
			dyingAnimationReversed = FrameAnimation.create(assassinData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES,
					FrameAnimation.FOUR_PER_BEAT, 0xFF0000, true);
			
			standingAnimation = FrameAnimation.create(assassinData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1,
					FrameAnimation.ONE_THIRD_PER_BEAT, 0x0000FF, false);
			standingAnimationReversed = FrameAnimation.create(assassinData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1,
					FrameAnimation.ONE_THIRD_PER_BEAT, 0xFF0000, true);
		}
		
		public function AssassinSprite(facesRight:Boolean) 
		{
			super();
			
			var move:FrameAnimation, summon:FrameAnimation;
			var assassinate:FrameAnimation, fight:FrameAnimation, die:FrameAnimation;
			var stand:FrameAnimation;
			
			if (facesRight) {
				move = movementAnimation.copy();
				summon = summonAnimation.copy();
				fight = fightingAnimation.copy();
				assassinate = assassinateAnimation.copy();
				die = dyingAnimation.copy();
				stand = standingAnimation.copy();
				
				relativeCenter = CENTER;
				relativeHitBox = HIT_BOX;
			} else {
				move = movementAnimationReversed.copy();
				summon = summonAnimationReversed.copy();
				fight = fightingAnimationReversed.copy();
				assassinate = assassinateAnimationReversed.copy();
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
				
			super.animations[Status.ASSASSINATING] = assassinate;
			this.addChild(assassinate);
			assassinate.visible = false;
				
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