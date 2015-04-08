package test 
{
	
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.core.throws;
	import org.hamcrest.CustomMatcher;
	import org.hamcrest.Matcher;
	import org.hamcrest.object.instanceOf;
	import src.GWError;
	import src.Note;
	import src.Song;
	

	public class SongTest 
	{
		
		private var noteList:Vector.<Vector.<Note>>;
		private var emptyBlocks:Vector.<Number>;
		
		/**
		 * Creates a matcher for a given note.
		 * @param	letter
		 * @param	time
		 * @param	isHold
		 * @param	endTime
		 * @return
		 */
		private function isNote(letter:int, time:Number,
				isHold:Boolean = false, endTime:Number = -1.0):Matcher {

			var description:String = "is Note: ";
			
			if (letter == Note.NOTE_A)
				description += "A";
			else if (letter == Note.NOTE_D)
				description += "D";
			else if (letter == Note.NOTE_F)
				description += "F";
			else if (letter == Note.NOTE_S)
				description += "S";
				
			description += " " + time;
			if (isHold) {
				description += " to " + endTime;
			}
					
			return new CustomMatcher(description,
				function(item:Object):Boolean {
					if (!item is Note)
						return false;
					
					var note:Note = Note(item);
					
					return note.letter == letter &&
							note.time == time &&
							note.isHold == isHold &&
							(isHold) ? (note.endtime == endTime) : (true);
				}
			)
		}
		
		[Before]
		public function setup():void {
			noteList = new Vector.<Vector.<Note>>();
			emptyBlocks = new Vector.<Number>();
		}
		
		//Parsing block separators...
		
		[Test]
		public function errorWithBadBlock():void {
			assertThat(function():void {
				Song.parseBlocks(emptyBlocks, "123 abc");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithNegativeBlock():void {
			assertThat(function():void {
				Song.parseBlocks(emptyBlocks, "-123 456");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithBackwardsBlock():void {
			assertThat(function():void {
				Song.parseBlocks(emptyBlocks, "555 444");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorOnRepeatedBlock():void {
			assertThat(function():void {
				Song.parseBlocks(emptyBlocks, "123 123");
			}, throws(instanceOf(GWError)));
		}
		
		//------
		
		[Test]
		public function emptyBlocksWithEmptyString():void {
			Song.parseBlocks(emptyBlocks, "");
			
			assertThat(emptyBlocks.length, 0);
		}
		
		[Test]
		public function readsOneBlock():void {
			Song.parseBlocks(emptyBlocks, "123");
			
			assertThat(emptyBlocks, array(123));
		}
		
		[Test]
		public function readsMultipleBlocks():void {
			Song.parseBlocks(emptyBlocks, "123 456 789 1011");
			
			assertThat(emptyBlocks, array(123, 456, 789, 1011));
		}
		
		
		
		//Parsing notes with just one block...
		
		[Test]
		public function errorWithNullVector():void {
			
			assertThat(function():void {
				Song.parseNotes(null, emptyBlocks, "A 123 S 456");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithInitialHold():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "H 123 A 456 H 555 S 999");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithRepeatedHold():void {
			assertThat(function():void {
				//											 V --- V
				Song.parseNotes(noteList, emptyBlocks, "A 100 H 150 S 200 H 300 H 350 A 500 H 600")
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithWrongLetter():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "A 100 Q 200 H 300");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithLongLetter():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "S 100 AF 200");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithInitialTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "123 S 456 A 999");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithMisplacedTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "A 250 H 350 S 400 999 D 1024");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithBadTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "A 100 D asdf H 200 S 1234");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithNegativeTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "A -100 S 10 H 100");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithNoFinalTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "A 100 S 200 H 300 D 400 H 500 F 600 A");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithBackwardsTimeStamps():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "A 200 S 400 D 300 F 500");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithBackwardsTimeStampOnHold():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "A 200 S 400 H 300 F 500");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithSimultaneousNote():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "A 100 S 200 S 200 D 300 H 400");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithSimultaneousHold():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, emptyBlocks, "A 100 H 200 A 100 H 250");
			}, throws(instanceOf(GWError)));
		}
		
		//---------------
		
		
		[Test]
		public function emptyWithEmptyString():void {
			Song.parseNotes(noteList, emptyBlocks, "");
			
			assertThat(noteList.length, 0);
		}
		
		[Test]
		public function readsOneNote():void {
			
			Song.parseNotes(noteList, emptyBlocks, "A 100");
			
			assertThat(noteList.length, 1);
			assertThat(noteList[0], array(isNote(Note.NOTE_A, 100)));
		}
		
		[Test]
		public function readsOneHold():void {
			
			Song.parseNotes(noteList, emptyBlocks, "A 100 H 200");
			
			assertThat(noteList.length, 1);
			assertThat(noteList[0], array(isNote(Note.NOTE_A, 100, true, 200)));
		}
		
		[Test]
		public function readsMultipleNotes():void {
			
			Song.parseNotes(noteList, emptyBlocks, "A 100 D 200 S 300");
			
			assertThat(noteList.length, 1);
			assertThat(noteList[0], array(isNote(Note.NOTE_A, 100),
										isNote(Note.NOTE_D, 200),
										isNote(Note.NOTE_S, 300)));
		}
		
		[Test]
		public function readsMultipleHolds():void {
			
			Song.parseNotes(noteList, emptyBlocks, "A 100 H 200 S 300 H 400 D 500 H 600");
			
			assertThat(noteList.length, 1);
			assertThat(noteList[0], array(isNote(Note.NOTE_A, 100, true, 200),
										isNote(Note.NOTE_S, 300, true, 400),
										isNote(Note.NOTE_D, 500, true, 600)));
		}
		
		[Test]
		public function readsMixed():void {
			
			Song.parseNotes(noteList, emptyBlocks, "A 100 S 200 H 300 D 400 A 500 H 600 S 700 S 800 F 900 H 1000");
			
			assertThat(noteList.length, 1);
			assertThat(noteList[0], array(isNote(Note.NOTE_A, 100),
										isNote(Note.NOTE_S, 200, true, 300),
										isNote(Note.NOTE_D, 400),
										isNote(Note.NOTE_A, 500, true, 600),
										isNote(Note.NOTE_S, 700),
										isNote(Note.NOTE_S, 800),
										isNote(Note.NOTE_F, 900, true, 1000)));
		}
		
		[Test]
		public function okayWithSameTimeStamp():void {
			
			Song.parseNotes(noteList, emptyBlocks, "A 100 S 200 D 200 H 300 S 400 D 400 F 400 A 500");
			
			assertThat(noteList.length, 1);
			assertThat(noteList[0], array(isNote(Note.NOTE_A, 100),
										isNote(Note.NOTE_S, 200),
										isNote(Note.NOTE_D, 200, true, 300),
										isNote(Note.NOTE_S, 400),
										isNote(Note.NOTE_D, 400),
										isNote(Note.NOTE_F, 400),
										isNote(Note.NOTE_A, 500)));
		}
		
		[Test]
		public function okayWithNoteWithinHold():void {
			
			Song.parseNotes(noteList, emptyBlocks, "A 100 S 200 H 400 D 300 F 500");
			
			assertThat(noteList.length, 1);
			assertThat(noteList[0], array(isNote(Note.NOTE_A, 100),
										isNote(Note.NOTE_S, 200, true, 400),
										isNote(Note.NOTE_D, 300),
										isNote(Note.NOTE_F, 500)));
		}
		
		
		
		//Parsing notes with multiple blocks.
		
		[Test]
		public function readsNotesInMultipleBlocks():void {
			var blocks:Vector.<Number> = new <Number>[100, 200];
			
			Song.parseNotes(noteList, blocks, "A 50 S 150 D 250");
			assertThat(noteList, array(array(isNote(Note.NOTE_A, 50)),
									array(isNote(Note.NOTE_S, 150)),
									array(isNote(Note.NOTE_D, 250))));
		}
		
		[Test]
		public function readsEmptyBlocks():void {
			var blocks:Vector.<Number> = new <Number>[100, 200, 300, 400];
			
			Song.parseNotes(noteList, blocks, "A 50, S 350, F 499");
			assertThat(noteList, array(array(isNote(Note.NOTE_A, 50)),
									array(),
									array(),
									array(isNote(Note.NOTE_S, 350)),
									array(isNote(Note.NOTE_F, 499))));
		}
		
		[Test]
		public function readsHoldsOverBlockBound():void {
			var blocks:Vector.<Number> = new <Number>[100];
			
			Song.parseNotes(noteList, blocks, "D 50 H 150 S 150");
			assertThat(noteList, array(array(isNote(Note.NOTE_D, 50, true, 150)),
									array(isNote(Note.NOTE_S, 150))));
		}
		
		[Test]
		public function stressTestMutipleBlocksNoteParse():void {
			var blocks:Vector.<Number> = new <Number>[100, 200, 300, 400, 500];
			
			Song.parseNotes(noteList, blocks, "A 20 H 90 S 20 H 120 F 40 H 350 D 75 " +
											"A 150 D 175 " +
											"A 250 H 350 S 275 F 280 H 300 " +
											"" +
											"A 410 H 480 S 420 D 440 S 440 F 460 S 460 H 510 " +
											"F 510 A 510 H 800");
			assertThat(noteList, array(	array(	isNote(Note.NOTE_A, 20, true, 90),		isNote(Note.NOTE_S, 20, true, 120),	isNote(Note.NOTE_F, 40, true, 350), isNote(Note.NOTE_D, 75)),
										array(	isNote(Note.NOTE_A, 150),				isNote(Note.NOTE_D, 175)),
										array(	isNote(Note.NOTE_A, 250, true, 350),	isNote(Note.NOTE_S, 275),			isNote(Note.NOTE_F, 280, true, 300)),
										array(),
										array(	isNote(Note.NOTE_A, 410, true, 480),	isNote(Note.NOTE_S, 420),			isNote(Note.NOTE_D, 440),			isNote(Note.NOTE_S, 440),	isNote(Note.NOTE_F, 460),	isNote(Note.NOTE_S, 460, true, 510)),
										array(	isNote(Note.NOTE_F, 510),				isNote(Note.NOTE_A, 510, true, 800))));
												
		}
		
		
		
	}

}