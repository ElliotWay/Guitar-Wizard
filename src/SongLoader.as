package  src
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class SongLoader
	{
		private var loading:Dictionary;
		
		public function SongLoader() 
		{
			loading = new Dictionary();
		}
		
		public function addSong(s:Sound, url:String):void {
			loading[s] = url;
		}
		
		public function load():void {
			for (var key:Object in loading) {
				var song:Sound = Sound(key);
				song.addEventListener(IOErrorEvent.IO_ERROR, songError);
				song.addEventListener(Event.COMPLETE, songComplete);
				
				song.load(new URLRequest(loading[song]));
			}
		}
		
		public function songError(e:Event):void {
			trace("song loading error");
			throw new Error("song loading error");
		}
		public function songComplete(e:Event):void {
			var song:Sound = (e.target as Sound);
			
			if (!(song in loading)) {
				trace("song missing from loader");
				throw new Error("missing song error");
			} else {
				delete loading[song];
				var numKeys:int = 0;
				for (var key:* in loading)
					numKeys++;
				if (numKeys == 0) {
					Main.go();
				}
			}
		}
		
	}

}