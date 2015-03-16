package test 
{
	import flash.events.Event;
	import flash.geom.Point;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.anyOf;
	import org.hamcrest.core.either;
	import org.hamcrest.core.isA;
	import src.Actor;
	import src.ActorSprite;
	import src.Main;
	import src.MainArea;
	import src.MiniSprite;
	import src.Projectile;
	import src.Status;
	import src.Wizard;
	
	MockolateRunner;
	/**
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class MainAreaTest 
	{
		private var mainArea:MainArea;
		
		[Mock]
		public var wizard:Wizard;
		
		[Mock]
		public var arrow:Projectile;
		
		[Mock]
		public var playerArrow:Projectile, opponentArrow:Projectile;
		
		[Mock]
		public var actor:Extension_Actor;
		
		[Mock]
		public var playerActor1:Extension_Actor, playerActor2:Extension_Actor;
		[Mock]
		public var opponentActor1:Extension_Actor, opponentActor2:Extension_Actor;
		
		[Mock]
		public var sprite:Extension_ActorSprite;
		
		[Mock]
		public var miniSprite:Extension_MiniSprite;
		
		[Before]
		public function setup():void {
			
			var location:Point = new Point(0, 0);
			
			stub(actor).getter("sprite").returns(sprite);
			stub(sprite).method("animate")
					.callsWithArguments(function(status:int, func:Function):void {
						func.call();
					});
			
			stub(actor).getter("miniSprite").returns(miniSprite);
			stub(actor).method("getPosition").returns(location);

			stub(playerActor1).getter("sprite").returns(sprite);
			stub(playerActor2).getter("sprite").returns(sprite);
			stub(opponentActor1).getter("sprite").returns(sprite);
			stub(opponentActor2).getter("sprite").returns(sprite);
			stub(wizard).getter("sprite").returns(sprite);

			stub(playerActor1).getter("miniSprite").returns(miniSprite);
			stub(playerActor2).getter("miniSprite").returns(miniSprite);
			stub(opponentActor1).getter("miniSprite").returns(miniSprite);
			stub(opponentActor2).getter("miniSprite").returns(miniSprite);
			
			stub(playerActor1).method("getPosition").returns(location);
			stub(playerActor2).method("getPosition").returns(location);
			stub(opponentActor1).method("getPosition").returns(location);
			stub(opponentActor2).method("getPosition").returns(location);
			stub(wizard).method("getPosition").returns(location);
			
			stub(playerArrow).getter("targets").returns(MainArea.OPPONENT_ACTORS);
			stub(opponentArrow).getter("targets").returns(MainArea.PLAYER_ACTORS);
			

			mainArea = new MainArea();
			
			Main.prepareRegularRuns();
			
			//Hopefully the initialization doesn't do anything that
			//necessarily requires a stage.
			mainArea.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
			mainArea.go(wizard, wizard);
		}
		
		[Test]
		public function summonsPlayerActor():void {
			mainArea.playerSummon(actor);
			
			assertThat(actor, received().getter("sprite"));
			
			assertThat(sprite, received().method("animate")
					.args(Status.SUMMONING, isA(Function)));
					
			
			assertThat(actor, received().getter("miniSprite"));
			assertThat(actor, received().method("go"));
		}
		
		[Test]
		public function summonsOpponentActor():void {
			mainArea.opponentSummon(actor);
			
			assertThat(actor, received().getter("sprite"));
			
			assertThat(sprite, received().method("animate")
					.args(Status.SUMMONING, isA(Function)));
					
			
			assertThat(actor, received().getter("miniSprite"));
			assertThat(actor, received().method("go"));
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
	}

}