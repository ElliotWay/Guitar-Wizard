package test 
{
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	import mockolate.nice;
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
	import src.factory;
	
	MockolateRunner;
	/**
	 * TODO: test predict position somehow?
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class ActorTest
	{
		
		private var playerActor:Actor;
		private var opponentActor:Actor;
		
		//It's usually better not to use partial mocks, but  this _is_ the Actor test.
		[Mock(type = "partial")]
		public var dyingCloseLeft:Actor, dyingCloseRight:Actor, closeLeft:Actor, closeRight:Actor;
		[Mock(type = "partial")]
		public var farLeft:Actor, farRight:Actor, movingActor:Actor;
		
		private var repeater:Repeater;
		
		[Mock]
		public var sprite:ActorSprite;
		
		[Mock]
		public var spriteCloseLeft:ActorSprite, spriteCloseRight:ActorSprite;
		[Mock]
		public var spriteFarLeft:ActorSprite, spriteFarRight:ActorSprite;
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
		
		private const middlePoint:int = 500;
		private const closeLeftPoint:int = middlePoint - Actor.DEFAULT_MELEE_RANGE + 1;
		private const closeRightPoint:int = middlePoint + Actor.DEFAULT_MELEE_RANGE - 1;
		private const farLeftPoint:int = closeLeftPoint - Actor.DEFAULT_MELEE_RANGE;
		private const farRightPoint:int = closeRightPoint + Actor.DEFAULT_MELEE_RANGE;
		
		private const CLOSE_RANGE:int = Actor.DEFAULT_MELEE_RANGE;
		private const LONG_RANGE:int = Actor.DEFAULT_MELEE_RANGE * 2.5;
		
		[Before(order = 1)]
		public function setup():void {
			use namespace factory;
			
			
			
			spriteCenter = new Point(middlePoint, 10);
			stub(sprite).getter("center").returns(spriteCenter);
			spriteHitBox = new Rectangle(10, 20, 40, 30);
			stub(sprite).getter("hitBox").returns(spriteHitBox);
			
			stub(spriteCloseLeft).getter("center").returns(new Point(closeLeftPoint, 10));
			dyingCloseLeft.restore();
			dyingCloseLeft.setSprite(spriteCloseLeft); dyingCloseLeft.setMiniSprite(miniSprite);
			dyingCloseLeft.setOrientation(Actor.PLAYER, Actor.RIGHT_FACING);
			dyingCloseLeft.hit(Actor.DEFAULT_MAX_HP);
			dyingCloseLeft.checkIfDead(repeater);
			
			closeLeft.restore();
			closeLeft.setSprite(spriteCloseLeft); closeLeft.setMiniSprite(miniSprite);
			closeLeft.setOrientation(Actor.PLAYER, Actor.RIGHT_FACING);
			
			stub(spriteCloseRight).getter("center").returns(new Point(closeRightPoint, 10));
			dyingCloseRight.restore();
			dyingCloseRight.setSprite(spriteCloseRight); dyingCloseRight.setMiniSprite(miniSprite);
			dyingCloseRight.setOrientation(Actor.OPPONENT, Actor.LEFT_FACING);
			dyingCloseRight.hit(Actor.DEFAULT_MAX_HP);
			dyingCloseRight.checkIfDead(repeater);
			
			closeRight.restore();
			closeRight.setSprite(spriteCloseRight); closeRight.setMiniSprite(miniSprite);
			closeRight.setOrientation(Actor.OPPONENT, Actor.LEFT_FACING);
			
			stub(spriteFarLeft).getter("center").returns(new Point(farLeftPoint, 10));
			farLeft.restore();
			farLeft.setSprite(spriteFarLeft); farLeft.setMiniSprite(miniSprite);
			farLeft.setOrientation(Actor.PLAYER, Actor.LEFT_FACING);
			
			stub(spriteFarRight).getter("center").returns(new Point(farRightPoint, 10));
			farRight.restore();
			farRight.setSprite(spriteFarRight); farRight.setMiniSprite(miniSprite);
			farRight.setOrientation(Actor.OPPONENT, Actor.LEFT_FACING);

			movingActor.restore();
			movingActor.setSprite(movingSprite); movingActor.setMiniSprite(miniSprite);
			movingActor.setOrientation(Actor.OPPONENT, Actor.LEFT_FACING);
			
			afterFirstBlow = new Timer(1.5 * TIME_BETWEEN_BLOWS, 1);
			afterSecondBlow = new Timer(2.5 * TIME_BETWEEN_BLOWS, 1);
			
			
			
			playerActor = new Actor();
			playerActor.restore();
			playerActor.setSprite(sprite);
			playerActor.setMiniSprite(miniSprite);
			playerActor.setOrientation(Actor.PLAYER, Actor.RIGHT_FACING);
			
			
			opponentActor = new Actor();
			opponentActor.restore();
			opponentActor.setSprite(sprite);
			opponentActor.setMiniSprite(miniSprite);
			opponentActor.setOrientation(Actor.OPPONENT, Actor.LEFT_FACING);
			
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
			assertThat(playerActor.withinRange(closeLeft, Actor.DEFAULT_MELEE_RANGE), true);
			assertThat(playerActor.withinRange(farLeft, Actor.DEFAULT_MELEE_RANGE), false);
			assertThat(playerActor.withinRange(closeRight, Actor.DEFAULT_MELEE_RANGE), true);
			assertThat(playerActor.withinRange(farRight, Actor.DEFAULT_MELEE_RANGE), false)
		}
		
		[Test(order = 1)]
		public function diesIfHit():void {
			playerActor.hit(Actor.DEFAULT_MAX_HP);
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
			playerActor.hit(Actor.DEFAULT_MAX_HP);
			
			assertThat(playerActor.status, not(Status.DYING));
			assertThat(sprite, not(received().method("animate").args(Status.DYING, isA(Function))));
			
			assertThat(playerActor.isDead, false);
		}
		
		[Test(order = 2)]
		public function notValidIfDying():void {
			assertThat(playerActor.isValidTarget(dyingCloseRight), false);
			
			assertThat(opponentActor.isValidTarget(dyingCloseLeft), false);
		}
		
		[Test(order = 2)]
		public function notValidIfWrongDirection():void {
			assertThat(playerActor.isValidTarget(closeLeft), false);
			
			assertThat(opponentActor.isValidTarget(closeRight), false);
		}
		
		[Test(order = 2)]
		public function validIfAliveCorrectDirection():void {
			assertThat(playerActor.isValidTarget(closeRight), true);
			
			assertThat(opponentActor.isValidTarget(closeLeft), true);
		}
		
		// Actor.getClosest tests.
		
		[Test(order = 3)]
		public function nullWithEmptyList():void {
			var empty:Vector.<Actor> = new Vector.<Actor>();
			
			assertThat(playerActor.getClosest(empty, LONG_RANGE), null);
		}
		
		[Test(order = 3)]
		public function nullIfNoneInRange():void {
			var tooFar:Vector.<Actor> = new <Actor>[farLeft, farRight];
			
			assertThat(playerActor.getClosest(tooFar, CLOSE_RANGE), null);
			
			assertThat(opponentActor.getClosest(tooFar, CLOSE_RANGE), null);
		}
		
		[Test(order = 3)]
		public function findsClosest():void {
			var left:Vector.<Actor> = new <Actor>[farLeft, closeLeft];
			var right:Vector.<Actor> = new <Actor>[closeRight, farRight];
			
			assertThat(playerActor.getClosest(right, LONG_RANGE), closeRight);
			
			assertThat(opponentActor.getClosest(left, LONG_RANGE), closeLeft);
		}
		
		[Test(order = 3)]
		public function nullIfNoneValid():void {
			var leftInvalid:Vector.<Actor> = new <Actor>[dyingCloseLeft, farLeft, closeLeft, dyingCloseRight];
			var rightInvalid:Vector.<Actor> = new <Actor>[farRight, dyingCloseRight, dyingCloseLeft, closeRight];
			
			assertThat(playerActor.getClosest(leftInvalid, LONG_RANGE), null);
			
			assertThat(opponentActor.getClosest(rightInvalid, LONG_RANGE), null);
		}
		
		[Test(order = 3)]
		public function nullIfOnlyCloseInvalid():void {
			var closeInvalidForPlayer:Vector.<Actor> = new <Actor>[closeLeft, dyingCloseRight, farRight];
			var closeInvalidForOpponent:Vector.<Actor> = new <Actor>[closeRight, dyingCloseLeft, farLeft];
			
			assertThat(playerActor.getClosest(closeInvalidForPlayer, CLOSE_RANGE), null);
			
			assertThat(opponentActor.getClosest(closeInvalidForOpponent, CLOSE_RANGE), null);
		}
		
		[Test(order = 3)]
		public function findsClosestIfFarInvalid():void {
			var invalidFar:Vector.<Actor> = new <Actor>[farLeft, closeLeft, closeRight, farRight];
			
			assertThat(playerActor.getClosest(invalidFar, CLOSE_RANGE), closeRight);
			
			assertThat(opponentActor.getClosest(invalidFar, CLOSE_RANGE), closeLeft);
		}
		
		[Test(order = 3)]
		public function findsClosestIfInvalidIsCloser():void {
			var closeInvalidForPlayer:Vector.<Actor> = new <Actor>[dyingCloseRight, farRight];
			var closeInvalidForOpponent:Vector.<Actor> = new <Actor>[dyingCloseLeft, farLeft];
		
			assertThat(playerActor.getClosest(closeInvalidForPlayer, LONG_RANGE), farRight);
			
			assertThat(opponentActor.getClosest(closeInvalidForOpponent, LONG_RANGE), farLeft);
		}
		
		//End Actor.getClosest tests.
		
		
		// Actor.meleeAttack tests.
		
		[Test(order = 4)]
		public function meleeStartsImmediately():void {
			playerActor.meleeAttack(closeRight, TIME_BETWEEN_BLOWS, repeater);
			
			assertThat(sprite, received().method("animate").args(Status.FIGHTING, repeater));
			assertThat(playerActor.status, Status.FIGHTING);
			assertThat(closeRight, received().method("hit").arg(Actor.DEFAULT_BASE_MELEE_DAMAGE));
		}
		
		[Test(async, order = 4)]
		public function hitsAgain():void {
			playerActor.meleeAttack(closeRight, TIME_BETWEEN_BLOWS, repeater);
			
			var firstHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(closeRight, received().method("hit")
						.arg(Actor.DEFAULT_BASE_MELEE_DAMAGE).twice());
			}, 2*TIME_BETWEEN_BLOWS - 1);
					
			var secondHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(closeRight, received().method("hit")
						.arg(Actor.DEFAULT_BASE_MELEE_DAMAGE).thrice());
			}, 3*TIME_BETWEEN_BLOWS - 1);
			
			afterFirstBlow.addEventListener(TimerEvent.TIMER_COMPLETE, firstHandler, false, 0, true);
			afterSecondBlow.addEventListener(TimerEvent.TIMER_COMPLETE, secondHandler, false, 0, true);
			
			afterFirstBlow.start();
			afterSecondBlow.start();
		}
		
		[Test(async, order = 4)]
		public function meleeStopsWhenTargetMoves():void {
			stub(movingSprite).getter("center").returns(
					new Point(closeRightPoint, 10), new Point(farRightPoint, 10));
			playerActor.meleeAttack(movingActor, TIME_BETWEEN_BLOWS, repeater);
			
			var firstHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(movingActor, received().method("hit")
						.arg(Actor.DEFAULT_BASE_MELEE_DAMAGE).twice());
			}, 2*TIME_BETWEEN_BLOWS - 1);
					
			var secondHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(movingActor, received().method("hit")
						.arg(Actor.DEFAULT_BASE_MELEE_DAMAGE).twice());
			}, 3*TIME_BETWEEN_BLOWS - 1);
			
			afterFirstBlow.addEventListener(TimerEvent.TIMER_COMPLETE, firstHandler, false, 0, true);
			afterSecondBlow.addEventListener(TimerEvent.TIMER_COMPLETE, secondHandler, false, 0, true);
			
			afterFirstBlow.start();
			afterSecondBlow.start();
		}
		
		[Test(async, order = 4)]
		public function meleeStopsWhenTargetDies():void {
			playerActor.meleeAttack(closeRight, TIME_BETWEEN_BLOWS, repeater);
			
			var firstHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(closeRight, received().method("hit")
						.arg(Actor.DEFAULT_BASE_MELEE_DAMAGE).twice());
				closeRight.hit(Actor.DEFAULT_MAX_HP);
				closeRight.checkIfDead(repeater);
			}, 2*TIME_BETWEEN_BLOWS - 1);
					
			var secondHandler:Function = Async.asyncHandler(this, function():void {
				//It's hit twice by player actor, then stops.
				//(Though it is hit by closeRight for a different amount.)
				assertThat(closeRight, received().method("hit")
						.arg(Actor.DEFAULT_BASE_MELEE_DAMAGE).twice());
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