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
		public static const HOLD_RATIO:Number = 0.01; //0.02
		
		public static const BAD_HOLD_RATIO:Number = 0.005;
		
		private var repeater:Repeater;
		private var summoningMeter:SummoningMeter;
		private var musicPlayer:MusicPlayer;
		
		private var managedHolds:Vector.<Note>;
		private var lateHolds:Vector.<Note>;
		
		private var lastBeatTime:uint;
		
		private var quarterBeatCounter:int;
		
		public function HoldManager(repeater:Repeater, summoningMeter:SummoningMeter, musicPlayer:MusicPlayer) 
		{
			this.repeater = repeater;
			this.summoningMeter = summoningMeter;
			this.musicPlayer = musicPlayer;
			
			managedHolds = new Vector.<Note>();
			lateHolds = new Vector.<Note>();
			
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
			
			var changeAmount:Number = 0;
			
			//First deal with holds that are past their ends.
			var index:int = lateHolds.length - 1;
			var hold:Note;
			while (index >= 0) {
				hold = lateHolds[index];
				
				//But don't decrease anything if the user might still finish the end in time.
				if (currentTime - hold.endtime > GameUI.HIT_TOLERANCE) {
					changeAmount -= beatDuration * BAD_HOLD_RATIO;
				}
				
				index--;
			}
			
			//Then update the holds that are still ongoing.
			index = managedHolds.length - 1;
			while (index >= 0) {
				hold = managedHolds[index];
				
				var duration:int;
				
				if (hold.endtime < currentTime) {
					if (lastBeatTime < hold.time)
						duration = hold.endtime - hold.time;
					else
						duration = hold.endtime - lastBeatTime;
					
					//Remove holds that have reached their end.
					managedHolds.splice(index, 1);
					lateHolds.push(hold);
					
				} else if (lastBeatTime < hold.time) {
					duration = currentTime - hold.time;
				} else {
					duration = beatDuration;
				}
				
				duration = Math.max(0, duration); //Unusual circumstances make it less than 0.
				
				changeAmount += duration * HOLD_RATIO;
				
				index--;
			}
			
			if (changeAmount != 0)
				summoningMeter.increase(changeAmount);
			
			lastBeatTime = currentTime;
		}
		
		/**
		 * Add a hold that will regularly portion out its duration to the summoning meter.
		 * The Note object must be a hold. If the end of the hold is reached, it will switch
		 * to decreasing the summoning meter.
		 * @param	hold a Note that is a hold that should be managed
		 */
		public function manageHold(hold:Note):void {
			if (!hold.isHold)
				throw new GWError("Can't manage non-hold.");
			
			managedHolds.push(hold);
		}
		
		/**
		 * Stop managing the hold.
		 * If the hold is still ongoing, immediately increase the summoning meter by the
		 * duration up to the current time or to the end of the hold, whichever is less.
		 * If the hold is past the end, stop decreasing the summoning meter.
		 * The hold should already be managed. If it is not, this function does nothing.
		 * The hold is no longer managed after calling this function.
		 * @param	hold the hold to finish
		 * @param   currentTime the current time of the song, in milliseconds
		 * @param   forceComplete use the duration up the end of the hold, irrespective of the current time
		 */
		public function finishHold(hold:Note, currentTime:uint, forceComplete:Boolean = false):void {
			var holdIndex:int = managedHolds.indexOf(hold);
			if (holdIndex < 0) {
				holdIndex = lateHolds.indexOf(hold);
				
				if (holdIndex >= 0)
					lateHolds.splice(holdIndex, 1);
				
				return;
			}
				
			var remainingDuration:int = ((forceComplete || hold.endtime < currentTime) ?
					hold.endtime : currentTime) - Math.max(lastBeatTime, hold.time);
			
			//Unusual for it to be negative, as a managed hold will already be removed
			//if the last beat is past its end time.
			//Can plausibly happen if a hold is managed and then finished before a beat occurs.
			if (remainingDuration > 0)
				summoningMeter.increase(remainingDuration * HOLD_RATIO);
			
			managedHolds.splice(holdIndex, 1);
		}
	}

}