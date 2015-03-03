package src 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MenuTextButton extends Sprite 
	{
		
		private var onClick:Function;
		private var onClickArgs:Array;
		
		private var normal:TextField;
		private var rollover:TextField;
		private var pressed:TextField;
		
		public function MenuTextButton(text:String, onClick:Function, ... onClickArgs) 
		{
			this.onClick = onClick;
			this.onClickArgs = onClickArgs;
			
			normal = new TextField();
			this.addChild(normal);
			normal.width = 1000;
			normal.text = text;
			var normalText:TextFormat = new TextFormat("Garamond, _serif", 100, 0x0040FF);
			normal.setTextFormat(normalText);
			normal.visible = true;
			
			rollover = new TextField();
			this.addChild(rollover);
			rollover.width = 1000;
			rollover.text = text;
			var rolloverText:TextFormat = new TextFormat("Garamond, _serif", 100, 0xFFFFFF);
			rollover.setTextFormat(rolloverText);
			rollover.visible = false;
			
			pressed = new TextField();
			this.addChild(pressed);
			pressed.width = 1000;
			pressed.text = text;
			var pressedText:TextFormat = new TextFormat("Garamond, _serif", 100, 0xF0F0A0);
			pressed.setTextFormat(pressedText);
			pressed.visible = false;
			
			this.addEventListener(MouseEvent.ROLL_OVER, setRollover);
			this.addEventListener(MouseEvent.ROLL_OUT, setNormal);
			this.addEventListener(MouseEvent.MOUSE_DOWN, setPressed);
			this.addEventListener(MouseEvent.MOUSE_UP, doThing);
		}
		
		public function setRollover(e:Event):void {
			Mouse.cursor = MouseCursor.BUTTON;
			
			normal.visible = false;
			pressed.visible = false;
			
			rollover.visible = true;
		}
		
		public function setNormal(e:Event):void {
			Mouse.cursor = MouseCursor.AUTO;
			
			rollover.visible = false;
			pressed.visible = false;
			
			normal.visible = true;
		}
		
		public function setPressed(e:Event):void {
			normal.visible = false;
			rollover.visible = false;
			
			pressed.visible = true;
		}
		
		public function doThing(e:Event):void {
			onClick.apply(null, onClickArgs);
		}
		
	}

}