package test 
{
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.anyOf;
	import org.hamcrest.core.both;
	import org.hamcrest.core.either;
	import org.hamcrest.core.not;
	import org.hamcrest.number.lessThanOrEqualTo;
	import src.GameUI;
	import src.Note;
	import src.NoteBlock;
	import src.NoteSprite;
	import src.NoteSpriteFactory;
	import src.Repeater;
	
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
		public var spriteA1:NoteSprite, spriteA2H3:NoteSprite, spriteS2_5:NoteSprite, spriteA3:NoteSprite;
		[Mock]
		public var spriteS3:NoteSprite, spriteA4H9:NoteSprite, spriteS4_5H5_5:NoteSprite;
		
		[Mock]
		public var noteSpriteFactory:NoteSpriteFactory;
		
		[Mock]
		public var repeater:Repeater;
		
		private var noteList:Vector.<Note>;
		
		private const END_TIME:Number = 5 * GameUI.HIT_TOLERANCE;
		private const DISTANT_TIME:Number = 2 * END_TIME;
		
		private const SEVERAL_FRAMES:int = 12;
		
		[Before]
		public function setup():void {
			
			stub(noteA1).getter("letter").returns(Note.NOTE_A);
			stub(noteA1).getter("time").returns(1.0 * GameUI.HIT_TOLERANCE);
			
			stub(noteA2H3).getter("letter").returns(Note.NOTE_A);
			stub(noteA2H3).getter("time").returns(2.0 * GameUI.HIT_TOLERANCE);
			stub(noteA2H3).getter("isHold").returns(true);
			stub(noteA2H3).getter("endTime").returns(3.0 * GameUI.HIT_TOLERANCE);
			stub(noteA2H3).getter("sprite").returns(spriteA2H3);
			
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
			stub(noteA4H9).getter("sprite").returns(spriteA4H9);
			
			stub(noteS4_5H5_5).getter("letter").returns(Note.NOTE_S);
			stub(noteS4_5H5_5).getter("time").returns(4.5 * GameUI.HIT_TOLERANCE);
			stub(noteS4_5H5_5).getter("isHold").returns(true);
			stub(noteS4_5H5_5).getter("endtime").returns(5.5 * GameUI.HIT_TOLERANCE);
			stub(noteS4_5H5_5).getter("sprite").returns(spriteS4_5H5_5);
			
			stub(noteSpriteFactory).method("create").args(noteA1).returns(spriteA1);
			stub(noteSpriteFactory).method("create").args(noteA2H3).returns(spriteA2H3);
			stub(noteSpriteFactory).method("create").args(noteS2_5).returns(spriteS2_5);
			stub(noteSpriteFactory).method("create").args(noteA3).returns(spriteA3);
			stub(noteSpriteFactory).method("create").args(noteS3).returns(spriteS3);
			stub(noteSpriteFactory).method("create").args(noteA4H9).returns(spriteA4H9);
			stub(noteSpriteFactory).method("create").args(noteS4_5H5_5).returns(spriteS4_5H5_5);
			
			noteList = new <Note>[noteA1, noteA2H3, noteS2_5, noteA3, noteS3, noteA4H9, noteS4_5H5_5];
			
			noteBlock = new NoteBlock(noteList, END_TIME, noteSpriteFactory);
			
			var emptyList:Vector.<Note> = new Vector.<Note>();
			emptyBlock = new NoteBlock(emptyList, END_TIME, noteSpriteFactory);
		}
		
		[Test]
		public function rendersCorrectly():void {
			noteBlock.render();
			
			for (var i:int; i < SEVERAL_FRAMES; i++) {
				noteBlock.continueSplitActions();
			}
			
			//Only the notes without sprites should be rendered.
			assertThat(noteSpriteFactory, received().method("create").arg(noteA1));
			assertThat(noteSpriteFactory, received().method("create").arg(noteS2_5));
			assertThat(noteSpriteFactory, received().method("create").arg(noteA3));
			assertThat(noteSpriteFactory, received().method("create").arg(noteS3));
			
			//Check that they've been added as children.
			assertThat(noteBlock.contains(spriteA1));
			assertThat(noteBlock.contains(spriteS2_5));
			assertThat(noteBlock.contains(spriteA3));
			assertThat(noteBlock.contains(spriteS3));
		}
		
		[Test]
		public function derendersCorrectly():void {
			noteBlock.render(); //This allows derender to be called.
			
			//Fake rendering.
			noteBlock.addChild(spriteA2H3);
			noteBlock.addChild(spriteA4H9);
			noteBlock.addChild(spriteS4_5H5_5);
			
			noteBlock.derender();
			
			for (var j:int; j < SEVERAL_FRAMES; j++) {
				noteBlock.continueSplitActions();
			}
			
			//And only the notes with sprites should be derendered.
			assertThat(noteSpriteFactory, received().method("destroy").arg(spriteA2H3));
			assertThat(noteSpriteFactory, received().method("destroy").arg(spriteA4H9));
			assertThat(noteSpriteFactory, received().method("destroy").arg(spriteS4_5H5_5));
			
			//Check that they've been removed.
			assertThat(noteBlock.contains(spriteA2H3), false);
			assertThat(noteBlock.contains(spriteA4H9), false);
			assertThat(noteBlock.contains(spriteS4_5H5_5), false);
		}
		
		//-------------------------------------
		//Find hit tests.
		
		[Test]
		public function findsNullIfEmpty():void {
			
			var note:Note = emptyBlock.findHit(Note.NOTE_A, 2.0 * GameUI.HIT_TOLERANCE, repeater);
			
			assertThat(note, null);
		}
		
		[Test]
		public function findsNullIfNoLetterMatch():void {
			var note:Note = noteBlock.findHit(Note.NOTE_F, 3.0 * GameUI.HIT_TOLERANCE, repeater);
			
			assertThat(note, null);
		}
		
		[Test]
		public function findsNullIfNoTimeMatch():void {
			var note:Note = noteBlock.findHit(Note.NOTE_A, DISTANT_TIME, repeater);
			
			assertThat(note, null);
		}
		
		[Test]
		public function findsNoteIfExactTime():void {
			var note:Note = noteBlock.findHit(Note.NOTE_S, 2.5 * GameUI.HIT_TOLERANCE, repeater);
			
			assertThat(note, noteS2_5);	
			assertThat(note, received().method("hit").arg(repeater));
		}
		
		[Test]
		public function findsNoteIfCloseTime():void {
			var closeTime:Number = 3.5 * GameUI.HIT_TOLERANCE;
			
			var note:Note = noteBlock.findHit(Note.NOTE_A, closeTime, repeater);
			
			assertThat(note, noteA3);
			assertThat(note, received().method("hit").arg(repeater));
		}
		
		[Test]
		public function findsFirstIfMultiple():void {
			var ambiguousTime:Number = 2.8 * GameUI.HIT_TOLERANCE;
			
			var note:Note = noteBlock.findHit(Note.NOTE_S, ambiguousTime, repeater);
			
			assertThat(note, noteS2_5);
			assertThat(note, received().method("hit").arg(repeater));
		}
		
		//---------------------------------
		//Miss until tests.
		
		[Test]
		public function noErrorsMissingEmptyBlock():void {
			var noteMissed:Boolean = emptyBlock.missUntil(END_TIME, repeater);
			
			assertThat(noteMissed, false);
		}
		
		[Test]
		public function missesAllNotes():void {
			var noteMissed:Boolean = noteBlock.missUntil(DISTANT_TIME, repeater);
			
			assertThat(noteA1, received().method("miss").arg(repeater));
			assertThat(noteA2H3, received().method("miss").arg(repeater));
			assertThat(noteS2_5, received().method("miss").arg(repeater));
			assertThat(noteA3, received().method("miss").arg(repeater));
			assertThat(noteS3, received().method("miss").arg(repeater));
			assertThat(noteA4H9, received().method("miss").arg(repeater));
			assertThat(noteS4_5H5_5, received().method("miss").arg(repeater));

			assertThat(noteMissed, true);
		}
		
		[Test]
		public function missesNoNotes():void {
			var noteMissed:Boolean = noteBlock.missUntil(GameUI.HIT_TOLERANCE / 2, repeater);
			
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
			var noteMissed:Boolean = noteBlock.missUntil(GameUI.HIT_TOLERANCE * 4, repeater);
			
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
			
			noteBlock.missUntil(DISTANT_TIME, repeater);
			
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
			noteBlock.missUntil(GameUI.HIT_TOLERANCE * 4, repeater);
			
			noteBlock.missUntil(DISTANT_TIME, repeater);
			
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
			assertThat(spriteA4H9, received().method("refresh").once());
			
			
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
			assertThat(spriteA4H9, received().method("refresh").twice());
			
			assertThat(noteS4_5H5_5, both(received().setter("isHold").arg(true), //and
					received().setter("endtime").arg(5.5 * GameUI.HIT_TOLERANCE)));
			assertThat(spriteS4_5H5_5, received().method("refresh").twice());
		}
	}

}