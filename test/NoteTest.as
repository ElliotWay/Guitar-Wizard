package test 
{
	
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import src.Note;
	import src.NoteSprite;
	
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
		
		private var note:Note;
		
		[Before]
		public function setup():void {
			note = new Note();
			
			note.setSprite(sprite);
		}
		
		[Test]
		public function forwardsHit():void {
			note.hit();
			
			assertThat(sprite, received().method("hit"));
		}
		
		[Test]
		public function forwardsMiss():void {
			note.miss();
			
			assertThat(sprite, received().method("miss"));
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