package test
{
import flash.display.Sprite;
import flash.events.Event;
import flash.system.System;
import org.flexunit.internals.TraceListener;
import org.flexunit.runner.FlexUnitCore;

/**
 * Generated test runner class.
 * If you want to change it, be sure to change "generateTestFile" to false.
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

		testCore.run(GameUI_FindHitTest);
		testCore.run(GameUI_MissUntilTest);
		testCore.run(GameUI_SwitchTrackTest);
		testCore.run(MainAreaTest);
		testCore.run(MusicPlayerTest);
		testCore.run(NoteSpriteTest);
		testCore.run(NoteTest);
		testCore.run(SongLoaderTest);
		testCore.run(Song_ParseNotesTest);
		testCore.run(TestTest);
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
		ongoingRuns++;
		if (ongoingRuns == 10)
			System.exit(0);
	}

	public function testRunStarted(description:IDescription):void {
       //Test run started, doesn't run opposite test run finished?
	}

	public function testStarted(description:IDescription):void {
		//Test started.
	}
}
