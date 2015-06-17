package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class HoldManager 
	{
		/**
		 * 0.02 summoning units / millisecond.
		 * Equivalent to 10 units per beat, at 120BPM.
		 */
		public static const HOLD_RATIO:Number = 0.015; //0.02
		
		private var repeater:Repeater;
		private var summoningMeter:SummoningMeter;
		private var musicPlayer:MusicPlayer;
		
		private var managedHolds:Vector.<Note>;
		
		private var lastBeatTime:uint;
		
		private var quarterBeatCounter:int;
		
		public function HoldManager(repeater:Repeater, summoningMeter:SummoningMeter, musicPlayer:MusicPlayer) 
		{
			this.repeater = repeater;
			this.summoningMeter = summoningMeter;
			this.musicPlayer = musicPlayer;
			
			managedHolds = new Vector.<Note>();
			
			quarterBeatCounter = 0;
			lastBeatTime = 0;
			repeater.runEveryQuarterBeat(advanceHolds);
		}
		
		private function advanceHolds():void {
			quarterBeatCounter++;
			if (quarterBeatCounter < 4)
				return;
			quarterBeatCounter = 0;
			
			var currentTime:int = musicPlayer.getTime();
			var beatDuration:int = currentTime - lastBeatTime;
			
			var index:int = managedHolds.length - 1;
			while (index >= 0) {
				var hold:Note = managedHolds[index];
				
				var duration:int;
				
				if (hold.endtime < currentTime) {
					if (lastBeatTime < hold.time)
						duration = hold.endtime - hold.time;
					else
						duration = hold.endtime - lastBeatTime;
					
					//Remove holds that have reached their end.
					managedHolds.splice(index, 1);
					
				} else if (lastBeatTime < hold.time) {
					duration = currentTime - hold.time;
				} else {
					duration = beatDuration;
				}
				
				duration = Math.max(0, duration); //Unusual circumstances make it less than 0.
				
				summoningMeter.increase(duration * HOLD_RATIO);
				
				index--;
			}
			
			lastBeatTime = currentTime;
		}
		
		/**
		 * Add a hold that will regularly portion out its duration to the summoning meter.
		 * The Note object must be a hold. If the end of the hold is reached, it will stop
		 * increasing the summoning meter. You need not call finishHold if this happens.
		 * @param	hold a Note that is a hold that should be managed
		 */
		public function manageHold(hold:Note):void {
			if (!hold.isHold)
				throw new GWError("Can't manage non-hold.");
			
			managedHolds.push(hold);
		}
		
		/**
		 * Immediately increase the summoning meter by the duration up to the current time or to
		 * the end of the hold, whichever is less.
		 * The hold should already be managed. If it is not, this function does nothing.
		 * The hold is no longer managed after calling this function.
		 * @param	hold the hold to finish
		 * @param   currentTime the current time of the song, in milliseconds
		 * @param   forceComplete use the duration up the end of the hold, irrespective of the current time
		 */
		public function finishHold(hold:Note, currentTime:uint, forceComplete:Boolean = false):void {
			var holdIndex:int = managedHolds.indexOf(hold);
			if (holdIndex < 0)
				return;
				
			var remainingDuration:uint = ((forceComplete || hold.endtime < currentTime) ?
					hold.endtime : currentTime) - Math.max(lastBeatTime, hold.time);
					
			summoningMeter.increase(remainingDuration * HOLD_RATIO);
			
			managedHolds.splice(holdIndex, 1);
		}
	}

}