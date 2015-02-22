package test 
{	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import src.GameUI;
	import src.Main;
	import src.MusicArea;
	import src.MusicPlayer;
	
	MockolateRunner;
	/**
	 * ...
	 * @author ...
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class GameUI_SwitchTrackTest extends GameUI
	{
		
		public function GameUI_SwitchTrackTest() 
		{
			
		}
		
		private static const RIGHT_NOW:Number = 100;
		
		private static const FIRST_SWITCH:Number =
				RIGHT_NOW + MusicArea.SWITCH_ADVANCE_TIME + 100;
				
		private static const CLOSER_TIME:Number = FIRST_SWITCH - (MusicArea.SWITCH_ADVANCE_TIME / 2);
				
		private static const SECOND_SWITCH:Number =
				FIRST_SWITCH + 5 * MusicArea.SWITCH_ADVANCE_TIME;
		
		[Mock]
		public var musicAreaMock:MusicArea;
		
		[Mock]
		public var musicPlayerMock:MusicPlayer;
		
		[Before]
		public function setup():void {
			//I wanted to use an alias for this ie
			//gameUI = this;
			//but actionscript is being silly.
			
			this.musicArea = musicAreaMock;
			this.musicPlayer = musicPlayerMock;
			
			this.currentTrack = Main.HIGH;
			this.switchTimer = null;
			this.advanceSwitchTimer = null;
			
		}
		
		private function setupRightNow():void {
			mock(musicPlayerMock).method("getTime").returns(RIGHT_NOW);
			mock(musicAreaMock).method("switchNotes").returns(FIRST_SWITCH);
		}
		
		private function setupCloser():void {
			mock(musicPlayerMock).method("getTime").returns(RIGHT_NOW, CLOSER_TIME);
			mock(musicAreaMock).method("switchNotes").returns(FIRST_SWITCH, SECOND_SWITCH);
		}
		
		[Test]
		public function changesNoteVisibility():void {
			setupRightNow();
			this.switchTrack(Main.MID);
			
			assertThat(musicArea, received().method("switchNotes").args(RIGHT_NOW, Main.MID));
		}
		
		[Test]
		public function doesNotSwitchEarly():void {
			setupRightNow();
			this.switchTrack(Main.MID)
			
			assertThat(this.currentTrack == Main.HIGH);
			assertThat(musicPlayer, received().method("switchTrack").never());
		}
		
		[Test]
		public function usesSwitchTimer():void {
			setupRightNow();
			this.switchTrack(Main.MID);
			
			assertThat(this.switchTimer != null);
			assertThat(this.switchTimer.delay == (FIRST_SWITCH - RIGHT_NOW));
		}
		
		[Test]
		public function switchesWithTimer():void {
			setupRightNow();
			this.switchTrack(Main.MID);
			
			this.switchTimer.dispatchEvent(new Event(TimerEvent.TIMER_COMPLETE));
			
			assertThat(this.currentTrack == Main.MID);
			assertThat(musicPlayer, received().method("switchTrack").arg(Main.MID));
			
			assertThat(switchTimer == null);
		}
		
		[Test]
		public function allowsOverwrite():void {
			setupRightNow();
			this.switchTrack(Main.MID);
			
			this.switchTrack(Main.LOW);
			
			this.switchTimer.dispatchEvent(new Event(TimerEvent.TIMER_COMPLETE));
			
			assertThat(this.currentTrack, Main.LOW);
			assertThat(musicPlayer, received().method("switchTrack").arg(Main.LOW));
		}
		
		[Test]
		public function usesAdvanceSwitchTimer():void {
			setupCloser();
			
			//This occurs at RIGHT_NOW.
			this.switchTrack(Main.MID);
			
			//This occurs at CLOSER_TIME.
			this.switchTrack(Main.LOW);
			
			assertThat(this.advanceSwitchTimer != null);
			assertThat(this.advanceSwitchTimer.delay, (SECOND_SWITCH - CLOSER_TIME));
		}
		
		[Test]
		public function switchesConsecutively():void {
			setupCloser();
			
			this.switchTrack(Main.MID);
			
			this.switchTrack(Main.LOW);
			
			switchTimer.dispatchEvent(new Event(TimerEvent.TIMER_COMPLETE));
			
			assertThat(this.currentTrack == Main.MID);
			assertThat(musicPlayer, received().method("switchTrack").arg(Main.MID));
			
			assertThat(switchTimer.delay, (SECOND_SWITCH - CLOSER_TIME));
			
			switchTimer.dispatchEvent(new Event(TimerEvent.TIMER_COMPLETE));
			
			assertThat(this.currentTrack, Main.LOW);
			assertThat(musicPlayer, received().method("switchTrack").arg(Main.LOW));
			
			assertThat(switchTimer, null);
		}
		
		public function allowsAdvanceOverwrite():void {
			setupCloser();
			
			this.switchTrack(Main.MID);
			
			//This occurs at CLOSER_TIME.
			this.switchTrack(Main.LOW);
			
			//This also occurs at CLOSER_TIME.
			this.switchTrack(Main.HIGH);
			
			advanceSwitchTimer.dispatchEvent(new Event(TimerEvent.TIMER_COMPLETE));
			
			assertThat(this.currentTrack, Main.HIGH);
			assertThat(musicPlayer, received().method("switchTrack").arg(Main.HIGH));
		}
		
	}

}