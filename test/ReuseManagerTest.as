package test 
{
	import org.hamcrest.assertThat;
	import org.hamcrest.core.anyOf;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import src.ReuseManager;
	/**
	 * ...
	 * @author ...
	 */
	public class ReuseManagerTest 
	{
		
		private var reuseManager:ReuseManager;
		
		private const firstArg:int = 1337;
		private const secondArg:String = "9001";
		
		[Before]
		public function setup():void {
			reuseManager = new ReuseManager(TestClass, [firstArg, secondArg]);
		}
		
		[Test]
		public function callsConstructorNoneRemoved():void {
			var obj:TestClass = reuseManager.create() as TestClass;
			
			assertThat(obj.arg1, firstArg);
			assertThat(obj.arg2, secondArg);
		}
		
		[Test]
		public function returnsRemovedObject():void {
			
			var oldObject:TestClass = new TestClass(1, "different");
			
			reuseManager.remove(oldObject);
			
			var newObject:TestClass = reuseManager.create() as TestClass;
			
			assertThat(newObject, oldObject);
		}
		
		[Test]
		public function callsConstructorAfterUsingRemoved():void {
			var str:String = "different";
			
			var oldObject:TestClass = new TestClass(1, str);
			
			reuseManager.remove(oldObject);
			
			reuseManager.create();
			
			var newObject:TestClass = reuseManager.create();
			
			assertThat(newObject.arg1, firstArg);
			assertThat(newObject.arg2, secondArg);
		}
		
		[Test]
		public function returnsSeveralRemovedObjects():void {
			var oldObject:TestClass = new TestClass(1, "string1");
			var oldObject2:TestClass = new TestClass(2, "string2");
			
			reuseManager.remove(oldObject);
			reuseManager.remove(oldObject2);
			
			
			var newObject:TestClass = reuseManager.create();
			assertThat(newObject, anyOf(equalTo(oldObject), equalTo(oldObject2)));
			
			if (newObject == oldObject) {
				assertThat(reuseManager.create(), oldObject2);
			} else {
				assertThat(reuseManager.create(), oldObject);
			}
			
			assertThat(reuseManager.create(), not(anyOf(equalTo(oldObject), equalTo(oldObject2))));
		}
	}

}

class TestClass
{
	private var _arg1:int;
	private var _arg2:String;
	
	public function TestClass(arg1:int, arg2:String) {
		_arg1 = arg1;
		_arg2 = arg2;
	}
	
	public function get arg1():int {
		return _arg1;
	}
	
	public function get arg2():String {
		return _arg2;
	}
}