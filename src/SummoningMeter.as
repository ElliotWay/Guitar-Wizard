package src 
{
	import com.greensock.easing.ElasticOut;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
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
		
		public static const WIDTH:int = MainArea.MINIMAP_WIDTH;
		public static const HEIGHT:int = 50;
		
		private static const BACKGROUND_COLOR:int = 0xFFFF00; //Yellow.
		private static const METER_COLOR:int = 0xB000B0; //Purple.
		
		private static const MIN_METER:int = 2;
		private static const MAX_METER:int = WIDTH - 4;
		private static const METER_LENGTH:int = MAX_METER - MIN_METER;
		
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
		
		private var increaseQueue:Vector.<Timer>;
		private var decreaseQueue:Vector.<Timer>;
		
		private var uncover:Sprite;
		
		private var changer:TweenLite;
		
		private var changeRate:Number;
		
		public function SummoningMeter(ui:GameUI) 
		{
			this.ui = ui;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Background.
			graphics.beginFill(BACKGROUND_COLOR);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
			
			graphics.beginFill(METER_COLOR);
			graphics.drawRect(2, 2, WIDTH - 4, HEIGHT - 4);
			
			//This part moves right, uncovering the meter.
			uncover = new Sprite();
			this.addChild(uncover);
			uncover.graphics.beginFill(BACKGROUND_COLOR);
			uncover.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			uncover.graphics.endFill();
			
			uncover.x = MIN_METER;
			
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
			
			uncover.x = MIN_METER;
		}
		
		public function increase(amount:Number):void {
			
			var time:Number = 1000 * ((amount / 100) * METER_LENGTH) / BASE_SPEED;
			
			appendToIncreaseQueue(time);
			
			proceed();
		}
		
		public function decrease(amount:Number):void {
			
			var time:Number = 1000 * ((amount / 100) * METER_LENGTH) / BASE_SPEED;
			
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
			trace("increaseQueue length " + increaseQueue.length);
			
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
			changeRate -= BASE_SPEED;
			proceed();
			
			increaseQueue.shift();
			trace("finish increase queue length " + increaseQueue.length);
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
			changeRate += BASE_SPEED;
			decreaseQueue.shift();
		}
		
		private function proceed():void {
			trace("current summon rate: " + changeRate);
			if (uncover.x == MAX_METER) {
				uncover.x = MIN_METER;
			}
			
			var distance:Number;
			
			// 0 is the only point where the exact performance matters,
			// so reset it to exactly 0 whenever it's close.
			if (Math.abs(changeRate) < DOUBLE_TOLERANCE) {
				
				changeRate = 0;
				
				if (changer != null)
					changer.kill();
				
			} else if (changeRate > 0) {
				distance = MAX_METER - uncover.x;
				
				if (changer != null)
					changer.kill();
				
				changer = new TweenLite(uncover, distance / changeRate,
						{x:MAX_METER, ease:Linear.easeInOut, onComplete:function():void {
							ui.preparePlayerSummon();
							
							proceed();
						} } );
			} else if (changeRate < 0 && uncover.x > MIN_METER) {
				distance = MIN_METER - uncover.x; //This value will be negative, but so is changeRate.
				
				changer = new TweenLite(uncover, distance / changeRate,
						{x:MIN_METER, ease:Linear.easeInOut} );
			}
		}
	}

}