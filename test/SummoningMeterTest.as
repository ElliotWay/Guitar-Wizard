package test 
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mockolate.runner.MockolateRunner;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import mockolate.stub;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.number.closeTo;
	import org.hamcrest.number.greaterThan;
	import org.hamcrest.number.lessThan;
	import src.ActorSprite;
	import src.GameUI;
	import src.SummoningMeter;
	
	MockolateRunner;
	/**
	 * ...
	 * @author ...
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class SummoningMeterTest 
	{
		private var summoningMeter:SummoningMeter;
		
		[Mock]
		public var gameUI:GameUI;
		
		[Mock] //These should be DisplayObjects, but I couldn't mock those for some reason.
		public var overlay:Sprite;
		private var fill:Sprite; //And this one can't be mocked, because it needs to more like
								//a real display object.
		
		public static const MIN_METER:int = 300, MAX_METER:int = 25, METER_WIDTH:Number = MIN_METER - MAX_METER;
		
		public static const TOLERANCE:Number = 0.01 * METER_WIDTH;
		
		private var later:Timer, evenLater:Timer, moment:Timer;
		private const LATER_TIME:int = 1000;
		private const EVEN_LATER:int = 4000;
		private const MOMENT:int = 50;
		
		[Before]
		public function setup():void {
			later = new Timer(LATER_TIME, 1);
			evenLater = new Timer(EVEN_LATER, 1);
			moment = new Timer(MOMENT, 1);
			
			fill = new Sprite();
			
			summoningMeter = new SummoningMeter(gameUI, overlay, fill, MIN_METER, MAX_METER);
			summoningMeter.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
		}
		
		[Test]
		public function hasOverlayAboveFill():void {
			//These throw an error if they aren't children.
			var overlayIndex:int = summoningMeter.getChildIndex(overlay);
			var fillIndex:int = summoningMeter.getChildIndex(fill);
			
			assertThat(overlayIndex, greaterThan(fillIndex));
		}
		
		[Test(async)]
		public function increases():void {
			//Note that since we're going up on the Y axis, that actually
			//means a decreasing value.
			summoningMeter.increase(23);
			var expectedPosition:Number = MIN_METER - (23 / 100) * METER_WIDTH;
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, LATER_TIME + 100);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			later.start();
		}
		
		[Test(async)]
		public function increasesMultipleTimes():void {
			summoningMeter.increase(12);
			summoningMeter.increase(17);
			summoningMeter.increase(2);
			
			var expectedPosition:Number = MIN_METER - (31 / 100) * METER_WIDTH;
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, LATER_TIME + 100);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			later.start();
		}
		
		[Test(async, order = 1)]
		public function increasesMidIncrease():void {
			summoningMeter.increase(50);
			
			var intermediatePosition:Number = MIN_METER - (50 / 100) * METER_WIDTH;
			var expectedPosition:Number = MIN_METER - (62 / 100) * METER_WIDTH;
			
			var momentHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, greaterThan(intermediatePosition));
				summoningMeter.increase(12);
			}, MOMENT + 50);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, LATER_TIME + 100);
			
			moment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			moment.start();
			later.start();
		}
		
		[Test(async)]
		public function combinationIncreaseDecrease():void {
			summoningMeter.increase(23);
			summoningMeter.decrease(12);
			summoningMeter.decrease(5);
			summoningMeter.increase(12);
			
			var expectedPosition:Number = MIN_METER - (18 / 100) * METER_WIDTH;
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, LATER_TIME + 100);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			later.start();
		}
		
		[Test(async, order = 1)]
		public function decreasesMidIncrease():void {
			summoningMeter.increase(50);
			
			var intermediatePosition:Number = MIN_METER - (50 / 100) * METER_WIDTH;
			var expectedPosition:Number = MIN_METER - (38 / 100) * METER_WIDTH;
			
			var momentHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, greaterThan(intermediatePosition));
				summoningMeter.decrease(12);
			}, MOMENT + 50);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, LATER_TIME + 100);
			
			moment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			moment.start();
			later.start();
		}
		
		[Test(async, order = 1)]
		public function wrapsAroundUp():void {
			summoningMeter.increase(124);
			
			var expectedPosition:Number = MIN_METER - (24 / 100) * METER_WIDTH;
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, LATER_TIME + 100);
			
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			later.start();
		}
		
		[Test(async, order = 1)]
		public function reallyWrapsAroundUp():void {
			summoningMeter.increase(436);
			
			var expectedPosition:Number = MIN_METER - (36 / 100) * METER_WIDTH;
			
			var evenLaterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, EVEN_LATER + 200);
			
			evenLater.addEventListener(TimerEvent.TIMER_COMPLETE, evenLaterHandler, false, 0, true);
			evenLater.start();
		}
		
		[Test(async, order = 1)]
		public function doesNotWrapDownImmediately():void {
			summoningMeter.decrease(20);
			
			var expectedPosition:Number = MIN_METER;
			
			//It shouldn't even start to move.
			var momentHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, MOMENT + 100);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, LATER_TIME + 50);
			
			moment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			moment.start();
			later.start();
		}
		
		[Test(async, order = 1)]
		public function doesNotWrapDownAfterIncrease():void {
			summoningMeter.increase(44);
			
			var expectedPosition:Number = MIN_METER;
			
			var momentHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, lessThan(MIN_METER));
				summoningMeter.decrease(49);
			}, MOMENT + 50);
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(fill.y, closeTo(expectedPosition, TOLERANCE));
			}, LATER_TIME + 100);
			
			moment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			later.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			moment.start();
			later.start();
		}
		
		[After]
		public function tearDown():void {
			later.stop();
			evenLater.stop();
			moment.stop();
		}
		
	}

}