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
		
		//				indexed by	  type,   owner,  facing,
		private var availableSprites:Vector.<Vector.<Vector.<ReuseManager>>>;
		private var availableMiniSprites:Vector.<Vector.<ReuseManager>>;
		
		private var availableActors:Vector.<ReuseManager>;
		
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
			
			availableSprites = new Vector.<Vector.<Vector.<ReuseManager>>>(NUM_CLASSES, true);
			for (typeIndex = 0; typeIndex < NUM_CLASSES; typeIndex++) {
				availableSprites[typeIndex] = new Vector.<Vector.<ReuseManager>>(2, true);
				for (ownerIndex = 0; ownerIndex < 2; ownerIndex++) {
					availableSprites[typeIndex][ownerIndex] = new Vector.<ReuseManager>(2, true);
					for (facingIndex = 0; facingIndex < 2; facingIndex++) {
						availableSprites[typeIndex][ownerIndex][facingIndex] =
							new ReuseManager(spriteClasses[typeIndex],
								[(ownerIndex == Actor.PLAYER), (facingIndex == Actor.RIGHT_FACING)]);
					}
				}
			}
			
			availableMiniSprites = new Vector.<Vector.<ReuseManager>>(NUM_CLASSES, true);
			for (typeIndex = 0; typeIndex < NUM_CLASSES; typeIndex++) {
				availableMiniSprites[typeIndex] = new Vector.<ReuseManager>(2, true);
				for (ownerIndex = 0; ownerIndex < 2; ownerIndex++) {
					availableMiniSprites[typeIndex][ownerIndex] =
							new ReuseManager(miniSpriteClasses[typeIndex],
								[(ownerIndex == Actor.PLAYER)]);
				}
			}
			
			availableActors = new Vector.<ReuseManager>(NUM_CLASSES, true);
			for (typeIndex = 0; typeIndex < NUM_CLASSES; typeIndex++) {
				availableActors[typeIndex] = new ReuseManager(actorClasses[typeIndex]);
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
			var sprite:ActorSprite = availableSprites[actorClass][owner][facing].create();
			
			var miniSprite:MiniSprite = availableMiniSprites[actorClass][owner].create();
			
			var actor:Actor = availableActors[actorClass].create();
			
			use namespace factory;
			
			actor.restore();
			actor.setSprite(sprite);
			actor.setMiniSprite(miniSprite);
			actor.setOrientation(owner, facing);
			
			return actor;
		}
		
		/**
		 * Destroy this actor, freeing it and its sprites to be reeused.
		 * Calls the dispose method on the actor, so don't use the actor after this method.
		 * @param	actor the actor to destroy
		 */
		public function destroy(actor:Actor):void {
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
			
			availableSprites[actorClass][owner][facing].remove(actor.sprite);
			availableMiniSprites[actorClass][owner].remove(actor.miniSprite);
			
			actor.dispose(); //Important, as it dereferences the sprites.
			availableActors[actorClass].remove(actor);
		}
		
	}

}