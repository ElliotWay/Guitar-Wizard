package test 
{
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import src.Note;
	import src.NoteSprite;
	import src.TrimmedNote;
	
	MockolateRunner;
	/**
	 * ...
	 * @author ...
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class TrimmedNoteTest 
	{
		private var stayingHold:TrimmedNote, becomingNote:TrimmedNote;
		
		[Mock]
		public var stayHold:Note, becomeNote:Note;
		
		[Mock]
		public var sprite:NoteSprite;
		
		[Before]
		public function setup():void {
			stub(stayHold).getter("time").returns(100);
			stub(stayHold).getter("isHold").returns(true);
			stub(stayHold).getter("endtime").returns(700);
			stub(stayHold).getter("sprite").returns(sprite);
			
			stub(becomeNote).getter("time").returns(200);
			stub(becomeNote).getter("isHold").returns(true);
			stub(becomeNote).getter("endtime").returns(400);
			stub(becomeNote).getter("sprite").returns(sprite);
			
			stayingHold = new TrimmedNote(stayHold, true, 400);
			becomingNote = new TrimmedNote(becomeNote, false);
		}
		
		[Test]
		public function trimsStayingHold():void {
			stayingHold.trim();
			
			assertThat(stayHold, received().setter("isHold").never());
			assertThat(stayHold, received().setter("endtime").arg(400));
			assertThat(sprite, received().method("refresh").once());
		}
		
		[Test]
		public function unTrimsStayingHold():void {
			stayingHold.trim();
			stayingHold.unTrim();
			
			assertThat(stayHold, received().setter("endtime").arg(700));
			assertThat(sprite, received().method("refresh").twice());
		}
		
		[Test]
		public function trimsBecomingNote():void {
			becomingNote.trim();
			
			assertThat(becomeNote, received().setter("isHold").arg(false));
			assertThat(becomeNote, received().setter("endtime").arg(200));
			assertThat(sprite, received().method("refresh").once());
		}
		
		[Test]
		public function unTrimsBecomingNote():void {
			becomingNote.trim();
			becomingNote.unTrim();
			
			assertThat(becomeNote, received().setter("isHold").arg(true));
			assertThat(becomeNote, received().setter("endtime").arg(400));
			assertThat(sprite, received().method("refresh").twice());
		}
		
		
	}

}