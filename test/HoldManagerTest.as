package test 
{
	
	import mockolate.received;
	import mockolate.runner.MockolateRunner;
	import mockolate.stub;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.anyOf;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.throws;
	import src.GWError;
	import src.HoldManager;
	import src.MusicPlayer;
	import src.Note;
	import src.Repeater;
	import src.SummoningMeter;
	
	MockolateRunner;
	/**
	 * ...
	 * @author ...
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class HoldManagerTest 
	{
		[Mock]
		public var repeater:Repeater;
		
		[Mock]
		public var summoningMeter:SummoningMeter;
		
		[Mock]
		public var musicPlayer:MusicPlayer;
		
		private var runningFunction:Function;
		
		private var holdManager:HoldManager;
		
		public static const FIRST_BEAT:int = 500;
		public static const SECOND_BEAT:int = 1000;
		public static const THIRD_BEAT:int = 1500;
		public static const FOURTH_BEAT:int = 2000;
		public static const FIFTH_BEAT:int = 2500;
		
		public static const DOUBLE_TOLERANCE:Number = 0.0001;
		
		[Before]
		public function setup():void {
			stub(repeater).method("runEveryQuarterBeat").callsWithArguments(function(func:Function):void {
				runningFunction = func;
			});
			
			stub(musicPlayer).method("getTime")
					.returns(FIRST_BEAT, SECOND_BEAT, THIRD_BEAT, FOURTH_BEAT, FIFTH_BEAT);
			
			holdManager = new HoldManager(repeater, summoningMeter, musicPlayer);
		}
		
		[Test]
		public function startsRunning():void {
			assertThat(repeater, received().method("runEveryQuarterBeat").arg(isA(Function)));
			assertThat(runningFunction != null);
			
			//Make sure it doesn't increase prematurely.
			assertThat(summoningMeter, received().method("increase").never());
		}
		
		private function nextBeat():void {
			runningFunction.call();
			runningFunction.call();
			runningFunction.call();
			runningFunction.call();
		}
		
		[Test]
		public function cannotManageNonHold():void {
			var note:Note = new Note();
			note.letter = Note.NOTE_A; note.time = 100; note.isHold = false;
			
			assertThat(function():void { holdManager.manageHold(note); }, throws(isA(GWError)));
		}
		
		[Test]
		public function managesShortHold():void {
			var shortHold:Note = new Note();
			shortHold.letter = Note.NOTE_A;	shortHold.time = FIRST_BEAT - 300;
			shortHold.isHold = true;		shortHold.endtime = FIRST_BEAT - 100;
			
			holdManager.manageHold(shortHold);
			
			assertThat(summoningMeter, received().method("increase").never());
			
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase")
					.arg(200 * HoldManager.HOLD_RATIO).once());
					
			assertThat(summoningMeter, received().method("increase").once());
		}
		
		[Test]
		public function managesTwoStepHold():void {
			var twoStepHold:Note = new Note();
			twoStepHold.letter = Note.NOTE_A;	twoStepHold.time = FIRST_BEAT - 300;
			twoStepHold.isHold = true;			twoStepHold.endtime = FIRST_BEAT + 100;
			
			holdManager.manageHold(twoStepHold);
			
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase")
					.arg(300 * HoldManager.HOLD_RATIO).once());
					
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase")
					.arg(100 * HoldManager.HOLD_RATIO).once());
			
			assertThat(summoningMeter, received().method("increase").twice());
		}
		
		[Test]
		public function managesThreeStepHold():void {
			var threeStepHold:Note = new Note();
			threeStepHold.letter = Note.NOTE_A;	threeStepHold.time = FIRST_BEAT - 300;
			threeStepHold.isHold = true;		threeStepHold.endtime = SECOND_BEAT + 100;
			
			holdManager.manageHold(threeStepHold);
			
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase")
					.arg(300 * HoldManager.HOLD_RATIO).once());
					
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase")
					.arg((SECOND_BEAT - FIRST_BEAT) * HoldManager.HOLD_RATIO).once());
					
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase")
					.arg(100 * HoldManager.HOLD_RATIO).once());
			
			assertThat(summoningMeter, received().method("increase").thrice());
		}
		
		[Test]
		public function managesLateHold():void {
			var lateHold:Note = new Note();
			lateHold.letter = Note.NOTE_A;	lateHold.time = FIRST_BEAT + 100;
			lateHold.isHold = true;			lateHold.endtime = FIRST_BEAT + 300;
			
			//This one doesn't have _any_ part within the last beat, so it shouldn't increase at all.
			
			holdManager.manageHold(lateHold);
			
			nextBeat();
			
			assertThat(summoningMeter, anyOf(received().method("increase").arg(0),
					received().method("increase").never()));
					
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase")
					.arg(200 * HoldManager.HOLD_RATIO).once());
			
			assertThat(summoningMeter, received().method("increase").atMost(2));
		}
		
		[Test]
		public function managesEarlyHold():void {
			var earlyHold:Note = new Note();
			earlyHold.letter = Note.NOTE_A;	earlyHold.time = FIRST_BEAT - 300;
			earlyHold.isHold = true;		earlyHold.endtime = FIRST_BEAT - 100;
			
			nextBeat(); //Advance to the first beat before adding the hold.
			
			//This case is unusual and would only occur as the result of a bug or crazy
			//unpredictable lag. I still need to make sure it has predicatable results.
			
			holdManager.manageHold(earlyHold);
			
			nextBeat();
			
			assertThat(summoningMeter, anyOf(received().method("increase").arg(0),
					received().method("increase").never()));
			
			assertThat(summoningMeter, received().method("increase").atMost(1));
		}
		
		[Test(order = 1)]
		public function managesManyHolds():void {
			/*	Beats:		0         1         2         3         4
			 * 	1	 |                  |-|                      
			 * 	2    |           |------------------------------|    
			 * 	3    |                      |------------------------|
			 * 	4    |                   |-------------------|
			 * 	5    |                       |---------|
			 * 
			 */
			
			var hold1:Note = new Note();
			hold1.letter = Note.NOTE_A;	hold1.time = FIRST_BEAT + 100;
			hold1.isHold = true;		hold1.endtime = FIRST_BEAT + 200;
			
			var hold2:Note = new Note();
			hold2.letter = Note.NOTE_A;	hold2.time = FIRST_BEAT - 250;
			hold2.isHold = true;		hold2.endtime = THIRD_BEAT + 300;
			
			var hold3:Note = new Note();
			hold3.letter = Note.NOTE_A;	hold3.time = SECOND_BEAT - 200;
			hold3.isHold = true;		hold3.endtime = FOURTH_BEAT + 50;
			
			var hold4:Note = new Note();
			hold4.letter = Note.NOTE_A;	hold4.time = SECOND_BEAT - 350;
			hold4.isHold = true;		hold4.endtime = THIRD_BEAT + 150;
			
			var hold5:Note = new Note();
			hold5.letter = Note.NOTE_A;	hold5.time = SECOND_BEAT - 150;
			hold5.isHold = true;		hold5.endtime = SECOND_BEAT + 450;
			
			
			
			
			holdManager.manageHold(hold2);
			
			nextBeat();
			
			//0 + 250 + 0 + 0 + 0 = 250
			assertThat(summoningMeter, received().method("increase")
					.arg(250 * HoldManager.HOLD_RATIO).once());
			assertThat(summoningMeter, received().method("increase").once());
			
			holdManager.manageHold(hold1);
			holdManager.manageHold(hold3);
			holdManager.manageHold(hold4);
			holdManager.manageHold(hold5);
			
			nextBeat();
			
			//100 + 500 + 200 + 350 + 150 = 1300
			assertThat(summoningMeter, received().method("increase")
					.arg(1300 * HoldManager.HOLD_RATIO).once());
			assertThat(summoningMeter, received().method("increase").twice());
			
			holdManager.finishHold(hold1, 0, true);
			nextBeat();
			
			//0 + 500 + 500 + 500 + 450 = 1950
			assertThat(summoningMeter, received().method("increase")
					.arg(1950 * HoldManager.HOLD_RATIO).once());
			assertThat(summoningMeter, received().method("increase").thrice());
			
			holdManager.finishHold(hold5, 0, true);
			nextBeat();
			
			//0 + 300 + 500 + 150 + 0 = 950
			assertThat(summoningMeter, received().method("increase")
					.arg(950 * HoldManager.HOLD_RATIO).once());
			assertThat(summoningMeter, received().method("increase").times(4));
			
			holdManager.finishHold(hold2, 0, true);
			holdManager.finishHold(hold4, 0, true);
			nextBeat();
			
			//0 + 0 + 50 + 0 + 0 = 50
			assertThat(summoningMeter, received().method("increase")
					.arg(50 * HoldManager.HOLD_RATIO).once());
			assertThat(summoningMeter, received().method("increase").times(5));
		}
		
		[Test]
		public function decreasesAfterFinishing():void {
			var hold:Note = new Note();
			hold.letter = Note.NOTE_A;	hold.time = FIRST_BEAT - 100;
			hold.isHold = true;			hold.endtime = FIRST_BEAT + 100;
			
			holdManager.manageHold(hold);
			
			//Finish the hold first.
			nextBeat();
			nextBeat();
			assertThat(summoningMeter, received().method("increase").twice());
			
			//After finishing, it should decrease the summoning meter.
			
			nextBeat();
			assertThat(summoningMeter, received().method("increase")
					.arg(-500 * HoldManager.BAD_HOLD_RATIO).once());
					
			nextBeat();
			assertThat(summoningMeter, received().method("increase")
					.arg(-500 * HoldManager.BAD_HOLD_RATIO).twice());
					
			assertThat(summoningMeter, received().method("increase").times(4));
			
		}
		
		[Test]
		public function doesNotFinishUnmanagedHold():void {
			var hold:Note = new Note();
			hold.letter = Note.NOTE_A; 	hold.time = FIRST_BEAT - 100;
			hold.isHold = true;			hold.endtime = FOURTH_BEAT - 100;
			
			holdManager.finishHold(hold, SECOND_BEAT + 100);
			
			assertThat(summoningMeter, received().method("increase").never());
		}
		
		[Test]
		public function finishShortHold():void {
			var shortHold:Note = new Note();
			shortHold.letter = Note.NOTE_A;	shortHold.time = FIRST_BEAT - 400;
			shortHold.isHold = true;		shortHold.endtime = FIRST_BEAT - 150;
			
			holdManager.manageHold(shortHold);
			
			holdManager.finishHold(shortHold, FIRST_BEAT - 50);
			
			assertThat(summoningMeter, received().method("increase")
					.arg(250 * HoldManager.HOLD_RATIO).once());
		}
		
		[Test]
		public function finishHoldPastCurrentTime():void {
			var pastCurrent:Note = new Note();
			pastCurrent.letter = Note.NOTE_A;	pastCurrent.time = FIRST_BEAT - 300;
			pastCurrent.isHold = true;			pastCurrent.endtime = FIRST_BEAT + 100;
			
			holdManager.manageHold(pastCurrent);
			
			holdManager.finishHold(pastCurrent, FIRST_BEAT - 100);
			
			assertThat(summoningMeter, received().method("increase")
					.arg(200 * HoldManager.HOLD_RATIO).once());
		}
		
		[Test]
		public function finishHoldBeforeLastBeat():void {
			var beforeLast:Note = new Note();
			beforeLast.letter = Note.NOTE_A;	beforeLast.time = FIRST_BEAT - 100;
			beforeLast.isHold = true;			beforeLast.endtime = FIRST_BEAT + 400;
			
			nextBeat();	//Make FIRST_BEAT the last beat.
			
			holdManager.manageHold(beforeLast);
			
			holdManager.finishHold(beforeLast, SECOND_BEAT);
			
			assertThat(summoningMeter, received().method("increase")
					.arg(400 * HoldManager.HOLD_RATIO).once());
		}
		
		[Test]
		public function finishHoldBeyondConstraints():void {
			var unconstrained:Note = new Note();
			unconstrained.letter = Note.NOTE_A;		unconstrained.time = FIRST_BEAT - 100;
			unconstrained.isHold = true;			unconstrained.endtime = FIRST_BEAT + 400;
			
			nextBeat();
			
			holdManager.manageHold(unconstrained);
			
			holdManager.finishHold(unconstrained, FIRST_BEAT + 300);
			
			assertThat(summoningMeter, received().method("increase")
					.arg(300 * HoldManager.HOLD_RATIO).once());
		}
		
		[Test]
		public function finishesToEndIfRequested():void {
			var unconstrained:Note = new Note();
			unconstrained.letter = Note.NOTE_A;		unconstrained.time = FIRST_BEAT - 100;
			unconstrained.isHold = true;			unconstrained.endtime = FIRST_BEAT + 400;
			
			nextBeat();
			
			holdManager.manageHold(unconstrained);
			
			holdManager.finishHold(unconstrained, FIRST_BEAT + 300, true);
			
			assertThat(summoningMeter, received().method("increase")
					.arg(400 * HoldManager.HOLD_RATIO).once());
		}
		
		[Test]
		public function finishesWellManagedHold():void {
			var threeStepHold:Note = new Note();
			threeStepHold.letter = Note.NOTE_A;	threeStepHold.time = FIRST_BEAT - 300;
			threeStepHold.isHold = true;		threeStepHold.endtime = SECOND_BEAT + 250;
			
			holdManager.manageHold(threeStepHold);
			
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase")
					.arg(300 * HoldManager.HOLD_RATIO).once());
					
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase")
					.arg((SECOND_BEAT - FIRST_BEAT) * HoldManager.HOLD_RATIO).once());
					
			holdManager.finishHold(threeStepHold, SECOND_BEAT + 200);
			
			assertThat(summoningMeter, received().method("increase")
					.arg(200 * HoldManager.HOLD_RATIO).once());
					
			assertThat(summoningMeter, received().method("increase").thrice());
					
			//And make sure it was removed.
			nextBeat();
			nextBeat();
			nextBeat();
			
			assertThat(summoningMeter, received().method("increase").thrice());
		}
		
		[Test]
		public function finishesLateManagedHold():void {
			var lateHold:Note = new Note();
			lateHold.letter = Note.NOTE_A;	lateHold.time = FIRST_BEAT - 300;
			lateHold.isHold = true;			lateHold.endtime = FIRST_BEAT - 100;
			
			nextBeat();
			
			holdManager.manageHold(lateHold);
			
			holdManager.finishHold(lateHold, FIRST_BEAT + 100);
			
			//The hold was managed too late, and it is already completely past, so
			//it should not increase the summoning meter at all.
			
			assertThat(summoningMeter, anyOf(received().method("increase").arg(0),
					received().method("increase").never()));
		}
	}

}