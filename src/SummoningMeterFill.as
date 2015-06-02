package src 
{
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	TweenPlugin.activate([ColorTransformPlugin]);
	
	/**
	 * ...
	 * @author ...
	 */
	public class SummoningMeterFill extends Sprite 
	{
		private var background:Shape;
		
		private var colorTransition:TweenLite;
		
		public function SummoningMeterFill(width:int, height:int, repeater:Repeater)
		{
			background = new Shape();
			background.graphics.beginFill(MusicArea.MID_COLOR);
			background.graphics.drawRect(0, 0, width, height);
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.addChild(background);
		}
		
		public function changeColor(newColor:uint, delay:Number):void {
			if (colorTransition != null)
				colorTransition.kill();
				
												//Half of delay, converted to seconds.
			/*colorTransition = new TweenLite(background, delay / 2000, 
					{delay:delay / 2000, tint:newColor } );*/
			colorTransition = new TweenLite(background, delay / 1000, 
					{ease:Quad.easeIn, tint:newColor } );

		}
		
	}

}