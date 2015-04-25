package test
{
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.media.Sound;
import flash.system.System;
import mockolate.prepare;
import noiseandheat.flexunit.visuallistener.VisualListener;
import org.flexunit.internals.TraceListener;
import org.flexunit.listeners.UIListener;
import org.flexunit.listeners.VisualDebuggerListener;
import org.flexunit.runner.FlexUnitCore;
import org.fluint.uiImpersonation.VisualTestEnvironmentBuilder;
import src.Actor;
import src.ActorSprite;
import src.MiniSprite;
import src.Note;
import src.NoteSprite;
import src.Repeater;

/**
 * 
 */
public class TestRunner extends Sprite
{

	private var core:FlexUnitCore;
	private var listener:VisualListener;
	
	private var classNames:Vector.<Class>;

	public function TestRunner()
	{
		core = new FlexUnitCore();
        VisualTestEnvironmentBuilder.getInstance(this);

		listener = new VisualListener(800, 600);
        addChild(listener);
        core.addListener(listener);

		core.addListener(new TraceListener());
		
	    //core.addListener(new AfterTestClose());

		classNames = new Vector.<Class>();
		
		//#### Populate classNames here.
		classNames.push(ActorSpriteTest);
		classNames.push(ActorTest);
		classNames.push(ArcherTest);
		classNames.push(AssassinTest);
		classNames.push(ClericTest);
		classNames.push(FrameAnimationTest);
		classNames.push(MainAreaTest);
		classNames.push(MusicPlayerTest);
		classNames.push(NoteBlockTest);
		classNames.push(NoteSpriteTest);
		classNames.push(NoteTest);
		classNames.push(ProjectileTest);
		classNames.push(RepeaterTest);
		classNames.push(SongLoaderTest);
		classNames.push(SongTest);
		classNames.push(TestTest);
//%%%%

		var dispatcher:IEventDispatcher = prepare(
			ActorSprite,
			Actor,
			MiniSprite,
			NoteSprite,
			Repeater,
			Sound);
		
		dispatcher.addEventListener(Event.COMPLETE, run);
	}
	
	public function run(event:Event):void {
		
		for each (var clazz:Class in classNames) {
			core.run(clazz);
		}

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
