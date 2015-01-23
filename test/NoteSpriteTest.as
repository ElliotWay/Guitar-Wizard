package test 
{
	
	import com.greensock.plugins.GlowFilterPlugin;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;
	import src.Note;
	import src.NoteSprite;
	
	MockolateRunner;
	
	/**
	 * Most of the output is graphical, which can't really be tested
	 * (I can't even mock a Graphics object) so mostly we can only really test
	 * hold behavior.
	 * @author Elliot Way
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class NoteSpriteTest 
	{
		
		private var holdSprite:NoteSprite;
		
		private var dispatcher:EventDispatcher;
		
		[Before]
		public function setUp():void {
			
			//Note is sufficiently simple that I'm not bothering to mock it (or test it).	
			
			holdSprite = new NoteSprite(new Note(Note.NOTE_A, 0, true, 100));
			NoteSprite.global_hit_line_position = new Point(50, 0);
			
			dispatcher = new EventDispatcher();
		}
		
		[Test]
		public function canLoadANote():void {
			var noteSprite:NoteSprite = new NoteSprite(new Note(Note.NOTE_A, 0));
		}
		
		[Test]
		public function willStartHold():void {
			holdSprite.hit();
			//It needs to do _something_ regularly when a hold is hit.
			assertThat(holdSprite.hasEventListener(Event.ENTER_FRAME), isTrue());			
		}
		
		[Test]
		public function continueHoldCausesNoErrors():void {
			//Hard to test it's functionality, but we can check that it causes no errors.
			holdSprite.hit();
			
			holdSprite.dispatchEvent(new Event(Event.ENTER_FRAME));
		}
		
		[Test]
		public function willStopHold():void {
			holdSprite.hit();
			
			holdSprite.x -= 200;
			
			holdSprite.dispatchEvent(new Event(Event.ENTER_FRAME));
			
			//The enter frame handler should now be gone.
			assertThat(holdSprite.hasEventListener(Event.ENTER_FRAME), isFalse());
		}
	
		//Nothing to do After.
	}

}