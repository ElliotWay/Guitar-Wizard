package src 
{
	import com.greensock.easing.ElasticOut;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SummoningMeter extends Sprite 
	{
		
		private static const BACKGROUND_COLOR:int = 0xFFFFB0; //Faded Yellow.
		
		private var minMeter:int;
		private var maxMeter:int;
		private var meterLength:int;
		
		/**
		 * Or "Number" tolerance really. Used for equal comparisons between doubles.
		 */
		private static const DOUBLE_TOLERANCE:Number = 0.00001;
		
		/**
		 * Starting speed at which the meter advances.
		 * pxl/s
		 */
		public static const BASE_SPEED:Number = 75; //100
		
		private var ui:GameUI;
		private var overlay:DisplayObject;
		private var fill:DisplayObject;
		
		private var increaseQueue:Vector.<Timer>;
		private var decreaseQueue:Vector.<Timer>;
		
		private var changer:TweenLite;
		
		private var changeRate:Number;
		
		/**
		 * Create the summoning meter. This controls the rate at which the fill object is revealed,
		 * underneath the overlay object.
		 * @param	ui the gameUI
		 * @param	overlay the overlay object appears on top of the rest of the meter
		 * @param	fill the fill object is revealed when the meter fills up
		 * @param	minMeter the y pixel position of the lowest part of the meter
		 * @param	maxMeter the y pixel position of the highest part of the meter
		 */
		public function SummoningMeter(ui:GameUI, overlay:DisplayObject, fill:DisplayObject, minMeter:int, maxMeter:int) 
		{
			this.ui = ui;
			this.overlay = overlay;
			this.fill = fill;
			
			this.minMeter = minMeter;
			this.maxMeter = maxMeter;
			this.meterLength = minMeter - maxMeter; //minMeter is actually a higher y value.
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Background.
			graphics.beginFill(BACKGROUND_COLOR);
			graphics.drawRect(0, 0, overlay.width, overlay.height);
			graphics.endFill();
			
			//This part moves up, filling the meter.
			this.addChild(fill);
			
			fill.y = minMeter;
			
			//And the overlay is on top.
			this.addChild(overlay);
			
			increaseQueue = new Vector.<Timer>();
			decreaseQueue = new Vector.<Timer>();
			
			changeRate = 0;
		}
		
		public function reset():void {
			if (changer != null)
				changer.kill();
			
			var timer:Timer;
			for each (timer in increaseQueue)
				timer.stop();
			increaseQueue = new Vector.<Timer>();
			
			for each (timer in decreaseQueue)
				timer.stop();
			decreaseQueue = new Vector.<Timer>();
			
			changeRate = 0;
			
			fill.y = minMeter;
		}
		
		public function increase(amount:Number):void {
			
			var time:Number = 1000 * ((amount / 100) * meterLength) / BASE_SPEED;
			
			appendToIncreaseQueue(time);
			
			proceed();
		}
		
		public function decrease(amount:Number):void {
			
			var time:Number = 1000 * ((amount / 100) * meterLength) / BASE_SPEED;
			
			appendToDecreaseQueue(time);
			
			proceed();
		}
		
		public function increaseRate(rateChange:Number):void {
			changeRate += rateChange;
			
			proceed();
		}
		
		public function decreaseRate(rateChange:Number):void {
			changeRate -= rateChange;
			
			proceed();
		}
		
		private function appendToIncreaseQueue(time:Number):void {
			
			var timer:Timer = new Timer(time, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, finishIncreaseQueue);
			
			if (increaseQueue.length == 0) {
				changeRate += BASE_SPEED;
				
				timer.start();
				
			} else {
			
				var top:Timer = increaseQueue[increaseQueue.length - 1];
				
				top.removeEventListener(TimerEvent.TIMER_COMPLETE, finishIncreaseQueue);
				top.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					increaseQueue.shift();
					timer.start();
				});
			}
			
			increaseQueue.push(timer);
		}
		
		private function finishIncreaseQueue(event:Event):void {
			(event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, finishIncreaseQueue);
			changeRate -= BASE_SPEED;
			proceed();
			
			increaseQueue.shift();
		}
		
		private function appendToDecreaseQueue(time:Number):void {
			
			var timer:Timer = new Timer(time, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, finishDecreaseQueue);
			
			if (decreaseQueue.length == 0) {
				changeRate -= BASE_SPEED;
				
				timer.start();
				
			} else {
			
				var top:Timer = decreaseQueue[decreaseQueue.length - 1];
				
				top.removeEventListener(TimerEvent.TIMER_COMPLETE, finishDecreaseQueue);
				top.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					decreaseQueue.shift();
					timer.start();
				});
			}
			
			decreaseQueue.push(timer);
		}
		
		private function finishDecreaseQueue(event:Event):void {
			(event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, finishDecreaseQueue);
			changeRate += BASE_SPEED;
			decreaseQueue.shift();
		}
		
		private function proceed():void {
			if (fill.y == maxMeter) {
				fill.y = minMeter;
			}
			
			var distance:Number;
			
			// 0 is the only point where the exact performance matters,
			// so reset it to exactly 0 whenever it's close.
			if (Math.abs(changeRate) < DOUBLE_TOLERANCE) {
				
				changeRate = 0;
				
				if (changer != null)
					changer.kill();
				
			} else if (changeRate > 0) {
				distance = fill.y - maxMeter;
				
				if (changer != null)
					changer.kill();
				
				changer = new TweenLite(fill, distance / changeRate,
						{y:maxMeter, ease:Linear.easeInOut, onComplete:function():void {
							ui.preparePlayerSummon();
							
							proceed();
						} } );
			} else if (changeRate < 0 && fill.x > minMeter) {
				distance = minMeter - fill.x; //This value will be negative, but so is changeRate.
				
				changer = new TweenLite(fill, distance / changeRate,
						{y:minMeter, ease:Linear.easeInOut} );
			}
		}
	}

}