package test 
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import mockolate.received;
	import mockolate.runner.MockolateRule;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.anyOf;
	import org.hamcrest.core.either;
	import org.hamcrest.core.isA;
	import org.hamcrest.number.closeTo;
	import org.hamcrest.number.lessThanOrEqualTo;
	import src.Actor;
	import src.ActorFactory;
	import src.ActorSprite;
	import src.GameUI;
	import src.Main;
	import src.factory;
	import src.MainArea;
	import src.MiniSprite;
	import src.Projectile;
	import src.Repeater;
	import src.ScrollArea;
	import src.Shield;
	import src.Status;
	import src.Wizard;
	
	public class MainAreaTest 
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		use namespace factory;
		
		private var mainArea:MainArea;
		
		private var beforeScroll:Timer;
		private var afterScroll:Timer;
		private var afterSecondScroll:Timer;
		
		[Mock]
		public var gameUI:GameUI;
		
		[Mock]
		public var repeater:Repeater;
		[Mock]
		public var actorFactory:ActorFactory;
		
		[Mock]
		public var scrollable:ScrollArea;
		private var scrollTarget:Number;
		
		[Mock]
		public var wizard:Wizard;
		
		[Mock]
		public var playerShield:Shield, opponentShield:Shield;
		
		[Mock]
		public var arrow:Projectile;
		
		[Mock]
		public var playerArrow:Projectile, opponentArrow:Projectile;
		
		[Mock]
		public var actor:Actor;
		
		[Mock]
		public var playerActor1:Actor, playerActor2:Actor, playerActorMiddle:Actor;
		[Mock]
		public var opponentActor1:Actor, opponentActor2:Actor;
		
		[Mock] //You'll need multiple sprites if you want to test removal on multiple actors.
		public var sprite:ActorSprite;
		
		[Mock]
		public var miniSprite:MiniSprite;
		
		[Before]
		public function setup():void {
			
			var leftSide:Point = new Point(0, 0);
			var almostLeftSide:Point = new Point(50, 0);
			var rightSide:Point = new Point(MainArea.ARENA_WIDTH, 0);
			var almostRightSide:Point = new Point(MainArea.ARENA_WIDTH - 50, 0);
			var middle:Point = new Point(MainArea.ARENA_WIDTH / 2, 0);
			
			stub(actor).getter("sprite").returns(sprite);
			stub(sprite).method("animate")
					.callsWithArguments(function(status:int, repeater:Repeater, func:Function):void {
						func.call();
					});
			
			stub(actor).getter("miniSprite").returns(miniSprite);
			stub(actor).method("getPosition").returns(leftSide);

			stub(playerActor1).getter("sprite").returns(sprite);
			stub(playerActor2).getter("sprite").returns(sprite);
			stub(playerActorMiddle).getter("sprite").returns(sprite);
			stub(opponentActor1).getter("sprite").returns(sprite);
			stub(opponentActor2).getter("sprite").returns(sprite);
			stub(wizard).getter("sprite").returns(sprite);
			stub(playerShield).getter("sprite").returns(sprite);
			stub(opponentShield).getter("sprite").returns(sprite);

			stub(playerActor1).getter("miniSprite").returns(miniSprite);
			stub(playerActor2).getter("miniSprite").returns(miniSprite);
			stub(playerActorMiddle).getter("miniSprite").returns(miniSprite);
			stub(opponentActor1).getter("miniSprite").returns(miniSprite);
			stub(opponentActor2).getter("miniSprite").returns(miniSprite);
			stub(playerShield).getter("miniSprite").returns(miniSprite);
			stub(opponentShield).getter("miniSprite").returns(miniSprite);
			
			stub(playerActor1).getter("isPlayerActor").returns(true);
			stub(playerActor2).getter("isPlayerActor").returns(true);
			stub(playerActorMiddle).getter("isPlayerActor").returns(true);
			stub(opponentActor1).getter("isPlayerActor").returns(false);
			stub(opponentActor2).getter("isPlayerActor").returns(false);
			stub(wizard).getter("isPlayerActor").returns(true);
			stub(playerShield).getter("isPlayerActor").returns(true);
			stub(opponentShield).getter("isPlayerActor").returns(false);
			
			stub(playerActor1).method("getPosition").returns(leftSide);
			stub(playerActor2).method("getPosition").returns(almostLeftSide);
			stub(playerActorMiddle).method("getPosition").returns(middle);
			stub(opponentActor1).method("getPosition").returns(rightSide);
			stub(opponentActor2).method("getPosition").returns(almostRightSide);
			stub(wizard).method("getPosition").returns(leftSide);
			stub(playerShield).method("getPosition").returns(leftSide);
			stub(opponentShield).method("getPosition").returns(rightSide);
			
			stub(playerArrow).getter("targets").returns(MainArea.OPPONENT_ACTORS);
			stub(opponentArrow).getter("targets").returns(MainArea.PLAYER_ACTORS);
			
			stub(scrollable).method("scrollTo")
					.callsWithArguments(function(target:Number):void {
						scrollTarget = target;
					});
			
			beforeScroll = new Timer(MainArea.AUTO_SCROLL_DELAY +
					MainArea.REPEATED_SCROLL_DELAY - 100, 1);
			afterScroll = new Timer(MainArea.AUTO_SCROLL_DELAY +
					MainArea.REPEATED_SCROLL_DELAY + 100, 1);
			afterSecondScroll = new Timer(MainArea.AUTO_SCROLL_DELAY +
					MainArea.REPEATED_SCROLL_DELAY + MainArea.REPEATED_SCROLL_DELAY + 100, 1);
			
			
			stub(gameUI).getter("repeater").returns(repeater);
			stub(gameUI).getter("actorFactory").returns(actorFactory);
					
			mainArea = new MainArea(gameUI);
			mainArea.setScrollable(scrollable);
			
			//Hopefully the initialization doesn't do anything that
			//necessarily requires a stage.
			mainArea.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
			mainArea.go(wizard, wizard, playerShield, opponentShield);
		}
		
		[Test]
		public function summonsPlayerActor():void {
			mainArea.playerSummon(actor);
			
			assertThat(actor, received().getter("sprite"));
			assertThat(actor, received().getter("miniSprite"));
			
			assertThat(actor, received().method("summon").arg(repeater));
		}
		
		[Test]
		public function summonsOpponentActor():void {
			mainArea.opponentSummon(actor);
			
			assertThat(actor, received().getter("sprite"));
			assertThat(actor, received().getter("miniSprite"));
			
			assertThat(actor, received().method("summon").arg(repeater));
		}
		
		[Test(order = 1)]
		public function checksActorsOnStep():void {
			mainArea.playerSummon(playerActor1);
			mainArea.playerSummon(playerActor2);
			mainArea.opponentSummon(opponentActor1);
			mainArea.opponentSummon(opponentActor2);
			
			mainArea.step();
			
			assertThat(playerActor1, received().method("act").once());
			assertThat(playerActor2, received().method("act").once());
			assertThat(opponentActor1, received().method("act").once());
			assertThat(opponentActor2, received().method("act").once());
			
			assertThat(playerActor1, received().method("updateMiniMap"));
			assertThat(playerActor2, received().method("updateMiniMap"));
			assertThat(opponentActor1, received().method("updateMiniMap"));
			assertThat(opponentActor2, received().method("updateMiniMap"));

			assertThat(playerActor1, received().getter("isDead"));
			assertThat(playerActor2, received().getter("isDead"));
			assertThat(opponentActor1, received().getter("isDead"));
			assertThat(opponentActor2, received().getter("isDead"));
		}
		
		[Test]
		public function addsProjectile():void {
			mainArea.addProjectile(arrow);
			
			assertThat(arrow, anyOf(received().method("go"),
					received().method("addEventListener").args(Event.ADDED_TO_STAGE, isA(Function))));
		}
		
		[Test(order = 1)]
		public function checksProjectilesOnStep():void {
			mainArea.addProjectile(playerArrow);
			mainArea.addProjectile(opponentArrow);
			
			mainArea.step();
			
			assertThat(playerArrow, received().getter("finished"));
			assertThat(opponentArrow, received().getter("finished"));
		}
		
		[Test(order = 2)]
		public function projectilesHitCorrectTargets():void {
			mainArea.addProjectile(playerArrow);
			mainArea.addProjectile(opponentArrow);
			
			mainArea.playerSummon(playerActor1);
			mainArea.opponentSummon(opponentActor1);
			
			mainArea.step();
			
			assertThat(playerArrow, received().method("hitTest").arg(opponentActor1));
			assertThat(playerArrow, received().method("hitTest").arg(playerActor1).never());
			
			assertThat(opponentArrow, received().method("hitTest").arg(playerActor1));
			assertThat(opponentArrow, received().method("hitTest").arg(opponentActor1).never());
		}
		
		[Test(order = 3)]
		public function projectilesCollideOnHit():void {
			stub(playerArrow).method("hitTest").returns(true);
			stub(opponentArrow).method("hitTest").returns(true);
			
			mainArea.addProjectile(playerArrow);
			mainArea.addProjectile(opponentArrow);
			
			mainArea.playerSummon(playerActor1);
			mainArea.opponentSummon(opponentActor1);
			
			mainArea.step();
			
			assertThat(playerArrow, received().method("collide").arg(opponentActor1));
			assertThat(opponentArrow, received().method("collide").arg(playerActor1));
		}
		
		[Test(order = 3)]
		public function projectilesDoNotCollideOnMiss():void {
			stub(playerArrow).method("hitTest").returns(false);
			stub(opponentArrow).method("hitTest").returns(false);
			
			mainArea.addProjectile(playerArrow);
			mainArea.addProjectile(opponentArrow);
			
			mainArea.playerSummon(playerActor1);
			mainArea.opponentSummon(opponentActor1);
			
			mainArea.step();
			
			assertThat(playerArrow, received().method("collide").never());
			assertThat(opponentArrow, received().method("collide").never());
		}
		
		[Test]
		public function hitsShields():void {
			mainArea.killShields();
			
			assertThat(playerShield, received().method("hit"));
			assertThat(opponentShield, received().method("hit"));
		}
		
		
		//Most of lightning is a visual effect,
		//but we can test the correct target is zapped.
		[Test(order = 1)]
		public function zapsClosestTarget():void {
			//Note that I'm being sneaky and summoning the actors
			//into the wrong lists.
			mainArea.playerSummon(opponentActor2);
			mainArea.playerSummon(opponentActor1);
			mainArea.opponentSummon(playerActor1);
			mainArea.opponentSummon(playerActor2);
			
			mainArea.doLightning(true);
			assertThat(playerActor1, received().method("hit").arg(MainArea.LIGHTNING_DAMAGE));
			assertThat(playerActor2, received().method("hit").never());
			assertThat(opponentActor1, received().method("hit").never());
			assertThat(opponentActor2, received().method("hit").never());
			
			mainArea.doLightning(false);
			assertThat(opponentActor1, received().method("hit").arg(MainArea.LIGHTNING_DAMAGE));
			assertThat(opponentActor2, received().method("hit").never());
			assertThat(playerActor1, received().method("hit").once());
			assertThat(playerActor2, received().method("hit").never());
		}
		
		[Test(order = 1)]
		public function doesNotZapIfTooFar():void {
			//Now we're summoning to the correct lists again.
			mainArea.playerSummon(playerActor1);
			mainArea.opponentSummon(opponentActor1);
			
			mainArea.doLightning(true);
			mainArea.doLightning(false);
			
			assertThat(playerActor1, received().method("hit").never());
			assertThat(opponentActor1, received().method("hit").never());
		}
		
		[Test]
		public function scrollsInCorrectDirection():void {
			mainArea.forceScroll(true);
			
			assertThat(scrollable, received().method("scrollRight").once());
			assertThat(scrollable, received().method("scrollLeft").never());
			
			mainArea.forceScroll(false);
			
			assertThat(scrollable, received().method("scrollRight").once());
			assertThat(scrollable, received().method("scrollLeft").once());
		}
		
		[Test]
		public function stopsScrollingIfCorrectDirection():void {
			mainArea.forceScroll(true);
			mainArea.stopScroll(true);
			
			assertThat(scrollable, received().method("stopScrolling").once());
			
			mainArea.forceScroll(false);
			mainArea.stopScroll(false);
			
			assertThat(scrollable, received().method("stopScrolling").twice());
		}
		
		[Test]
		public function doesNotStopScrollingIfWrongDirection():void {
			mainArea.stopScroll(true);
			
			assertThat(scrollable, received().method("stopScrolling").never());
			
			mainArea.forceScroll(true);
			mainArea.stopScroll(false);
			
			assertThat(scrollable, received().method("stopScrolling").never());
			
			mainArea.forceScroll(false);
			mainArea.stopScroll(true);
			
			assertThat(scrollable, received().method("stopScrolling").never());
		}
		
		[Test(async, order = 1)]
		public function autoScrollsAtCorrectTime():void {
			mainArea.playerSummon(playerActor1);
			
			mainArea.forceScroll(true);
			mainArea.stopScroll(true);
			
			var earlyHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollable, received().method("scrollTo").never());
			}, MainArea.AUTO_SCROLL_DELAY + MainArea.REPEATED_SCROLL_DELAY * 2);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollable, received().method("scrollTo").once());
			}, MainArea.AUTO_SCROLL_DELAY + MainArea.REPEATED_SCROLL_DELAY * 2);
			
			var evenLaterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollable, received().method("scrollTo").twice());
			}, MainArea.AUTO_SCROLL_DELAY + MainArea.REPEATED_SCROLL_DELAY * 3);
			
			beforeScroll.addEventListener(TimerEvent.TIMER_COMPLETE, earlyHandler, false, 0, true);
			afterScroll.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0 , true);
			afterSecondScroll.addEventListener(TimerEvent.TIMER_COMPLETE, evenLaterHandler, false, 0, true);
			
			beforeScroll.start();
			afterScroll.start();
			afterSecondScroll.start();
		}
		
		[Test(async, order = 1)]
		public function doesNotAutoScrollIfScrolling():void {
			mainArea.playerSummon(playerActor1);
			
			mainArea.forceScroll(true);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollable, received().method("scrollTo").never());
			}, MainArea.AUTO_SCROLL_DELAY + MainArea.REPEATED_SCROLL_DELAY * 3);
			
			afterSecondScroll.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			afterSecondScroll.start();
		}
		
		[Test(async, order = 1)]
		public function scrollsToLeftWithNoActors():void {
			mainArea.forceScroll(true);
			mainArea.stopScroll(true);
			
			var scrollHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollable, received().method("scrollTo").once());
				assertThat(scrollTarget, lessThanOrEqualTo(0));
			}, MainArea.AUTO_SCROLL_DELAY + MainArea.REPEATED_SCROLL_DELAY * 2);
			
			afterScroll.addEventListener(TimerEvent.TIMER_COMPLETE, scrollHandler, false, 0, true);
			
			afterScroll.start();
		}
		
		[Test(async, order = 1)]
		public function scrollsToRightMostActor():void {
			mainArea.playerSummon(playerActor2);
			mainArea.playerSummon(playerActorMiddle);
			mainArea.playerSummon(playerActor1);
			
			mainArea.forceScroll(true);
			mainArea.stopScroll(true);
			
			var scrollHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollable, received().method("scrollTo").once());
				assertThat(scrollTarget, closeTo(MainArea.ARENA_WIDTH / 2, MainArea.WIDTH));
			}, MainArea.AUTO_SCROLL_DELAY + MainArea.REPEATED_SCROLL_DELAY * 2);
			
			afterScroll.addEventListener(TimerEvent.TIMER_COMPLETE, scrollHandler, false, 0, true);
			
			afterScroll.start();
		}
		
		[After]
		public function tearDown():void {
			if (beforeScroll != null) {
				beforeScroll.stop();
				beforeScroll = null;
			}
			
			if (afterScroll != null) {
				afterScroll.stop();
				afterScroll = null;
			}
			
			if (afterSecondScroll != null) {
				afterSecondScroll.stop();
				afterSecondScroll = null;
			}
		}
	}

}