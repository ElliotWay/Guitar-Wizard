package test 
{
	
	import mockolate.runner.MockolateRunner;
	import org.hamcrest.assertThat;
	import src.Repeater;
	
	
	MockolateRunner;
	/**
	 * 
	 * @author 
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class RepeaterTest 
	{
		public static const TIME:int = 500;
		
		private var wasCalled:Boolean;
		private var func:Function;
		
		[Before]
		public function setup():void {
			wasCalled = false;
			func = function():void {
				wasCalled = true;
			};
		}
		
		[Test]
		public function runs():void {
			assertThat(true);
		}
		
		[Test]
		public function runsFrame():void {
			assertThat(true);
		}
		
		[After]
		public function tearDown():void {
			
		}
		
	}

}