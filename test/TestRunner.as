package test 
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import org.flexunit.internals.TraceListener;
	import org.flexunit.runner.FlexUnitCore;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class TestRunner extends Sprite
	{
		
		private static var testCore:FlexUnitCore;
		
		public function TestRunner() 
		{
			runTests();
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event):void {
			
			testCore.addListener(new AfterTestClose());
		}
		
		public static function runTests() : void {
			testCore  = new FlexUnitCore();
			testCore.addListener(new TraceListener());
			
			//The order of these tests is important (sadly).
			
			testCore.run(TestTest);
			testCore.run(MusicPlayerTest);
			testCore.run(SongLoaderTest);
			testCore.run(NoteSpriteTest);
			testCore.run(GameUI_MissUntilTest);
			testCore.run(GameUI_FindHitTest);
			testCore.run(NoteTest);
			testCore.run(Song_ParseNotesTest);

			//Number of Tests was 54.
		}
	}

}
import flash.system.System;
import org.flexunit.runner.IDescription;
import org.flexunit.runner.notification.Failure;
import org.flexunit.runner.notification.IRunListener;
import org.flexunit.runner.Result;

class AfterTestClose implements IRunListener {
	
	private var ongoingRuns:int;
	
	public function AfterTestClose() {
		ongoingRuns = 0;
	}
	
	public function testAssumptionFailure(failure:Failure):void {
		//Failed assumption.
	}
	
	public function testFailure(failure:Failure):void {
		//Test failed.
	}
	
	public function testFinished(description:IDescription):void {
		//Single test complete.
	}
	
	public function testIgnored(description:IDescription):void {
		//Test ignored.
	}
	
	public function testRunFinished(result:Result):void {
		ongoingRuns--;
		trace("run finished " + ongoingRuns);
		if (ongoingRuns == -8)
			System.exit(0);
	}
	
	public function testRunStarted(description:IDescription):void {
		
	}
	
	public function testStarted(description:IDescription):void {
		//Test started.
	}
}