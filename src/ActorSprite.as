package src {
	import com.greensock.core.Animation;
	import flash.display.Sprite;
	
	/**
	 * write this class later, probably give it animations
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
		
		public function animateDefault():void {
			if (currentAnimation != defaultAnimation && currentAnimation != null) {
				currentAnimation.stop();
				currentAnimation.visible = false;
				
				defaultAnimation.go();
				defaultAnimation.visible = true;
				
				currentAnimation = defaultAnimation;
			}
		}
		
		public function freeze():void {
			if (currentAnimation != null)
				currentAnimation.stop();
		}
	}

}