package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class MusicArea extends Sprite 
	{
		public static const HEIGHT:int = 250;
		public static const WIDTH:int = 800;
		
		public function MusicArea() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			
			//Change this if you change the stage background.
			/*//Draw Background (there remains no "background" property so far as I'm aware)
			graphics.lineStyle(0);
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();*/
			
			//Draw 4 lines.
			graphics.lineStyle(3);
			for (var i:int = 0; i < 4; i++) {
				graphics.moveTo(0, HEIGHT * ((i + 1) / 5));
				graphics.lineTo(WIDTH, HEIGHT * ((i + 1) / 5));
			}
			
			//Draw "hit here" region
			graphics.lineStyle(0, 0, 0.0);
			graphics.beginFill(0xFFA319, 0.7);
			graphics.drawRect(25, 0, 50, HEIGHT);
			graphics.endFill();
		}
		
	}

}