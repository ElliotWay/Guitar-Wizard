package src 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.geom.Point;
	
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class MainArea extends Sprite 
	{
		
		[Embed(source = "../assets/tower.png")]
		private static const TowerImage:Class;
		
		[Embed(source = "../assets/tower_fore.png")]
		private static const TowerForeImage:Class;
		
		public static var mainArea:MainArea;
		
		public static const WIDTH:int = 600;
		public static const HEIGHT:int = Main.HEIGHT - MusicArea.HEIGHT;
		
		public static const ARENA_WIDTH:int = 2000;
		public static const SHIELD_POSITION:int = 450;
		
		public static const WIZARD_HEIGHT:int = 100;
		
		public static const END_POINT:int = 20;
		
		public static const MINIMAP_WIDTH:int = Main.WIDTH - WIDTH;
		public static const MINIMAP_HEIGHT:int = 50;
		
		public static const SCROLL_SPEED:Number = 600; //pixels per second
		
		public static const PLAYER_ACTORS:int = 1;
		public static const OPPONENT_ACTORS:int = 2;
		
		// (1 / BPM) * 60 * 1000, 500 is 120BPM
		public static const MILLISECONDS_PER_BEAT:int = 500;
		
		private static const EMPTY_ACTOR_LIST:Vector.<Actor> = new Vector.<Actor>(0, true);
		
		private var playerActors : Vector.<Actor>;
		private var opponentActors : Vector.<Actor>;
		
		private var playerWizard:Wizard;
		private var opponentWizard:Wizard;
		
		private var playerWizardKiller:Actor;
		private var opponentWizardKiller:Actor;
		
		//TODO do this better
		public static var playerShieldIsUp:Boolean;
		public static var opponentShieldIsUp:Boolean;
		
		private var projectiles:Vector.<Projectile>;
		
		private var background:Sprite;
		private var arena : Sprite;
		private var foreground:Sprite;
		
		private var scrollable:Sprite;
		private var scroller:TweenLite;
		
		private var minimap:Sprite;
		
		public function MainArea() 
		{
			mainArea = this;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.graphics.beginFill(0xD0D0FF);
			this.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			this.graphics.endFill();
			
			playerActors = new Vector.<Actor>();
			opponentActors = new Vector.<Actor>();
			
			projectiles = new Vector.<Projectile>();
			
			//prep arena
			scrollable = new Sprite();
			this.addChild(scrollable);
			
			background = new Sprite();
			scrollable.addChild(background);
			
			arena = new Sprite();
			scrollable.addChild(arena);
			
			foreground = new Sprite();
			scrollable.addChild(foreground);
			
			background.graphics.beginFill(0xB0D090);
			background.graphics.drawRect(0, 0, ARENA_WIDTH, HEIGHT);
			background.graphics.endFill();
			
			background.graphics.beginFill(0x909000);
			background.graphics.drawRect(0, Actor.Y_POSITION, ARENA_WIDTH, 3);
			
			//minimap
			minimap = new Sprite();
			this.addChild(minimap);
			
			minimap.graphics.beginFill(0xFFFFB0);
			minimap.graphics.drawRect(0, 0, MINIMAP_WIDTH, MINIMAP_HEIGHT);
			minimap.graphics.endFill();
			
			minimap.x = WIDTH;
			minimap.y = 0;
			
			scroller = null;
			
		}
		
		/**
		 * Adds the projectile to the list of projectiles, adds it to the arena,
		 * and starts the projectile moving.
		 * @param	projectile
		 */
		public function addProjectile(projectile:Projectile):void {
			
			projectiles.push(projectile);
						
			projectile.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
				projectile.go();
			});
			
			arena.addChild(projectile);
		}
		
		public function hardCode():void {
			
			var index:int;
			var actor:Actor;
			
			for (index = 0; index < 0; index++) {
				actor = new Archer(false, false);
				opponentSummon(actor);
			}
			for (index = 0; index < 2; index++) {
				actor = new Assassin(false, false);
				opponentSummon(actor);
			}
			for (index = 0; index < 0; index++) {
				actor = new Cleric(false, false);
				opponentSummon(actor);
			}
			
			for (index = 0; index < 0; index++) {
				actor = new Archer(true, true);
				playerSummon(actor);
			}
			for (index = 0; index < 0; index++) {
				actor = new Assassin(true, true);
				playerSummon(actor)
			}
			for (index = 0; index < 0; index++) {
				actor = new Cleric(true, true);
				playerSummon(actor);
			}
			
		}
		
		public function go():void {
			

			var playerShield:Shield = new Shield(true, true);
			playerShield.position();
			arena.addChild(playerShield.sprite);
			minimap.addChild(playerShield.miniSprite);
			
			playerShieldIsUp = true;
			
			var opponentShield:Shield = new Shield(false, false);
			opponentShield.position();
			arena.addChild(opponentShield.sprite);
			minimap.addChild(opponentShield.miniSprite);
			
			opponentShieldIsUp = true;
			
			playerWizard = new Wizard(true);
			playerWizard.sprite.x = 220;
			playerWizard.sprite.y = WIZARD_HEIGHT - playerWizard.sprite.height;
			arena.addChild(playerWizard.sprite);
			
			opponentWizard = new Wizard(false);
			opponentWizard.sprite.y = ARENA_WIDTH - 180;
			opponentWizard.sprite.y = WIZARD_HEIGHT - opponentWizard.sprite.height;
			arena.addChild(playerWizard.sprite);
			
			playerWizardKiller = null;
			opponentWizardKiller = null;
			
			playerActors.push(playerShield);
			opponentActors.push(opponentShield);
			
			//Set up background/foreground.
			var playerTower:Bitmap = (new TowerImage() as Bitmap);
			background.addChild(playerTower);
			playerTower.x = 0; playerTower.y = 0;
			
			var playerTowerFore:Bitmap = (new TowerForeImage() as Bitmap);
			foreground.addChild(playerTowerFore);
			playerTowerFore.x = 0; playerTowerFore.y = 0;
			
			hardCode();
			
			Main.setBeat(MILLISECONDS_PER_BEAT);
			
			Main.runEveryFrame(step);
		}
		
		
		public function stop():void {
			Main.stopRunningEveryFrame(step);
			
			var actor:Actor;
			
			for each (actor in playerActors) {
				actor.clean();
				arena.removeChild(actor.sprite);
				minimap.removeChild(actor.miniSprite);
			}
			playerActors = new Vector.<Actor>();
			
			for each (actor in opponentActors) {
				actor.clean();
				arena.removeChild(actor.sprite);
				minimap.removeChild(actor.miniSprite);
			}
			opponentActors = new Vector.<Actor>();
			
			var projectile:Projectile;
			
			for each (projectile in projectiles) {
				projectile.forceFinish();
			}
			projectiles = new Vector.<Projectile>();
			
			arena.removeChild(playerWizard.sprite);
			playerWizard = null;
			
			arena.removeChild(opponentWizard.sprite);
			opponentWizard = null;
			
			playerWizardKiller = null;
			opponentWizardKiller = null;
		}
		
		public function playerSummon(actor : Actor):void {
			var position : Number = Math.random() * (SHIELD_POSITION - 80) + 50;
			arena.addChild(actor.sprite);
			actor.setPosition(new Point(position, Actor.Y_POSITION - actor.sprite.height));
			
			actor.sprite.animate(Status.SUMMONING, function():void {
				
				minimap.addChild(actor.miniSprite);
				playerActors.push(actor);
				
				actor.go();
			});
		}
		
		public function opponentSummon(actor : Actor):void {
			var position : Number = ARENA_WIDTH - (Math.random() * (SHIELD_POSITION - 80) + 50);
			arena.addChild(actor.sprite);
			actor.setPosition(new Point(position, Actor.Y_POSITION - actor.sprite.height));
			
			actor.sprite.animate(Status.SUMMONING, function():void {
				
				minimap.addChild(actor.miniSprite);
				opponentActors.push(actor);
				
				actor.go();
			});
		}
		
		/**
		 * Prepare this actor for killing a wizard, namely, move it into position behind the wizard.
		 * @param	actor
		 */
		public function wizardKillMode(actor:Actor):void {
			trace("Kill!!!!");
			if (actor.isPlayerActor) {
				playerWizardKiller = actor;
			} else {
				opponentWizardKiller = actor;
			}
			
			actor.sprite.y = WIZARD_HEIGHT - actor.sprite.height;
			actor.retreat();
		}
		
		/**
		 * Make the player's wizard continue playing.
		 */
		public function updateWizard():void {
			playerWizard.play();
		}
		
		/**
		 * Tell all the actors to act.
		 * @param	e an enter frame event
		 */
		public function step():void {
			var actor:Actor;
			
			for each (actor in playerActors) {
				actor.act(playerActors, opponentActors);
			}
			
			for each (actor in opponentActors) {
				actor.act(opponentActors, playerActors);
			}
			
			checkProjectiles();
			updateMinimap();
			
			//Collect the dead.
			filterDead(playerActors);
			playerActors = playerActors.filter(checkAlive, this);
			
			filterDead(opponentActors);
			opponentActors = opponentActors.filter(checkAlive, this);
			
			//Check wizard killing status.
			var index:int;
			var wizardList:Vector.<Actor>;
			if (playerWizardKiller == null) {
				index = 0;
				while (index < playerActors.length) {
					if (playerActors[index].getPosition().x > ARENA_WIDTH - END_POINT) {
						wizardKillMode(playerActors[index]);
						playerActors.splice(index - 1, 1);
						break;
					}
					index++;
				}
			} else {
				wizardList = new Vector.<Actor>(1, true);
				wizardList[0] = playerWizard;
				//playerWizardKiller.act(EMPTY_ACTOR_LIST, wizardList);
			}
			
			if (opponentWizardKiller == null) {
				index = 0;
				while (index < opponentActors.length) {
					if (opponentActors[index].getPosition().x < END_POINT) {
						wizardKillMode(opponentActors[index]);
						opponentActors.splice(index, 1);
						break;
					}
					index++;
				}
			} else {
				wizardList = new Vector.<Actor>(1, true);
				wizardList[0] = opponentWizard;
				//opponentWizardKiller.act(EMPTY_ACTOR_LIST, wizardList);
			}
		}
		
		private function updateMinimap():void {
			var actor:Actor;
			for each (actor in playerActors) {
				actor.updateMiniMap();
			}
			
			for each (actor in opponentActors) {
				actor.updateMiniMap();
			}
		}
		
		/**
		 * Checks if the projectiles have hit anything.
		 */
		private function checkProjectiles():void {
			var projectile:Projectile;
			var target:Actor;
			
			for each (projectile in projectiles) {
				if ((projectile.targets & PLAYER_ACTORS) > 0) {
					for each (target in playerActors) {
						if (projectile.hitTest(target)) {
							projectile.collide(target);
						}
					}
				}
				
				if ((projectile.targets & OPPONENT_ACTORS) > 0) {
					for each (target in opponentActors) {
						if (projectile.hitTest(target)) {
							projectile.collide(target);
						}
					}
				}
				
				if (!projectile.finished) {
					projectile.askIfFinished();
				}
			}
			
			projectiles = projectiles.filter(function(projectile:Projectile, index:int, vector:Vector.<Projectile>):Boolean {
				return !projectile.finished;
			});
		}
		
		/**
		 * Finds the dead actors in the list, and removes them.
		 * That consists of removing them from the arena, removing them
		 * from the minimap, and stopping any ongoing animations.
		 * Unfortunately, because I can't pass by reference, I can't
		 * remove the dead from the list, so be sure to do that after
		 * calling this method.
		 * @param	actorList the list of actors to check
		 */
		private function filterDead(actorList:Vector.<Actor>):void {
			
			for each (var actor:Actor in actorList.filter(checkDead, this)) {
				minimap.removeChild(actor.miniSprite);
			}
		}
		
		private function checkDead(actor : Actor , index : int, vector : Vector.<Actor>) : Boolean {
			return actor.isDead;
		}
		
		private function checkAlive(actor:Actor, index:int, vector:Vector.<Actor>):Boolean {
			return !actor.isDead;
		}
		
		public function scroll(right:Boolean):void {
			if (scroller == null) {
				var distance:Number;
				if (right) {
					distance = scrollable.x - (-(ARENA_WIDTH - WIDTH));
					scroller = new TweenLite(scrollable, distance / SCROLL_SPEED, { x : -(ARENA_WIDTH - WIDTH), ease:Linear.easeInOut, onComplete:stopScrolling } );
				} else {
					distance = -scrollable.x;
					scroller = new TweenLite(scrollable, distance / SCROLL_SPEED, { x : 0, ease:Linear.easeInOut, onComplete:stopScrolling} );
				}
			}
		}
		
		public function stopScrolling():void {
			if (scroller != null) {
				scroller.kill();
				scroller = null;
			}
		}
		
	}

}