package src {
	import com.greensock.core.Animation;
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
		
		protected var animations:Object;
		
		protected var currentAnimation:FrameAnimation;
		protected var defaultAnimation:FrameAnimation;
		
		public function ActorSprite() 
		{
			animations = new Object();
			
			currentAnimation = null;
		}
		
		/**
		 * Animate the given status.
		 * @param	status the status to animate
		 * @param	onComplete a function to run once we're past the last frame
		 */
		public function animate(status:int, onComplete:Function = null):void {
			
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
				currentAnimation.stop();
				currentAnimation.visible = false;
			}
			
			if (animation != null) {
				animation.go();
				animation.visible = true;
				currentAnimation = animation;
				
			} else {
				defaultAnimation.go();
				defaultAnimation.visible = true;
				currentAnimation = defaultAnimation;
			}
			
			if (onComplete != null) {
				currentAnimation.setOnComplete(onComplete);
			}
		}
		
		/**
		 * Animate the default animation.
		 */
		public function animateDefault():void {
			if (currentAnimation != defaultAnimation && currentAnimation != null) {
				currentAnimation.stop();
				currentAnimation.visible = false;
				
				defaultAnimation.go();
				defaultAnimation.visible = true;
				
				currentAnimation = defaultAnimation;
			}
		}
		
		/**
		 * Stop the current animation at its current frame.
		 */
		public function freeze():void {
			if (currentAnimation != null)
				currentAnimation.stop();
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