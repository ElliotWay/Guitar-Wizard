package test 
{
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import src.GameUI;
	import src.MusicArea;
	import src.MusicPlayer;
	import src.Note;
	import src.Song;
	
	MockolateRunner;
	/**
	 * Tests the missNotesUntil and the clearNotesUntil methods.
	 * @author Elliot Way
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class GameUI_MissUntilTest
	{
		
		[Mock]
		public var note10:Note, note20:Note, note30A:Note, note30B:Note, note40:Note;
		
		private var noteList:Vector.<Note>;
		
		
		[Before]
		public function setup():void {
			stub(note10).getter("time").returns(10.0);
			stub(note20).getter("time").returns(20.0);
			stub(note30A).getter("time").returns(30.0);
			stub(note30B).getter("time").returns(30.0);
			stub(note40).getter("time").returns(40.0);
			
			noteList = new <Note>[note40, note30A, note30B, note20, note10];
		}
		
		
		[Test]
		public function noErrorsMissingEmptyVector():void {
			var emptyVector:Vector.<Note> = new Vector.<Note>();
			
			GameUI.missNotesUntil(emptyVector, 100.0);
			GameUI.clearNotesUntil(emptyVector, 100.0);
		}
		
		[Test]
		public function missesAllNotes():void {
			//Check that all notes are missed if the cutoff time is late.
			GameUI.missNotesUntil(noteList, 100.0);
			
			assertThat(noteList.length == 0);
			
			assertThat(note10, received().method("miss"));
			assertThat(note20, received().method("miss"));
			assertThat(note30A, received().method("miss"));
			assertThat(note30B, received().method("miss"));
			assertThat(note40, received().method("miss"));
		}
		
		[Test]
		public function clearsAllNotes():void {
			GameUI.clearNotesUntil(noteList, 100.0);
			
			assertThat(noteList.length == 0);
			
			assertThat(note10, received().method("miss").never());
			assertThat(note20, received().method("miss").never());
			assertThat(note30A, received().method("miss").never());
			assertThat(note30B, received().method("miss").never());
			assertThat(note40, received().method("miss").never());
		}
		
		[Test]
		public function missesNoNotes():void {
			//Check that no notes are missed if the cutoff time is early.
			GameUI.missNotesUntil(noteList, 10.0);
			
			assertThat(noteList, array(note40, note30A, note30B, note20, note10));
			
			assertThat(note10, received().method("miss").never());
			assertThat(note20, received().method("miss").never());
			assertThat(note30A, received().method("miss").never());
			assertThat(note30B, received().method("miss").never());
			assertThat(note40, received().method("miss").never());
		}
		
		[Test]
		public function clearsNoNotes():void {
			GameUI.clearNotesUntil(noteList, 10.0);
			
			assertThat(noteList, array(note40, note30A, note30B, note20, note10));
		}
		
		[Test]
		public function missesSomeNotes():void {
			//Checks that some notes are missed if the cutoff time is in the middle.
			GameUI.missNotesUntil(noteList, 30.0);
			
			assertThat(noteList, array(note40, note30A, note30B));
			
			assertThat(note10, received().method("miss"));
			assertThat(note20, received().method("miss"));
			assertThat(note30A, received().method("miss").never());
			assertThat(note30B, received().method("miss").never());
			assertThat(note40, received().method("miss").never());
		}
		
		[Test]
		public function clearsSomeNotes():void {
			GameUI.clearNotesUntil(noteList, 30.0);
			
			assertThat(noteList, array(note40, note30A, note30B));
		}
	}

}