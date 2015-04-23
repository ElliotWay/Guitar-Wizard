package test 
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import src.Repeater;
	
	
	MockolateRunner;
	/**
	 * Doesn't accurately test the timing, because I can't seem to deterministically
	 * time my tests.
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class RepeaterTest 
	{
		private var repeater:Repeater;
		
		private var dispatcher:EventDispatcher;
		
		private var later:Timer;
		
		public static const TIME:int = 500;
		
		//Dammit, can't mock final class function.
		private var func1:Function, func2:Function, func3:Function;
		
		private var func1Called:Boolean, func2Called:Boolean, func3Called:Boolean;
		
		[Before]
		public function setup():void {
			func1 = function():void {
				func1Called = true;
			}
			func2 = function():void {
				func2Called = true;
			}
			func3 = function():void {
				func3Called = true;
			}
			
			func1Called = false;
			func2Called = false;
			func3Called = false;
			
			later = new Timer(TIME, 1);
			
			dispatcher = new EventDispatcher();
			repeater = new Repeater(dispatcher);
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
		
		[Test]
		public function runsOnFrame():void {
			repeater.runEveryFrame(func1);
			repeater.runEveryFrame(func2);
			repeater.runEveryFrame(func3);
			
			dispatcher.dispatchEvent(new Event(Event.ENTER_FRAME));
			
			assertThat(func1Called, true);
			assertThat(func2Called, true);
			assertThat(func3Called, true);
		}
		
		[Test(order = 1)]
		public function stopsOnFrame():void {
			repeater.runEveryFrame(func1);
			repeater.runEveryFrame(func2);
			repeater.runEveryFrame(func3);
			
			repeater.stopRunningEveryFrame(func1);
			repeater.stopRunningEveryFrame(func3);
			
			dispatcher.dispatchEvent(new Event(Event.ENTER_FRAME));
			
			assertThat(func1Called, false);
			assertThat(func2Called, true);
			assertThat(func3Called, false);
		}
		
		[Test]
		public function reportsRunsOnFrame():void {
			repeater.runEveryFrame(func1);
			repeater.runEveryFrame(func2);
			repeater.runEveryFrame(func3);
			
			repeater.stopRunningEveryFrame(func1);
			repeater.stopRunningEveryFrame(func3);
			
			dispatcher.dispatchEvent(new Event(Event.ENTER_FRAME));
			
			assertThat(repeater.isRunningEveryFrame(func1), false);
			assertThat(repeater.isRunningEveryFrame(func2), true);
			assertThat(repeater.isRunningEveryFrame(func3), false);
		}
		
		[Test(async)]
		public function doesNotRunWithoutSetBeat():void {
			repeater.runEveryQuarterBeat(func1);
			repeater.runEveryThirdBeat(func2);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(func1Called, false);
				assertThat(func2Called, false);
			}, TIME * 2);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			later.start();
		}
		
		[Test(async)]
		public function runsOnQuarterBeat():void {
			repeater.setBeat(TIME);
			
			repeater.runEveryQuarterBeat(func1);
			repeater.runEveryQuarterBeat(func2);
			repeater.runEveryQuarterBeat(func3);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(func1Called, true);
				assertThat(func2Called, true);
				assertThat(func3Called, true);
			}, TIME * 2);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			later.start();
		}
		
		[Test(async, order = 1)]
		public function stopsOnQuarterBeat():void {
			repeater.setBeat(TIME);
			
			repeater.runEveryQuarterBeat(func1);
			repeater.runEveryQuarterBeat(func2);
			repeater.runEveryQuarterBeat(func3);
			
			repeater.stopRunningEveryQuarterBeat(func1);
			repeater.stopRunningEveryQuarterBeat(func2);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(func1Called, false);
				assertThat(func2Called, false);
				assertThat(func3Called, true);
			}, TIME * 2);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			later.start();
		}
		
		[Test(async, order = 1)]
		public function reportsRunsOnQuarterBeat():void {
			repeater.setBeat(TIME);
			
			repeater.runEveryQuarterBeat(func1);
			repeater.runEveryQuarterBeat(func2);
			repeater.runEveryQuarterBeat(func3);
			
			repeater.stopRunningEveryQuarterBeat(func1);
			repeater.stopRunningEveryQuarterBeat(func2);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(repeater.isRunningEveryQuarterBeat(func1), false);
				assertThat(repeater.isRunningEveryQuarterBeat(func2), false);
				assertThat(repeater.isRunningEveryQuarterBeat(func3), true);
			}, TIME * 2);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			later.start();
		}
		
		public function runsOnThirdBeat():void {
			repeater.setBeat(TIME);
			
			repeater.runEveryThirdBeat(func1);
			repeater.runEveryThirdBeat(func2);
			repeater.runEveryThirdBeat(func3);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(func1Called, true);
				assertThat(func2Called, true);
				assertThat(func3Called, true);
			}, TIME * 2);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			later.start();
		}
		
		[Test(async, order = 1)]
		public function stopsOnThirdBeat():void {
			repeater.setBeat(TIME);
			
			repeater.runEveryThirdBeat(func1);
			repeater.runEveryThirdBeat(func2);
			repeater.runEveryThirdBeat(func3);
			
			repeater.stopRunningEveryThirdBeat(func1);
			repeater.stopRunningEveryThirdBeat(func2);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(func1Called, false);
				assertThat(func2Called, false);
				assertThat(func3Called, true);
			}, TIME * 2);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			later.start();
		}
		
		[Test(async, order = 1)]
		public function reportsRunsOnThirdBeat():void {
			repeater.setBeat(TIME);
			
			repeater.runEveryThirdBeat(func1);
			repeater.runEveryThirdBeat(func2);
			repeater.runEveryThirdBeat(func3);
			
			repeater.stopRunningEveryThirdBeat(func2);
			repeater.stopRunningEveryThirdBeat(func3);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(repeater.isRunningEveryThirdBeat(func1), true);
				assertThat(repeater.isRunningEveryThirdBeat(func2), false);
				assertThat(repeater.isRunningEveryThirdBeat(func3), false);
			}, TIME * 2);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			later.start();
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
		}
		
		[After]
		public function tearDown():void {
			repeater.killRuns();
			
			if (later != null) {
				later.stop();
				later = null;
			}
		}
		
	}

}