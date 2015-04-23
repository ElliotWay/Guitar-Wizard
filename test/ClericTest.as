package test 
{
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import mockolate.nice;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import src.Actor;
	import src.Cleric;
	import src.ClericSprite;
	import src.MainArea;
	import src.Repeater;
	import src.SmallCircleSprite;
	import src.Status;
	
	MockolateRunner;
	/**
	 * ...
	 * @author 
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class ClericTest 
	{
		private var cleric:Cleric;
		
		private var repeater:Repeater;
		
		private var emptyVector:Vector.<Actor>;
		private var opponentVector:Vector.<Actor>;
		private var playerVector:Vector.<Actor>;
		
		private var afterBless:Timer;
		
		private static const FAR_AWAY:int = Cleric.BLESS_RANGE + 200;
		private static const BLESS_DISTANCE:int = Cleric.BLESS_RANGE - 50;
		private static const MELEE_DISTANCE:int = Cleric.MELEE_RANGE - 5;
		
		[Mock]
		public var opponentActor:Actor;

		[Mock]
		public var playerActor:Actor, playerActor2:Actor, playerActor3:Actor;
		
		[Mock]
		public var sprite:ClericSprite;
		private var animateOnComplete:Function;
		
		[Mock]
		public var miniSprite:SmallCircleSprite;
		
		[Before]
		public function setup():void {
			emptyVector = new Vector.<Actor>();
			opponentVector = new <Actor>[opponentActor];
			
			stub(sprite).method("animate").callsWithArguments(function(status:int, repeater:Repeater, func:Function = null):void {
				animateOnComplete = func;
			});
			stub(sprite).getter("center").returns(new Point(0, 0));
			
			cleric = new Cleric(true, true, sprite, miniSprite);
			
			playerVector = new <Actor>[playerActor, playerActor2, cleric];
			
			repeater = nice(Repeater);
			
			MainArea.playerShieldIsUp = false;
			MainArea.opponentShieldIsUp = false;
		}
		
		private function positionActor(actor:Actor, position:Number):void {
			stub(actor).method("getPosition").returns(new Point(position, 0));
			stub(actor).method("predictPosition").returns(new Point(position, 0));
		}
		
		[Test]
		public function advancesIfTooFar():void {
			positionActor(opponentActor, FAR_AWAY);
			
			cleric.act(emptyVector, opponentVector, repeater);
			
			assertThat(cleric.status, Status.MOVING);
		}
		
		[Test]
		public function fightsIfClose():void {
			positionActor(opponentActor, MELEE_DISTANCE);
			
			cleric.act(emptyVector, opponentVector, repeater);
			
			assertThat(cleric.status, Status.FIGHTING);
		}
		
		[Test]
		public function blessesIfNearbyAllies():void {
			positionActor(playerActor, BLESS_DISTANCE);
			positionActor(playerActor2, BLESS_DISTANCE - 20);
			
			cleric.act(playerVector, emptyVector, repeater);
			
			assertThat(cleric.status, Status.BLESSING);
			assertThat(sprite, received().method("animate").args(Status.BLESSING, repeater, isA(Function)));
		}
		
		[Test(order = 1)]
		public function doesNotStopFighting():void {
			positionActor(opponentActor, MELEE_DISTANCE);
					
			cleric.act(emptyVector, opponentVector, repeater);
			
			
			cleric.act(emptyVector, emptyVector, repeater);
			
			assertThat(cleric.status, Status.FIGHTING);
		}
		
		[Test(order = 1)]
		public function doesNotStopBlessing():void {
			positionActor(playerActor, BLESS_DISTANCE);
			positionActor(playerActor2, BLESS_DISTANCE - 20);
			
			cleric.act(playerVector, emptyVector, repeater);
			
			
			cleric.act(emptyVector, emptyVector, repeater);
			
			assertThat(cleric.status, Status.BLESSING);
		}
		
		[Test(order = 1)]
		public function doesNotBlessIfAllyTooFar():void {
			positionActor(playerActor, BLESS_DISTANCE);
			positionActor(playerActor2, FAR_AWAY);
			
			cleric.act(playerVector, emptyVector, repeater);
			
			assertThat(cleric.status, Status.MOVING);
		}
		
		[Test(order = 1)]
		public function doesNotBlessIfAllyAlreadyBlessed():void {
			positionActor(playerActor, BLESS_DISTANCE);
			positionActor(playerActor2, BLESS_DISTANCE);
			
			stub(playerActor2).getter("isBlessed").returns(true);
			
			cleric.act(playerVector, emptyVector, repeater);
			
			assertThat(cleric.status, Status.MOVING);
		}
		
		[Test(async, order = 1)]
		public function blessesWhileBlessing():void {
			positionActor(playerActor, BLESS_DISTANCE);
			positionActor(playerActor2, BLESS_DISTANCE - 20);
			
			afterBless = new Timer(ClericSprite.timeToBless(repeater) + 100, 1);
			
			var blessedHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(playerActor, received().method("bless"));
				assertThat(playerActor2, received().method("bless"));
				
				animateOnComplete.call();
				assertThat(cleric.status, Status.STANDING);
			}, ClericSprite.timeToBless(repeater) + 500);
			
			afterBless.addEventListener(TimerEvent.TIMER_COMPLETE, blessedHandler, false, 0, true);
			
			cleric.act(playerVector, emptyVector, repeater);
			
			afterBless.start();
			
			assertThat(playerActor, received().method("preBless"));
			assertThat(playerActor2, received().method("preBless"));
		}
		
		[Test(async, order = 2)]
		public function cannotBlessImmediatelyAfterBlessing():void {
			positionActor(playerActor, BLESS_DISTANCE);
			positionActor(playerActor2, BLESS_DISTANCE - 20);
			
			//We need 3 actors that necessarily are unblessed.
			positionActor(playerActor3, BLESS_DISTANCE - 30);
			playerVector.push(playerActor3);
			
			afterBless = new Timer(ClericSprite.timeToBless(repeater) + 100, 1);
			
			var blessedHandler:Function = Async.asyncHandler(this, function():void {
				animateOnComplete.call();
				
				cleric.act(playerVector, emptyVector, repeater);
				
				assertThat(cleric.status, Status.MOVING);
			}, ClericSprite.timeToBless(repeater) + 500);
			
			afterBless.addEventListener(TimerEvent.TIMER_COMPLETE, blessedHandler, false, 0, true);
			
			cleric.act(playerVector, emptyVector, repeater);
			
			afterBless.start();
		}
		
		[Test(async, order = 2)]
		public function canBlessAgainAfterCooldown():void {
			positionActor(playerActor, BLESS_DISTANCE);
			positionActor(playerActor2, BLESS_DISTANCE - 20);
			
			//We need 3 actors that necessarily are unblessed.
			positionActor(playerActor3, BLESS_DISTANCE - 30);
			playerVector.push(playerActor3);
			
			afterBless = new Timer(Cleric.BLESS_COOLDOWN + 100, 1);
			
			var blessedHandler:Function = Async.asyncHandler(this, function():void {
				animateOnComplete.call();
				
				cleric.act(playerVector, emptyVector, repeater);
				
				assertThat(cleric.status, Status.BLESSING);
			}, Cleric.BLESS_COOLDOWN + 500);
			
			afterBless.addEventListener(TimerEvent.TIMER_COMPLETE, blessedHandler, false, 0, true);
			
			cleric.act(playerVector, emptyVector, repeater);
			
			afterBless.start();
		}
		
		[Test]
		public function diesIfHit():void {
			cleric.hit(MainArea.MASSIVE_DAMAGE);
			
			cleric.act(emptyVector, emptyVector, repeater);
			
			assertThat(cleric.isDead);
		}
		
		[After]
		public function tearDown():void {
			cleric.clean();
			
			if (afterBless != null) {
				afterBless.stop();
				afterBless = null;
			}
		}
	}

}