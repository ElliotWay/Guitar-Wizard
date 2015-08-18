package src 
{
	import com.greensock.easing.Ease;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.ElasticInOut;
	import com.greensock.easing.ElasticOut;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Power2;
	import com.greensock.easing.Power4;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	
	public class ScrollArea extends Sprite 
	{
		public static const SCROLL_SPEED:Number = 600; //pixels per second
		
		public static const SCROLL_TO_DURATION:Number = 3; //seconds
		
		public static const JUMP_DURATION:Number = 0.5;
		
		private var scroller:TweenLite;
		
		private var maxScroll:Number;
		private var onScroll:Function;
		
		/**
		 * Whether the ScrollArea is currently scrolling.
		 */
		public function get isScrolling():Boolean {
			return !(scroller == null);
		}
		
		/**
		 * Create a new scrollable area.
		 * @param	maxScroll the rightmost point of the scroll.
		 * @param   onScroll function to call every time the x position changes.
		 * 		The function should be func(x) where x is the current x position.
		 */
		public function ScrollArea(maxScroll:Number, onScroll:Function) 
		{
			this.maxScroll = maxScroll;
			this.onScroll = onScroll;
		}
		
		/**
		 * Start scrolling right at a constant rate. Call stopScrolling or any other scroll function to stop.
		 * This stops automatically if it reachs the rightmost position.
		 */
		public function scrollRight():void {
			if (scroller != null)
				scroller.kill();
				
			var distance:Number = this.x + maxScroll; //Remember that x is negative here.
			scroller = new TweenLite(this, distance / SCROLL_SPEED,
					{ x : -maxScroll, ease:Linear.easeInOut, onComplete:stopScrolling } );
		}
		
		/**
		 * Start scrolling left at a constant rate. Call stopScrolling or any other scroll function to stop.
		 * This stops automatically if it reachs the leftmost position.
		 */
		public function scrollLeft():void {
			if (scroller != null)
				scroller.kill();
				
			var distance:Number = -this.x;
			scroller =  new TweenLite(this, distance / SCROLL_SPEED,
					{ x : 0, ease:Linear.easeInOut, onComplete:stopScrolling} );
		}
		
		/**
		 * Stop scrolling immediately. Does nothing if not already scrolling.
		 */
		public function stopScrolling():void {
			if (scroller != null) {
				scroller.kill();
				scroller = null;
			}
		}
		
		/**
		 * Gently scroll to the desired position over SCROLL_TO_DURATION.
		 * @param	position the position to scroll to
		 */
		public function scrollTo(position:int):void {
			if (position > maxScroll)
				position = maxScroll;
			else if (position < 0)
				position = 0;
			
			var distance:Number = Math.abs(this.x + position); // - -position
			if (this.isScrolling) {
				scroller =  new TweenLite(this, SCROLL_TO_DURATION,
					{ x : -position, ease:ElasticOut, onComplete:stopScrolling} );
			} else {
				scroller =  new TweenLite(this, SCROLL_TO_DURATION,
					{ x : -position, ease:ElasticInOut, onComplete:stopScrolling} );
			}
		}
		
		/**
		 * Scroll quickly to the rightmost position over JUMP_DURATION.
		 * This can be interrupted with stopScrolling or any other scroll function.
		 */
		public function jumpRight():void {
			if (scroller != null)
				scroller.kill();
				
			scroller = new TweenLite(this, JUMP_DURATION,
				{ x : -maxScroll, ease:Linear.easeInOut, onComplete:stopScrolling } );
		}
		
		/**
		 * Scroll quickly to the leftmost position over JUMP_DURATION.
		 * This can be interrupted with stopScrolling or any other scroll function.
		 */
		public function jumpLeft():void {
			if (scroller != null)
				scroller.kill();
				
			scroller = new TweenLite(this, JUMP_DURATION,
				{ x : 0, ease:Linear.easeInOut, onComplete:stopScrolling } );
		}
		
		override public function set x(num:Number):void {
			super.x = num;
			onScroll.call(null, num);
		}
	}
	

}