package test 
{
	
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import src.Note;
	import src.NoteSprite;
	import src.Repeater;
	
	MockolateRunner;
	/**
	 * ...
	 * @author Elliot Way
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class NoteTest 
	{
		[Mock]
		public var sprite:NoteSprite;
		
		[Mock]
		public var repeater:Repeater;
		
		private var note:Note;
		
		[Before]
		public function setup():void {
			note = new Note();
			
			note.setSprite(sprite);
		}
		
		[Test]
		public function forwardsHit():void {
			note.hit(repeater);
			
			assertThat(sprite, received().method("hit").arg(repeater));
		}
		
		[Test]
		public function forwardsMiss():void {
			note.miss(repeater);
			
			assertThat(sprite, received().method("miss").arg(repeater));
		}
		
		[Test]
		public function forwardsIsHit():void {
			stub(sprite).method("isHit").returns(true);
			
			var response:Boolean = note.isHit();
			
			assertThat(response == true);
			assertThat(sprite, received().method("isHit"));
		}
		
	}

}