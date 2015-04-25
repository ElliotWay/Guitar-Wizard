package test 
{
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.anyOf;
	import org.hamcrest.core.both;
	import org.hamcrest.core.either;
	import org.hamcrest.number.lessThanOrEqualTo;
	import src.GameUI;
	import src.Note;
	import src.NoteBlock;
	import src.NoteSprite;
	
	MockolateRunner;
	/**
	 * ...
	 * @author ...
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class NoteBlockTest 
	{
		private var noteBlock:NoteBlock;
		private var emptyBlock:NoteBlock;
		
		[Mock]
		public var noteA1:Note, noteA2H3:Note, noteS2_5:Note, noteA3:Note
		[Mock]
		public var noteS3:Note, noteA4H9:Note, noteS4_5H5_5:Note;
		
		[Mock]
		public var spriteA4H7:NoteSprite, spriteS4_5H5_5:NoteSprite;
		
		private var noteList:Vector.<Note>;
		
		private const END_TIME:Number = 5 * GameUI.HIT_TOLERANCE;
		private const DISTANT_TIME:Number = 2 * END_TIME;
		
		[Before]
		public function setup():void {
			
			stub(noteA1).getter("letter").returns(Note.NOTE_A);
			stub(noteA1).getter("time").returns(1.0 * GameUI.HIT_TOLERANCE);
			
			stub(noteA2H3).getter("letter").returns(Note.NOTE_A);
			stub(noteA2H3).getter("time").returns(2.0 * GameUI.HIT_TOLERANCE);
			stub(noteA2H3).getter("isHold").returns(true);
			stub(noteA2H3).getter("endTime").returns(3.0 * GameUI.HIT_TOLERANCE);
			
			stub(noteS2_5).getter("letter").returns(Note.NOTE_S);
			stub(noteS2_5).getter("time").returns(2.5 * GameUI.HIT_TOLERANCE);
			
			stub(noteA3).getter("letter").returns(Note.NOTE_A);
			stub(noteA3).getter("time").returns(3.0 * GameUI.HIT_TOLERANCE);
			
			stub(noteS3).getter("letter").returns(Note.NOTE_S);
			stub(noteS3).getter("time").returns(3.0 * GameUI.HIT_TOLERANCE);
			
			stub(noteA4H9).getter("letter").returns(Note.NOTE_A);
			stub(noteA4H9).getter("time").returns(4 * GameUI.HIT_TOLERANCE);
			stub(noteA4H9).getter("isHold").returns(true);
			stub(noteA4H9).getter("endtime").returns(9 * GameUI.HIT_TOLERANCE);
			stub(noteA4H9).getter("sprite").returns(spriteA4H7);
			
			stub(noteS4_5H5_5).getter("letter").returns(Note.NOTE_S);
			stub(noteS4_5H5_5).getter("time").returns(4.5 * GameUI.HIT_TOLERANCE);
			stub(noteS4_5H5_5).getter("isHold").returns(true);
			stub(noteS4_5H5_5).getter("endtime").returns(5.5 * GameUI.HIT_TOLERANCE);
			stub(noteS4_5H5_5).getter("sprite").returns(spriteS4_5H5_5);
			
			noteList = new <Note>[noteA1, noteA2H3, noteS2_5, noteA3, noteS3, noteA4H9, noteS4_5H5_5];
			
			noteBlock = new NoteBlock(noteList, END_TIME);
			
			var emptyList:Vector.<Note> = new Vector.<Note>();
			emptyBlock = new NoteBlock(emptyList, END_TIME);
		}
		
		//-------------------------------------
		//Find hit tests.
		
		[Test]
		public function findsNullIfEmpty():void {
			
			var note:Note = emptyBlock.findHit(Note.NOTE_A, 2.0 * GameUI.HIT_TOLERANCE);
			
			assertThat(note, null);
		}
		
		[Test]
		public function findsNullIfNoLetterMatch():void {
			var note:Note = noteBlock.findHit(Note.NOTE_F, 3.0 * GameUI.HIT_TOLERANCE);
			
			assertThat(note, null);
		}
		
		[Test]
		public function findsNullIfNoTimeMatch():void {
			var note:Note = noteBlock.findHit(Note.NOTE_A, DISTANT_TIME);
			
			assertThat(note == null);
		}
		
		[Test]
		public function findsNoteIfExactTime():void {
			var note:Note = noteBlock.findHit(Note.NOTE_S, 2.5 * GameUI.HIT_TOLERANCE);
			
			assertThat(note, noteS2_5);
		}
		
		[Test]
		public function findsNoteIfCloseTime():void {
			var closeTime:Number = 3.5 * GameUI.HIT_TOLERANCE;
			
			var note:Note = noteBlock.findHit(Note.NOTE_A, closeTime);
			
			assertThat(note, noteA3);
		}
		
		[Test]
		public function findsFirstIfMultiple():void {
			var ambiguousTime:Number = 2.8 * GameUI.HIT_TOLERANCE;
			
			var note:Note = noteBlock.findHit(Note.NOTE_S, ambiguousTime);
			
			assertThat(note, noteS2_5);
		}
		
		//---------------------------------
		//Miss until tests.
		
		[Test]
		public function noErrorsMissingEmptyBlock():void {
			var noteMissed:Boolean = emptyBlock.missUntil(END_TIME);
			
			assertThat(noteMissed, false);
		}
		
		[Test]
		public function missesAllNotes():void {
			var noteMissed:Boolean = noteBlock.missUntil(DISTANT_TIME);
			
			assertThat(noteA1, received().method("miss"));
			assertThat(noteA2H3, received().method("miss"));
			assertThat(noteS2_5, received().method("miss"));
			assertThat(noteA3, received().method("miss"));
			assertThat(noteS3, received().method("miss"));
			assertThat(noteA4H9, received().method("miss"));
			assertThat(noteS4_5H5_5, received().method("miss"));

			assertThat(noteMissed, true);
		}
		
		[Test]
		public function missesNoNotes():void {
			var noteMissed:Boolean = noteBlock.missUntil(GameUI.HIT_TOLERANCE / 2);
			
			assertThat(noteA1, received().method("miss").never());
			assertThat(noteA2H3, received().method("miss").never());
			assertThat(noteS2_5, received().method("miss").never());
			assertThat(noteA3, received().method("miss").never());
			assertThat(noteS3, received().method("miss").never());
			assertThat(noteA4H9, received().method("miss").never());
			assertThat(noteS4_5H5_5, received().method("miss").never());
			
			assertThat(noteMissed, false);
		}
		
		[Test]
		public function missesSomeNotes():void {
			var noteMissed:Boolean = noteBlock.missUntil(GameUI.HIT_TOLERANCE * 4);
			
			assertThat(noteA1, received().method("miss"));
			assertThat(noteA2H3, received().method("miss"));
			assertThat(noteS2_5, received().method("miss"));
			assertThat(noteA3, received().method("miss").never());
			assertThat(noteS3, received().method("miss").never());
			assertThat(noteA4H9, received().method("miss").never());
			assertThat(noteS4_5H5_5, received().method("miss").never());
			
			assertThat(noteMissed, true);
		}
		
		[Test]
		public function cannotMissHitNotes():void {
			stub(noteA2H3).method("isHit").returns(true);
			stub(noteS3).method("isHit").returns(true);
			
			noteBlock.missUntil(DISTANT_TIME);
			
			assertThat(noteA1, received().method("miss"));
			assertThat(noteA2H3, received().method("miss").never());
			assertThat(noteS2_5, received().method("miss"));
			assertThat(noteA3, received().method("miss"));
			assertThat(noteS3, received().method("miss").never());
			assertThat(noteA4H9, received().method("miss"));
			assertThat(noteS4_5H5_5, received().method("miss"));
		}
		
		[Test]
		public function doesNotRepeatedlyMissNotes():void {
			noteBlock.missUntil(GameUI.HIT_TOLERANCE * 4);
			
			noteBlock.missUntil(DISTANT_TIME);
			
			assertThat(noteA1, received().method("miss").once());
			assertThat(noteA2H3, received().method("miss").once());
		}
		
		//---------------------------
		//Cutting tests.
		
		[Test]
		public function cutsTrailingNotes():void {
			noteBlock.cut();
			
			assertThat(noteA4H9, anyOf(received().setter("isHold").arg(false), //or
					received().setter("endtime").arg(lessThanOrEqualTo(END_TIME))));
			assertThat(spriteA4H7, received().method("refresh").once());
			
			
			assertThat(noteS4_5H5_5, anyOf(received().setter("isHold").arg(false), //or
					received().setter("endtime").arg(lessThanOrEqualTo(END_TIME))));
			assertThat(spriteS4_5H5_5, received().method("refresh").once());
		}
		
		[Test]
		public function doesNotModifyWellPositionedNotes():void {
			noteBlock.cut();
			
			var wellPositioned:Vector.<Note> =
					new <Note>[noteA1, noteA2H3, noteS2_5, noteA3, noteS3];
					
			for each (var note:Note in wellPositioned) {
				assertThat(note, received().setter("letter").never());
				assertThat(note, received().setter("time").never());
				assertThat(note, received().setter("isHold").never());
				assertThat(note, received().setter("endTime").never());
			}
		}
		
		[Test]
		public function restoresCutNotes():void {
			noteBlock.cut();
			noteBlock.uncut();
			
			assertThat(noteA4H9, both(received().setter("isHold").arg(true), //and
					received().setter("endtime").arg(9 * GameUI.HIT_TOLERANCE)));
			assertThat(spriteA4H7, received().method("refresh").twice());
			
			assertThat(noteS4_5H5_5, both(received().setter("isHold").arg(true), //and
					received().setter("endtime").arg(5.5 * GameUI.HIT_TOLERANCE)));
			assertThat(spriteS4_5H5_5, received().method("refresh").twice());
		}
	}

}