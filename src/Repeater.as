package src 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * The Repeater controls the flow of repeated events, calling callback functions
	 * every frame or every portion of the beat.
	 */
	public class Repeater {
	
		private var everyFrameDispatcher:EventDispatcher;
		private var everyFrameRun:Dictionary;
		
		private var millisecondsPerBeat:int = 500;
		
		private var quarterBeatRun:Dictionary;
		private var quarterBeatTimer:Timer;
		private var thirdBeatRun:Dictionary;
		private var thirdBeatTimer:Timer;
		
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
			quarterBeatTimer = null;
			thirdBeatRun = new Dictionary(true);
			thirdBeatTimer = null;
			
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
			
			millisecondsPerBeat = millisPerBeat;
			
			if (quarterBeatTimer != null) {
				quarterBeatTimer.stop();
			}
			//Remember that repeating 0 times means repeat indefinitely.
			quarterBeatTimer = new Timer(millisPerBeat / 4, 0);
			quarterBeatTimer.addEventListener(TimerEvent.TIMER, quarterBeatRunner);
			
			if (thirdBeatTimer != null) {
				thirdBeatTimer.stop();
			}
			thirdBeatTimer = new Timer(millisPerBeat / 3, 0);
			thirdBeatTimer.addEventListener(TimerEvent.TIMER, thirdBeatRunner);
			
			quarterBeatTimer.start();
			thirdBeatTimer.start();
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
			
			if (quarterBeatTimer != null)
				quarterBeatTimer.stop();
			if (thirdBeatTimer != null)
				thirdBeatTimer.stop();
			everyFrameDispatcher.removeEventListener(Event.ENTER_FRAME, frameRunner);
			
			quarterBeatRun = null;
			quarterBeatTimer = null;
			thirdBeatRun = null;
			thirdBeatTimer = null;
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
			for (var func:Object in everyFrameRun) {
				
				(func as Function).call();
			}
		}
		
		private function quarterBeatRunner(e:Event):void {
			for (var func:Object in quarterBeatRun) {
				(func as Function).call();
			}
		}
		
		private function thirdBeatRunner(e:Event):void {
			for (var func:Object in thirdBeatRun) {
				
				(func as Function).call();
			}
		}
	}

}