package src 
{
	import com.greensock.easing.ElasticOut;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Power1;
	import com.greensock.easing.Power3;
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
		 * Tolerance for comparisons between Numbers.
		 */
		public static const DOUBLE_TOLERANCE:Number = 0.0001;
		
		public static const ANIMATION_TIME:Number = 0.5; //seconds
		public static const MIN_FILL_RATE:Number = 100; //pxl/second
		
		private var ui:GameUI;
		private var overlay:DisplayObject;
		private var fill:DisplayObject;
		
		private var amountFilled:Number;
		
		private var changer:TweenLite;
		
		
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
			
			amountFilled = 0;
			
			//And the overlay is on top.
			this.addChild(overlay);
		}
		
		/**
		 * Stop the meter moving and set the amount filled to 0.
		 */
		public function reset():void {
			if (changer != null)
				changer.kill();
			
			fill.y = minMeter;
			amountFilled = 0;
		}
		
		/**
		 * Add to the amount in the summoning meter.
		 * @param	amount portion out of 100 to fill the summoning meter
		 */
		public function increase(amount:Number):void {
			amountFilled += amount;
			
			proceed();
		}
		
		/**
		 * Remove from the amount in the summoning meter.
		 * @param	amount portion out of 100 to remove from the summoning meter
		 */
		public function decrease(amount:Number):void {
			amountFilled -= amount;
			
			proceed();
		}
		
		
		private function proceed():void {
			
			var distance:Number;
			
			if (changer != null)
				changer.kill();
				
			var targetY:Number = minMeter - (amountFilled / 100) * meterLength;
			if (amountFilled >= 100)
				targetY = maxMeter;
			else if (amountFilled <= 0)
				targetY = minMeter;
			
			var time:Number = Math.min(ANIMATION_TIME, Math.abs(targetY - fill.y) / MIN_FILL_RATE);
			
			if (amountFilled >= 100) {
				changer = new TweenLite(fill, time,
						{y:maxMeter, ease:Linear.easeInOut, onComplete:finishMeter } );
				
			} else if (amountFilled <= 0) {
				amountFilled = 0;
				changer = new TweenLite(fill, time,
						{y:minMeter, ease:Power1.easeOut } );
				
			} else {
				if (Math.abs(targetY - fill.y) >= DOUBLE_TOLERANCE) {
					changer = new TweenLite(fill, time,
							{y:targetY, ease:Power1.easeOut } );
				}
			}
		}
		
		private function finishMeter():void {
			ui.preparePlayerSummon();
			
			amountFilled -= 100;
			fill.y = minMeter;
			
			proceed();
		}
	}

}