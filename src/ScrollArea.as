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
		
		public function get isScrolling():Boolean {
			return !(scroller == null);
		}
		
		public function ScrollArea(maxScroll:Number) 
		{
			this.maxScroll = maxScroll;
		}
		
		public function scrollRight():void {
			if (scroller != null)
				scroller.kill();
				
			var distance:Number = this.x + maxScroll; //Remember that x is negative here.
			scroller = new TweenLite(this, distance / SCROLL_SPEED,
					{ x : -maxScroll, ease:Linear.easeInOut, onComplete:stopScrolling } );
		}
		
		public function scrollLeft():void {
			if (scroller != null)
				scroller.kill();
				
			var distance:Number = -this.x;
			scroller =  new TweenLite(this, distance / SCROLL_SPEED,
					{ x : 0, ease:Linear.easeInOut, onComplete:stopScrolling} );
		}
		
		public function stopScrolling():void {
			if (scroller != null) {
				scroller.kill();
				scroller = null;
			}
		}
		
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
		
		public function jumpRight():void {
			if (scroller != null)
				scroller.kill();
				
			scroller = new TweenLite(this, JUMP_DURATION,
				{ x : -maxScroll, ease:Linear.easeInOut, onComplete:stopScrolling } );
		}
		
		public function jumpLeft():void {
			if (scroller != null)
				scroller.kill();
				
			scroller = new TweenLite(this, JUMP_DURATION,
				{ x : 0, ease:Linear.easeInOut, onComplete:stopScrolling } );
		}
	}
	

}