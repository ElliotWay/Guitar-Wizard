package src 
{
	/**
	 * Sprite for an actor whose movement is defined by arbitrary requested steps,
	 * instead of regular frames.
	 */
	public class SteppedActorSprite extends ActorSprite 
	{
		
		public function SteppedActorSprite() 
		{
			super();
			
		}
		
		/**
		 * Switch to the requested status animation. Doesn't actually <i>animate</i> anything,
		 * but use step() to switch through the frames.
		 * @param	status  the animation to switch to
		 * @param	onComplete a function to run when the final frame is stepped past
		 */
		override public function animate(status:int, onComplete:Function = null):void {
			
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
				currentAnimation.visible = false;
			}
			
			if (animation != null) {
				animation.visible = true;
				currentAnimation = animation;
				
			} else {
				defaultAnimation.visible = true;
				currentAnimation = defaultAnimation;
			}
			
			if (onComplete != null) {
				currentAnimation.setOnComplete(onComplete);
			}
		}
		
		/**
		 * Switch to the default animation. Doesn't actually <i>animate</i> anything,
		 * but use step() to switch through the frames.
		 */
		override public function animateDefault():void {
			if (currentAnimation != defaultAnimation && currentAnimation != null) {
				currentAnimation.visible = false;
				
				defaultAnimation.visible = true;
				
				currentAnimation = defaultAnimation;
			}
		}
		
		/**
		 * Move to the next frame of the current animation.
		 */
		public function step():void {
			currentAnimation.nextFrame();
		}
	}

}