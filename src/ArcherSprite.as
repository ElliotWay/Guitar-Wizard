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
		
		private static const FRAME_WIDTH:int = 36;
		private static const FRAME_HEIGHT:int = 48;
		
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
		
		private static const DYING_POSITION:int = FRAME_HEIGHT * 3;
		private static const DYING_FRAMES:int = 9;
		private static const DYING_FRAME_WIDTH:int = 70;
		private static var dyingAnimation:FrameAnimation;
		private static var dyingAnimationReversed:FrameAnimation;
		
		private static var standingAnimation:FrameAnimation;
		private static var standingAnimationReversed:FrameAnimation;
		
												//24FPS, 4th frame, 5 frames/frame
		public static const TIME_UNTIL_FIRED:Number = 1000 * (1.0/24.0) * 5 * 4;
		public static const TIME_TO_SHOOT:Number = 1000 * (1.0 / 24.0) * 5 * SHOOTING_FRAMES;
		public static const ARROW_POSITION:Point = new Point(30, 12);
		
		public static const CENTER:Point = new Point(FRAME_WIDTH / 2, FRAME_HEIGHT / 2);
		public static const HIT_BOX:Rectangle = new Rectangle(10, 10, 11, 30);
		
		private var relativeCenter:Point;
		private var relativeArrowPosition:Point;
		
		public static function initializeAnimations():void {
			var archerData:BitmapData = (new ArcherImage() as Bitmap).bitmapData;
			
			movementAnimation = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 5,
					0x0000FF, false);
			movementAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 5,
					0xFF0000, true);
					
			retreatingAnimation = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 5,
					0x0000FF, true);
			retreatingAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 5,
					0xFF0000, false);
			
			summonAnimation = FrameAnimation.create(archerData,
					new Point(0, SUMMON_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SUMMON_FRAMES, 5,
					0x0000FF, false);
			summonAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, SUMMON_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SUMMON_FRAMES, 5,
					0xFF0000, true);
					
			shootingAnimation = FrameAnimation.create(archerData,
					new Point(0, SHOOTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SHOOTING_FRAMES, 5,
					0x0000FF, false);
			shootingAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, SHOOTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SHOOTING_FRAMES, 5,
					0xFF0000, true);
			
			dyingAnimation = FrameAnimation.create(archerData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES, 5,
					0x0000FF, false);
			dyingAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES, 5,
					0xFF0000, true);
			
			standingAnimation = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1, 50,
					0x0000FF, false);
			standingAnimationReversed = FrameAnimation.create(archerData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1, 50,
					0xFF0000, true);
		}
		
		public function ArcherSprite(color:uint, facesRight:Boolean) 
		{
			super();
			
			//Copy these animations instead of using the animations themselves.
			//This way there's only one copy of each bitmap frame.
			
			var move:FrameAnimation, retreat:FrameAnimation, summon:FrameAnimation;
			var shoot:FrameAnimation, die:FrameAnimation, stand:FrameAnimation;
			
			if (facesRight) {
				move = movementAnimation.copy();
				retreat = retreatingAnimation.copy();
				summon = summonAnimation.copy();
				shoot = shootingAnimation.copy();
				die = dyingAnimation.copy();
				stand = standingAnimation.copy();
				
				relativeCenter = CENTER;
				relativeArrowPosition = ARROW_POSITION;
			} else {
				move = movementAnimationReversed.copy();
				retreat = retreatingAnimationReversed.copy();
				summon = summonAnimationReversed.copy();
				shoot = shootingAnimationReversed.copy();
				die = dyingAnimationReversed.copy();
				die.x = (FRAME_WIDTH - DYING_FRAME_WIDTH); //Large animations need to be shifted.
				stand = standingAnimationReversed.copy();
				
				relativeCenter = new Point(FRAME_WIDTH - CENTER.x, CENTER.y);
				relativeArrowPosition = new Point(FRAME_WIDTH - ARROW_POSITION.x, ARROW_POSITION.y);
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
				
			super.animations[Status.DYING] = die;
			this.addChild(die);
			die.visible = false;
				
			super.animations[Status.STANDING] = stand;
			this.addChild(stand);
			stand.visible = true;
			
			currentAnimation = stand;
			
			super.defaultAnimation = stand;
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