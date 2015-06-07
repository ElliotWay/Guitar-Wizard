package src 
{
	/**
	 * ...
	 * @author ...
	 */
	public class NoteSpriteFactory 
	{
		private static const PREPOPULATE_AMOUNT:int = 200;
		
		private var availableNoteSprites:Vector.<ReuseManager>;
		
		public function NoteSpriteFactory() 
		{
			availableNoteSprites = new Vector.<ReuseManager>(4, true);
			
			//	A	0
			//	S	1
			//	D	2
			//	F	3
			// (see Note.as)
			
			for (var index:int = 0; index < 4; index++) {
				availableNoteSprites[index] = new ReuseManager(NoteSprite, [index]);
				availableNoteSprites[index].prepopulate(PREPOPULATE_AMOUNT);
			}
		}
		
		/**
		 * Create a new NoteSprite to reflect the given Note.
		 * @param	note the Note the sprite will represent
		 * @return  the created NoteSprite
		 */
		public function create(note:Note):NoteSprite {
			var sprite:NoteSprite = availableNoteSprites[note.letter].create();
			
			use namespace factory;
			sprite.setAssociatedNote(note);
			sprite.restore();
			
			return sprite;
		}
		
		/**
		 * Destroy the sprite, freeing it to be reeused later.
		 * Dissociates the sprite from the note.
		 * @param	sprite the sprite to destory
		 */
		public function destroy(sprite:NoteSprite):void {
			availableNoteSprites[sprite.letter].remove(sprite);
			sprite.dissociate();
		}
		
	}

}