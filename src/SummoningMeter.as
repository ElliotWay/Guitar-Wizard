package src 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SummoningMeter extends Sprite 
	{
		
		public static const WIDTH:int = MainArea.MINIMAP_WIDTH;
		
		public static const HEIGHT:int = 50;
		
		public static const BACKGROUND_COLOR:int = 0xFFFF00; //Yellow.
		
		public static const METER_COLOR:int = 0xB000B0; //Purple.
		
		private var ui:GameUI;
		
		private var progress:Number;
		
		private var uncover:Sprite;
		
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
			
			uncover.x = 2;
			
			
			progress = 0;
		}
		
		public function reset():void {
			progress = 0;
			
			uncover.x = 2;
		}
		
		public function increase(amount:Number):void {
			
			progress += amount;
			
			while (progress >= 100) {
				ui.preparePlayerSummon();
				
				progress -= 100;
			}
			
			uncover.x = 2 + (progress / 100) * (WIDTH - 4);
		}
		
		public function decrease(amount:Number):void {
			
			progress -= amount;
			if (progress < 0)
				progress = 0;
				
			uncover.x = 2 + (progress / 100) * (WIDTH - 4);
		}
	}

}