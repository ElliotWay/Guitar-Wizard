package test 
{
	
	import com.greensock.plugins.GlowFilterPlugin;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.not;
	import src.Note;
	import src.NoteSprite;
	import src.factory;
	import src.Repeater;
	
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
		
		[Mock]
		public var repeater:Repeater;
		
		[Before]
		public function setUp():void {
			
			//Note is sufficiently simple that I'm not bothering to mock it here.
			var hold:Note = new Note();
			hold.letter = Note.NOTE_A;
			hold.time = 0;
			hold.isHold = true;
			hold.endtime == 100;
			
			holdSprite = new NoteSprite(Note.NOTE_A);
			use namespace factory;
			
			holdSprite.setAssociatedNote(hold);
			holdSprite.restore(repeater);
			
			NoteSprite.global_hit_line_position = new Point(50, 0);
		}
		
		[Test]
		public function canLoadANote():void {
			var note:Note = new Note();
			note.letter = Note.NOTE_A;
			note.time = 0;
			
			var noteSprite:NoteSprite = new NoteSprite(Note.NOTE_A);
			
			use namespace factory;
			noteSprite.setAssociatedNote(note);
		}
		
		[Test]
		public function getsIsHit():void {
			assertThat(holdSprite.isHit(), false);
			holdSprite.hit(repeater);
			assertThat(holdSprite.isHit(), true);
		}
		
		[Test]
		public function isNotHitByMiss():void {
			holdSprite.miss(repeater);
			assertThat(holdSprite.isHit(), false);
		}
		
		[Test]
		public function willStartHold():void {
			holdSprite.hit(repeater);
			//It needs to do _something_ regularly when a hold is hit.
			assertThat(repeater, received().method("runConsistentlyEveryFrame")
					.arg(isA(Function)).twice());
			//One call is from the animation.
		}
		
		[Test]
		public function continueHoldCausesNoErrors():void {
			var holdFunction:Function;
			stub(repeater).method("runConsistentlyEveryFrame").callsWithArguments(function(func:Function):void {
				holdFunction = func;
			});
			
			//Hard to test it's functionality, but we can check that it causes no errors.
			holdSprite.hit(repeater);
			
			assertThat(holdFunction, not(null));
			
			holdFunction.call();
		}
		
		[Test]
		public function goingOverTheEndCausesNoErrors():void {
			var holdFunction:Function;
			stub(repeater).method("runConsistentlyEveryFrame").callsWithArguments(function(func:Function):void {
				holdFunction = func;
			});
			
			holdSprite.hit(repeater);
			
			holdSprite.x -= 200;
			
			holdFunction.call();
		}
		
		[Test]
		public function stopsHold():void {
			var holdFunction:Function;
			stub(repeater).method("runConsistentlyEveryFrame").callsWithArguments(function(func:Function):void {
				holdFunction = func;
			});
			
			holdSprite.hit(repeater);
			
			holdSprite.stopHolding(repeater);
			
			assertThat(repeater, received().method("stopRunningConsistentlyEveryFrame").arg(holdFunction));
		}
		
		[Test]
		public function cannotRestartHold():void {
			var holdFunction:Function;
			stub(repeater).method("runConsistentlyEveryFrame").callsWithArguments(function(func:Function):void {
				holdFunction = func;
			});
			
			holdSprite.hit(repeater);
			
			holdSprite.x -= 200;
			
			holdFunction.call();
			holdSprite.stopHolding(repeater);
			
			holdSprite.x = 0;
			
			holdSprite.hit(repeater); //Attempt to hit a second time.
			
			assertThat(repeater, received().method("runConsistentlyEveryFrame").twice());
			//Remember that the first call is from the animation.
		}
	}

}