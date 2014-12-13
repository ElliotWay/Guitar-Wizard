package  
{
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class Song 
	{
		
		private var _lowPart:Vector.<Note>;
		private var _midPart:Vector.<Note>;
		private var _highPart:Vector.<Note>;
		//private var lowMusic, midMusic, highMusic, baseMusic:musicType?;
		
		public function Song() 
		{
			
		}
		
		public function hardcode():void {
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
		
	}

}