package test 
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import mockolate.nice;
	import mockolate.received;
	import mockolate.stub;
	import mockolate.runner.MockolateRunner;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import src.Actor;
	import src.Archer;
	import src.ArcherSprite;
	import src.MainArea;
	import src.Repeater;
	import src.SmallTriangleSprite;
	import src.Status;
	import src.factory;
	
	MockolateRunner;
	/**
	 * ...
	 * @author 
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class ArcherTest 
	{
		private var archer:Archer;
		
		private var repeater:Repeater;
		
		private var emptyVector:Vector.<Actor>;
		private var opponentVector:Vector.<Actor>;
		
		private static const BEHIND_SHIELD:int = Archer.NO_RETREAT_DISTANCE + 10;
		private static const PAST_SHIELD:int = MainArea.SHIELD_POSITION + 100;
		
		private static const ADVANCE_DISTANCE:int = Archer.BASE_RANGE + 250;
		private static const SHOOT_DISTANCE:int = 280;//(Archer.BASE_RANGE + Archer.BASE_SKIRMISH_DISTANCE) / 2;
		private static const RETREAT_DISTANCE:int = Archer.MELEE_RANGE + 50;
		private static const MELEE_DISTANCE:int = Archer.MELEE_RANGE - 3;
		
		[Mock]
		public var opponentActor:Actor, opponentActor2:Actor;
		
		[Mock]
		public var sprite:ArcherSprite;
		
		[Mock]
		public var miniSprite:SmallTriangleSprite;
		
		[Before]
		public function setup():void {
			
			emptyVector = new Vector.<Actor>();
			opponentVector = new <Actor>[opponentActor];
			
			MainArea.playerShieldIsUp = false;
			MainArea.opponentShieldIsUp = false;
			
			stub(sprite).getter("arrowPosition").returns(new Point());
			
			stub(opponentActor).getter("status").returns(Status.MOVING);
			stub(opponentActor2).getter("status").returns(Status.MOVING);
			
			repeater = nice(Repeater);
			
			use namespace factory;
			
			archer = new Archer();
			archer.restore();
			archer.setSprite(sprite);
			archer.setMiniSprite(miniSprite);
			archer.setOrientation(Actor.PLAYER, Actor.RIGHT_FACING);
		}
		
		private function positionOpponent(position:Number):void {
			stub(opponentActor).method("getPosition").returns(new Point(position, 0));
			stub(opponentActor).method("predictPosition").returns(new Point(position, 0));
		}
		
		[Test]
		public function movesCloserIfFar():void {
			stub(sprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(ADVANCE_DISTANCE + BEHIND_SHIELD);
			
			archer.act(emptyVector, opponentVector, repeater);
			
			assertThat(archer.status, Status.MOVING);
		}
		
		[Test]
		public function shootsIfInRange():void {
			stub(sprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(SHOOT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector, repeater);
			
			assertThat(archer.status, Status.SHOOTING);
			assertThat(sprite, received().method("animate").args(Status.SHOOTING, repeater, isA(Function)));
		}
		
		[Test]
		public function retreatsIfTooClose():void {
			stub(sprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(RETREAT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector, repeater);
			
			assertThat(archer.status, Status.RETREATING);
		}
		
		[Test]
		public function fightsIfReallyClose():void {
			stub(sprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(MELEE_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector, repeater);
			
			assertThat(archer.status, Status.FIGHTING);
		}
		
		[Test(order = 1)]
		public function doesNotShootIfBehindShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(sprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(SHOOT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector, repeater);
			
			assertThat(archer.status, Status.MOVING);
		}
		
		[Test(order = 1)]
		public function doesNotRetreatIfBehindShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(sprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(RETREAT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector, repeater);
			
			assertThat(archer.status, Status.MOVING);
		}
		
		[Test]
		public function stillFightsBehindShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(sprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(MELEE_DISTANCE + BEHIND_SHIELD);
			
			archer.act(emptyVector, opponentVector, repeater);
			
			assertThat(archer.status, Status.FIGHTING);
		}
		
		[Test]
		public function shootsIfPastShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(sprite).getter("center").returns(new Point(PAST_SHIELD, 0));
			positionOpponent(SHOOT_DISTANCE + PAST_SHIELD);
			
			archer.act(emptyVector, opponentVector, repeater);
					
			assertThat(archer.status, Status.SHOOTING);
		}
		
		[Test]
		public function retreatsIfPastShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(sprite).getter("center").returns(new Point(PAST_SHIELD, 0));
			positionOpponent(RETREAT_DISTANCE + PAST_SHIELD);
			
			archer.act(emptyVector, opponentVector, repeater);
					
			assertThat(archer.status, Status.RETREATING);
		}
		
		[Test(order = 1)]
		public function doesNotStopShooting():void {
			stub(sprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(SHOOT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector, repeater);
			
			var newVector:Vector.<Actor> = new <Actor>[opponentActor2];
			
			stub(opponentActor2).method("getPosition").returns(
					new Point(RETREAT_DISTANCE + BEHIND_SHIELD, 0));
			stub(opponentActor2).method("predictPosition").returns(
					new Point(RETREAT_DISTANCE + BEHIND_SHIELD, 0));
					
			archer.act(emptyVector, newVector, repeater);
			
			assertThat(archer.status, Status.SHOOTING);
		}
		
		[Test(order = 1)]
		public function doesNotStopFighting():void {
			stub(sprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(MELEE_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector, repeater);
			
			var newVector:Vector.<Actor> = new <Actor>[opponentActor2];
			
			stub(opponentActor2).method("getPosition").returns(
					new Point(RETREAT_DISTANCE + BEHIND_SHIELD, 0));
			stub(opponentActor2).method("predictPosition").returns(
					new Point(RETREAT_DISTANCE + BEHIND_SHIELD, 0));
					
			archer.act(emptyVector, newVector, repeater);
			
			assertThat(archer.status, Status.FIGHTING);
		}
		
		[After]
		public function tearDown():void {
			archer.clean();
		}
		
	}

}