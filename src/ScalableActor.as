package src 
{
	
	/**
	 * Adds the setScale function to the interface,
	 * used for actors created from holds that need to be stronger for longer holds.
	 * @author Elliot Way
	 */
	public interface ScalableActor extends AbstractActor
	{
		function setScale(scale:Number):void;
	}
	
}