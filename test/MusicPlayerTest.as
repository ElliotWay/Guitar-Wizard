package test 
{
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.mock;
	import mockolate.stub;
	import mockolate.verify;
	import org.hamcrest.assertThat;
	import org.hamcrest.CustomMatcher;
	import org.hamcrest.Matcher;
	import org.hamcrest.number.lessThan;
	import src.Main;
	import src.MusicPlayer;
	import src.Song;
	
	MockolateRunner; 
	
	
	/**
	 * Test Class for MusicPlayer.
	 * SoundChannel is a final class, so unfortunately I can't mock it.
	 * As a result, I cannot test when stop calls are made.
	 * @author Elliot Way
	 */	
	[RunWith("mockolate.runner.MockolateRunner")]
	public class MusicPlayerTest 
	{
		
		[Mock]
		public var song:Song;
		
		[Mock]
		public var baseMusic:SoundExtension, highMusic:SoundExtension,
			midMusic:SoundExtension, lowMusic:SoundExtension;

		private var channel:SoundChannel;
		
		private var player:MusicPlayer;
		
		private function isMutedSoundTransform():Matcher {
			return new CustomMatcher("Muted SoundTransform", 
				function(item:Object):Boolean {
					return (item is SoundTransform) && (SoundTransform(item).volume == 0);
				});
		}
		
		[Before]
		public function createSong():void {
			mock(song).getter("baseMusic").returns(baseMusic);
			mock(song).getter("highMusic").returns(highMusic);
			mock(song).getter("midMusic").returns(midMusic);
			mock(song).getter("lowMusic").returns(lowMusic);
			
			//Can't mock SoundChannel since it's final.
			channel = new SoundChannel();
			
			stub(baseMusic).method("play").returns(channel);
			stub(highMusic).method("play").returns(channel);
			stub(midMusic).method("play").returns(channel);
			stub(lowMusic).method("play").returns(channel);
			
			player = new MusicPlayer(Main.HIGH, null);
		}
		
		[Test]
		public function verifyLoad():void {
			player.loadMusic(song);
			
			verify(song);
		}
		
		[Test]
		public function playsBaseAndHigh():void {
			player.loadMusic(song);
			
			player.go();
			
			assertThat(baseMusic, received().method("play").noArgs());
			assertThat(highMusic, received().method("play").noArgs());
			assertThat(midMusic, received().method("play").args(0, 0, isMutedSoundTransform()));
			assertThat(lowMusic, received().method("play").args(0, 0, isMutedSoundTransform()));
		}
		
		[Test]
		public function switchesTrack():void {
			player.loadMusic(song);
			player.go();
			
			player.switchTrack(Main.MID);
			
			assertThat(midMusic, received().method("play"));
			
			assertThat(highMusic, received().method("play").once());
		}
		
		//Can't test resume and stop track anymore, since that happens entirely internally.
		
		[Test]
		public function isPlayingIsCorrect():void {
			player.loadMusic(song);
			player.go();
			
			assertThat(player.isPlaying);
			
			player.stop();
			
			assertThat(!player.isPlaying);
			
			player.go();
			
			assertThat(player.isPlaying);
		}
		
		//Can't properly test getTime, but can test the failure case.
		[Test]
		public function returnsNegativeWhenNotStarted():void {
			player.loadMusic(song);
			
			assertThat(player.getTime(), lessThan(0));
		}
		
		[Test]
		public function returnsNegativeWhenStopped():void {
			player.loadMusic(song);
			player.go();
			player.stop();
			
			assertThat(player.getTime(), lessThan(0));
		}
		
		[After]
		public function stopPlayback():void {
			channel.stop();
		}
	}

}