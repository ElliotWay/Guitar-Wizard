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
			
			var song1Button:MenuTextButton = new MenuTextButton("Fur Elise",
					function():void { Main.switchToGame(1); } );
			var song2Button:MenuTextButton = new MenuTextButton("Moonlight Sonata",
					function():void { Main.switchToGame(2); } );
			
			this.addChild(song1Button);
			song1Button.x = 100;
			song1Button.y = 100;
			this.addChild(song2Button);
			song2Button.x = 100;
			song2Button.y = 300;
		}
		
	}

}