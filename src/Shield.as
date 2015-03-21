package src 
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import util.LinkedList;
	/**
	 * ...
	 * @author ...
	 */
	public class Shield extends Actor 
	{
		
		public function Shield(playerPiece:Boolean, facesRight:Boolean) 
		{
			super(playerPiece, facesRight,
					new ShieldSprite(playerPiece, facesRight),
					new ThinLineSprite(0x00FFFF));
			
			this.speed = 0;
			this._hitpoints = 200;
		}
		
		override public function act(allies:LinkedList, enemies:LinkedList):void {
			//Do nothing.
			
			checkIfDead();
			
			if (isDead) {
				if (isPlayerPiece) {
					MainArea.playerShieldIsUp = false;
				} else {
					MainArea.opponentShieldIsUp = false;
				}
			}
		}
		
		/**
		 * Position the shield in its correct starting position.
		 */
		public function position():void {
			if (isPlayerPiece) {
				_sprite.x = MainArea.SHIELD_POSITION - _sprite.width;
			} else {
				_sprite.x = MainArea.ARENA_WIDTH - MainArea.SHIELD_POSITION;
			}
			
			_sprite.y = Actor.Y_POSITION - _sprite.height + 30;
		}
		
		public function intersects(thing:DisplayObject):Boolean {
			//TODO rewrite when you have a better shield sprite
			
			var rect:Rectangle = thing.getBounds(_sprite);
			
			if (isPlayerPiece) {
				return rect.left * (ShieldSprite.FRAME_HEIGHT / ShieldSprite.FRAME_WIDTH) <
						rect.bottom;
			} else {
				return rect.right * ( -ShieldSprite.FRAME_HEIGHT / ShieldSprite.FRAME_WIDTH) + ShieldSprite.FRAME_HEIGHT <
						rect.bottom;
			}
		}
	}

}