package src 
{
	import flash.media.Sound;
	/**
	 * ...
	 * @author 
	 */
	public class SoundPlayer 
	{
		[Embed(source = "../assets/sfx/Wilhelm_-jacko-8948_hifi.mp3")]
		private static const ScreamData:Class;
		private static var screamSound:Sound = (new ScreamData() as Sound);
		
		public static function playScream():void {
			screamSound.play();
		}
		
	}

}