package src 
{
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.plugins.DirectionalRotationPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TimelineLite;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class Projectile extends Sprite
	{
		[Embed(source="../assets/arrow.png")]
		private static const ArrowImage:Class;
		
		public static const DAMAGE:Number = 1;
		
		
		public static const VELOCITY:Number = 400; // pxl/s
		
		public static const GRAVITY:Number = 300; // pxl/s^2
		
		/**
		 * Constant for use in trajectory equations: v^2/g.
		 * Also the maximum range of a projectile.
		 */
		public static const TRAJECTORY_CONSTANT:Number = (VELOCITY * VELOCITY) / GRAVITY; //pxl
		
		public static const ERROR:Number = .2; //.1 radians
		
		
		private var _targetPosition:Point;
		
		private var _targets:int;
		private var _finished:Boolean;
		
		private var timeline:TimelineLite;
		
		private var arrowHead:Sprite;
		
		/**
		 * Create a new projectile.
		 * @param	targets bit mask of possible targets
		 * @param	targetPosition x position of intended target
		 */
		public function Projectile(targets:int, targetPosition:Point) 
		{
			_targets = targets;
			
			_finished = false;
			
			_targetPosition = targetPosition;
			
			this.addChild((new ArrowImage() as Bitmap));
			
			arrowHead = new Sprite();
			this.addChild(arrowHead);
			arrowHead.graphics.beginFill(0xFF00FF);
			arrowHead.graphics.drawRect(0, 0, 2, 2);
			arrowHead.visible = false;
			arrowHead.x = 16;
			
		/*	this.graphics.beginFill(0x005000);
			this.graphics.moveTo( -3, -3);
			this.graphics.lineTo( -3, 3);
			this.graphics.lineTo( 9, 0);
			this.graphics.endFill();*/
		}
		
		/**
		 * The projectile collides with the actor.
		 * @param	actor the actor to collide with
		 */
		public function collide(actor:Actor):void {
			actor.hit(DAMAGE);
			
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
			if (actor is Shield) {
				return (actor as Shield).intersects(arrowHead);
			} else {
				return !actor.isDead &&
						arrowHead.getBounds(this.parent).intersects(actor.getHitBox());
			}
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
			var targetIsLeft:Boolean = (_targetPosition.x < this.x);
			
			var targetDistance:Number = targetIsLeft ? (this.x - _targetPosition.x) : (_targetPosition.x - this.x);
			
			var relativeTargetX:Number = _targetPosition.x - this.x;
			var relativeTargetY:Number = - (_targetPosition.y - this.y);
			
			// Here we go, big formula that I haven't verified personally:
			//                                           ___________________
			//                                / 2  +    /  4       2      2  \
			//  angle to target              | V   -  \/  V  - G(GX  + 2YV )  |
			// (X, Y) from (0,0)    =  arctan| ______________________________ |
			//  with gravity G               |           GX                   |
			//  and intial velocity V         \                              /
			//
			//  We want the lower angle, so we'll be using the minus portion of the plus or minus.
			
			var idealAngle:Number;
			var radical:Number = VELOCITY * VELOCITY * VELOCITY * VELOCITY
							- GRAVITY * (GRAVITY * relativeTargetX * relativeTargetX +
													2 * relativeTargetY * VELOCITY * VELOCITY)
			
			if (radical < 0) {
				idealAngle = (relativeTargetX > 0 ) ? Math.PI / 4 : 3 * Math.PI / 4;
			} else {
				idealAngle =
					Math.max(( -Math.PI / 2) + .1, //Restict it to about -85 to 85 degrees.
					Math.min(Math.PI / 2 - .1,
						Math.atan((VELOCITY * VELOCITY - Math.sqrt(radical)) / (GRAVITY * relativeTargetX))));
				
				if (targetIsLeft)
					idealAngle += Math.PI; //Limitations of arctangent.
			}
			
			var actualAngle:Number = Math.random() * 2 * ERROR - ERROR + idealAngle;
					
			var horizontalVelocity:Number = Math.cos(actualAngle) * VELOCITY;
			var initialVerticalVelocity:Number = Math.sin(actualAngle) * VELOCITY;
			
			var peakTime:Number;
			var peakHeight:Number
			
			//If we're pointed up, we need separate calulations for the path up.
			if (actualAngle > 0 && actualAngle < Math.PI) {
				peakTime = initialVerticalVelocity / GRAVITY;
				
				peakHeight = this.y - (initialVerticalVelocity * initialVerticalVelocity)
													/ (GRAVITY * 2);
			} else {
				peakTime = 0.0;
				peakHeight = this.y;
			}
			
			
			var peakToGroundTime:Number = Math.sqrt(2 * (Actor.Y_POSITION - peakHeight) / GRAVITY);
			
			var fullTime:Number = peakTime + peakToGroundTime;
			
			
			//Now create the animations.
			var angleInDegrees:Number = (actualAngle * 180 / Math.PI);
			var targetRotation:Number;
			/*if (targetIsLeft) {
				this.rotation = 180 + angleInDegrees;
				targetRotation = 180 - angleInDegrees;
			} else {
				this.rotation = -angleInDegrees;
				targetRotation = angleInDegrees;
			}*/
			this.rotation = -angleInDegrees;
			targetRotation = angleInDegrees;
			
			timeline = new TimelineLite( /*{ onComplete:forceFinish }*/ );
			
			
			//TODO simplify expressions
			
			//Add y movement and time labels
			timeline.add("start", "+=0");
			if (actualAngle > 0 && actualAngle < Math.PI)
				timeline.to(this, peakTime, { y:peakHeight, ease:Quad.easeOut } );
			timeline.to(this, peakToGroundTime, { y:Actor.Y_POSITION, ease:Quad.easeIn } );
			
			//X movement is simpler.
			timeline.to(this, fullTime,
					{x:this.x + (horizontalVelocity * fullTime), ease:Linear.easeIn }, "start");
			
			//And rotation. "Linear" isn't accurate in general, but it serves
			//as a decent approximation at the top of a parabola.
			//(The real one is atan((initialVerticalVelocity + GRAVITY * time) / horizontalVelocity)
			TweenPlugin.activate([DirectionalRotationPlugin]);
			timeline.to(this, fullTime,
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