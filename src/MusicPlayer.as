package  
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	/**
	 * Controls music playback. Plays the base music at the same time as the track,
	 * and allows for switching between tracks.
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
		
		/**
		 * Construct a new player
		 * @param	startingTrack the starting track (probably mid)
		 */
		public function MusicPlayer(startingTrack:int) 
		{
			currentTrack = startingTrack;
		}
		
		/**
		 * Load a song into the player. The music should already be loaded
		 * (or at least loading by this point).
		 * Do not call this function while the player is currently playing;
		 * use stop() first.
		 * @param	s the song to load
		 */
		public function loadMusic(s:Song):void {
			lowMusic = s.lowMusic;
			midMusic = s.midMusic;
			highMusic = s.highMusic;
			baseMusic = s.baseMusic;
		}
		
		/**
		 * Start playing the base music and the currently selected track.
		 */
		public function go():void {
			baseChannel = baseMusic.play();
			switchTrack(currentTrack);
		}
		
		/**
		 * Switches tracks. Use the Main constants to select the track.
		 * If we've started playing, this will switch tracks on the fly,
		 * otherwise it will simply switch which track to start later.
		 * @param	track the track to switch to
		 */
		public function switchTrack(track:int):void {
			if (baseChannel != null)
				stopTrack();
			
			currentTrack = track;
			
			if (baseChannel != null)
				resumeTrack();
		}
		
		/**
		 * Stops the current track from playing, but not the base part.
		 */
		public function stopTrack():void {
			if (lowChannel != null) {
				lowChannel.stop();
				lowChannel = null;
			}
			if (midChannel != null) {
				midChannel.stop();
				midChannel = null;
			}
			if (highChannel != null) {
				highChannel.stop();
				highChannel = null;
			}
		}
		
		/**
		 * Resumes the track at the current time of the base part.
		 * This should not be called if the base part is not currently playing.
		 */
		public function resumeTrack():void {
			//Tracks are already going if not null.
			if (currentTrack == Main.HIGH && highChannel == null)
				highChannel = highMusic.play(baseChannel.position);
			if (currentTrack == Main.MID && midChannel == null)
				midChannel = midMusic.play(baseChannel.position);
			if (currentTrack == Main.LOW && lowChannel == null)
				lowChannel = lowMusic.play(baseChannel.position);
		}
		
		/**
		 * Halts both the base part and the track.
		 * The player is ready to restart with go() or load a new song
		 * with load song.
		 */
		public function stop():void {
			stopTrack();
			if (baseChannel != null) {
				baseChannel.stop();
				baseChannel = null;
			}
		}
		
		public function playMissSound():void {
			//TODO add this functionality
		}
		
		/**
		 * Returns the playhead of the base part. In a perfect world,
		 * this is the same as real time and the time of the tracks.
		 * Returns -1 if the base part is not currently playing.
		 * @return current playhead
		 */
		public function getTime():Number {
			if (baseChannel != null)
				return baseChannel.position;
			else
				return -1;
		}
		
	}

}