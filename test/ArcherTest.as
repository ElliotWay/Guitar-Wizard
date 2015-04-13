package test 
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import mockolate.received;
	import mockolate.stub;
	import mockolate.runner.MockolateRunner;
	import org.hamcrest.assertThat;
	import src.Actor;
	import src.Archer;
	import src.ArcherSprite;
	import src.MainArea;
	import src.SmallTriangleSprite;
	import src.Status;
	
	MockolateRunner;
	/**
	 * ...
	 * @author 
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class ArcherTest 
	{
		private var archer:Archer;
		
		private var emptyVector:Vector.<Actor>;
		private var opponentVector:Vector.<Actor>;
		
		private static const BEHIND_SHIELD:int = Archer.NO_RETREAT_DISTANCE + 10;
		private static const PAST_SHIELD:int = MainArea.SHIELD_POSITION + 100;
		
		private static const ADVANCE_DISTANCE:int = Archer.BASE_RANGE + 250;
		private static const SHOOT_DISTANCE:int = 280;//(Archer.BASE_RANGE + Archer.BASE_SKIRMISH_DISTANCE) / 2;
		private static const RETREAT_DISTANCE:int = Archer.MELEE_RANGE + 50;
		private static const MELEE_DISTANCE:int = Archer.MELEE_RANGE - 3;
		
		[Mock]
		public var opponentActor:Extension_Actor2, opponentActor2:Extension_Actor2;
		
		[Mock]
		public var archerSprite:ArcherSprite;
		
		[Mock]
		public var archerMiniSprite:SmallTriangleSprite;
		
		[Before]
		public function setup():void {
			
			emptyVector = new Vector.<Actor>();
			opponentVector = new <Actor>[opponentActor];
			
			MainArea.playerShieldIsUp = false;
			MainArea.opponentShieldIsUp = false;
			
			stub(archerSprite).getter("arrowPosition").returns(new Point());
			
			archer = new Archer(true, true, archerSprite, archerMiniSprite);
		}
		
		private function positionOpponent(position:Number):void {
			stub(opponentActor).method("getPosition").returns(new Point(position, 0));
			stub(opponentActor).method("predictPosition").returns(new Point(position, 0));
		}
		
		[Test]
		public function movesCloserIfFar():void {
			stub(archerSprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(ADVANCE_DISTANCE + BEHIND_SHIELD);
			
			archer.act(emptyVector, opponentVector);
			
			assertThat(archer.status, Status.MOVING);
		}
		
		[Test]
		public function shootsIfInRange():void {
			stub(archerSprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(SHOOT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector);
			
			assertThat(archer.status, Status.SHOOTING);
		}
		
		[Test]
		public function retreatsIfTooClose():void {
			stub(archerSprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(RETREAT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector);
			
			assertThat(archer.status, Status.RETREATING);
		}
		
		[Test]
		public function fightsIfReallyClose():void {
			stub(archerSprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(MELEE_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector);
			
			assertThat(archer.status, Status.FIGHTING);
		}
		
		[Test(order = 1)]
		public function doesNotShootIfBehindShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(archerSprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(SHOOT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector);
			
			assertThat(archer.status, Status.MOVING);
		}
		
		[Test(order = 1)]
		public function doesNotRetreatIfBehindShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(archerSprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(RETREAT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector);
			
			assertThat(archer.status, Status.MOVING);
		}
		
		[Test]
		public function stillFightsBehindShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(archerSprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(MELEE_DISTANCE + BEHIND_SHIELD);
			
			archer.act(emptyVector, opponentVector);
			
			assertThat(archer.status, Status.FIGHTING);
		}
		
		[Test]
		public function shootsIfPastShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(archerSprite).getter("center").returns(new Point(PAST_SHIELD, 0));
			positionOpponent(SHOOT_DISTANCE + PAST_SHIELD);
			
			archer.act(emptyVector, opponentVector);
					
			assertThat(archer.status, Status.SHOOTING);
		}
		
		[Test]
		public function retreatsIfPastShield():void {
			MainArea.playerShieldIsUp = true;
			
			stub(archerSprite).getter("center").returns(new Point(PAST_SHIELD, 0));
			positionOpponent(RETREAT_DISTANCE + PAST_SHIELD);
			
			archer.act(emptyVector, opponentVector);
					
			assertThat(archer.status, Status.RETREATING);
		}
		
		[Test(order = 1)]
		public function doesNotStopShooting():void {
			stub(archerSprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(SHOOT_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector);
			
			var newVector:Vector.<Actor> = new <Actor>[opponentActor2];
			
			stub(opponentActor2).method("getPosition").returns(
					new Point(RETREAT_DISTANCE + BEHIND_SHIELD, 0));
			stub(opponentActor2).method("predictPosition").returns(
					new Point(RETREAT_DISTANCE + BEHIND_SHIELD, 0));
					
			archer.act(emptyVector, newVector);
			
			assertThat(archer.status, Status.SHOOTING);
		}
		
		[Test(order = 1)]
		public function doesNotStopFighting():void {
			stub(archerSprite).getter("center").returns(new Point(BEHIND_SHIELD, 0));
			positionOpponent(MELEE_DISTANCE + BEHIND_SHIELD);
					
			archer.act(emptyVector, opponentVector);
			
			var newVector:Vector.<Actor> = new <Actor>[opponentActor2];
			
			stub(opponentActor2).method("getPosition").returns(
					new Point(RETREAT_DISTANCE + BEHIND_SHIELD, 0));
			stub(opponentActor2).method("predictPosition").returns(
					new Point(RETREAT_DISTANCE + BEHIND_SHIELD, 0));
					
			archer.act(emptyVector, newVector);
			
			assertThat(archer.status, Status.FIGHTING);
		}
		
		[Test]
		public function diesIfHit():void {
			archer.hit(MainArea.MASSIVE_DAMAGE);
			
			archer.act(emptyVector, emptyVector);
			
			assertThat(archer.isDead);
		}
		
		[After]
		public function tearDown():void {
			archer.clean();
		}
		
	}

}