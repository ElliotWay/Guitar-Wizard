package  src
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Song 
	{
		
		private var _lowPart:Vector.<Note>;
		private var _midPart:Vector.<Note>;
		private var _highPart:Vector.<Note>;

		private var _lowMusic:Sound;
		private var _midMusic:Sound;
		private var _highMusic:Sound;
		private var _baseMusic:Sound;
		
		private var loader:URLLoader;
		
		public function Song() 
		{
			
		}
		
		/**
		 * Load a gsw file, that is a Guitar Wizard Song file.
		 * @param	fileName the url of the file
		 */
		public function loadFile(fileName:String):void {
			loader = new URLLoader(new URLRequest(fileName));
			
			loader.addEventListener(Event.COMPLETE, interpretFile);
			loader.addEventListener(IOErrorEvent.IO_ERROR, fileError);
		}
		
		private function fileError(e:Event):void {
			Main.showError("Error loading file");
		}
		
		private function interpretFile(e:Event):void {
			var lines:Array = String(loader.data).split("\n");
			
			if (lines.length < 7)
				Main.showError("Error: Corrupt GSW file: missing lines");
			
			var baseName:String = lines[0];
			var highName:String = lines[1];
			var midName:String = lines[2];
			var lowName:String = lines[3];
			
			_baseMusic = new Sound();
			_highMusic = new Sound();
			_midMusic = new Sound();
			_lowMusic = new Sound();
			
			//TODO definitely change this later.
			Main.loadSong(baseMusic, baseName);
			Main.loadSong(highMusic, highName);
			Main.loadSong(midMusic, midName);
			//Main.loadSong(lowMusic, lowName);
			
			var highNoteString:String = lines[4];
			var midNoteString:String = lines[5];
			var lowNoteString:String = lines[6];
			
			_highPart = new Vector.<Note>();
			_midPart = new Vector.<Note>();
			_lowPart = new Vector.<Note>();
			
			try {
				parseNotes(_highPart, highNoteString);
				parseNotes(_midPart, midNoteString);
				parseNotes(_lowPart, lowNoteString);
			} catch (error:Error) {
				trace(error.message);
				Main.showError(error.message);
			}
			
			
			Main.fileLoaded();
		}
		
		/**
		 * Parse the notes out of string into a vector.
		 * 
		 * The basic format of these strings is
		 * 
		 * L dddd L dddd L dddd
		 * 
		 * where L is some letter and dddd is a timestamp in milliseconds.
		 * If L is A, S, D, or F, the following timestamp is the start time of a note
		 * with the same letter.
		 * If L is H, then the following timestamp is the end time of the note that should be
		 * converted to a hold. An H should never follow another H.
		 * Timestamps should be nonnegative and increasing, with an exception that notes may
		 * be earlier than the end of an earlier hold.
		 * 
		 * A known issue with this function is that is doesn't detect certain bad timestamps;
		 * parseInt isn't strict enough.
		 * 
		 * @param	noteList the list to add the notes to
		 * @param	str the string out of which to parse the notes
		 */
		public static function parseNotes(noteList:Vector.<Note>, str:String):void {
			
			if (noteList == null) {
				throw new GWError("Error: parse notes called with null vector");
			}
			
			if (str == "")
				return;
			
			var tokens:Array = str.split(/\s+/);
			
			var note:Note = null;
			var lastTime:Number = -1;
			var lastLetter:String;
			
			var index:int = 0;
			while (index < tokens.length) {
				var letter:String = tokens[index];
				
				if (letter.length > 1) {
					trace("Long letter: " + letter);
					throw new GWError("Error: Corrupt GWS File: long letter " +
							"Token # " + index + " " + letter);
				} else if (letter.length == 0) {
					index++;
					continue;
				}
				
				switch(letter) {
					case "F":
					case "f":
						note = new Note();
						note.letter = Note.NOTE_F;
						break;
					case "D":
					case "d":
						note = new Note();
						note.letter = Note.NOTE_D;
						break;
					case "S":
					case "s":
						note = new Note();
						note.letter = Note.NOTE_S;
						break;
					case "A":
					case "a":
						note = new Note();
						note.letter = Note.NOTE_A;
						break;
					case "H":
					case "h":
						//Check if we had an H last time, or if this is the first token.
						if (note == null || note.isHold) {
							throw new GWError("Error: Corrupt GSW File: hold with no corresponding note " +
									"Token # " + index);
						}
						
						note.isHold = true;
						break;
					default:
						throw new GWError("Error: Corrupt GWS File: invalid letter " +
								"Token # " + index + " " + letter);
						return;
				}
				
				index++;
				if (index >= tokens.length) {
					throw new GWError("Error: Corrupt GWS File: missing token " +
							"Token # " + index + " " + letter + " ???");
					return;
				}
				
				var time:Number = parseInt(String(tokens[index]));

				if (isNaN(time) || time < 0) {
					throw new GWError("Error: Corrupt GWS File: bad timestamp " + 
							"Token # " + index + " Funny timestamp: " + String(tokens[index]));
				} else if (time < lastTime) {
					throw new GWError("Error: Corrupt GWS File: timestamps out of order " +
							"Token # " + index + " " + time + " < " + lastTime);
				} else if (time == lastTime && letter == lastLetter) {
					throw new GWError("Error: Corrupt GWS File: simultaneous note " + 
							"Token # " + index + " " + letter + " " + time);
				}
				else if (note.isHold)
					note.endtime = time;
				else {
					note.time = time;
					lastTime = time;
					
					lastLetter = letter;
					
					noteList.push(note);
				}
				
				index++;
			}
		}
		
		public function hardcode():void {
			/*_midMusic = new Sound();
			Main.loadSong(_midMusic, "../assets/Fur_Elise_Adapted_-_Mid.mp3");
			_baseMusic = new Sound();
			Main.loadSong(_baseMusic, "../assets/Fur_Elise_Adapted_-_Baseline.mp3");
			
			_lowPart = new Vector.<Note>();
			_highPart = new Vector.<Note>();
			
			_midPart = new Vector.<Note>();
			
			_midPart.push(new Note(Note.NOTE_F, 5760));
			_midPart.push(new Note(Note.NOTE_D, 6000));
			_midPart.push(new Note(Note.NOTE_F, 6240));
			_midPart.push(new Note(Note.NOTE_D, 6480));
			_midPart.push(new Note(Note.NOTE_F, 6729));
			_midPart.push(new Note(Note.NOTE_S, 6960));
			_midPart.push(new Note(Note.NOTE_A, 7200)); _midPart.push(new Note(Note.NOTE_F, 7200));
			_midPart.push(new Note(Note.NOTE_D, 7440));
			_midPart.push(new Note(Note.NOTE_S, 7680, true, 8640));
			
			_midPart.push(new Note(Note.NOTE_A, 8880));
			_midPart.push(new Note(Note.NOTE_S, 9120));
			_midPart.push(new Note(Note.NOTE_D, 9360));
			_midPart.push(new Note(Note.NOTE_F, 9600, true, 10560));
			
			_midPart.push(new Note(Note.NOTE_A, 10800));
			_midPart.push(new Note(Note.NOTE_S, 11040));
			_midPart.push(new Note(Note.NOTE_D, 11280));
			_midPart.push(new Note(Note.NOTE_F, 11520, true, 12480));
			
			_midPart.push(new Note(Note.NOTE_A, 13200));
			
			_midPart.push(new Note(Note.NOTE_F, 13440));
			_midPart.push(new Note(Note.NOTE_D, 13680));
			_midPart.push(new Note(Note.NOTE_F, 13920));
			_midPart.push(new Note(Note.NOTE_D, 14160));
			_midPart.push(new Note(Note.NOTE_F, 14400));
			_midPart.push(new Note(Note.NOTE_S, 14640));
			_midPart.push(new Note(Note.NOTE_A, 14880)); _midPart.push(new Note(Note.NOTE_F, 14880));
			_midPart.push(new Note(Note.NOTE_D, 15120));
			_midPart.push(new Note(Note.NOTE_S, 15360, true, 16320));
			
			_midPart.push(new Note(Note.NOTE_A, 16560));
			_midPart.push(new Note(Note.NOTE_S, 16800));
			_midPart.push(new Note(Note.NOTE_D, 17040));
			_midPart.push(new Note(Note.NOTE_F, 17280, true, 18240));
			
			_midPart.push(new Note(Note.NOTE_A, 18480));
			_midPart.push(new Note(Note.NOTE_F, 18720));
			_midPart.push(new Note(Note.NOTE_D, 18960));
			_midPart.push(new Note(Note.NOTE_S, 19200, true, 20160));
			
			
			_midPart.push(new Note(Note.NOTE_A, 20400));
			_midPart.push(new Note(Note.NOTE_S, 20640));
			_midPart.push(new Note(Note.NOTE_D, 20880));
			_midPart.push(new Note(Note.NOTE_F, 21120, true, 22080));
			
			_midPart.push(new Note(Note.NOTE_S, 22320));
			_midPart.push(new Note(Note.NOTE_F, 22560));
			_midPart.push(new Note(Note.NOTE_D, 22800));
			_midPart.push(new Note(Note.NOTE_S, 23040, true, 24000));
			
			_midPart.push(new Note(Note.NOTE_A, 24240));
			_midPart.push(new Note(Note.NOTE_F, 24480));
			_midPart.push(new Note(Note.NOTE_D, 24720));
			_midPart.push(new Note(Note.NOTE_S, 24960, true, 25920));
			
			_midPart.push(new Note(Note.NOTE_A, 26160));
			_midPart.push(new Note(Note.NOTE_D, 26400));
			_midPart.push(new Note(Note.NOTE_S, 26880));
			_midPart.push(new Note(Note.NOTE_A, 27360));
			
			_midPart.push(new Note(Note.NOTE_D, 30960));
			_midPart.push(new Note(Note.NOTE_F, 31200));
			
			_midPart.push(new Note(Note.NOTE_D, 31920));
			_midPart.push(new Note(Note.NOTE_F, 32160));
			
			_midPart.push(new Note(Note.NOTE_D, 32880));
			
			_midPart.push(new Note(Note.NOTE_F, 33120));
			_midPart.push(new Note(Note.NOTE_D, 33360));
			_midPart.push(new Note(Note.NOTE_F, 33600));
			_midPart.push(new Note(Note.NOTE_D, 33840));
			_midPart.push(new Note(Note.NOTE_F, 34080));
			_midPart.push(new Note(Note.NOTE_S, 34320));
			_midPart.push(new Note(Note.NOTE_A, 34560)); _midPart.push(new Note(Note.NOTE_F, 34560));
			_midPart.push(new Note(Note.NOTE_D, 34800));
			_midPart.push(new Note(Note.NOTE_S, 35040, true, 36000));
			
			_midPart.push(new Note(Note.NOTE_A, 36240));
			_midPart.push(new Note(Note.NOTE_S, 36480));
			_midPart.push(new Note(Note.NOTE_D, 36720));
			_midPart.push(new Note(Note.NOTE_F, 36960, true, 37920));
			
			_midPart.push(new Note(Note.NOTE_A, 38160));
			_midPart.push(new Note(Note.NOTE_S, 38400));
			_midPart.push(new Note(Note.NOTE_D, 38640));
			_midPart.push(new Note(Note.NOTE_F, 38880, true, 39840));
			
			_midPart.push(new Note(Note.NOTE_A, 40560));
			
			_midPart.push(new Note(Note.NOTE_F, 40800));
			_midPart.push(new Note(Note.NOTE_D, 41040));
			_midPart.push(new Note(Note.NOTE_F, 41280));
			_midPart.push(new Note(Note.NOTE_D, 41520));
			_midPart.push(new Note(Note.NOTE_F, 41760));
			_midPart.push(new Note(Note.NOTE_S, 42000));
			_midPart.push(new Note(Note.NOTE_A, 42240)); _midPart.push(new Note(Note.NOTE_F, 42240));
			_midPart.push(new Note(Note.NOTE_D, 42480));
			_midPart.push(new Note(Note.NOTE_S, 42720, true, 43680));
			
			_midPart.push(new Note(Note.NOTE_A, 43920));
			_midPart.push(new Note(Note.NOTE_S, 44160));
			_midPart.push(new Note(Note.NOTE_D, 44400));
			_midPart.push(new Note(Note.NOTE_F, 44640, true, 45600));
			
			_midPart.push(new Note(Note.NOTE_A, 45840));
			_midPart.push(new Note(Note.NOTE_F, 46080));
			_midPart.push(new Note(Note.NOTE_D, 46320));
			_midPart.push(new Note(Note.NOTE_S, 46560, true, 47520));
			
			for each (var note:Note in _midPart) {
				note._time *= (200 / 192);
				note._endtime *= (200 / 192);
			}*/
		}
		
		public function get lowPart():Vector.<Note> 
		{
			return _lowPart;
		}
		
		public function get midPart():Vector.<Note> 
		{
			return _midPart;
		}
		
		public function get highPart():Vector.<Note> 
		{
			return _highPart;
		}
		
		public function get lowMusic():Sound 
		{
			return _lowMusic;
		}
		
		public function get midMusic():Sound 
		{
			return _midMusic;
		}
		
		public function get highMusic():Sound 
		{
			return _highMusic;
		}
		
		public function get baseMusic():Sound 
		{
			return _baseMusic;
		}
		
	}

}