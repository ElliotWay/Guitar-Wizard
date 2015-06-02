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
		
		private var millisecondsPerBeat:int = 500;
		private var timePerQuarter:int;
		private var timePerThird:int;
		
		private var quarterBeatRun:Dictionary;
		private var thirdBeatRun:Dictionary;
		
		private var beatTime:uint;
		private var quarterCount:int;
		private var thirdCount:int;
		
		private var running:Boolean = false;
		
		/**
		 * Create a repeater. Call prepareRegularRuns to start it.
		 * @param	dispatcher the event dispatcher on which to listen for ENTER_FRAME events
		 */
		public function Repeater(dispatcher:EventDispatcher) {
			everyFrameDispatcher = dispatcher;
		}
		
		public function get isRunning():Boolean {
			return running;
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
			
			quarterBeatRun = new Dictionary(true);
			thirdBeatRun = new Dictionary(true);
			
			everyFrameDispatcher.addEventListener(Event.ENTER_FRAME, frameRunner);
			
			running = true;
		}
		
		/**
		 * Start running things on the beat, or change the beat while running.
		 * This function has NO EFFECT while the repeater is not running, that is
		 * calling setBeat THEN prepareRegularRuns does not work.
		 * @param	millisPerBeat
		 */
		public function setBeat(millisPerBeat:int):void {
			if (!running)
				return;
				
			//Catch up to the beat immediately, as we're about to change it.
			//This shouldn't do anything, but if there was lag we don't want to skip frames.
			checkBeat();
				
			beatTime = getTimer();
			
			millisecondsPerBeat = millisPerBeat;
			timePerQuarter = millisecondsPerBeat / 4;
			timePerThird = millisecondsPerBeat / 3;
		}
		
		/**
		 * Get the current beat, in milliseconds per beat. If the beat has not been set, this returns 500.
		 * This beat drives the functions running every quarter and every third beat.
		 * @return the current beat, in milliseconds per beat
		 */
		public function getBeat():int {
			return millisecondsPerBeat;
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
		
		/**
		 * Check if enough time has passed to run the quarter beat or third beat functions.
		 */
		private function checkBeat():void {
			var rightNow:uint = getTimer();
			
			//Resync beat time.
			while (rightNow - beatTime > millisecondsPerBeat) {
				beatTime += millisecondsPerBeat;
				quarterCount -= 4;
				thirdCount -= 3;
			}
			
			//Determine the number of ticks we need to do to catch up.
			//Ideally this is always either 0 or 1.
			//Check the difference with beat time as that is guaranteed to not
			//be off due to rounding.
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