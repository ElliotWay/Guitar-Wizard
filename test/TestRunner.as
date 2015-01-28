package test 
{
	
	import org.flexunit.internals.TraceListener;
	import org.flexunit.runner.FlexUnitCore;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class TestRunner 
	{
		
		public function TestRunner() 
		{
			
		}
		
		public static function runTests() : void {
			var testCore : FlexUnitCore = new FlexUnitCore();
			testCore.addListener(new TraceListener());
			
			//The order of these tests is important (sadly).
			
			testCore.run(TestTest);
			testCore.run(MusicPlayerTest);
			testCore.run(SongLoaderTest);
			testCore.run(NoteSpriteTest);
			testCore.run(GameUI_MissUntilTest);
			testCore.run(GameUI_FindHitTest);
			testCore.run(NoteTest);
			testCore.run(Song_ParseNotesTest);

			//Number of Tests was 54.
		}
	}

}