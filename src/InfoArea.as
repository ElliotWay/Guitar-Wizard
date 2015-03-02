package src 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class InfoArea extends Sprite 
	{
		/**
		 * Time in milliseconds before the info area clears itself.
		 */
		public static const CLEAR_TIME:Number = 2000;
		
		public static const HEIGHT:int = 200;
		
		private var text:TextField;
		
		private var clearTimer:Timer;
		
		public function InfoArea() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			text = new TextField();
			this.addChild(text);
			
			text.multiline = true;
			text.wordWrap = true;
			
			text.width = MainArea.MINIMAP_WIDTH;
			text.height = HEIGHT;
			
			text.background = true;
			text.backgroundColor = 0xA0A0A0;
			
			var textFormat:TextFormat = new TextFormat("Times New Roman, _sans", 20, 0x0);
			text.defaultTextFormat = textFormat;
			
			text.text = "Starting Text";
		}
		
		public function displayText(message:String):void {
			text.text = message;
			
			if (clearTimer != null)
				clearTimer.stop();
				
			clearTimer = new Timer(CLEAR_TIME, 1);
			clearTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
				text.text = "";
				clearTimer = null;
			});
			clearTimer.start();
		}
		
	}

}