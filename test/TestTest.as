package test
{
	
	import org.flexunit.asserts.assertEquals;
	
	/**
	 * Tests that the testing framework is at least partially working.
	 * @author Elliot Way
	 */
	public class TestTest 
	{
		
		[Test]
		public function addTest():void {
			var num : int = 2 + 3;
			assertEquals(num, 5);
		}
		
		[Test]
		public function subtractTest():void {
			var num : int = 5 - 3;
			assertEquals(num, 2);
		}
		
	}

}