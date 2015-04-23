package src {
	
	import com.greensock.core.Animation;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Base class for actor sprite that defines interaction with animations.
	 * Subclasses should add elements to animations and set defaultAnimation.
	 * @author Elliot Way
	 */
	public class ActorSprite extends Sprite 
	{
		public static const PLAYER_COLOR:uint = 0x0000FF;
		public static const OPPONENT_COLOR:uint = 0xFF0000;
		
		public static const PLAYER:int = 0;
		public static const OPPONENT:int = 1;
		
		public static const RIGHT_FACING:int = 0;
		public static const LEFT_FACING:int = 1;
		
		
		
		[Embed(source = "../assets/blessing.png")]
		private static const BlessImage:Class;
		
		protected var animations:Object;
		
		protected var currentAnimation:FrameAnimation;
		protected var defaultAnimation:FrameAnimation;
		
		private static const BLESS_EFFECT:BitmapData = (new BlessImage() as Bitmap).bitmapData;
		
		private var blessedEffect:Bitmap;
		
		
		
		public function ActorSprite() 
		{
			animations = new Object();
			
			currentAnimation = null;
			
			blessedEffect = new Bitmap(BLESS_EFFECT);
			this.addChild(blessedEffect);
			blessedEffect.visible = false;
		}
		
		public function alignEffects(relativeCenter:Point):void {
			blessedEffect.x = relativeCenter.x - BLESS_EFFECT.width / 2;
			blessedEffect.y = 0;
		}
		
		public function showBlessed():void {
			
			blessedEffect.visible = true;
		}
		
		public function hideBlessed():void {
			blessedEffect.visible = false;
		}
		
		/**
		 * Animate the given status.
		 * @param	status the status to animate
		 * @param	onComplete a function to run once we're past the last frame
		 */
		public function animate(status:int, repeater:Repeater, onComplete:Function = null):void {
			if (status == Status.DYING)
				hideBlessed();
			
			var animation:FrameAnimation;
			var value:* = animations[status];
			
			if (value == undefined) {
				animation = null;
			} else {
				animation = value as FrameAnimation;
			}
			
			//If we're already animating this status, just keep doing that.
			if (animation == currentAnimation && currentAnimation != null) {
				return;
			}
			
			if (currentAnimation != null) {
				currentAnimation.stop(repeater);
				currentAnimation.visible = false;
			}
			
			if (animation != null) {
				animation.go(repeater);
				animation.visible = true;
				currentAnimation = animation;
				
			} else {
				defaultAnimation.go(repeater);
				defaultAnimation.visible = true;
				currentAnimation = defaultAnimation;
			}
			
			if (onComplete != null) {
				currentAnimation.setOnComplete(onComplete);
			}
		}
		
		/**
		 * Tell the current animation to advance to the next frame immediately.
		 * This is more effective if the animations frame rate is slow or only on step.
		 */
		public function step():void {
			currentAnimation.nextFrame();
		}
		
		
		/**
		 * Animate the default animation.
		 *//* Function was unused.
		public function animateDefault(repeater:Repeater):void {
			if (currentAnimation != defaultAnimation && currentAnimation != null) {
				currentAnimation.stop(repeater);
				currentAnimation.visible = false;
				
				defaultAnimation.go(repeater);
				defaultAnimation.visible = true;
				
				currentAnimation = defaultAnimation;
			}
		}*/
		
		/**
		 * Stop the current animation at its current frame.
		 */
		public function freeze(repeater:Repeater):void {
			if (currentAnimation != null)
				currentAnimation.stop(repeater);
		}
		
		/**
		 * Move this animation to the bottom of its parent container.
		 */
		public function moveToBottom():void {
			if (this.parent != null) {
				this.parent.addChildAt(this, 0);
			}
		}
		
		public function get center():Point {
			return new Point(this.x + this.width / 2, this.y + this.height / 2);
		}
		
		public function get hitBox():Rectangle {
			return this.getBounds(this.parent);
		}
	}

}