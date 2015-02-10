package src {
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
		
		public function animate(status:int):void {
			
			var animation:FrameAnimation = (animations[status] as FrameAnimation);
			
			//If we're already animating this status, just keep doing that.
			if (animation == currentAnimation) {
				return;
			}
			
			if (currentAnimation != null) {
				currentAnimation.stop();
				currentAnimation.visible = false;
			}
			
			if (animation != undefined) {
				animation.go();
				animation.visible = true;
				currentAnimation = animation;
				
			} else {
				defaultAnimation.go();
				defaultAnimation.visible = true;
				currentAnimation = defaultAnimation
			}
		}
		
		public function defaultAnimation():void {
			if (currentAnimation != defaultAnimation && currentAnimation != null) {
				currentAnimation.stop();
				currentAnimation.visible = false;
				
				defaultAnimation.go();
				defaultAnimation.visible = true;
				
				currentAnimation = defaultAnimation;
			}
		}
		
	}

}