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
	

	/**
	 * Tests the Song.parseNotes method, which parses the notes out of a string
	 * and throws and error if they're badly formatted.
	 * @author Elliot Way
	 */
	public class Song_ParseNotesTest 
	{
		
		private var noteList:Vector.<Note>;
		
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
			noteList = new Vector.<Note>();
		}
		
		[Test]
		public function emptyWithEmptyString():void {
			Song.parseNotes(noteList, "");
			
			assertThat(noteList, emptyArray());
		}
		
		//Various Possible Errors
		
		[Test]
		public function errorWithNullVector():void {
			
			assertThat(function():void {
				Song.parseNotes(null, "A 123 S 456");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithInitialHold():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "H 123 A 456 H 555 S 999");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithRepeatedHold():void {
			assertThat(function():void {
				//											 V --- V
				Song.parseNotes(noteList, "A 100 H 150 S 200 H 300 H 350 A 500 H 600")
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithWrongLetter():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "A 100 Q 200 H 300");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithLongLetter():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "S 100 AF 200");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithInitialTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "123 S 456 A 999");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithMisplacedTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "A 250 H 350 S 400 999 D 1024");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithBadTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "A 100 D asdf H 200 S 1234");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithNegativeTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "A -100 S 10 H 100");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithNoFinalTimeStamp():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "A 100 S 200 H 300 D 400 H 500 F 600 A");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithBackwardsTimeStamps():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "A 200 S 400 D 300 F 500");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithBackwardsTimeStampOnHold():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "A 200 S 400 H 300 F 500");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithSimultaneousNote():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "A 100 S 200 S 200 D 300 H 400");
			}, throws(instanceOf(GWError)));
		}
		
		[Test]
		public function errorWithSimultaneousHold():void {
			
			assertThat(function():void {
				Song.parseNotes(noteList, "A 100 H 200 A 100 H 250");
			}, throws(instanceOf(GWError)));
		}
		
		
		//Expected Behavior Without Errors
		
		[Test]
		public function readsOneNote():void {
			
			Song.parseNotes(noteList, "A 100");
			
			assertThat(noteList, array(isNote(Note.NOTE_A, 100)));
		}
		
		[Test]
		public function readsOneHold():void {
			
			Song.parseNotes(noteList, "A 100 H 200");
			
			assertThat(noteList, array(isNote(Note.NOTE_A, 100, true, 200)));
		}
		
		[Test]
		public function readsMultipleNotes():void {
			
			Song.parseNotes(noteList, "A 100 D 200 S 300");
			
			assertThat(noteList, array(isNote(Note.NOTE_A, 100),
										isNote(Note.NOTE_D, 200),
										isNote(Note.NOTE_S, 300)));
		}
		
		[Test]
		public function readsMultipleHolds():void {
			
			Song.parseNotes(noteList, "A 100 H 200 S 300 H 400 D 500 H 600");
			
			assertThat(noteList, array(isNote(Note.NOTE_A, 100, true, 200),
										isNote(Note.NOTE_S, 300, true, 400),
										isNote(Note.NOTE_D, 500, true, 600)));
		}
		
		[Test]
		public function readsMixed():void {
			
			Song.parseNotes(noteList, "A 100 S 200 H 300 D 400 A 500 H 600 S 700 S 800 F 900 H 1000");
			
			assertThat(noteList, array(isNote(Note.NOTE_A, 100),
										isNote(Note.NOTE_S, 200, true, 300),
										isNote(Note.NOTE_D, 400),
										isNote(Note.NOTE_A, 500, true, 600),
										isNote(Note.NOTE_S, 700),
										isNote(Note.NOTE_S, 800),
										isNote(Note.NOTE_F, 900, true, 1000)));
		}
		
		[Test]
		public function okayWithSameTimeStamp():void {
			
			Song.parseNotes(noteList, "A 100 S 200 D 200 H 300 S 400 D 400 F 400 A 500");
			
			assertThat(noteList, array(isNote(Note.NOTE_A, 100),
										isNote(Note.NOTE_S, 200),
										isNote(Note.NOTE_D, 200, true, 300),
										isNote(Note.NOTE_S, 400),
										isNote(Note.NOTE_D, 400),
										isNote(Note.NOTE_F, 400),
										isNote(Note.NOTE_A, 500)));
		}
		
		[Test]
		public function okayWithNoteWithinHold():void {
			
			Song.parseNotes(noteList, "A 100 S 200 H 400 D 300 F 500");
			
			assertThat(noteList, array(isNote(Note.NOTE_A, 100),
										isNote(Note.NOTE_S, 200, true, 400),
										isNote(Note.NOTE_D, 300),
										isNote(Note.NOTE_F, 500)));
		}
		
		
		
	}

}