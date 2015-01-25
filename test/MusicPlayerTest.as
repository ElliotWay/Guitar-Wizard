package test 
{
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.mock;
	import mockolate.stub;
	import mockolate.verify;
	import org.hamcrest.assertThat;
	import org.hamcrest.number.lessThan;
	import src.Main;
	import src.MusicPlayer;
	import src.Song;
	
	MockolateRunner; 
	
	
	/**
	 * Test Class for MusicPlayer.
	 * SoundChannel is a final class, so unfortuneately I can't mock it.
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
			
			player = new MusicPlayer(Main.HIGH);
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
			
			assertThat(baseMusic, received().method("play"));
			assertThat(highMusic, received().method("play"));
			assertThat(midMusic, received().method("play").never());
			assertThat(lowMusic, received().method("play").never());
		}
		
		[Test]
		public function switchesTrack():void {
			player.loadMusic(song);
			player.go();
			
			player.switchTrack(Main.MID);
			
			assertThat(midMusic, received().method("play"));
			
			assertThat(highMusic, received().method("play").once());
		}
		
		//Can't test stopTrack
		
		[Test]
		public function resumesTrack():void {
			player.loadMusic(song);
			player.go();
			player.stopTrack();
			
			player.resumeTrack();
			
			assertThat(highMusic, received().method("play").twice());
		}
		
		//Can't test stop.
		
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