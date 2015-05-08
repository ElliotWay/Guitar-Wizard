package src 
{
	import com.greensock.TweenLite;
	/**
	 * ...
	 * @author ...
	 */
	public class Wizard extends Actor 
	{
		private var _isCompletelyDead:Boolean = false;
		
		public static function create(isPlayerPiece:Boolean):Wizard {
			return new Wizard(isPlayerPiece,
					new WizardSprite(isPlayerPiece),
					new SmallTriangleSprite(0x000060));
		}
		
		public function Wizard(playerPiece:Boolean, sprite:ActorSprite, miniSprite:MiniSprite) 
		{
			super(playerPiece, playerPiece, sprite, miniSprite);
					
					
			this._hitpoints = 1;
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
		
		/**
		 * Updates isDead. Does NOT start the dieing animation, unlike most actors.
		 * Use die to kill, then isCompletelyDead to check if the wizard has finished dieing.
		 * @param	repeater
		 */
		override public function checkIfDead(repeater:Repeater):void {
			if (_hitpoints < 0)
				_isDead = true;
		}
		
		public function die(callback:Function, repeater:Repeater):void {
			halt();
			clean();
			
			_sprite.moveToBottom();
			
			_status = Status.DYING;
			_isDead = true;
			_sprite.animate(Status.DYING, repeater, function():void {
				
				fading = new TweenLite(_sprite, 5, { tint : 0xB0D090,
				onComplete:function():void {
						_sprite.parent.removeChild(_sprite);
						clean();
						
						_isCompletelyDead = true;
						
						callback.call();
				} } );
			} );
		}
		
		/**
		 * Whether the wizard has finished dying.
		 */
		public function get isCompletelyDead():Boolean 
		{
			return _isCompletelyDead;
		}
		
		
	}

}