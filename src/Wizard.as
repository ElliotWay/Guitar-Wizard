package src 
{
	import com.greensock.TweenLite;
	/**
	 * ...
	 * @author ...
	 */
	public class Wizard extends Actor 
	{
		
		public function Wizard() 
		{
			super();
		}
		
		override protected function get speed():int {
			return 0; //Hopefully wizards aren't asked to move at all, but if they are,
						//they should stand still.
		}
		
		override protected function get maxHP():int {
			return 1; //Wizards die immediately when they're hit.
		}
		
		override public function act(allies:Vector.<Actor>, enemies:Vector.<Actor>, repeater:Repeater):void {
			throw new Error("Error: wizards shouldn't be in the acting list");
		}
		
		public function play():void {
			if (_status == Status.PLAY_MID) {
				_sprite.step();
			}
		}
		
		public function playTrack(track:int, repeater:Repeater):void {
			if (!this.isDead) {
				switch(track) {
					case Main.HIGH:
						_status = Status.PLAY_HIGH;
						break;
					case Main.MID:
						_status = Status.PLAY_MID;
						break;
					case Main.LOW:
						_status = Status.PLAY_LOW;
				}
				
				_sprite.animate(_status, repeater);
			}
		}
	}

}