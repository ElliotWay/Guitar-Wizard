package src 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * The Repeater controls the flow of repeated events, calling callback functions
	 * every frame or every portion of the beat.
	 */
	public class Repeater {
	
		private var everyFrameDispatcher:EventDispatcher;
		private var everyFrameRun:Dictionary;
		
		private var timeCounter:TimeCounter;
		
		public static const MILLIS_PER_FRAME:int = 17;
		private var consistentEveryFrameRun:Dictionary;
		
		private var frameTime:uint;
		
		private var tempoSchedule:Vector.<TempoChange>;
		private var currentTempoIndex:int;
		private var millisecondsPerBeat:Number = -1;
		private var lastTempoChangeTime:Number;
		
		private var timePerQuarter:int;
		private var timePerThird:int;
		
		private var quarterBeatRun:Dictionary;
		private var thirdBeatRun:Dictionary;
		
		private var beatCount:int;
		private var beatTime:uint;
		
		private var quarterCount:int;
		private var thirdCount:int;
		
		private var running:Boolean = false;
		
		public function get isRunning():Boolean {
			return running;
		}
		
		/**
		 * Create a repeater. Call prepareRegularRuns to start it.
		 * @param	dispatcher the event dispatcher on which to listen for ENTER_FRAME events
		 */
		public function Repeater(dispatcher:EventDispatcher, timer:TimeCounter) {
			everyFrameDispatcher = dispatcher;
			timeCounter = timer;
		}
		
		/**
		 * Start running things repeatedly. Every frame will start immediately, call setBeat to run things on the beat.
		 * Repeated calls to this function while the repeater is running have no effect.
		 * @param	dispatcher the EventDispatcher from which to listen for ENTER_FRAME events
		 */
		public function prepareRegularRuns():void {
			if (running)
				return;
				
			everyFrameRun = new Dictionary(true);
			consistentEveryFrameRun = new Dictionary(true);
			
			quarterBeatRun = new Dictionary(true);
			thirdBeatRun = new Dictionary(true);
			
			everyFrameDispatcher.addEventListener(Event.ENTER_FRAME, frameRunner);
			
			running = true;
		}
		
		public function startBeats(schedule:Vector.<TempoChange>):void {
			if (tempoSchedule != null) {
				tempoSchedule.splice(0, tempoSchedule.length);
			}
			tempoSchedule = schedule;
			
			//Catch up to the beat immediately, as we're about to change it.
			//This shouldn't do anything, but if there was lag we don't want to skip frames.
			checkBeat();
			
			currentTempoIndex = 0;
			millisecondsPerBeat = tempoSchedule[0].millisecondsPerBeat;
			
			beatCount = 0;
			beatTime = timeCounter.getTime();
			frameTime = beatTime;
			lastTempoChangeTime = beatTime;
			
			thirdCount = 0;
			quarterCount = 0;
			
			timePerQuarter = millisecondsPerBeat / 4;
			timePerThird = millisecondsPerBeat / 3;
		}
		
		/**
		 * Get the current beat, in milliseconds per beat. If the beat has not been set, this returns 500.
		 * This beat drives the functions running every quarter and every third beat.
		 * @return the current beat, in milliseconds per beat
		 */
		public function getBeat():int {
			return millisecondsPerBeat > 0 ? millisecondsPerBeat : 500;
		}
		
		/**
		 * Stop running things on the beat and on each frame.
		 */
		public function killRuns():void {
			if (!running)
				return;
				
			everyFrameDispatcher.removeEventListener(Event.ENTER_FRAME, frameRunner);
			
			quarterBeatRun = null;
			thirdBeatRun = null;
			everyFrameRun = null;
			
			running = false;
		}
		
		/**
		 * Run a given function every frame. The function should take no arguments.
		 * @param	func the function to run every frame
		 */
		public function runEveryFrame(func:Function):void {
			everyFrameRun[func] = func;
		}
		
		/**
		 * Stop running the function every frame.
		 * @param   func the function to stop running
		 */
		public function stopRunningEveryFrame(func:Function):void {
			delete everyFrameRun[func];
		}
		
		public function isRunningEveryFrame(func:Function):Boolean {
			return (everyFrameRun[func] != undefined);
		}
		
		/**
		 * Runs based on time elapsed instead of when frames actually occur.
		 * As a result, this may move through 2 or more frames to catch up if there is lag.
		 * @param	func the function to run every frame
		 */
		public function runConsistentlyEveryFrame(func:Function):void {
			consistentEveryFrameRun[func] = func;
		}
		
		/**
		 * Stop running the function every frame.
		 * @param   func the function to stop running
		 */
		public function stopRunningConsistentlyEveryFrame(func:Function):void {
			delete consistentEveryFrameRun[func];
		}
		
		public function isRunningConsistentlyEveryFrame(func:Function):Boolean {
			return (consistentEveryFrameRun[func] != undefined);
		}
		
		/**
		 * Run a given function every quarter beat. The function should take no arguments.
		 * @param	func the function to run every quarter beat
		 */
		public function runEveryQuarterBeat(func:Function):void {
			quarterBeatRun[func] = func;
		}
		
		/**
		 * Stop running the function every quarter beat. 
		 * @param	func the function to stop running
		 */
		public function stopRunningEveryQuarterBeat(func:Function):void {
			delete quarterBeatRun[func];
		}
		
		public function isRunningEveryQuarterBeat(func:Function):Boolean {
			return (quarterBeatRun[func] != undefined);
		}
		
		/**
		 * Run a given function every third beat. The function should take no arguments.
		 * @param	func the function to run every third beat
		 */
		public function runEveryThirdBeat(func:Function):void {
			thirdBeatRun[func] = func;
		}
		
		/**
		 * Stop running the function every third beat. 
		 * @param	func the function to stop running
		 */
		public function stopRunningEveryThirdBeat(func:Function):void {
			delete thirdBeatRun[func];
		}
		
		public function isRunningEveryThirdBeat(func:Function):Boolean {
			return (thirdBeatRun[func] != undefined);
		}
		
		private function frameRunner(e:Event):void {
			
			var func:Object;
			for (func in everyFrameRun) {
				
				(func as Function).call();
			}
			checkBeat();
		}
		
		private var fpsLastTime:uint = 0;
		private var fpsFrameCounter:int = 0;
		
		/**
		 * Check if enough time has passed to run the quarter beat or third beat functions,
		 * or the consistent frame functions.
		 */
		private function checkBeat():void {
			if (millisecondsPerBeat < 0)
				return;
			
			var rightNow:uint = timeCounter.getTime();
			
			fpsFrameCounter++;
			if (fpsFrameCounter >= 10) {
				fpsFrameCounter = 0;
				if (GameUI.fps_counter.visible) {
					var currentFPS:Number = (1 / ((rightNow - fpsLastTime) / 10 ) * 1000);
					GameUI.fps_counter.text = "FPS: " + currentFPS.toPrecision(8);
					trace("FPS: " + currentFPS.toPrecision(8));
				}
				fpsLastTime = rightNow;
			}
			
			//Resync beat time. (The time of the last beat.)
			while (rightNow - beatTime > millisecondsPerBeat) {
				beatCount++;
				//Adjust the tempo if a change is scheduled.
				if (currentTempoIndex + 1 < tempoSchedule.length &&
						beatCount == tempoSchedule[currentTempoIndex + 1].beatNumber) {
							
					//Make sure the beat functions are caught up, as we're about to change the
					//beat, which would throw those calculations off.
					checkBeatFunctions(rightNow);
					
					beatTime = lastTempoChangeTime +
							(beatCount - tempoSchedule[currentTempoIndex].beatNumber) *
							millisecondsPerBeat;
							
					lastTempoChangeTime = beatTime;
					currentTempoIndex++;
					
					millisecondsPerBeat = tempoSchedule[currentTempoIndex].millisecondsPerBeat;
					timePerQuarter = millisecondsPerBeat / 4;
					timePerThird = millisecondsPerBeat / 3;
					trace("Tempo changed to: " + millisecondsPerBeat);
				
				//Every 100 beats correct for rounding drift.
				//By adding the duration of the beat to the beat time instead of multiplying
				//the duration by the number of beats, a small rounding error in the duration
				//can add up to a lot over time.
				} else if (beatCount % 100 == 0) {
					beatTime = lastTempoChangeTime +
							(beatCount - tempoSchedule[currentTempoIndex].beatNumber) *
							millisecondsPerBeat;
							
				} else {
					beatTime += millisecondsPerBeat;
				}
				
				quarterCount -= 4;
				thirdCount -= 3;
			}
			
			checkBeatFunctions(rightNow);
			
			
			//And the consistent frame functions.
			var func:Object;
			while (rightNow - frameTime > MILLIS_PER_FRAME) {
				for (func in consistentEveryFrameRun) {
					(func as Function).call();
				}
				frameTime += MILLIS_PER_FRAME;
			}
		}
		
		private function checkBeatFunctions(rightNow:uint):void {
			//Determine the number of ticks we need to do to catch up.
			//Ideally this is always either 0 or 1.
			//Check the difference with beat time as that is guaranteed to not
			//be too far off due to rounding.
			var quarterCountLag:int = ((rightNow - beatTime) / timePerQuarter) - quarterCount;
			var thirdCountLag:int = ((rightNow - beatTime) / timePerThird) - thirdCount;
			
			var n:int;
			var func:Object;
			for (n = 0; n < quarterCountLag; n++) {
				for (func in quarterBeatRun) {
					(func as Function).call();
				}
				quarterCount++;
			}
			for (n = 0; n < thirdCountLag; n++) {
				for (func in thirdBeatRun) {
					(func as Function).call();
				}
				thirdCount++;
			}
		}
	}

}