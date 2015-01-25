package test 
{
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import org.hamcrest.CustomMatcher;
	import org.hamcrest.Matcher;
	import org.hamcrest.object.instanceOf;
	import src.SongLoader;
	
	MockolateRunner;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class SongLoaderTest 
	{
		
		[Mock]
		public var song1:Sound, song2:Sound, song3:Sound;
		
		private var songLoader:SongLoader;
		
		private function isURLRequest(string:String):Matcher {
			return new CustomMatcher(("URLRequest from " + string),
				function(item:Object):Boolean {
					return (item is URLRequest) && (URLRequest(item).url == string);
				}
			)
		}
		
		[Before]
		public function setup():void {
			songLoader = new SongLoader();
			
			stub(song1).method("load");
			stub(song1).method("addEventListener").args(Event.COMPLETE, instanceOf(Function));
			
			stub(song2).method("load");
			stub(song2).method("addEventListener").args(Event.COMPLETE, instanceOf(Function));
			
			stub(song3).method("load");
			stub(song3).method("addEventListener").args(Event.COMPLETE, instanceOf(Function));
		}
		
		[Test]
		public function loadsOneSong():void {
			songLoader.addSong(song1, "url1");
			
			songLoader.load();
			
			assertThat(song1, received().method("addEventListener").args(Event.COMPLETE, instanceOf(Function)));
			assertThat(song1, received().method("load").arg(isURLRequest("url1")));
		}
		
		[Test]
		public function loadsThreeSongs():void {
			songLoader.addSong(song1, "url1");
			songLoader.addSong(song2, "url2");
			songLoader.addSong(song3, "url3");
			
			songLoader.load();
			
			assertThat(song1, received().method("addEventListener").args(Event.COMPLETE, instanceOf(Function)));
			assertThat(song2, received().method("addEventListener").args(Event.COMPLETE, instanceOf(Function)));
			assertThat(song3, received().method("addEventListener").args(Event.COMPLETE, instanceOf(Function)));
			
			//Make sure it didn't try to load url1 instead of url2 or something.
			assertThat(song1, received().method("load").arg(isURLRequest("url1")).once());
			assertThat(song2, received().method("load").arg(isURLRequest("url2")).once());
			assertThat(song3, received().method("load").arg(isURLRequest("url3")).once());
		}
		
		[Test]
		public function cannotLoadWhileLoading():void {
			songLoader.addSong(song1, "url1");
			songLoader.addSong(song2, "url2");
			
			songLoader.load();
			
			songLoader.addSong(song3, "url3");
			songLoader.load();
			
			//url3 should not be loading.
			assertThat(song3, received().method("addEventListener")
				.args(Event.COMPLETE, instanceOf(Function)).never());
			assertThat(song3, received().method("load").never());
			
			//Make sure url1 wasn't loaded twice.
			assertThat(song1, received().method("load").arg(isURLRequest("url1")).once());
			assertThat(song2, received().method("load").arg(isURLRequest("url2")).once());
		}
		
		//Can't test that loading is allowed after loading,
		//because that calls Main.go, which I can't stub.
		
	}

}