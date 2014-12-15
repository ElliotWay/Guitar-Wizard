package  
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class MusicPlayer 
	{
		private var lowMusic:Sound;
		private var lowChannel:SoundChannel;
		private var midMusic:Sound;
		private var midChannel:SoundChannel;
		private var highMusic:Sound;
		private var highChannel:SoundChannel;
		private var baseMusic:Sound;
		private var baseChannel:SoundChannel;
		
		private var currentTrack:int;
		
		public function MusicPlayer(startingTrack:int) 
		{
			currentTrack = startingTrack;
		}
		
		public function loadMusic(s:Song):void {
			lowMusic = s.lowMusic;
			midMusic = s.midMusic;
			highMusic = s.highMusic;
			baseMusic = s.baseMusic;
		}
		
		public function go():void {
			baseChannel = baseMusic.play();
			switchTrack(currentTrack);
		}
		
		public function switchTrack(track:int):void {
			stopTrack();
			
			currentTrack = track;
			
			resumeTrack();
		}
		
		public function stopTrack():void {
			if (lowChannel != null)
				lowChannel.stop();
			if (midChannel != null)
				midChannel.stop();
			if (highChannel != null)
				highChannel.stop();
		}
		
		public function resumeTrack():void {
			if (currentTrack == Main.HIGH)
				highChannel = highMusic.play(baseChannel.position);
			if (currentTrack == Main.MID)
				midChannel = midMusic.play(baseChannel.position);
			if (currentTrack == Main.LOW)
				lowChannel = lowMusic.play(baseChannel.position);
		}
		
		public function stop():void {
			stopTrack();
			if (baseChannel != null)
				baseChannel.stop();
		}
		
	}

}