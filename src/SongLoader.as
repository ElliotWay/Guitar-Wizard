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
	 * Handles loading several audio files all at once.
	 * 
	 * Files are added with addSong, then loaded with load.
	 * When all files are finished loading, a call is made to
	 * Main.go. Errors while loading may cause unpredictable behavior.
	 * @author Elliot Way
	 */
	public class SongLoader
	{
		private var loading:Dictionary;
		
		private var _isLoading:Boolean;
		
		public function SongLoader() 
		{
			loading = new Dictionary();
			
			_isLoading = false;
		}
		
		/**
		 * Add an audio file to be loaded.
		 * 
		 * Calling this method while loading is occuring will have no effect.
		 * @param	s the Sound object to load the file into, this should not already have a sound loaded
		 * @param	url the url of the mp3 file
		 */
		public function addSong(s:Sound, url:String):void {
			if (!_isLoading)
				loading[s] = url;
		}
		
		/**
		 * Loads the requested songs.
		 * 
		 * Unless an error occurs, a call will be made to Main.go
		 * when the files are finished loading.
		 * 
		 * Calling this method before the Main.go has been called will
		 * have not effect.
		 */
		public function load():void {
			if (!_isLoading) {
				for (var key:Object in loading) {
					var song:Sound = Sound(key);
					song.addEventListener(IOErrorEvent.IO_ERROR, songError);
					song.addEventListener(Event.COMPLETE, songComplete);
					
					song.load(new URLRequest(loading[song]));
				}
				
				_isLoading = true;
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
				trace("song loaded: " + loading[song]);
				delete loading[song];
				var numKeys:int = 0;
				for (var key:* in loading)
					numKeys++;
				if (numKeys == 0) {
					_isLoading = false;
					
					Main.go();
				}
			}
		}
		
	}

}