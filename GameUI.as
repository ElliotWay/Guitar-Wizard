package  {
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class GameUI extends Sprite
	{
		private var musicArea:MusicArea;
		//private var mainArea:MainArea;
		//private var minimapArea:MiniMapArea;
		//private var controlArea:ControlArea;
		
		public function GameUI() 
		{
			super();
			
			musicArea = new MusicArea();
			this.addChild(musicArea);
			musicArea.x = 0; musicArea.y = 0;
		}
		
		public function loadSong(song:Song):void {
			musicArea.loadNotes(song);
		}
		
		public function go():void {
			musicArea.go();
		}
		
	}

}