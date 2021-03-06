package  src
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.VolumePlugin;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	TweenPlugin.activate([VolumePlugin]);
	
	/**
	 * Controls music playback. Plays the base music at the same time as the track,
	 * and allows for switching between tracks.
	 * The "base" track is the underlying part which plays continuously throughout the song
	 * until the song is over. The "track" part is the part played on top the reflects the playing
	 * of the player; misses stop playing and hits continue it, and the player can switch between
	 * tracks.
	 * @author Elliot Way
	 */
	public class MusicPlayer 
	{
		[Embed(source="../assets/sfx/miss1.mp3")]
		private static const MissData1:Class;
		private static const missSound1:Sound = (new MissData1() as Sound);
		[Embed(source="../assets/sfx/miss2.mp3")]
		private static const MissData2:Class;
		private static const missSound2:Sound = (new MissData2() as Sound);
		[Embed(source="../assets/sfx/miss3.mp3")]
		private static const MissData3:Class;
		private static const missSound3:Sound = (new MissData3() as Sound);
		[Embed(source="../assets/sfx/miss4.mp3")]
		private static const MissData4:Class;
		private static const missSound4:Sound = (new MissData4() as Sound);
		[Embed(source="../assets/sfx/miss5.mp3")]
		private static const MissData5:Class;
		private static const missSound5:Sound = (new MissData5() as Sound);
		[Embed(source="../assets/sfx/miss6.mp3")]
		private static const MissData6:Class;
		private static const missSound6:Sound = (new MissData6() as Sound);
		[Embed(source="../assets/sfx/miss7.mp3")]
		private static const MissData7:Class;
		private static const missSound7:Sound = (new MissData7() as Sound);
		[Embed(source="../assets/sfx/miss8.mp3")]
		private static const MissData8:Class;
		private static const missSound8:Sound = (new MissData8() as Sound);
		[Embed(source="../assets/sfx/miss9.mp3")]
		private static const MissData9:Class;
		private static const missSound9:Sound = (new MissData9() as Sound);
		
		
		
		private var lowMusic:Sound;
		private var lowChannel:SoundChannel;
		private var midMusic:Sound;
		private var midChannel:SoundChannel;
		private var highMusic:Sound;
		private var highChannel:SoundChannel;
		private var baseMusic:Sound;
		private var baseChannel:SoundChannel;
		
		private var startingTrack:int;
		private var currentTrack:int;
		private var trackStopped:Boolean;
		
		private var fadingIn:TweenLite;
		private var fadingOut:TweenLite;
		
		private var missSoundReady:Boolean;
		
		private var gameUI:GameUI;
		
		private static const MUTE:SoundTransform = new SoundTransform(0);
		private static const UNMUTE:SoundTransform = new SoundTransform(1);
		
		private static const MISS_LEVEL:SoundTransform = new SoundTransform(0.5);
		
		/**
		 * Approximate time between calling play and the music actually starting.
		 * Value is in milliseconds.
		 */
		public static const STARTUP_LAG:Number = 40;
		
		/**
		 * Time in seconds to fade out the last track and fade in the new one.
		 */
		public static const TRACK_SWITCH_TIME:Number = 0.4; //0.1
		
		/**
		 * Construct a new player
		 * @param	startingTrack the starting track (probably mid)
		 */
		public function MusicPlayer(startingTrack:int, gameUI:GameUI) 
		{
			this.gameUI = gameUI;
			
			this.startingTrack = startingTrack;
			
			fadingIn = null;
			fadingOut = null;
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
			currentTrack = startingTrack;
			
			baseChannel = baseMusic.play();
			
			baseChannel.addEventListener(Event.SOUND_COMPLETE, finishSong);
			
			if (startingTrack == Main.HIGH)
				highChannel = highMusic.play();
			else
				highChannel = highMusic.play(0, 0, MUTE);
			
			if (startingTrack == Main.MID)
				midChannel = midMusic.play();
			else
				midChannel = midMusic.play(0, 0, MUTE);
			
			if (startingTrack == Main.LOW)
				lowChannel = lowMusic.play();
			else
				lowChannel = lowMusic.play(0, 0, MUTE);
				
			trackStopped = false;
			
			gameUI.repeater.runEveryBeat(allowMissSound);
		}
		
		private function finishSong(event:Event):void {
			(event.target as SoundChannel).removeEventListener(Event.SOUND_COMPLETE, finishSong);
			gameUI.songFinished();
			stop();
		}
		
		/**
		 * Switches tracks. Use the Main constants to select the track.
		 * If we've started playing, this will switch tracks on the fly,
		 * otherwise it will simply switch which track to start later.
		 * @param	track the track to switch to
		 */
		public function switchTrack(track:int):void {
			var newTrack:int = track;
			
			if (baseChannel != null && currentTrack != newTrack && !trackStopped) {
				//It should never occur that tracks are switched before one track has a chance to
				//fade out, but we need to handle it if it does.
				if (fadingOut != null) {
					(fadingOut.target as SoundChannel).soundTransform = MUTE;
					fadingOut.kill();
				}
				if (fadingIn != null) {
					fadingIn.kill();
				}
				var currentChannel:SoundChannel, newChannel:SoundChannel;
				if (currentTrack == Main.HIGH)
					currentChannel = highChannel;
				else if (currentTrack == Main.MID)
					currentChannel = midChannel;
				else if (currentTrack == Main.LOW)
					currentChannel = lowChannel;
					
				if (newTrack == Main.HIGH)
					newChannel = highChannel;
				else if (newTrack == Main.MID)
					newChannel = midChannel;
				else if (newTrack == Main.LOW)
					newChannel = lowChannel;
				
				fadingOut = new TweenLite(currentChannel, TRACK_SWITCH_TIME, { volume:0,
						onComplete:finishFadingOut } );
						
				fadingIn = new TweenLite(newChannel, TRACK_SWITCH_TIME, { volume:1,
						onComplete:finishFadingIn } );
			}
			
			currentTrack = newTrack;
		}
		
		private function finishFadingOut():void {
			fadingOut.kill();
			fadingOut = null;
		}
		
		private function finishFadingIn():void {
			fadingIn.kill();
			fadingIn = null;
		}
		
		/**
		 * Stops the current track from playing, but not the base part.
		 */
		public function stopTrack():void {
			if (isPlaying && !trackStopped) {
				if (currentTrack == Main.HIGH)
					highChannel.soundTransform = MUTE;
				else if (currentTrack == Main.MID)
					midChannel.soundTransform = MUTE;
				else if (currentTrack == Main.LOW)
					lowChannel.soundTransform = MUTE;
			}
				
			trackStopped = true;
		}
		
		/**
		 * Resumes the track at the current time of the base part.
		 * This should not be called if the base part is not currently playing.
		 */
		public function resumeTrack():void {
			if (isPlaying && trackStopped) {
				if (currentTrack == Main.HIGH) {
					highChannel.soundTransform = UNMUTE;
				} else if (currentTrack == Main.MID) {
					midChannel.soundTransform = UNMUTE;
				} else if (currentTrack == Main.LOW) {
					lowChannel.soundTransform = UNMUTE;
				}
			}
			
			trackStopped = false;
		}
		
		/**
		 * Halts both the base part and the track.
		 * The player is ready to restart with go() or load a new song
		 * with load song.
		 */
		public function stop():void {
			if (baseChannel != null) {
				baseChannel.stop();
				baseChannel = null;
				
				highChannel.stop();
				highChannel = null;
				
				midChannel.stop();
				midChannel = null;
				
				lowChannel.stop();
				lowChannel = null;
			}
			
			gameUI.repeater.stopRunningEveryBeat(allowMissSound);
		}
		
		private var lastMiss:int = -1;
		
		//TODO put this function in another class
		public function playMissSound():void {
			if (!missSoundReady)
				return;
			
			var missNumber:int;
			
			do {
				missNumber = Math.random() * 9;
			} while (missNumber == lastMiss);

			lastMiss = missNumber;
			
			var missSound:Sound = null;
			
			switch (missNumber) {
				case 0:
					missSound = missSound = missSound = missSound1;
					break;
				case 1:
					missSound = missSound2;
					break;
				case 2:
					missSound = missSound3;
					break;
				case 3:
					missSound = missSound4;
					break;
				case 4:
					missSound = missSound5;
					break;
				case 5:
					missSound = missSound6;
					break;
				case 6:
					missSound = missSound7;
					break;
				case 7:
					missSound = missSound8;
					break;
				case 8:
					missSound = missSound9;
					
			}
			
			(missSound.play()).soundTransform = MISS_LEVEL;
			
			missSoundReady = false;
		}
		
		
		private function allowMissSound():void {
			missSoundReady = true;
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
		
		public function get isPlaying():Boolean {
			return baseChannel != null;
		}
	}

}