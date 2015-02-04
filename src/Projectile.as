package src 
{
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.plugins.DirectionalRotationPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TimelineLite;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author ...
	 */
	public class Projectile extends Sprite
	{
		
		public static const DAMAGE:Number = 10;
		
		
		public static const VELOCITY:Number = 350; // pxl/s
		
		public static const GRAVITY:Number = 300; // pxl/s^2
		
		/**
		 * Constant for use in trajectory equations: v^2/g.
		 * Also the maximum range of a projectile.
		 */
		public static const TRAJECTORY_CONSTANT:Number = (VELOCITY * VELOCITY) / GRAVITY; //pxl
		
		public static const ERROR:Number = .1; // radians
		
		
		private var _targetPosition:Number;
		
		private var _targets:int;
		private var _finished:Boolean;
		
		private var timeline:TimelineLite;
		
		/**
		 * Create a new projectile.
		 * @param	targets bit mask of possible targets
		 * @param	targetPosition x position of intended target
		 */
		public function Projectile(targets:int, targetPosition:Number) 
		{
			_targets = targets;
			
			_finished = false;
			
			_targetPosition = targetPosition;
			
			this.graphics.beginFill(0x005000);
			this.graphics.moveTo( -3, -3);
			this.graphics.lineTo( -3, 3);
			this.graphics.lineTo( 9, 0);
			this.graphics.endFill();
		}
		
		/**
		 * The projectile collides with the actor.
		 * @param	actor the actor to collide with
		 */
		public function collide(actor:Actor):void {
			actor.hitpoints -= DAMAGE;
			
			_finished = true;
			
			timeline.kill();
			
			this.parent.removeChild(this);
		}
		
		/**
		 * Checks if the projectile can hit the actor.
		 * @param	actor the actor to check
		 * @return whether the projectile can hit the actor
		 */
		public function hitTest(actor:Actor):Boolean {
			return actor.isValidTarget() && this.hitTestObject(actor.sprite);
		}
		
		/**
		 * Checks if the projectile should stop from means unrelated to
		 * collisions, generally because it hasn't hit anything.
		 */
		public function askIfFinished():void {
			if (this.y >= Actor.Y_POSITION) {
				this.parent.removeChild(this);
				
				timeline.kill();
				
				_finished = true;
			}
		}
		
		/**
		 * Starts the projectile animation.
		 */
		public function go():void {
			
			//Do some calcuations first.
			var targetIsLeft:Boolean = (_targetPosition < this.x);
			
			var targetDistance:Number = targetIsLeft ? (this.x - _targetPosition) : (_targetPosition - this.x);
			
			var temp:Number = targetDistance / TRAJECTORY_CONSTANT;
			var idealAngle:Number;
			if (Math.abs(temp) > 1) {
				idealAngle = Math.PI / 4;
			} else {
				idealAngle = (0.5) * Math.asin(temp);
			}
			
			var actualAngle:Number = Math.max(.04, // around 2 degrees
					Math.min(1.5, // less than 90 degrees
					Math.random() * 2 * ERROR - ERROR + idealAngle));
					
			var horizontalVelocity:Number = Math.cos(actualAngle) * VELOCITY;
			var initialVerticalVelocity:Number = Math.sin(actualAngle) * VELOCITY;
					
			var actualDistance:Number = Math.sin(2 * actualAngle) * TRAJECTORY_CONSTANT;
			
			var peakTime:Number = initialVerticalVelocity / GRAVITY;
			
			var peakHeight:Number = this.y - (initialVerticalVelocity * initialVerticalVelocity)
											/ (GRAVITY * 2);
					
			var actualTarget:Number = targetIsLeft ? (this.x - actualDistance) : (this.x + actualDistance);
			
			
			//Now create the animations.
			var angleInDegrees:Number = (actualAngle * 180 / Math.PI);
			var targetRotation:Number;
			if (targetIsLeft) {
				this.rotation = 180 + angleInDegrees;
				targetRotation = 180 - angleInDegrees;
			} else {
				this.rotation = -angleInDegrees;
				targetRotation = angleInDegrees;
			}
			
			timeline = new TimelineLite( { onComplete:forceFinish } );
			
			//TODO simplify expressions
			
			//Add y movement and time labels
			timeline.add("start", "+=0");
			timeline.to(this, peakTime, { y:peakHeight, ease:Quad.easeOut } );
			timeline.to(this, peakTime, { y:this.y, ease:Quad.easeIn } );
			
			//X movement is simpler.
			timeline.to(this, actualDistance / horizontalVelocity,
					{x:actualTarget, ease:Linear.easeIn }, "start");
			
			//And rotation. "Linear" isn't accurate in general, but it serves
			//as a decent approximation at the top of a parabola.
			//(The real one is atan((initialVerticalVelocity + GRAVITY * time) / horizontalVelocity)
			TweenPlugin.activate([DirectionalRotationPlugin]);
			timeline.to(this, peakTime * 2,
					{directionalRotation:(targetRotation + "_short"), ease:Linear.easeIn }, "start");
					
			timeline.play();
		}
		
		public function forceFinish():void {
			this.parent.removeChild(this);
			
			timeline.kill();
			
			_finished = true;
		}
		
		public function get targets():int {
			return _targets;
		}
		
		public function get finished():Boolean {
			return _finished;
		}
	
	}

}