package test
{
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.system.System;
import noiseandheat.flexunit.visuallistener.VisualListener;
import org.flexunit.internals.TraceListener;
import org.flexunit.listeners.UIListener;
import org.flexunit.listeners.VisualDebuggerListener;
import org.flexunit.runner.FlexUnitCore;
import org.fluint.uiImpersonation.VisualTestEnvironmentBuilder;

/**
 * Generated test runner class.
 * If you want to change it, be sure to change "generateTestFile" to false.
 */
public class TestRunner extends Sprite
{

	private var core:FlexUnitCore;
	private var listener:VisualListener;

	public function TestRunner()
	{
		core = new FlexUnitCore();
        VisualTestEnvironmentBuilder.getInstance(this);

		listener = new VisualListener(800, 600);
        addChild(listener);
        core.addListener(listener);

		core.addListener(new TraceListener());
		
	    //core.addListener(new AfterTestClose());

		var classNames:Vector.<Class> = new Vector.<Class>();
		
		//#### Populate classNames here.
		classNames.push(ActorSpriteTest);
		classNames.push(ActorTest);
		classNames.push(ArcherTest);
		classNames.push(AssassinTest);
		classNames.push(ClericTest);
		classNames.push(MainAreaTest);
		classNames.push(MusicPlayerTest);
		classNames.push(NoteSpriteTest);
		classNames.push(NoteTest);
		classNames.push(SongLoaderTest);
		classNames.push(SongTest);
		classNames.push(TestTest);
//%%%%		
		for each (var clazz:Class in classNames) {
			core.run(clazz);
		}
		/*
		core.run(ActorTest);
		core.run(GameUI_FindHitTest);
		core.run(GameUI_MissUntilTest);
		core.run(GameUI_SwitchTrackTest);
		core.run(MainAreaTest);
		core.run(MusicPlayerTest);
		core.run(NoteSpriteTest);
		core.run(NoteTest);
		core.run(SongLoaderTest);
		core.run(Song_ParseNotesTest);
		core.run(TestTest);*/

        addEventListener(Event.ADDED_TO_STAGE, addedToStage);
    }

    protected function addedToStage(event:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;

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
	}

	public function testRunStarted(description:IDescription):void {
       //Test run started, doesn't run opposite test run finished?
	}

	public function testStarted(description:IDescription):void {
		//Test started.
	}
}
