package test 
{
	
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.mock;
	import mockolate.stub;
	import mockolate.verify;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.CustomMatcher;
	import org.hamcrest.Matcher;
	import org.hamcrest.number.between;
	import org.hamcrest.number.lessThan;
	import src.Main;
	import src.MusicPlayer;
	import src.Song;
	
	MockolateRunner; 
	
	
	/**
	 */	
	[RunWith("mockolate.runner.MockolateRunner")]
	public class MusicPlayerTest 
	{
		private static const MUTE:SoundTransform = new SoundTransform(0);
		
		[Mock]
		public var song:Song;
		
		[Mock]
		public var baseMusic:Sound, highMusic:Sound, midMusic:Sound, lowMusic:Sound;

		private var baseChannel:SoundChannel;
		private var lowChannel:SoundChannel;
		private var midChannel:SoundChannel;
		private var highChannel:SoundChannel;
		
		private var player:MusicPlayer;
		
		private var beforeSwitchTimer:Timer;
		private var afterSwitchTimer:Timer;
		
		private function isMutedSoundTransform():Matcher {
			return new CustomMatcher("Muted SoundTransform", 
				function(item:Object):Boolean {
					return (item is SoundTransform) && (SoundTransform(item).volume == 0);
				});
		}
		
		[Before]
		public function setup():void {
			mock(song).getter("baseMusic").returns(baseMusic);
			mock(song).getter("highMusic").returns(highMusic);
			mock(song).getter("midMusic").returns(midMusic);
			mock(song).getter("lowMusic").returns(lowMusic);
			
			//Can't mock SoundChannel since it's final.
			baseChannel = new SoundChannel();
			highChannel = new SoundChannel();
			midChannel = new SoundChannel();
			midChannel.soundTransform = MUTE;
			lowChannel = new SoundChannel();
			lowChannel.soundTransform = MUTE;
			
			stub(baseMusic).method("play").returns(baseChannel);
			stub(highMusic).method("play").returns(highChannel);
			stub(midMusic).method("play").returns(midChannel);
			stub(lowMusic).method("play").returns(lowChannel);
			
			player = new MusicPlayer(Main.HIGH, null);
			
			beforeSwitchTimer = new Timer(MusicPlayer.TRACK_SWITCH_TIME / 3, 1);
			afterSwitchTimer = new Timer(MusicPlayer.TRACK_SWITCH_TIME * 1000 + 50, 1);
			
			player.loadMusic(song);
		}
		
		[Test]
		public function playsBaseAndHigh():void {
			player.go();
			
			assertThat(baseMusic, received().method("play").noArgs());
			assertThat(highMusic, received().method("play").noArgs());
			assertThat(midMusic, received().method("play").args(0, 0, isMutedSoundTransform()));
			assertThat(lowMusic, received().method("play").args(0, 0, isMutedSoundTransform()));
		}
		
		[Test(async, order = 1)]
		public function switchesTrack():void {
			player.go();
			
			player.switchTrack(Main.MID);
			
			var afterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(highChannel.soundTransform.volume, 0);
				assertThat(midChannel.soundTransform.volume, 1);
			}, MusicPlayer.TRACK_SWITCH_TIME * 2 * 1000);
			
			afterSwitchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, afterHandler, false, 0, true);
			
			afterSwitchTimer.start();
		}
		
		[Test(async, order = 2)]
		public function handlesMidSwitch():void {
			player.go();
			
			player.switchTrack(Main.MID);
			
			var midSwitch:Function = function():void {

				player.switchTrack(Main.LOW);
				afterSwitchTimer.start();
			};
			
			var afterFinishedSwitch:Function = Async.asyncHandler(this, function():void {
				assertThat(lowChannel.soundTransform.volume, 1);
				assertThat(midChannel.soundTransform.volume, 0);
				assertThat(highChannel.soundTransform.volume, 0);
			}, MusicPlayer.TRACK_SWITCH_TIME * 4 * 1000);
			
			beforeSwitchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, midSwitch, false, 0, true);
			afterSwitchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, afterFinishedSwitch, false, 0, true);
			
			beforeSwitchTimer.start();
		}
		
		[Test(order = 1)]
		public function stopsTrack():void {
			player.go();
			player.stopTrack();
			
			assertThat(baseChannel.soundTransform.volume, 1);
			assertThat(highChannel.soundTransform.volume, 0);
		}
		
		[Test(order = 2)]
		public function resumesTrack():void {
			player.go();
			player.stopTrack();
			player.resumeTrack();
			
			assertThat(baseChannel.soundTransform.volume, 1);
			assertThat(highChannel.soundTransform.volume, 1);
		}
		
		//Can't test stop because can't check whether SoundChannel::stop has been called.
		
		
		[Test(order = 1)]
		public function getsIsPlaying():void {
			player.go();
			
			assertThat(player.isPlaying, true);
			
			player.stop();
			
			assertThat(player.isPlaying, false);
			
			player.go();
			
			assertThat(player.isPlaying, true);
		}
		
		//Can't properly test getTime, but can test the failure case.
		[Test]
		public function returnsNegativeWhenNotStarted():void {
			
			assertThat(player.getTime(), lessThan(0));
		}
		
		[Test]
		public function returnsNegativeWhenStopped():void {
			player.go();
			player.stop();
			
			assertThat(player.getTime(), lessThan(0));
		}
		
		[After]
		public function tearDown():void {
			baseChannel.stop();
			highChannel.stop();
			midChannel.stop();
			lowChannel.stop();
			
			if (afterSwitchTimer != null) {
				afterSwitchTimer.stop();
				afterSwitchTimer = null;
			}
		}
	}

}