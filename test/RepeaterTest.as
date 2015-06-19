package test 
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import src.Repeater;
	import src.TempoChange;
	import src.TimeCounter;
	
	
	MockolateRunner;
	/**
	 * Doesn't accurately test the timing, because I can't seem to deterministically
	 * time my tests.
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class RepeaterTest 
	{
		private var repeater:Repeater;
		
		[Mock]
		public var timeCounter:TimeCounter;
		
		private var dispatcher:EventDispatcher;
		
		public static const BEAT:int = 500;
		public static const QUARTER_BEAT:int = BEAT / 4;
		public static const THIRD_BEAT:int = BEAT / 3;
		private var CONSTANT_BEAT:Vector.<TempoChange>
		
		public static const CONSISTENT_FRAME:int = Repeater.MILLIS_PER_FRAME;
		
		//Dammit, can't mock final class function.
		private var func1:Function, func2:Function, func3:Function;
		
		private var timesFunc1Called:int, timesFunc2Called:int, timesFunc3Called:int;
		
		[Before]
		public function setup():void {
			timesFunc1Called = 0;
			timesFunc2Called = 0;
			timesFunc3Called = 0;
			
			func1 = function():void {
				timesFunc1Called++;
			}
			func2 = function():void {
				timesFunc2Called++;
			}
			func3 = function():void {
				timesFunc3Called++;
			}
			
			CONSTANT_BEAT = new <TempoChange>[new TempoChange(BEAT, 0)];
			
			dispatcher = new EventDispatcher();
			repeater = new Repeater(dispatcher, timeCounter);
			repeater.prepareRegularRuns();
		}
		
		[Test]
		public function runs():void {
			
			assertThat(repeater.isRunning, true);
		}
		
		[Test]
		public function stops():void {
			repeater.killRuns();
			
			assertThat(repeater.isRunning, false);
		}
		
		
		
		
		//------------ On Frame ---------------------
		
		
		private function advanceFrame():void {
			dispatcher.dispatchEvent(new Event(Event.ENTER_FRAME));
		}
		
		private function prepFrameRuns():void {
			repeater.runEveryFrame(func1);
			repeater.runEveryFrame(func2);
			repeater.runEveryFrame(func3);
		}
		
		[Test]
		public function doesNotRunOnFramePrematurely():void {
			prepFrameRuns();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 0);
			assertThat(timesFunc3Called, 0);
		}
		
		[Test]
		public function runsOnFrame():void {
			prepFrameRuns();
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 1);
			assertThat(timesFunc3Called, 1);
		}
		
		[Test(order = 1)]
		public function stopsOnFrame():void {
			prepFrameRuns();
			
			repeater.stopRunningEveryFrame(func1);
			repeater.stopRunningEveryFrame(func3);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 1);
			assertThat(timesFunc3Called, 0);
		}
		
		[Test(order = 1)]
		public function runsTwiceOnFrame():void {
			prepFrameRuns();
			
			advanceFrame();
			
			repeater.stopRunningEveryFrame(func1);
			repeater.stopRunningEveryFrame(func3);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 2);
			assertThat(timesFunc3Called, 1);
		}
		
		[Test]
		public function reportsRunsOnFrame():void {
			prepFrameRuns();
			
			repeater.stopRunningEveryFrame(func1);
			repeater.stopRunningEveryFrame(func3);
			
			advanceFrame();
			
			assertThat(repeater.isRunningEveryFrame(func1), false);
			assertThat(repeater.isRunningEveryFrame(func2), true);
			assertThat(repeater.isRunningEveryFrame(func3), false);
		}
		
		
		[Test]
		public function doesNotRunWithoutSetBeat():void {
			repeater.runEveryQuarterBeat(func1);
			repeater.runEveryThirdBeat(func2);
			repeater.runConsistentlyEveryFrame(func3);
			
			stub(timeCounter).method("getTime").returns(BEAT * 10);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 0);
			assertThat(timesFunc3Called, 0);
		}
		
		
		
		//----------- Quarter Beat ----------------
		
		
		private function prepQuarterRuns():void {
			repeater.startBeats(CONSTANT_BEAT);
			repeater.runEveryQuarterBeat(func1);
			repeater.runEveryQuarterBeat(func2);
			repeater.runEveryQuarterBeat(func3);
		}
		
		[Test]
		public function doesNotRunOnQuarterBeatPrematurely():void {
			prepQuarterRuns();
			
			stub(timeCounter).method("getTime").returns(QUARTER_BEAT * .8);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 0);
			assertThat(timesFunc3Called, 0);
		}
		
		[Test]
		public function runsOnQuarterBeat():void {
			prepQuarterRuns();
			
			stub(timeCounter).method("getTime").returns(QUARTER_BEAT * 1.2);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, true);
			assertThat(timesFunc2Called, true);
			assertThat(timesFunc3Called, true);
		}
		
		[Test(order = 1)]
		public function stopsOnQuarterBeat():void {
			prepQuarterRuns();
			
			repeater.stopRunningEveryQuarterBeat(func1);
			repeater.stopRunningEveryQuarterBeat(func2);
			
			stub(timeCounter).method("getTime").returns(QUARTER_BEAT * 1.2);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 0);
			assertThat(timesFunc3Called, 1);
		}
		
		[Test(order = 2)]
		public function runsThriceOnQuarterBeatImmediately():void {
			prepQuarterRuns();
			
			stub(timeCounter).method("getTime").returns(QUARTER_BEAT * 3.2);
			
			repeater.stopRunningEveryQuarterBeat(func1);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 3);
			assertThat(timesFunc3Called, 3);
		}
		
		[Test(order = 2)]
		public function runsThriceOnQuarterBeatOverTime():void {
			prepQuarterRuns();
			
			stub(timeCounter).method("getTime").returns(QUARTER_BEAT * 1.2,
					QUARTER_BEAT * 2.2, QUARTER_BEAT * 3.2);
					
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 1);
			assertThat(timesFunc3Called, 1);
			
			repeater.stopRunningEveryQuarterBeat(func1);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 2);
			assertThat(timesFunc3Called, 2);
			
			repeater.stopRunningEveryQuarterBeat(func2);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 2);
			assertThat(timesFunc3Called, 3);
		}
		
		[Test(order = 2)]
		public function runsManyTimesOnQuarterBeat():void {
			prepQuarterRuns();
			
			stub(timeCounter).method("getTime").returns(QUARTER_BEAT * 1.2,
					QUARTER_BEAT * 3.2, QUARTER_BEAT * 4.2, QUARTER_BEAT * 5.2,
					QUARTER_BEAT * 8.2, QUARTER_BEAT * 8.8, QUARTER_BEAT * 12.2);
			
			advanceFrame();
			assertThat(timesFunc1Called, 1);
			
			advanceFrame();
			assertThat(timesFunc1Called, 3);
			
			advanceFrame();
			assertThat(timesFunc1Called, 4);
			
			advanceFrame();
			assertThat(timesFunc1Called, 5);
			
			advanceFrame();
			assertThat(timesFunc1Called, 8);
			
			advanceFrame();
			assertThat(timesFunc1Called, 8);
			
			advanceFrame();
			assertThat(timesFunc1Called, 12);
			
			advanceFrame();
			assertThat(timesFunc1Called, 12);
		}
		
		[Test(order = 1)]
		public function reportsRunsOnQuarterBeat():void {
			prepQuarterRuns();
			
			stub(timeCounter).method("getTime").returns(QUARTER_BEAT * 1.2);
			
			assertThat(repeater.isRunningEveryQuarterBeat(func1), true);
			assertThat(repeater.isRunningEveryQuarterBeat(func2), true);
			assertThat(repeater.isRunningEveryQuarterBeat(func3), true);
			
			repeater.stopRunningEveryQuarterBeat(func1);
			repeater.stopRunningEveryQuarterBeat(func2);
			
			assertThat(repeater.isRunningEveryQuarterBeat(func1), false);
			assertThat(repeater.isRunningEveryQuarterBeat(func2), false);
			assertThat(repeater.isRunningEveryQuarterBeat(func3), true);
			
			advanceFrame();
			
			assertThat(repeater.isRunningEveryQuarterBeat(func1), false);
			assertThat(repeater.isRunningEveryQuarterBeat(func2), false);
			assertThat(repeater.isRunningEveryQuarterBeat(func3), true);
		}
		
		
		
		
		//------------ Third Beat --------------
		
		
		private function prepThirdRuns():void {
			repeater.startBeats(CONSTANT_BEAT);
			repeater.runEveryThirdBeat(func1);
			repeater.runEveryThirdBeat(func2);
			repeater.runEveryThirdBeat(func3);
		}
		
		[Test]
		public function doesNotRunOnThirdBeatPrematurely():void {
			prepThirdRuns();
			
			stub(timeCounter).method("getTime").returns(THIRD_BEAT * .8);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 0);
			assertThat(timesFunc3Called, 0);
		}
		
		[Test]
		public function runsOnThirdBeat():void {
			prepThirdRuns();
			
			stub(timeCounter).method("getTime").returns(THIRD_BEAT * 1.2);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 1);
			assertThat(timesFunc3Called, 1);
		}
		
		[Test(order = 1)]
		public function stopsOnThirdBeat():void {
			prepThirdRuns();
			
			repeater.stopRunningEveryThirdBeat(func1);
			repeater.stopRunningEveryThirdBeat(func2);
			
			stub(timeCounter).method("getTime").returns(THIRD_BEAT * 1.2);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 0);
			assertThat(timesFunc3Called, 1);
		}
		
		[Test(order = 2)]
		public function runsThriceOnThirdBeatImmediately():void {
			prepThirdRuns();
			
			stub(timeCounter).method("getTime").returns(THIRD_BEAT * 3.2);
			
			repeater.stopRunningEveryThirdBeat(func1);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 3);
			assertThat(timesFunc3Called, 3);
		}
		
		[Test(order = 2)]
		public function runsThriceOnThirdBeatOverTime():void {
			prepThirdRuns();
			
			stub(timeCounter).method("getTime").returns(THIRD_BEAT * 1.2,
					THIRD_BEAT * 2.2, THIRD_BEAT * 3.2);
					
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 1);
			assertThat(timesFunc3Called, 1);
			
			repeater.stopRunningEveryThirdBeat(func1);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 2);
			assertThat(timesFunc3Called, 2);
			
			repeater.stopRunningEveryThirdBeat(func2);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 2);
			assertThat(timesFunc3Called, 3);
		}
		
		[Test(order = 2)]
		public function runsManyTimesOnThirdBeat():void {
			prepThirdRuns();
			
			stub(timeCounter).method("getTime").returns(THIRD_BEAT * 1.2,
					THIRD_BEAT * 3.2, THIRD_BEAT * 4.2, THIRD_BEAT * 5.2,
					THIRD_BEAT * 8.2, THIRD_BEAT * 8.8, THIRD_BEAT * 12.2);
			
			advanceFrame();
			assertThat(timesFunc1Called, 1);
			
			advanceFrame();
			assertThat(timesFunc1Called, 3);
			
			advanceFrame();
			assertThat(timesFunc1Called, 4);
			
			advanceFrame();
			assertThat(timesFunc1Called, 5);
			
			advanceFrame();
			assertThat(timesFunc1Called, 8);
			
			advanceFrame();
			assertThat(timesFunc1Called, 8);
			
			advanceFrame();
			assertThat(timesFunc1Called, 12);
			
			advanceFrame();
			assertThat(timesFunc1Called, 12);
		}
		
		[Test(order = 1)]
		public function reportsRunsOnThirdBeat():void {
			prepThirdRuns();
			
			stub(timeCounter).method("getTime").returns(THIRD_BEAT * 1.2);
			
			assertThat(repeater.isRunningEveryThirdBeat(func1), true);
			assertThat(repeater.isRunningEveryThirdBeat(func2), true);
			assertThat(repeater.isRunningEveryThirdBeat(func3), true);
			
			repeater.stopRunningEveryThirdBeat(func1);
			repeater.stopRunningEveryThirdBeat(func2);
			
			assertThat(repeater.isRunningEveryThirdBeat(func1), false);
			assertThat(repeater.isRunningEveryThirdBeat(func2), false);
			assertThat(repeater.isRunningEveryThirdBeat(func3), true);
			
			advanceFrame();
			
			assertThat(repeater.isRunningEveryThirdBeat(func1), false);
			assertThat(repeater.isRunningEveryThirdBeat(func2), false);
			assertThat(repeater.isRunningEveryThirdBeat(func3), true);
		}
		
		
		
		
		//-------- Consistent Frame Length ---------------------
		
		
		private function prepConsistentRuns():void {
			repeater.startBeats(CONSTANT_BEAT);
			repeater.runConsistentlyEveryFrame(func1);
			repeater.runConsistentlyEveryFrame(func2);
			repeater.runConsistentlyEveryFrame(func3);
		}
		
		[Test]
		public function doesNotRunOnConsistentFramePrematurely():void {
			prepConsistentRuns();
			
			stub(timeCounter).method("getTime").returns(CONSISTENT_FRAME * .8);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 0);
			assertThat(timesFunc3Called, 0);
		}
		
		[Test]
		public function runsOnConsistentFrame():void {
			prepConsistentRuns();
			
			stub(timeCounter).method("getTime").returns(CONSISTENT_FRAME * 1.2);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, true);
			assertThat(timesFunc2Called, true);
			assertThat(timesFunc3Called, true);
		}
		
		[Test(order = 1)]
		public function stopsOnConsistentFrame():void {
			prepConsistentRuns();
			
			repeater.stopRunningConsistentlyEveryFrame(func1);
			repeater.stopRunningConsistentlyEveryFrame(func2);
			
			stub(timeCounter).method("getTime").returns(CONSISTENT_FRAME * 1.2);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 0);
			assertThat(timesFunc3Called, 1);
		}
		
		[Test(order = 2)]
		public function runsThriceOnConsistentFrameImmediately():void {
			prepConsistentRuns();
			
			stub(timeCounter).method("getTime").returns(CONSISTENT_FRAME * 3.2);
			
			repeater.stopRunningConsistentlyEveryFrame(func1);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 0);
			assertThat(timesFunc2Called, 3);
			assertThat(timesFunc3Called, 3);
		}
		
		[Test(order = 2)]
		public function runsThriceOnConsistentFrameOverTime():void {
			prepConsistentRuns();
			
			stub(timeCounter).method("getTime").returns(CONSISTENT_FRAME * 1.2,
					CONSISTENT_FRAME * 2.2, CONSISTENT_FRAME * 3.2);
					
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 1);
			assertThat(timesFunc3Called, 1);
			
			repeater.stopRunningConsistentlyEveryFrame(func1);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 2);
			assertThat(timesFunc3Called, 2);
			
			repeater.stopRunningConsistentlyEveryFrame(func2);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 1);
			assertThat(timesFunc2Called, 2);
			assertThat(timesFunc3Called, 3);
		}
		
		[Test(order = 2)]
		public function runsManyTimesOnConsistentFrame():void {
			prepConsistentRuns();
			
			stub(timeCounter).method("getTime").returns(CONSISTENT_FRAME * 1.2,
					CONSISTENT_FRAME * 3.2, CONSISTENT_FRAME * 4.2, CONSISTENT_FRAME * 5.2,
					CONSISTENT_FRAME * 8.2, CONSISTENT_FRAME * 8.8, CONSISTENT_FRAME * 12.2);
			
			advanceFrame();
			assertThat(timesFunc1Called, 1);
			
			advanceFrame();
			assertThat(timesFunc1Called, 3);
			
			advanceFrame();
			assertThat(timesFunc1Called, 4);
			
			advanceFrame();
			assertThat(timesFunc1Called, 5);
			
			advanceFrame();
			assertThat(timesFunc1Called, 8);
			
			advanceFrame();
			assertThat(timesFunc1Called, 8);
			
			advanceFrame();
			assertThat(timesFunc1Called, 12);
			
			advanceFrame();
			assertThat(timesFunc1Called, 12);
		}
		
		[Test(order = 1)]
		public function reportsRunsOnConsistentFrame():void {
			prepConsistentRuns();
			
			stub(timeCounter).method("getTime").returns(CONSISTENT_FRAME * 1.2);
			
			assertThat(repeater.isRunningConsistentlyEveryFrame(func1), true);
			assertThat(repeater.isRunningConsistentlyEveryFrame(func2), true);
			assertThat(repeater.isRunningConsistentlyEveryFrame(func3), true);
			
			repeater.stopRunningConsistentlyEveryFrame(func1);
			repeater.stopRunningConsistentlyEveryFrame(func2);
			
			assertThat(repeater.isRunningConsistentlyEveryFrame(func1), false);
			assertThat(repeater.isRunningConsistentlyEveryFrame(func2), false);
			assertThat(repeater.isRunningConsistentlyEveryFrame(func3), true);
			
			advanceFrame();
			
			assertThat(repeater.isRunningConsistentlyEveryFrame(func1), false);
			assertThat(repeater.isRunningConsistentlyEveryFrame(func2), false);
			assertThat(repeater.isRunningConsistentlyEveryFrame(func3), true);
		}
		
		
		
		
		
		[Test]
		public function usesSeparateLists():void {
			repeater.runEveryFrame(func1);
			repeater.runEveryQuarterBeat(func2);
			repeater.runEveryThirdBeat(func3);
			
			assertThat(repeater.isRunningEveryFrame(func1), true);
			assertThat(repeater.isRunningEveryQuarterBeat(func1), false);
			assertThat(repeater.isRunningEveryThirdBeat(func1), false);
			
			assertThat(repeater.isRunningEveryFrame(func2), false);
			assertThat(repeater.isRunningEveryQuarterBeat(func2), true);
			assertThat(repeater.isRunningEveryThirdBeat(func2), false);
			
			assertThat(repeater.isRunningEveryFrame(func3), false);
			assertThat(repeater.isRunningEveryQuarterBeat(func3), false);
			assertThat(repeater.isRunningEveryThirdBeat(func3), true);
			
			assertThat(repeater.isRunningConsistentlyEveryFrame(func1), false);
			assertThat(repeater.isRunningConsistentlyEveryFrame(func2), false);
			assertThat(repeater.isRunningConsistentlyEveryFrame(func3), false);
		}
		
		
		
		
		[Test]
		public function changesTempo():void {
			var changingTempo:Vector.<TempoChange> =
					new <TempoChange>[	new TempoChange(500, 0),
										new TempoChange(750, 5),
										new TempoChange(500, 10)];
										
			repeater.startBeats(changingTempo);
			
			repeater.runEveryQuarterBeat(func1);
			repeater.runEveryThirdBeat(func2);
			
			stub(timeCounter).method("getTime").returns(2501, 6250, 8750);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 20);
			assertThat(timesFunc2Called, 15);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 40);
			assertThat(timesFunc2Called, 30);
			
			advanceFrame();
			
			assertThat(timesFunc1Called, 60);
			assertThat(timesFunc2Called, 45);
		}
		
		
		[After]
		public function tearDown():void {
			repeater.killRuns();
		}
		
	}

}