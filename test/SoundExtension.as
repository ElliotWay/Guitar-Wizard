package test 
{
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class SoundExtension extends Sound 
	{
		private var _number:Number;
		
		public function SoundExtension(stream:URLRequest=null, context:SoundLoaderContext=null) 
		{
			super(stream, context);
			
		}
		
		public function get number():Number 
		{
			return _number;
		}
		
		public function set number(value:Number):void 
		{
			_number = value;
		}
		
	}

}