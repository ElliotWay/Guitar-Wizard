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
		
		private static const FRAME_WIDTH:int = 18;
		private static const FRAME_HEIGHT:int = 24;
		
		private static const MOVEMENT_POSITION:int = 0;
		private static const MOVEMENT_FRAMES:int = 4;
		private static var movementAnimation:FrameAnimation;
		private static var movementAnimationReversed:FrameAnimation;
		private static var retreatingAnimation:FrameAnimation;
		private static var retreatingAnimationReversed:FrameAnimation;
		
		private static const SUMMON_POSITION:int = FRAME_HEIGHT;
		private static const SUMMON_FRAMES:int = 7;
		private static var summonAnimation:FrameAnimation;
		private static var summonAnimationReversed:FrameAnimation;
		
		private static const SHOOTING_POSITION:int = FRAME_HEIGHT * 2;
		private static const SHOOTING_FRAMES:int = 6;
		private static var shootingAnimation:FrameAnimation;
		private static var shootingAnimationReversed:FrameAnimation;
		
		private static const FIGHTING_POSITION:int = FRAME_HEIGHT * 3;
		private static const FIGHTING_FRAMES:int = 4;
		private static var fightingAnimation:FrameAnimation;
		private static var fightingAnimationReversed:FrameAnimation;
		
		private static const DYING_POSITION:int = FRAME_HEIGHT * 4;
		private static const DYING_FRAMES:int = 9;
		private static const DYING_FRAME_WIDTH:int = 35;
		private static var dyingAnimation:FrameAnimation;
		private static var dyingAnimationReversed:FrameAnimation;
		
		private static var standingAnimation:FrameAnimation;
		private static var standingAnimationReversed:FrameAnimation;
		
		public static const ARROW_TIME:Number = 6000;
		public static const ARROW_POSITION:Point = new Point(30, 12);
		
		public static const CENTER:Point = new Point(16, 24);
		public static const HIT_BOX:Rectangle = new Rectangle(10, 10, 11, 30);
		
		private var relativeCenter:Point;
		private var relativeArrowPosition:Point;
		
		public static function initializeAnimations():void {
			var archerData:BitmapData = (new ArcherImage() as Bitmap).bitmapData;
			
			movementAnimation = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, false);
			movementAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, true);
					
			retreatingAnimation = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, true);
			retreatingAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, false);
			
			summonAnimation = FrameAnimation.create(archerData,
					new Point(0, SUMMON_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SUMMON_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, false);
			summonAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, SUMMON_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SUMMON_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, true);
					
			shootingAnimation = FrameAnimation.create(archerData,
					new Point(0, SHOOTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SHOOTING_FRAMES,
					FrameAnimation.THREE_HALVES_PER_BEAT, 0x0000FF, false);
			shootingAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, SHOOTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SHOOTING_FRAMES,
					FrameAnimation.THREE_HALVES_PER_BEAT, 0xFF0000, true);
					
			fightingAnimation = FrameAnimation.create(archerData,
					new Point(0, FIGHTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, FIGHTING_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, false);
			fightingAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, FIGHTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, FIGHTING_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, true);
			
			dyingAnimation = FrameAnimation.create(archerData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0x0000FF, false);
			dyingAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES,
					FrameAnimation.TWO_PER_BEAT, 0xFF0000, true);
			
			standingAnimation = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1,
					FrameAnimation.ONE_THIRD_PER_BEAT, 0x0000FF, false);
			standingAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1,
					FrameAnimation.ONE_THIRD_PER_BEAT, 0xFF0000, true);
		}
		
		public function ArcherSprite(color:uint, facesRight:Boolean) 
		{
			super();
			
			//Copy these animations instead of using the animations themselves.
			//This way there's only one copy of each bitmap frame.
			
			var move:FrameAnimation, retreat:FrameAnimation, summon:FrameAnimation;
			var shoot:FrameAnimation, fight:FrameAnimation, die:FrameAnimation
			var stand:FrameAnimation;
			
			if (facesRight) {
				move = movementAnimation.copy();
				retreat = retreatingAnimation.copy();
				summon = summonAnimation.copy();
				shoot = shootingAnimation.copy();
				fight = fightingAnimation.copy();
				die = dyingAnimation.copy();
				stand = standingAnimation.copy();
				
				relativeCenter = CENTER;
				relativeArrowPosition = ARROW_POSITION;
			} else {
				move = movementAnimationReversed.copy();
				retreat = retreatingAnimationReversed.copy();
				summon = summonAnimationReversed.copy();
				shoot = shootingAnimationReversed.copy();
				fight = fightingAnimationReversed.copy();
				die = dyingAnimationReversed.copy();
				die.x = FrameAnimation.SCALE*(FRAME_WIDTH - DYING_FRAME_WIDTH); //Large animations need to be shifted.
				stand = standingAnimationReversed.copy();
				
				relativeCenter = new Point(
						FrameAnimation.SCALE*FRAME_WIDTH - CENTER.x, CENTER.y);
				relativeArrowPosition = new Point(
						FrameAnimation.SCALE*FRAME_WIDTH - ARROW_POSITION.x, ARROW_POSITION.y);
			}
				
			super.animations[Status.MOVING] = move;
			this.addChild(move);
			move.visible = false;
				
			super.animations[Status.RETREATING] = retreat;
			this.addChild(retreat);
			retreat.visible = false;
				
			super.animations[Status.SUMMONING] = summon;
			this.addChild(summon);
			summon.visible = false;
				
			super.animations[Status.SHOOTING] = shoot;
			this.addChild(shoot);
			shoot.visible = false;
			
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
			
			alignEffects(relativeCenter);
		}
		
		public static function timeUntilFired():Number {
			// (time/beat) * (beat/frame) * (5th frame)
			//		?	   *	(2/3)     *  5
			
			return Main.getBeat() * (10.0 / 3.0);
		}
		
		public static function timeBetweenBlows():Number {
			// (time/beat) * (beat/frame) * (4 frames)
			//		?	   *	(1/2)     *  4
			
			return Main.getBeat() * (2.0);
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