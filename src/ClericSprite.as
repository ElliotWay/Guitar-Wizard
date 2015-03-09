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
		
		private static const FRAME_WIDTH:int = 40;
		private static const FRAME_HEIGHT:int = 48;
		
		private static const MOVEMENT_POSITION:int = 0;
		private static const MOVEMENT_FRAMES:int = 4;
		private static var movementAnimation:FrameAnimation;
		private static var retreatingAnimation:FrameAnimation;
		
		private static const SUMMON_POSITION:int = FRAME_HEIGHT;
		private static const SUMMON_FRAMES:int = 6;
		private static var summonAnimation:FrameAnimation;
		private static var summonAnimationReversed:FrameAnimation;
		
		private static const FIGHTING_POSITION:int = FRAME_HEIGHT * 2;
		private static const FIGHTING_FRAMES:int = 9;
		private static var fightingAnimation:FrameAnimation;
		private static var fightingAnimationReversed:FrameAnimation;
		
		private static const DYING_POSITION:int = FRAME_HEIGHT * 3;
		private static const DYING_FRAMES:int = 8;
		private static const DYING_FRAME_WIDTH:int = 60;
		private static var dyingAnimation:FrameAnimation;
		private static var dyingAnimationReversed:FrameAnimation;
		
		private static var standingAnimation:FrameAnimation;
		private static var standingAnimationReversed:FrameAnimation;
		
		public static const TIME_BETWEEN_BLOWS:Number = 1000 * (1.0 / 24.0) * 3 * 5;
		
		public static const CENTER:Point = new Point(FRAME_WIDTH / 2, FRAME_HEIGHT / 2);
		public static const HIT_BOX:Rectangle = new Rectangle(10, 10, 11, 30);
		
		private var relativeCenter:Point;
		private var relativeHitBox:Rectangle;
		
		public static function initializeAnimations():void {
			var clericData:BitmapData = (new ClericImage() as Bitmap).bitmapData;
			
			movementAnimation = FrameAnimation.create(clericData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, MOVEMENT_FRAMES, 5);
					
			retreatingAnimation = FrameAnimation.flip(movementAnimation);
			
			summonAnimation = FrameAnimation.create(clericData,
					new Point(0, SUMMON_POSITION), FRAME_WIDTH, FRAME_HEIGHT, SUMMON_FRAMES, 5);
			summonAnimationReversed = FrameAnimation.flip(summonAnimation);
			
			fightingAnimation = FrameAnimation.create(clericData,
					new Point(0, FIGHTING_POSITION), FRAME_WIDTH, FRAME_HEIGHT, FIGHTING_FRAMES, 5);
			fightingAnimationReversed = FrameAnimation.flip(fightingAnimation);
			
			dyingAnimation = FrameAnimation.create(clericData,
					new Point(0, DYING_POSITION), DYING_FRAME_WIDTH, FRAME_HEIGHT, DYING_FRAMES, 5);
			dyingAnimationReversed = FrameAnimation.flip(dyingAnimation);
			
			standingAnimation = FrameAnimation.create(clericData,
					new Point(0, MOVEMENT_POSITION), FRAME_WIDTH, FRAME_HEIGHT, 1, 50);
			standingAnimationReversed = FrameAnimation.flip(standingAnimation);
		}
		
		public function ClericSprite(facesRight:Boolean) 
		{
			super();
			
			var move:FrameAnimation, retreat:FrameAnimation, summon:FrameAnimation;
			var bless:FrameAnimation, fight:FrameAnimation, die:FrameAnimation;
			var stand:FrameAnimation;
			
			if (facesRight) {
				move = movementAnimation.copy();
				retreat = retreatingAnimation.copy();
				summon = summonAnimation.copy();
				fight = fightingAnimation.copy();
				//bless = blessAnimation.copy();
				die = dyingAnimation.copy();
				stand = standingAnimation.copy();
				
				relativeCenter = CENTER;
				relativeHitBox = HIT_BOX;
			} else {
				move = retreatingAnimation.copy();
				retreat = movementAnimation.copy();
				summon = summonAnimationReversed.copy();
				fight = fightingAnimationReversed.copy();
				//bless = blessAnimationReversed.copy();
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
				
			super.animations[Status.RETREATING] = retreat;
			this.addChild(retreat);
			retreat.visible = false;
				
			super.animations[Status.SUMMONING] = summon;
			this.addChild(summon);
			summon.visible = false;
				
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
		
		override public function get center():Point {
			return new Point(this.x + relativeCenter.x, this.y + relativeCenter.y);
		}
		
		override public function get hitBox():Rectangle {
			return new Rectangle(this.x + relativeHitBox.x, this.y + relativeHitBox.y, relativeHitBox.width, relativeHitBox.height);
		}
		
	}

}