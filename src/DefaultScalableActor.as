package src 
{
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class DefaultScalableActor extends DefaultActor implements ScalableActor
	{
		private var scale:Number;
		
		public function DefaultScalableActor(isPlayerPiece:Boolean) 
		{
			super(isPlayerPiece);	
		}
		
		override public function createSprites(isPlayerPiece:Boolean):void {
			this._sprite = new ActorSprite((isPlayerPiece) ? (0x0000FF) : (0xFF0000));
			this._miniSprite = new SmallSquareSprite((isPlayerPiece) ? (0x0000FF) : (0xFF0000));
		}
		
		public function setScale(scale:Number):void {
			this.scale = scale;
			
			this._sprite.scaleX = scale;
			this._sprite.scaleY = scale;
			
			this._miniSprite.scaleX = scale;
			this._miniSprite.scaleY = scale;
		}
		
	}

}