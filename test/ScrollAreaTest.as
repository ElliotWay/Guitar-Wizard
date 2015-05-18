package test 
{
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mockolate.runner.MockolateRunner;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.number.greaterThan;
	import org.hamcrest.number.lessThan;
	import src.ScrollArea;
	
	MockolateRunner;
	/**
	 * ...
	 * @author ...
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	public class ScrollAreaTest 
	{
		private var scrollArea:ScrollArea;
		
		private const FULL_POSITION:Number = 400;
		private const INITIAL_POSITION:Number = 200;
		private const TARGET_POSITION:Number = 300;
		
		
		private const MOMENT:Number = 75;//100
		private const JUMP_TIME:Number = ScrollArea.JUMP_DURATION * 1000 + MOMENT;
		private const SCROLL_TIME:Number = ScrollArea.SCROLL_TO_DURATION * 1000 + MOMENT;
		
		private var afterMoment:Timer;
		private var afterJump:Timer;
		private var afterScroll:Timer;
		
		[Before]
		public function setup():void {
			scrollArea = new ScrollArea(FULL_POSITION);
			scrollArea.x = -INITIAL_POSITION;
			
			afterMoment = new Timer(MOMENT, 1);
			afterJump = new Timer(JUMP_TIME, 1);
			afterScroll = new Timer(SCROLL_TIME, 1);
		}
		
		[Test]
		public function doesNotStartScrolling():void {
			assertThat(scrollArea.isScrolling, false);
		}
		
		//Scrolling the view a direction actually moves the underlying object
		//the opposite direction.
		
		[Test(async)]
		public function scrollsLeft():void {
			scrollArea.scrollLeft();
			
			var momentHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollArea.x, greaterThan( -INITIAL_POSITION));
				assertThat(scrollArea.isScrolling, true);
			}, MOMENT + MOMENT);
			
			afterMoment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			
			afterMoment.start();
		}
		
		[Test(async)]
		public function scrollsRight():void {
			scrollArea.scrollRight();
			
			var momentHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollArea.x, lessThan( -INITIAL_POSITION));
				assertThat(scrollArea.isScrolling, true);
			}, MOMENT * 2);
			
			afterMoment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			
			afterMoment.start();
		}
		
		[Test(async)]
		public function stopsScrolling():void {
			scrollArea.scrollLeft();
			
			var currentPosition:Number;
			
			var momentHandler:Function = function():void {
				currentPosition = scrollArea.x;
				scrollArea.stopScrolling();
			};
			
			var laterHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollArea.x, currentPosition);
				assertThat(scrollArea.isScrolling, false);
			}, JUMP_TIME + MOMENT);
			
			afterMoment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			
			afterJump.addEventListener(TimerEvent.TIMER_COMPLETE, laterHandler, false, 0, true);
			
			afterMoment.start();
			afterJump.start();
		}
		
		[Test(async)]
		public function jumpsLeft():void {
			scrollArea.jumpLeft();
			
			var momentHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollArea.isScrolling, true);
			}, MOMENT + MOMENT);
			
			var jumpHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollArea.x, 0);
			}, JUMP_TIME + MOMENT);
			
			afterMoment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			
			afterJump.addEventListener(TimerEvent.TIMER_COMPLETE, jumpHandler, false, 0, true);
			
			afterMoment.start();
			afterJump.start();
		}
		
		[Test(async)]
		public function jumpsRight():void {
			scrollArea.jumpRight();
			
			var momentHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollArea.isScrolling, true);
			}, MOMENT + MOMENT);
			
			var jumpHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollArea.x, -FULL_POSITION);
			}, JUMP_TIME + MOMENT);
			
			afterMoment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			
			afterJump.addEventListener(TimerEvent.TIMER_COMPLETE, jumpHandler, false, 0, true);
			
			afterMoment.start();
			afterJump.start();
		}
		
		[Test(async)]
		public function scrollsToTarget():void {
			scrollArea.scrollTo(TARGET_POSITION);
			
			var momentHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollArea.isScrolling, true);
			}, MOMENT + MOMENT);
			
			var scrollHandler:Function = Async.asyncHandler(this, function():void {
				assertThat(scrollArea.x, -TARGET_POSITION);
			}, SCROLL_TIME + MOMENT);
			
			afterMoment.addEventListener(TimerEvent.TIMER_COMPLETE, momentHandler, false, 0, true);
			
			afterScroll.addEventListener(TimerEvent.TIMER_COMPLETE, scrollHandler, false, 0, true);
			
			afterMoment.start();
			afterScroll.start();
		}
		
		[After]
		public function tearDown():void {
			scrollArea.stopScrolling();
			
			if (afterMoment != null) {
				afterMoment.stop();
				afterMoment = null;
			}
			
			if (afterJump != null) {
				afterJump.stop();
				afterJump = null;
			}
			
			if (afterScroll != null) {
				afterScroll.stop();
				afterScroll = null;
			}
		}
		
	}

}