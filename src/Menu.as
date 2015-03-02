package src 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Menu extends Sprite 
	{
		
		public function Menu() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event):void {
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.graphics.beginFill(0xA0A0A0);
			this.graphics.drawRect(0, 0, Main.WIDTH, Main.HEIGHT);
			this.graphics.endFill();
			
			var goButton:MenuTextButton = new MenuTextButton("GO!!!!1",
					function():void { Main.switchToGame("../assets/FurElise.gws"); } );
			
			this.addChild(goButton);
			goButton.x = 100;
			goButton.y = 100;
		}
		
	}

}