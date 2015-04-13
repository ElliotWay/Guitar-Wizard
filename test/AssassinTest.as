package test 
{
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import mockolate.received;
	import mockolate.stub;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.number.lessThanOrEqualTo;
	import src.Actor;
	import src.Assassin;
	import mockolate.runner.MockolateRunner;
	import src.AssassinSprite;
	import src.MainArea;
	import src.SmallSquareSprite;
	import src.Status;
	
	MockolateRunner;
	/**
	 * ...
	 * @author 
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class AssassinTest 
	{
		private var assassin:Assassin;
		
		private var emptyVector:Vector.<Actor>;
		private var opponentVector:Vector.<Actor>;
		
		private var afterJump:Timer;
		
		private static const FAR_AWAY:int = Assassin.MAX_JUMP_DISTANCE + 300;
		private static const JUMP_DISTANCE:int = Assassin.MAX_JUMP_DISTANCE - 20;
		private static const CLOSE_TO_MELEE_DISTANCE:int = Assassin.MIN_JUMP_DISTANCE - 20;
		private static const MELEE_DISTANCE:int = Assassin.MELEE_RANGE - 10;
		
		[Mock]
		public var opponentActor:Extension_Actor3, opponentActor2:Extension_Actor3;
		
		[Mock]
		public var sprite:AssassinSprite;
		private var spriteX:int;
		private var animateOnComplete:Function;
		
		[Mock]
		public var miniSprite:SmallSquareSprite;
		
		[Before]
		public function setup():void {
			emptyVector = new Vector.<Actor>();
			opponentVector = new <Actor>[opponentActor];
			
			stub(sprite).method("animate").callsWithArguments(function(status:int, func:Function = null):void {
				animateOnComplete = func;
			});
			stub(sprite).getter("center").returns(new Point(0, 0));
			spriteX = 0;
			stub(sprite).getter("x").callsWithInvocation(function():Number {
				return spriteX;
			});
			stub(sprite).setter("x").callsWithArguments(function(num:int):void {
				spriteX = num;
			});
			
			assassin = new Assassin(true, true, sprite, miniSprite);
			
			MainArea.playerShieldIsUp = false;
			MainArea.opponentShieldIsUp = false;
		}
		
		private function positionOpponent(position:Number):void {
			stub(opponentActor).method("getPosition").returns(new Point(position, 0));
			stub(opponentActor).method("predictPosition").returns(new Point(position, 0));
		}
		
		[Test]
		public function advanceIfTooFar():void {
			positionOpponent(FAR_AWAY);
			
			assassin.act(emptyVector, opponentVector);
			
			assertThat(assassin.status, Status.MOVING);
		}
		
		[Test]
		public function assassinateInJumpRange():void {
			positionOpponent(JUMP_DISTANCE);
			
			assassin.act(emptyVector, opponentVector);
			
			assertThat(assassin.status, Status.ASSASSINATING);
			assertThat(sprite, received().method("animate").args(Status.ASSASSINATING, isA(Function)));
		}
		
		[Test]
		public function advanceIfTooCloseToJump():void {
			positionOpponent(CLOSE_TO_MELEE_DISTANCE);
			
			assassin.act(emptyVector, opponentVector);
			
			assertThat(assassin.status, Status.MOVING);
		}
		
		[Test]
		public function fightIfCloseEnough():void {
			positionOpponent(MELEE_DISTANCE);
			
			assassin.act(emptyVector, opponentVector);
			
			assertThat(assassin.status, Status.FIGHTING);
		}
		
		[Test(order = 1)]
		public function doesNotStopAssassinating():void {
			positionOpponent(JUMP_DISTANCE);
					
			assassin.act(emptyVector, opponentVector);
			
			var newVector:Vector.<Actor> = new <Actor>[opponentActor2];
			
			stub(opponentActor2).method("getPosition").returns(
					new Point(CLOSE_TO_MELEE_DISTANCE, 0));
			stub(opponentActor2).method("predictPosition").returns(
					new Point(CLOSE_TO_MELEE_DISTANCE, 0));
			
			assassin.act(emptyVector, newVector);
			
			assertThat(assassin.status, Status.ASSASSINATING);
		}
		
		[Test(order = 1)]
		public function doesNotStopFighting():void {
			positionOpponent(MELEE_DISTANCE);
					
			assassin.act(emptyVector, opponentVector);
			
			var newVector:Vector.<Actor> = new <Actor>[opponentActor2];
			
			stub(opponentActor2).method("getPosition").returns(
					new Point(CLOSE_TO_MELEE_DISTANCE, 0));
			stub(opponentActor2).method("predictPosition").returns(
					new Point(CLOSE_TO_MELEE_DISTANCE, 0));
					
			assassin.act(emptyVector, newVector);
			
			assertThat(assassin.status, Status.FIGHTING);
		}
		
		[Test(async, order = 1)]
		public function jumpsToTarget():void {
			var newVector:Vector.<Actor> = new <Actor>[opponentActor2];
			
			stub(opponentActor2).method("getPosition").returns(
				new Point(JUMP_DISTANCE, 0), new Point(MELEE_DISTANCE, 0));
			stub(opponentActor2).method("predictPosition").returns(
				new Point(JUMP_DISTANCE, 0), new Point(MELEE_DISTANCE, 0));
			
			afterJump = new Timer(AssassinSprite.timeToLand() + 100, 1);
			
			var landedHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(JUMP_DISTANCE - spriteX, lessThanOrEqualTo(Assassin.MELEE_RANGE));
				assertThat(opponentActor2, received().method("hit"));
				animateOnComplete.call();
				assertThat(assassin.status, Status.STANDING);
			}, AssassinSprite.timeToLand() + 500);
			
			afterJump.addEventListener(TimerEvent.TIMER_COMPLETE, landedHandler, false, 0, true);
			
			assassin.act(emptyVector, newVector);
			
			afterJump.start();
		}
		
		//Test jumping through shields
		
		[Test]
		public function diesIfHit():void {
			assassin.hit(MainArea.MASSIVE_DAMAGE);
			
			assassin.act(emptyVector, emptyVector);
			
			assertThat(assassin.isDead);
		}
		
		[After]
		public function tearDown():void {
			assassin.clean();
			
			if (afterJump != null) {
				afterJump.stop();
				afterJump = null;
			}
		}
		
	}

}