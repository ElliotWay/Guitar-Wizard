package src
{
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author ...
	 */
	public class ActorFactory 
	{
		public static const ARCHER:int = 0;
		public static const ASSASSIN:int = 1;
		public static const CLERIC:int = 2;
		public static const SHIELD:int = 3;
		public static const WIZARD:int = 4;
		
		private static const NUM_CLASSES:int = 5;
		
		private var actorClasses:Vector.<Class>;
		private var spriteClasses:Vector.<Class>;
		private var miniSpriteClasses:Vector.<Class>;
		
		//				indexed by	  type,   owner,  facing, (num available)
		private var availableSprites:Vector.<Vector.<Vector.<Vector.<ActorSprite>>>>;
		private var availableMiniSprites:Vector.<Vector.<Vector.<Vector.<MiniSprite>>>>;
		
		/**
		 * Create a factory through which to create actor classes. This class manages object reuse;
		 * sprites don't change so it's better to reuse them when creating new actors.
		 */
		public function ActorFactory() 
		{
			actorClasses = new Vector.<Class>(NUM_CLASSES, true);
			actorClasses[ARCHER] = Archer;
			actorClasses[ASSASSIN] = Assassin;
			actorClasses[CLERIC] = Cleric;
			actorClasses[SHIELD] = Shield;
			actorClasses[WIZARD] = Wizard;
			
			spriteClasses = new Vector.<Class>(NUM_CLASSES, true);
			spriteClasses[ARCHER] = ArcherSprite;
			spriteClasses[ASSASSIN] = AssassinSprite;
			spriteClasses[CLERIC] = ClericSprite;
			spriteClasses[SHIELD] = ShieldSprite;
			spriteClasses[WIZARD] = WizardSprite;
			
			miniSpriteClasses = new Vector.<Class>(NUM_CLASSES, true);
			miniSpriteClasses[ARCHER] = SmallTriangleSprite;
			miniSpriteClasses[ASSASSIN] = SmallSquareSprite;
			miniSpriteClasses[CLERIC] = SmallCircleSprite;
			miniSpriteClasses[SHIELD] = ThinLineSprite;
			miniSpriteClasses[WIZARD] = WizardMiniSprite;
			
			
			var typeIndex:int, ownerIndex:int, facingIndex:int;
			
			availableSprites = new Vector.<Vector.<Vector.<Vector.<ActorSprite>>>>(NUM_CLASSES, false);
			for (typeIndex = 0; typeIndex < NUM_CLASSES; typeIndex++) {
				availableSprites[typeIndex] = new Vector.<Vector.<Vector.<ActorSprite>>>(2, true);
				for (ownerIndex = 0; ownerIndex < 2; ownerIndex++) {
					availableSprites[typeIndex][ownerIndex] = new Vector.<Vector.<ActorSprite>>(2, true);
					for (facingIndex = 0; facingIndex < 2; facingIndex++) {
						availableSprites[typeIndex][ownerIndex][facingIndex]
							= new Vector.<ActorSprite>();
					}
				}
			}
			
			availableMiniSprites = new Vector.<Vector.<Vector.<Vector.<MiniSprite>>>>(NUM_CLASSES, false);
			for (typeIndex = 0; typeIndex < NUM_CLASSES; typeIndex++) {
				availableMiniSprites[typeIndex] = new Vector.<Vector.<Vector.<MiniSprite>>>(2, true);
				for (ownerIndex = 0; ownerIndex < 2; ownerIndex++) {
					availableMiniSprites[typeIndex][ownerIndex] = new Vector.<Vector.<MiniSprite>>(2, true);
					for (facingIndex = 0; facingIndex < 2; facingIndex++) {
						availableMiniSprites[typeIndex][ownerIndex][facingIndex]
							= new Vector.<MiniSprite>();
					}
				}
			}
		}
		
		/**
		 * Create an actor with the specified parameters.
		 * @param	actorClass class of the actor to create, use ActorFactory constants
		 * @param	owner owner of the actor, use Actor constants
		 * @param	facing direction the actor faces, use Actor constants
		 * @return  the newly created actor
		 */
		public function create(actorClass:int, owner:int, facing:int):Actor {
			var sprite:ActorSprite, miniSprite:MiniSprite;
			trace("CREATE: " + availableSprites[actorClass][owner][facing].length + " sprites available.");
			if (availableSprites[actorClass][owner][facing].length > 0) {
				sprite = availableSprites[actorClass][owner][facing].pop();
			} else {
				sprite = new spriteClasses[actorClass](owner == Actor.PLAYER, facing == Actor.RIGHT_FACING);
			}
			
			if (availableMiniSprites[actorClass][owner][facing].length > 0) {
				miniSprite = availableMiniSprites[actorClass][owner][facing].pop();
			} else {
				miniSprite = new miniSpriteClasses[actorClass](owner == Actor.PLAYER);
			}
			
			return new actorClasses[actorClass](owner == Actor.PLAYER, facing == Actor.RIGHT_FACING,
					sprite, miniSprite);
		}
		
		/**
		 * Destroy this actor, freeing its sprites to be reeused.
		 * Calls the dispose method on the actor, so don't use the actor after this method.
		 * @param	actor the actor to destroy
		 * @param   repeater damn if i'm not regetting leaving this thing global static right now
		 */
		public function destroy(actor:Actor, repeater:Repeater):void {
			var actorClass:int = -1, owner:int, facing:int;
			
			if (actor is Archer) {
				actorClass = ARCHER;
			} else if (actor is Assassin) {
				actorClass = ASSASSIN;
			} else if (actor is Cleric) {
				actorClass = CLERIC;
			} else if (actor is Shield) {
				actorClass = SHIELD;
			} else if (actor is Wizard) {
				actorClass = WIZARD;
			}
			
			owner = actor.isPlayerActor ? Actor.PLAYER : Actor.OPPONENT;
			
			facing = actor.facesRight ? Actor.RIGHT_FACING : Actor.LEFT_FACING;
			
			availableSprites[actorClass][owner][facing].push(actor.sprite);
			availableMiniSprites[actorClass][owner][facing].push(actor.miniSprite);
			trace("DESTROY: " + availableSprites[actorClass][owner][facing].length + " sprites available.");
			actor.dispose(repeater);
		}
		
	}

}