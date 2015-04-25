package test 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.throws;
	import src.Actor;
	import src.MainArea;
	import src.Projectile;
	
	MockolateRunner;
	/**
	 * ...
	 * @author ...
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class ProjectileTest 
	{
		
		private var projectile:Projectile;
		private var container:Sprite;
		
		private const DAMAGE:Number = 12;
		private const TARGETS:int = MainArea.OPPONENT_ACTORS;
		
		[Mock]
		public var target:Actor;
		
		[Before]
		public function setup():void {
			var point:Point = new Point(200, 50);
			
			container = new Sprite();
			projectile = new Projectile(DAMAGE, TARGETS, point);
			container.addChild(projectile);
			projectile.go();
		}
		
		[Test]
		public function doesNotStartFinished():void {
			assertThat(projectile.finished, false);
		}
		
		[Test]
		public function collides():void {
			projectile.collide(target);
			
			assertThat(target, received().method("hit").arg(DAMAGE));
			
			assertThat(projectile.finished, true);
			
			assertThat(function():void { container.getChildIndex(projectile); },
					throws(isA(ArgumentError)));
		}
		
		[Test]
		public function doesNotHitIfDead():void {
													//This rectangle surely intersects the arrow.
			stub(target).method("getHitBox").returns(new Rectangle( -1000, -1000, 2000, 2000));
			stub(target).getter("isDead").returns(true);
			
			assertThat(projectile.hitTest(target), false);
		}
		
		[Test]
		public function doesNotHitIfNoCollision():void {
													//Whereas this one surely does not.
			stub(target).method("getHitBox").returns(new Rectangle(1000, 1000, 1, 1));
			stub(target).getter("isDead").returns(false);
			
			assertThat(projectile.hitTest(target), false);
		}
		
		[Test]
		public function hitsIfOtherwiseGood():void {
			stub(target).method("getHitBox").returns(new Rectangle( -1000, -1000, 2000, 2000));
			stub(target).getter("isDead").returns(false);
			
			assertThat(projectile.hitTest(target), true);
		}
		
		[Test]
		public function finishesImmediately():void {
			projectile.forceFinish();
			
			assertThat(projectile.finished, true);
			
			assertThat(function():void { container.getChildIndex(projectile); },
					throws(isA(ArgumentError)));
		}
		
		[Test]
		public function getsTargets():void {
			assertThat(projectile.targets, TARGETS);
		}
		
		[After]
		public function tearDown():void {
			projectile.forceFinish();
		}
		
	}

}