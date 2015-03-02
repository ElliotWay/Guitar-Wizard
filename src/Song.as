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
		public static const MUSIC_FILE_DIRECTORY:String = "../assets/";
		
		private var _lowPart:Vector.<Note>;
		private var _midPart:Vector.<Note>;
		private var _highPart:Vector.<Note>;
		
		private var _blocks:Vector.<Number>;

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
		
		public function unload():void {
			var note:Note;
			
			for (note in _lowPart) {
				note.dissociate();
			}
			_lowPart = null;
			for (note in _midPart) {
				note.dissociate();
			}
			_midPart = null;
			for (note in _highPart) {
				note.dissociate();
			}
			_highPart = null;
			
			_blocks = null;
			
			_lowMusic = null;
			_midMusic = null;
			_highMusic = null;
		}
		
		private function fileError(e:Event):void {
			Main.showError("Error loading file");
		}
		
		private function interpretFile(e:Event):void {
			var lines:Array = String(loader.data).split("\n");
			
			if (lines.length < 8)
				Main.showError("Error: Corrupt GSW file: missing lines");
			
			var baseName:String = lines[0];
			var highName:String = lines[1];
			var midName:String = lines[2];
			var lowName:String = lines[3];
			
			_baseMusic = new Sound();
			_highMusic = new Sound();
			_midMusic = new Sound();
			_lowMusic = new Sound();
			
			Main.loadSong(baseMusic, MUSIC_FILE_DIRECTORY + baseName);
			Main.loadSong(highMusic, MUSIC_FILE_DIRECTORY + highName);
			Main.loadSong(midMusic, MUSIC_FILE_DIRECTORY + midName);
			Main.loadSong(lowMusic, MUSIC_FILE_DIRECTORY + lowName);
			
			var highNoteString:String = lines[4];
			var midNoteString:String = lines[5];
			var lowNoteString:String = lines[6];
			
			_highPart = new Vector.<Note>();
			_midPart = new Vector.<Note>();
			_lowPart = new Vector.<Note>();
			
			var blockString:String = lines[7];
			
			_blocks = new Vector.<Number>();
			
			try {
				parseNotes(_highPart, highNoteString);
				parseNotes(_midPart, midNoteString);
				parseNotes(_lowPart, lowNoteString);
				parseBlocks(_blocks, blockString);
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
								"Token # " + index + ", " + letter);
						return;
				}
				
				index++;
				if (index >= tokens.length) {
					throw new GWError("Error: Corrupt GWS File: missing token " +
							"Token # " + index + ", " + letter + " ???");
					return;
				}
				
				var time:Number = parseInt(String(tokens[index]));

				if (isNaN(time) || time < 0) {
					throw new GWError("Error: Corrupt GWS File: bad timestamp " + 
							"Token # " + index + " Funny timestamp: " + String(tokens[index]));
				} else if (time < lastTime) {
					throw new GWError("Error: Corrupt GWS File: timestamps out of order " +
							"Token # " + index + ", " + time + " < " + lastTime);
				} else if (time == lastTime && letter == lastLetter) {
					throw new GWError("Error: Corrupt GWS File: simultaneous note " + 
							"Token # " + index + ", " + letter + " " + time);
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
		
		/**
		 * Parse the block separators out of a string into a vector.
		 * 
		 * These are simpler than notes, and are simply space-separated numbers:
		 * 
		 * ddddd ddddd ddddd ddddd
		 * 
		 * As with notes, these timestamps should be nonegative and increasing.
		 * 
		 * @param	blocks the vector to parse the block separators into
		 * @param	str the string out of which to parse the blocks
		 */
		public static function parseBlocks(blocks:Vector.<Number>, str:String):void {
			var tokens:Array = str.split(/\s+/);
			
			var index:int = 0;
			var lastTime:Number = -1;
			
			while (index < tokens.length) {
				//Ignore empty tokens.
				if (String(tokens[index]).length == 0) {
					index++;
					continue;
				}
				
				var time:Number = parseInt(String(tokens[index]));

				if (isNaN(time) || time < 0) {
					throw new GWError("Error: Corrupt GWS File: bad separator timestamp " + 
							"Token # " + index + ", Funny timestamp: " + String(tokens[index]));
				} else if (time < lastTime) {
					throw new GWError("Error: Corrupt GWS File: separator timestamps out of order " +
							"Token # " + index + ", " + time + " < " + lastTime);
				}
				
				lastTime = time;
				
				blocks.push(time);
				
				index++;
			}
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
		
		public function get blocks():Vector.<Number>
		{
			return _blocks;
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