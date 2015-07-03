package src 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * The boundary between the 3 other major interface elements
	 * (the music area, the main area and the summoning meter).
	 * (TODO) Pulse to do a nice animation (multiple pulses can exist at once).
	 */
	public class Border extends Sprite 
	{
		public static const BOUNDARY_COLOR:uint = 0xB7B7B7; // a light gray
		public static const FILL_COLOR:uint = 0xA0A0A0; // a darker gray
		
		public static const WIDTH:int = 20;
		public static const SMALL_WIDTH:int = 14;
		
		public function Border() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Between MusicArea and MainArea.
			this.graphics.beginFill(FILL_COLOR);
			this.graphics.lineStyle(4, BOUNDARY_COLOR);
			this.graphics.moveTo(-3, MusicArea.HEIGHT - 1.5 * WIDTH);
			this.graphics.curveTo(WIDTH / 3, MusicArea.HEIGHT  - WIDTH / 4,
								3*WIDTH, MusicArea.HEIGHT);
			this.graphics.lineTo(Main.WIDTH + 5, MusicArea.HEIGHT);
			this.graphics.lineTo(Main.WIDTH + 5, MusicArea.HEIGHT + WIDTH);
			this.graphics.lineTo(3*WIDTH, MusicArea.HEIGHT + WIDTH);
			this.graphics.curveTo(WIDTH / 3, MusicArea.HEIGHT + WIDTH + WIDTH / 4,
								-3, MusicArea.HEIGHT + 2.5*WIDTH);
			this.graphics.lineTo( -3, MusicArea.HEIGHT - 1.5 * WIDTH);
			this.graphics.endFill();
			
			//Between MainArea and SummoningMeter.
			this.graphics.beginFill(FILL_COLOR);
			this.graphics.lineStyle(3, BOUNDARY_COLOR);
			this.graphics.moveTo(MainArea.WIDTH, MusicArea.HEIGHT + WIDTH);
			this.graphics.lineTo(MainArea.WIDTH, Main.HEIGHT + 5);
			this.graphics.lineTo(MainArea.WIDTH + SMALL_WIDTH, Main.HEIGHT + 5);
			this.graphics.lineTo(MainArea.WIDTH + SMALL_WIDTH, MusicArea.HEIGHT + WIDTH);
			this.graphics.endFill();
			
			this.cacheAsBitmap = true;
		}
	}

}