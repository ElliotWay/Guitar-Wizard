package test 
{
	import mockolate.runner.MockolateRunner;
	import org.hamcrest.assertThat;
	import src.ActionSplitter;
	
	MockolateRunner;
	/**
	 * ...
	 * @author ...
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class ActionSplitterTest 
	{
		
		private var actionSplitter:ActionSplitter;
		
		private static const NUM_INDICES:int = 3;
		private static const MAX_TIMES_CALLED:int = 4;
		
		private var numTimesCalled:int;
		private var startIndexArg:int, endIndexArg:int;
		
		public function testFunction(startIndex:int, endIndex:int):Boolean {
			startIndexArg = startIndex;
			endIndexArg = endIndex;
			
			numTimesCalled++;
			
			if (numTimesCalled == MAX_TIMES_CALLED)
				return false;
			else
				return true;
		}
		
		[Before]
		public function setup():void {
			numTimesCalled = 0;
			
			actionSplitter = new ActionSplitter(testFunction);
		}
		
		[Test]
		public function doesNotStartProcessing():void {
			assertThat(actionSplitter.processing, false);
		}
		
		[Test]
		public function cannotDoActionWithoutStarting():void {
			var stillGoing:Boolean = actionSplitter.doAction();
			assertThat(numTimesCalled, 0);
			assertThat(stillGoing, false);
		}
		
		[Test]
		public function runsOnceOnStart():void {
			actionSplitter.start(NUM_INDICES);
			
			assertThat(numTimesCalled, 1);
		}
		
		[Test]
		public function doesNotRunOnStartIfRequested():void {
			actionSplitter.start(NUM_INDICES, false);
			
			assertThat(numTimesCalled, 0);
		}
		
		[Test]
		public function processingAfterStart():void {
			actionSplitter.start(NUM_INDICES);
			
			assertThat(actionSplitter.processing, true);
		}
		
		[Test]
		public function usesCorrectInitialArgs():void {
			actionSplitter.start(NUM_INDICES);
			
			assertThat(startIndexArg, 0);
			assertThat(endIndexArg, NUM_INDICES);
		}
		
		[Test]
		public function doesActionAfterStart():void {
			actionSplitter.start(NUM_INDICES);
			
			actionSplitter.doAction();
			
			assertThat(numTimesCalled, 2);
		}
		
		[Test]
		public function continuesCorrectNumberOfTimes():void {
			actionSplitter.start(NUM_INDICES, false);
			
			for (var i:int = 0; i < MAX_TIMES_CALLED; i++) {
				actionSplitter.doAction();
			}
			
			assertThat(numTimesCalled, MAX_TIMES_CALLED);
		}
		
		[Test]
		public function stopsAfterFinished():void {
			actionSplitter.start(NUM_INDICES, false);
			
			for (var i:int = 0; i < MAX_TIMES_CALLED + 1; i++) {
				actionSplitter.doAction();
			}
			
			assertThat(numTimesCalled, MAX_TIMES_CALLED);
			assertThat(actionSplitter.processing, false);
		}
		
		[Test]
		public function isProcessingThroughout():void {
			actionSplitter.start(NUM_INDICES, false);
			
			for (var i:int = 0; i < MAX_TIMES_CALLED; i++) {
				assertThat(actionSplitter.processing, true);
				actionSplitter.doAction();
			}
		}
		
		[Test]
		public function isNotProcessingAfterCompletion():void {
			actionSplitter.start(NUM_INDICES, false);
			
			for (var i:int = 0; i < MAX_TIMES_CALLED; i++) {
				actionSplitter.doAction();
			}
			
			assertThat(actionSplitter.processing, false);
		}
		
		[Test]
		public function returnsTrueThroughout():void {
			actionSplitter.start(NUM_INDICES, false);
			
			for (var i:int = 0; i < MAX_TIMES_CALLED - 1; i++) {
				var stillGoing:Boolean = actionSplitter.doAction();
				assertThat(stillGoing, true);
			}
		}
		
		[Test]
		public function returnsFalseAfter():void {
			actionSplitter.start(NUM_INDICES, false);
			
			for (var i:int = 0; i < MAX_TIMES_CALLED - 1; i++) {
				actionSplitter.doAction();
			}
			
			var stillGoing:Boolean = actionSplitter.doAction();
			assertThat(stillGoing, false);
			
			stillGoing = actionSplitter.doAction();
			assertThat(stillGoing, false);
		}
		
		[Test]
		public function givesCorrectIndices():void {
			actionSplitter.start(NUM_INDICES, false);
			
			for (var i:int = 0; i < MAX_TIMES_CALLED; i++) {
				actionSplitter.doAction();
				assertThat(startIndexArg, i * NUM_INDICES);
				assertThat(endIndexArg, NUM_INDICES + i * NUM_INDICES);
			}
		}
		
		[Test]
		public function canStopMidAction():void {
			actionSplitter.start(NUM_INDICES);
			actionSplitter.doAction();
			
			actionSplitter.stop();
			
			assertThat(actionSplitter.processing, false);
			
			actionSplitter.doAction();
			
			assertThat(numTimesCalled, 2);
		}
		
		
	}

}