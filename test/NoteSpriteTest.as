package test 
{
	
	import com.greensock.plugins.GlowFilterPlugin;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
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
		
		[Before]
		public function setUp():void {
			
			//Note is sufficiently simple that I'm not bothering to mock it here.
			var hold:Note = new Note();
			hold.letter = Note.NOTE_A;
			hold.time = 0;
			hold.isHold = true;
			hold.endtime == 100;
			
			holdSprite = new NoteSprite(hold);
			NoteSprite.global_hit_line_position = new Point(50, 0);
		}
		
		[Test]
		public function canLoadANote():void {
			var note:Note = new Note();
			note.letter = Note.NOTE_A;
			note.time = 0;
			
			var noteSprite:NoteSprite = new NoteSprite(note);
		}
		
		[Test]
		public function getsIsHit():void {
			assertThat(holdSprite.isHit(), false);
			holdSprite.hit();
			assertThat(holdSprite.isHit(), true);
		}
		
		[Test]
		public function isNotHitByMiss():void {
			holdSprite.miss();
			assertThat(holdSprite.isHit(), false);
		}
		
		[Test]
		public function willStartHold():void {
			holdSprite.hit();
			//It needs to do _something_ regularly when a hold is hit.
			assertThat(holdSprite.hasEventListener(Event.ENTER_FRAME));			
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
			assertThat(!holdSprite.hasEventListener(Event.ENTER_FRAME));
		}
		
		[Test]
		public function cannotRestartHold():void {
			holdSprite.hit();
			
			holdSprite.x -= 200;
			
			holdSprite.dispatchEvent(new Event(Event.ENTER_FRAME));
			
			holdSprite.x = 0;
			
			holdSprite.hit(); //Attempt to hit a second time.
			
			
			//The enter frame handler should still be gone.
			assertThat(!holdSprite.hasEventListener(Event.ENTER_FRAME));
		}
	
		//Nothing to do After.
	}

}