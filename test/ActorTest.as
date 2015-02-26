package test 
{
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import src.Actor;
	import src.ActorSprite;
	import src.MiniSprite;
	import src.Status;
	
	
	MockolateRunner;
	/**
	 * 
	 * @author ...
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class ActorTest
	{
		
		private var actor:Actor;
		
		[Mock]
		public var sprite:ActorSprite;
		
		[Mock]
		public var farLeft:Actor, closeLeft:Actor, closeRight:Actor, farRight:Actor;
		
		[Mock]
		public var farInvalid:Actor, closeInvalid:Actor;
		
		[Mock]
		public var actorMock:Actor;
		
		private var spriteCenter:Point;
		private var spriteHitBox:Rectangle;
		
		[Mock]
		public var miniSprite:MiniSprite;
		
		//This needs to be sufficiently large to avoid frame rate issues.
		private static const TIME_BETWEEN_BLOWS:Number = 100;
		
		private var afterFirstBlow:Timer;
		private var afterSecondBlow:Timer;
		
		[Before]
		public function setup():void {
			spriteCenter = new Point(500, 10);
			stub(sprite).getter("center").returns(spriteCenter);
			spriteHitBox = new Rectangle(10, 20, 40, 30);
			stub(sprite).getter("hitBox").returns(spriteHitBox);
			
			stub(farLeft).method("getPosition").returns(new Point(200, 10));
			stub(farLeft).method("isValidTarget").returns(true);
			stub(closeLeft).method("getPosition").returns(new Point(450, 10));
			stub(closeLeft).method("isValidTarget").returns(true);
			stub(closeRight).method("getPosition").returns(new Point(600, 10));
			stub(closeRight).method("isValidTarget").returns(true);
			stub(farRight).method("getPosition").returns(new Point(750, 10));
			stub(farRight).method("isValidTarget").returns(true);
			
			stub(farInvalid).method("getPosition").returns(new Point(250, 10));
			stub(farInvalid).method("isValidTarget").returns(false);
			stub(closeInvalid).method("getPosition").returns(new Point(400, 10));
			stub(closeInvalid).method("isValidTarget").returns(false);

			
			afterFirstBlow = new Timer(1.5 * TIME_BETWEEN_BLOWS, 1);
			afterSecondBlow = new Timer(2.5 * TIME_BETWEEN_BLOWS, 1);
			
			actor = new Actor(true, sprite, miniSprite);
		}
		
		[Test]
		public function getsCenter():void {
			var result:Point = actor.getPosition();
			
			assertThat(result, spriteCenter);
		}
		
		[Test]
		public function getsHitBox():void {
			var result:Rectangle = actor.getHitBox();
			
			assertThat(result, spriteHitBox);
		}
		
		[Test]
		public function hitPointsAcessors():void {
			actor.hitpoints = 5;
			
			assertThat(actor.hitpoints, 5);
			
			actor.hitpoints += 10;
			actor.hitpoints -= 3;
			
			assertThat(actor.hitpoints, 12);
		}
		
		// Actor.getClosest tests.
		
		[Test]
		public function nullWithEmptyList():void {
			var empty:Vector.<Actor> = new Vector.<Actor>();
			
			assertThat(actor.getClosest(empty, 1000), null);
		}
		
		[Test]
		public function nullIfNoneInRange():void {
			var tooFar:Vector.<Actor> = new <Actor>[farLeft, farRight];
			
			assertThat(actor.getClosest(tooFar, 100), null);
		}
		
		[Test]
		public function findsClosest():void {
									//Jumbling the order just in case it makes a difference.
			var all:Vector.<Actor> = new <Actor>[closeLeft, farRight, closeRight, farLeft];
			
			assertThat(actor.getClosest(all, 400), closeLeft);
		}
		
		[Test]
		public function findsClosestIfRight():void {
			var far:Vector.<Actor> = new <Actor>[farRight, farLeft];
			
			assertThat(actor.getClosest(far, 400), farRight);
		}
		
		[Test]
		public function nullIfNoneValid():void {
			var invalid:Vector.<Actor> = new <Actor>[closeInvalid, farInvalid];
			
			assertThat(actor.getClosest(invalid, 200), null);
		}
		
		[Test]
		public function nullIfOnlyCloseInvalid():void {
			var invalidClose:Vector.<Actor> = new <Actor>[farLeft, farRight, closeInvalid];
			
			assertThat(actor.getClosest(invalidClose, 200), null);
		}
		
		[Test]
		public function findsClosestIfFarInvalid():void {
			var invalidFar:Vector.<Actor> = new <Actor>[farInvalid, farRight, closeRight];
			
			assertThat(actor.getClosest(invalidFar, 200), closeRight);
		}
		
		[Test]
		public function findsClosestIfInvalidIsCloser():void {
										//Far right is closer than far left at 250 away.
			var someValidClose:Vector.<Actor> = new <Actor>[closeInvalid, farLeft, farRight];
		
			assertThat(actor.getClosest(someValidClose, 275), farRight);
		}
		
		//End Actor.getClosest tests.
		
		[Test]
		public function checksWithinRange():void {
			assertThat(actor.withinRange(closeLeft, 100), true);
			assertThat(actor.withinRange(farLeft, 100), false);
			assertThat(actor.withinRange(closeRight, 200), true);
			assertThat(actor.withinRange(farRight, 200), false)
		}
		
		
		// Actor.meleeAttack tests.
		
		[Test]
		public function meleeStartsImmediately():void {
			actor.meleeAttack(closeLeft, 60, 1, 2);
			
			assertThat(sprite, received().method("animate").args(Status.FIGHTING));
			assertThat(closeLeft, received().setter("hitpoints").once());
		}
		
		[Test(async)]
		public function hitsAgain():void {
			actor.meleeAttack(closeLeft, 60, 1, TIME_BETWEEN_BLOWS);
			
			var firstHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(closeLeft, received().setter("hitpoints").twice());
			}, 2*TIME_BETWEEN_BLOWS - 1);
					
			var secondHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(closeLeft, received().setter("hitpoints").thrice());
			}, 3*TIME_BETWEEN_BLOWS - 1);
			
			afterFirstBlow.addEventListener(TimerEvent.TIMER_COMPLETE, firstHandler, false, 0, true);
			afterSecondBlow.addEventListener(TimerEvent.TIMER_COMPLETE, secondHandler, false, 0, true);
			
			afterFirstBlow.start();
			afterSecondBlow.start();
		}
		
		[Test(async)]
		public function meleeStopsWhenTargetMoves():void {
			stub(actorMock).method("getPosition").returns(new Point(450, 10), new Point(350, 10));
			stub(actorMock).method("isValidTarget").returns(true);
			
			actor.meleeAttack(actorMock, 100, 1, TIME_BETWEEN_BLOWS);
			
			var firstHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(actorMock, received().setter("hitpoints").twice());
			}, 2*TIME_BETWEEN_BLOWS - 1);
					
			var secondHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(actorMock, received().setter("hitpoints").twice());
			}, 3*TIME_BETWEEN_BLOWS - 1);
			
			afterFirstBlow.addEventListener(TimerEvent.TIMER_COMPLETE, firstHandler, false, 0, true);
			afterSecondBlow.addEventListener(TimerEvent.TIMER_COMPLETE, secondHandler, false, 0, true);
			
			afterFirstBlow.start();
			afterSecondBlow.start();
		}
		
		[Test(async)]
		public function meleeStopsWhenTargetBecomesInvalid():void {
			stub(actorMock).method("getPosition").returns(new Point(450, 10));
			stub(actorMock).method("isValidTarget").returns(true, false);
			
			actor.meleeAttack(actorMock, 100, 1, TIME_BETWEEN_BLOWS);
			
			var firstHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(actorMock, received().setter("hitpoints").twice());
			}, 2*TIME_BETWEEN_BLOWS - 1);
					
			var secondHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(actorMock, received().setter("hitpoints").twice());
			}, 3*TIME_BETWEEN_BLOWS - 1);
			
			afterFirstBlow.addEventListener(TimerEvent.TIMER_COMPLETE, firstHandler, false, 0, true);
			afterSecondBlow.addEventListener(TimerEvent.TIMER_COMPLETE, secondHandler, false, 0, true);
			
			afterFirstBlow.start();
			afterSecondBlow.start();
		}
		
		//End Actor.meleeAttack tests.
		
		[Test]
		public function goMoves():void {
			actor.go();
			
			assertThat(sprite, received().method("animate").arg(Status.MOVING));
		}
		
		[Test]
		public function retreatRetreats():void {
			actor.retreat();
			
			assertThat(sprite, received().method("animate").arg(Status.RETREATING));
		}
		
		/* Can't check the checkIfDead method because it requires sprite
		 * to be a more realisic sprite.
		[Test]
		public function diesIfDead():void {
			actor.hitpoints = 0;
			
			actor.checkIfDead();
			
			assertThat(sprite, received().method("animate").arg(Status.DYING));
		}
		
		[Test]
		public function livesIfAlive():void {
			actor.hitpoints = 1;
			
			actor.checkIfDead();
			
			assertThat(sprite, received().method("animate").arg(Status.DYING).never());
		}*/
		
		[After]
		public function tearDown():void {
			if (afterFirstBlow != null) {
				afterFirstBlow.stop();
				afterFirstBlow = null;
			}
			
			if (afterSecondBlow != null) {
				afterSecondBlow.stop();
				afterSecondBlow = null;
			}
			
			actor = null;
		}
	}

}