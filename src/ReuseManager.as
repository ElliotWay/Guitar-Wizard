package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class ReuseManager 
	{
		public static const MAX_CONSTRUCTOR_ARGS:int = 6;
		
		private var constructor:Class;
		private var args:Array;
		
		private var things:Array;
		
		/**
		 * The ReuseManager controls the reusing similar objects to improve on memory usage.
		 * The object should either be constant with respect to its constructing arguments,
		 * or it should have one or more restoration methods to set the object to it initial state
		 * externally.
		 * @param	constructor the class of the object to reuse.
		 * @param	args arguments to pass to the constructor. It is recommended that these be
		 * 		primitive constants, if possible.
		 */
		public function ReuseManager(constructor:Class, args:Array = null) 
		{
			
			
			this.constructor = constructor;
			this.args = (args == null) ? [] : args;
			
			if (this.args.length > MAX_CONSTRUCTOR_ARGS) {
				throw new GWError("Too many arguments for ctor passed to ReuseManager.\n" +
						"I could support more arguments, but really you should think about " + 
						"requring fewer than " + MAX_CONSTRUCTOR_ARGS + " arguments.");
			}
			
			things = [];
		}
		
		/**
		 * Ask the ReuseManager for another object. If an old one is available, the most recently
		 * removed object is returned, otherwise a new one is created.
		 * @return the "new" object
		 */
		public function create():* {
			if (things.length > 0) {
				return things.pop();
			} else {
				return callConstructor();
			}
		}
		
		/**
		 * Set the object aside for reuse later. This does not change the object in any way.
		 * Make sure to completely dereference this object besides its reference here.
		 * @param	object the object to remove for reuse
		 */
		public function remove(object:*):void {
			things.push(object);
		}
		
		/**
		 * Uuuuuuuuggggggggghhhhhhhhh...
		 * @return the constructed object
		 */
		private function callConstructor():* {
			switch (args.length) {
				case 0: return new constructor();
				case 1: return new constructor(args[0]);
				case 2: return new constructor(args[0], args[1]);
				case 3: return new constructor(args[0], args[1], args[2]);
				case 4: return new constructor(args[0], args[1], args[2], args[3]);
				case 5: return new constructor(args[0], args[1], args[2], args[3], args[4]);
				case 6: return new constructor(args[0], args[1], args[2], args[3], args[4], args[5]);
			}
		}
		
	}

}