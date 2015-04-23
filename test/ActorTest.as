package test 
{
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	import mockolate.nice;
	import mockolate.partial;
	import mockolate.prepare;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.anything;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.not;
	import src.Actor;
	import src.ActorSprite;
	import src.MiniSprite;
	import src.Repeater;
	import src.Status;
	
	
	MockolateRunner;
	/**
	 * TODO: test predict position somehow?
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class ActorTest
	{
		
		private var playerActor:Actor;
		private var opponentActor:Actor;
		
		private var dyingLeft450:Actor, dyingRight550:Actor, left450:Actor, right550:Actor;
		private var left350:Actor, right650:Actor, movingActor:Actor;
		
		private var repeater:Repeater;
		
		private static const HP:int = 10; //What the default HP is expected to be.
		
		[Mock]
		public var sprite:ActorSprite;
		
		[Mock]
		public var sprite450:ActorSprite, sprite550:ActorSprite;
		[Mock]
		public var sprite350:ActorSprite, sprite650:ActorSprite;
		[Mock]
		public var movingSprite:ActorSprite;
		
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
		/*
		[Before(async, timeout = 5000)]
		public function prepMocks():void {
			Async.proceedOnEvent(this,
				prepare(Actor),
				Event.COMPLETE);
		}*/
		
		[Before(order = 1)]
		public function setup():void {
			spriteCenter = new Point(500, 10);
			stub(sprite).getter("center").returns(spriteCenter);
			spriteHitBox = new Rectangle(10, 20, 40, 30);
			stub(sprite).getter("hitBox").returns(spriteHitBox);
			
			stub(sprite450).getter("center").returns(new Point(450, 10));
			dyingLeft450 = partial(Actor, "Dying Left 450", [true, true, sprite450, miniSprite]);
			dyingLeft450.hit(HP);
			dyingLeft450.checkIfDead(repeater);
			left450 = partial(Actor, "Left 450", [true, true, sprite450, miniSprite]);
			
			stub(sprite550).getter("center").returns(new Point(550, 10));
			dyingRight550 = partial(Actor, "Dying Right 550", [false, false, sprite550, miniSprite]);
			dyingRight550.hit(HP);
			dyingRight550.checkIfDead(repeater);
			right550 = partial(Actor, "Right 550", [false, false, sprite550, miniSprite]);
			
			stub(sprite350).getter("center").returns(new Point(350, 10));
			left350 = partial(Actor, "Left 350", [true, false, sprite350, miniSprite]);
			
			stub(sprite650).getter("center").returns(new Point(650, 10));
			right650 = partial(Actor, "Right 650", [false, false, sprite650, miniSprite]);

			movingActor = partial(Actor, "Moving Actor", [false, false, movingSprite, miniSprite]);
			
			afterFirstBlow = new Timer(1.5 * TIME_BETWEEN_BLOWS, 1);
			afterSecondBlow = new Timer(2.5 * TIME_BETWEEN_BLOWS, 1);
			
			playerActor = new Actor(true, true, sprite, miniSprite);
			opponentActor = new Actor(false, false, sprite, miniSprite);
			
			repeater = nice(Repeater);
		}
		
		[Test(order = 0)]
		public function getsSprite():void {
			assertThat(playerActor.sprite, sprite);
		}
		
		[Test(order = 0)]
		public function getsMiniSprite():void {
			assertThat(playerActor.miniSprite, miniSprite);
		}
		
		[Test(order = 0)]
		public function getsIsPlayerPiece():void {
			assertThat(playerActor.isPlayerActor, true);
			assertThat(opponentActor.isPlayerActor, false);
		}
		
		[Test(order = 0)]
		public function getsFacesRight():void {
			assertThat(playerActor.facesRight, true);
			assertThat(opponentActor.facesRight, false);
		}
		
		[Test(order = 0)]
		public function getsCenter():void {
			var result:Point = playerActor.getPosition();
			
			assertThat(result, spriteCenter);
		}
		
		[Test(order = 0)]
		public function getsHitBox():void {
			var result:Rectangle = playerActor.getHitBox();
			
			assertThat(result, spriteHitBox);
		}
		
		[Test(order = 1)]
		public function checksWithinRange():void {
			assertThat(playerActor.withinRange(left450, 100), true);
			assertThat(playerActor.withinRange(left350, 100), false);
			assertThat(playerActor.withinRange(right550, 100), true);
			assertThat(playerActor.withinRange(right650, 100), false)
		}
		
		[Test(order = 1)]
		public function diesIfHit():void {
			playerActor.hit(HP);
			playerActor.checkIfDead(repeater);
			
			assertThat(playerActor.status, Status.DYING);
			assertThat(sprite, received().method("animate").args(Status.DYING, repeater, isA(Function)));
			
			assertThat(playerActor.isDead, true);
		}
		
		[Test(order = 1)]
		public function livesIfNotHit():void {
			playerActor.checkIfDead(repeater);
			
			assertThat(playerActor.status, not(Status.DYING));
			assertThat(sprite, not(received().method("animate").args(Status.DYING, repeater, isA(Function))));
			
			assertThat(playerActor.isDead, false);
		}
		
		[Test(order = 1)]
		public function canBeBlessed():void {
			playerActor.bless();
			
			assertThat(sprite, received().method("showBlessed"));
		}
		
		[Test(order = 1)]
		public function resistantIfBlessed():void {
			playerActor.bless();
			playerActor.hit(HP);
			
			assertThat(playerActor.status, not(Status.DYING));
			assertThat(sprite, not(received().method("animate").args(Status.DYING, isA(Function))));
			
			assertThat(playerActor.isDead, false);
		}
		
		[Test(order = 2)]
		public function notValidIfDying():void {
			assertThat(playerActor.isValidTarget(dyingRight550), false);
			
			assertThat(opponentActor.isValidTarget(dyingLeft450), false);
		}
		
		[Test(order = 2)]
		public function notValidIfWrongDirection():void {
			assertThat(playerActor.isValidTarget(left450), false);
			
			assertThat(opponentActor.isValidTarget(right550), false);
		}
		
		[Test(order = 2)]
		public function validIfAliveCorrectDirection():void {
			assertThat(playerActor.isValidTarget(right550), true);
			
			assertThat(opponentActor.isValidTarget(left450), true);
		}
		
		// Actor.getClosest tests.
		
		[Test(order = 3)]
		public function nullWithEmptyList():void {
			var empty:Vector.<Actor> = new Vector.<Actor>();
			
			assertThat(playerActor.getClosest(empty, 1000), null);
		}
		
		[Test(order = 3)]
		public function nullIfNoneInRange():void {
			var tooFar:Vector.<Actor> = new <Actor>[left350, right650];
			
			assertThat(playerActor.getClosest(tooFar, 100), null);
			
			assertThat(opponentActor.getClosest(tooFar, 100), null);
		}
		
		[Test(order = 3)]
		public function findsClosest():void {
			var left:Vector.<Actor> = new <Actor>[left350, left450];
			var right:Vector.<Actor> = new <Actor>[right550, right650];
			
			assertThat(playerActor.getClosest(right, 400), right550);
			
			assertThat(opponentActor.getClosest(left, 400), left450);
		}
		
		[Test(order = 3)]
		public function nullIfNoneValid():void {
			var leftInvalid:Vector.<Actor> = new <Actor>[dyingLeft450, left350, left450, dyingRight550];
			var rightInvalid:Vector.<Actor> = new <Actor>[right650, dyingRight550, dyingLeft450, right550];
			
			assertThat(playerActor.getClosest(leftInvalid, 400), null);
			
			assertThat(opponentActor.getClosest(rightInvalid, 400), null);
		}
		
		[Test(order = 3)]
		public function nullIfOnlyCloseInvalid():void {
			var closeInvalidForPlayer:Vector.<Actor> = new <Actor>[left450, dyingRight550, right650];
			var closeInvalidForOpponent:Vector.<Actor> = new <Actor>[right550, dyingLeft450, left350];
			
			assertThat(playerActor.getClosest(closeInvalidForPlayer, 100), null);
			
			assertThat(opponentActor.getClosest(closeInvalidForOpponent, 100), null);
		}
		
		[Test(order = 3)]
		public function findsClosestIfFarInvalid():void {
			var invalidFar:Vector.<Actor> = new <Actor>[left350, left450, right550, right650];
			
			assertThat(playerActor.getClosest(invalidFar, 100), right550);
			
			assertThat(opponentActor.getClosest(invalidFar, 100), left450);
		}
		
		[Test(order = 3)]
		public function findsClosestIfInvalidIsCloser():void {
			var closeInvalidForPlayer:Vector.<Actor> = new <Actor>[dyingRight550, right650];
			var closeInvalidForOpponent:Vector.<Actor> = new <Actor>[dyingLeft450, left350];
		
			assertThat(playerActor.getClosest(closeInvalidForPlayer, 400), right650);
			
			assertThat(opponentActor.getClosest(closeInvalidForOpponent, 400), left350);
		}
		
		//End Actor.getClosest tests.
		
		
		// Actor.meleeAttack tests.
		
		[Test(order = 4)]
		public function meleeStartsImmediately():void {
			playerActor.meleeAttack(right550, 60, 10, TIME_BETWEEN_BLOWS, repeater);
			
			assertThat(sprite, received().method("animate").args(Status.FIGHTING, repeater));
			assertThat(playerActor.status, Status.FIGHTING);
			assertThat(right550, received().method("hit").arg(10));
		}
		
		[Test(async, order = 4)]
		public function hitsAgain():void {
			playerActor.meleeAttack(right550, 60, 10, TIME_BETWEEN_BLOWS, repeater);
			
			var firstHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(right550, received().method("hit").arg(10).twice());
			}, 2*TIME_BETWEEN_BLOWS - 1);
					
			var secondHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(right550, received().method("hit").arg(10).thrice());
			}, 3*TIME_BETWEEN_BLOWS - 1);
			
			afterFirstBlow.addEventListener(TimerEvent.TIMER_COMPLETE, firstHandler, false, 0, true);
			afterSecondBlow.addEventListener(TimerEvent.TIMER_COMPLETE, secondHandler, false, 0, true);
			
			afterFirstBlow.start();
			afterSecondBlow.start();
		}
		
		[Test(async, order = 4)]
		public function meleeStopsWhenTargetMoves():void {
			stub(movingSprite).getter("center").returns(new Point(550, 10), new Point(650, 10));
			playerActor.meleeAttack(movingActor, 100, 10, TIME_BETWEEN_BLOWS, repeater);
			
			var firstHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(movingActor, received().method("hit").arg(10).twice());
			}, 2*TIME_BETWEEN_BLOWS - 1);
					
			var secondHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(movingActor, received().method("hit").arg(10).twice());
			}, 3*TIME_BETWEEN_BLOWS - 1);
			
			afterFirstBlow.addEventListener(TimerEvent.TIMER_COMPLETE, firstHandler, false, 0, true);
			afterSecondBlow.addEventListener(TimerEvent.TIMER_COMPLETE, secondHandler, false, 0, true);
			
			afterFirstBlow.start();
			afterSecondBlow.start();
		}
		
		[Test(async, order = 4)]
		public function meleeStopsWhenTargetDies():void {
			playerActor.meleeAttack(right550, 100, 10, TIME_BETWEEN_BLOWS, repeater);
			
			var firstHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(right550, received().method("hit").arg(10).twice());
				right550.hit(HP);
				right550.checkIfDead(repeater);
			}, 2*TIME_BETWEEN_BLOWS - 1);
					
			var secondHandler:Function = Async.asyncHandler(this, function():void {
				//It's hit twice by player actor, and once by firstHandler.
				assertThat(right550, received().method("hit").arg(10).thrice());
			}, 3*TIME_BETWEEN_BLOWS - 1);
			
			afterFirstBlow.addEventListener(TimerEvent.TIMER_COMPLETE, firstHandler, false, 0, true);
			afterSecondBlow.addEventListener(TimerEvent.TIMER_COMPLETE, secondHandler, false, 0, true);
			
			afterFirstBlow.start();
			afterSecondBlow.start();
		}
		
		//End Actor.meleeAttack tests.
		
		
		[Test(order = 0)]
		public function goMoves():void {
			playerActor.go(repeater);
			
			assertThat(sprite, received().method("animate").args(Status.MOVING, repeater));
			assertThat(playerActor.status, Status.MOVING);
		}
		
		[Test(order = 0)]
		public function retreatRetreats():void {
			playerActor.retreat(repeater);
			
			assertThat(sprite, received().method("animate").args(Status.RETREATING, repeater));
			assertThat(playerActor.status, Status.RETREATING);
		}
		
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
			
			playerActor.clean();
			playerActor = null;
			
			opponentActor.clean();
			opponentActor = null;
		}
	}

}