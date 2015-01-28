package test 
{
	
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.flexunit.runner.manipulation.NoTestsRemainException;
	import org.hamcrest.assertThat;
	import src.GameUI;
	import src.Note;
	
	MockolateRunner;
	/**
	 * ...
	 * @author Elliot Way
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class GameUI_FindHitTest 
	{
		
		[Mock]
		public var noteA1:NoteExtension, noteA2:NoteExtension, noteS2_5:NoteExtension, noteA3:NoteExtension, noteS3:NoteExtension;
		
		private var noteList:Vector.<Note>;
		
		[Before]
		public function setup():void {
			
			stub(noteA1).getter("letter").returns(Note.NOTE_A);
			stub(noteA1).getter("time").returns(1.0 * GameUI.HIT_TOLERANCE);
			
			stub(noteA2).getter("letter").returns(Note.NOTE_A);
			stub(noteA2).getter("time").returns(2.0 * GameUI.HIT_TOLERANCE);
			
			stub(noteS2_5).getter("letter").returns(Note.NOTE_S);
			stub(noteS2_5).getter("time").returns(2.5 * GameUI.HIT_TOLERANCE);
			
			stub(noteA3).getter("letter").returns(Note.NOTE_A);
			stub(noteA3).getter("time").returns(3.0 * GameUI.HIT_TOLERANCE);
			
			stub(noteS3).getter("letter").returns(Note.NOTE_S);
			stub(noteS3).getter("time").returns(3.0 * GameUI.HIT_TOLERANCE);
			
			noteList = new <Note>[noteA3, noteS3, noteS2_5, noteA2, noteA1];
		}
		
		[Test]
		public function findsNullIfEmpty():void {
			var emptyList:Vector.<Note> = new Vector.<Note>();
			
			var note:Note = GameUI.findFirstHit(emptyList, Note.NOTE_A, 2.5 * GameUI.HIT_TOLERANCE);
			
			assertThat(note == null);
		}
		
		[Test]
		public function findsNullIfNoLetterMatch():void {
			var note:Note = GameUI.findFirstHit(noteList, Note.NOTE_F, 3.0 * GameUI.HIT_TOLERANCE);
			
			assertThat(note == null);
		}
		
		[Test]
		public function findsNullIfNoTimeMatch():void {
			var distantTime:Number = 4 * GameUI.HIT_TOLERANCE + 1.0;
			
			var note:Note = GameUI.findFirstHit(noteList, Note.NOTE_A, distantTime);
			
			assertThat(note == null);
		}
		
		[Test]
		public function findsNoteIfExactTime():void {
			var note:Note = GameUI.findFirstHit(noteList, Note.NOTE_S, 2.5 * GameUI.HIT_TOLERANCE);
			
			assertThat(note == noteS2_5);
		}
		
		[Test]
		public function findsNoteIfCloseTime():void {
			var closeTime:Number = 3.5 * GameUI.HIT_TOLERANCE;
			
			var note:Note = GameUI.findFirstHit(noteList, Note.NOTE_A, closeTime);
			
			assertThat(note == noteA3);
		}
		
		[Test]
		public function findsFirstIfMultiple():void {
			var ambiguousTime:Number = 2.8 * GameUI.HIT_TOLERANCE;
			
			var note:Note = GameUI.findFirstHit(noteList, Note.NOTE_S, ambiguousTime);
			
			assertThat(note == noteS2_5);
		}
	}

}