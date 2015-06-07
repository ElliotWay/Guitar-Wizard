package src 
{
	/**
	 * Split an action on an array into multiple actions. This has the advantage of not needing
	 * to process the entire array in one frame. A better solution than this would be to use
	 * separate threads so as not to interfere with the graphics thread, but actionscript threads
	 * aren't very good for any calulations that are heavily interrelated with display objects.
	 */
	public class ActionSplitter 
	{
		private var func:Function;
		private var _processing:Boolean;
		
		private var numIndices:int;
		
		private var startIndex:int;
		private var endIndex:int;
		
		public function get processing():Boolean {
			return _processing;
		}
		
		/**
		 * Separate an action on an array into multiple actions so as to take less time per frame.
		 * @param	func the function to run. This function should take 2 arguments: the starting index,
		 *  and the ending index. Operate on indexes starting from the starting index and ending on
		 * 	the ending index - 1. The function should return true if there are more indices left,
		 *  or false if there are not.
		 */
		public function ActionSplitter(func:Function) 
		{
			this.func = func;
			_processing = false;
		}
		
		/**
		 * Start the split action.
		 * @param	numIndices the number of indices to process at once.
		 * @param   startIteration whether to do an iteration right away
		 * @return 	whether the split action is <em>already</em> done, if startIteration was true
		 */
		public function start(numIndices:int, startIteration:Boolean = true):Boolean {
			if (_processing)
				throw new GWError("Can't start a split action that is already ongoing.");
			
			this.numIndices = numIndices;
			startIndex = 0;
			endIndex = numIndices;
				
			if (startIteration)
				return doAction();
			else
				return false;
		}
		
		/**
		 * Continue the split action. Does nothing if the action has not been started.
		 * @return whether the split action is finished.
		 */
		public function doAction():Boolean {
			if (!_processing)
				return;
			
			var stillProcessing:Boolean = func.call(null, startIndex, endIndex);
			
			if (stillProcessing) {
				startIndex = endIndex;
				endIndex += numIndices;
			} else {
				_processing = false;
			}
			
			return retVal;
		}
	}

}