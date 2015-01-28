package src 
{
	/**
	 * Error class for errors originating in my own code.
	 */
	public class GWError extends Error 
	{
		
		public function GWError(message:*="", id:*=0) 
		{
			super(message, id);
			
		}
		
	}

}