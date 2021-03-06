package src 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author ...
	 */
	public class Shield extends Actor 
	{
		public static const MAX_HP:int = 200;
		
		public function Shield() 
		{
			super();
		}
		
		override protected function get speed():int {
			return 0;
		}
		
		override protected function get maxHP():int {
			return MAX_HP;
		}
		
		/**
		 * Shields can have infinite attackers.
		 */
		override public function get isAttackLocked():Boolean {
			return false;
		}
		
		override public function act(allies:Vector.<Actor>, enemies:Vector.<Actor>, repeater:Repeater):void {
			//Do nothing.
		}
		
		override public function checkIfDead(repeater:Repeater, afterDead:Function = null):void {
			super.checkIfDead(repeater, afterDead);
			
			if (isDead) {
				if (isPlayerPiece) {
					MainArea.playerShieldIsUp = false;
				} else {
					MainArea.opponentShieldIsUp = false;
				}
			}
		}
		
		/**
		 * Always allow locking an attack; ie don't throw an exception if already locked.
		 */
		override protected function lockAttack():void {
			;
		}
		
		/**
		 * Position the shield in its correct starting position and tell it to stand there.
		 */
		public function position(repeater:Repeater):void {
			if (isPlayerPiece) {
				_sprite.x = MainArea.SHIELD_POSITION - _sprite.width;
			} else {
				_sprite.x = MainArea.ARENA_WIDTH - MainArea.SHIELD_POSITION;
			}
			
			_sprite.animate(Status.STANDING, repeater);
			
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