package src 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	
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
		
		[Embed(source="../assets/tower_flipped.png")]
		private static const TowerFlippedImage:Class;
		
		[Embed(source="../assets/tower_fore_flipped.png")]
		private static const TowerForeFlippedImage:Class;
		
		public static var mainArea:MainArea;
		
		public static const WIDTH:int = 600;
		public static const HEIGHT:int = Main.HEIGHT - MusicArea.HEIGHT;
		
		public static const ARENA_WIDTH:int = 2000;
		public static const SHIELD_POSITION:int = 450;
		
		public static const WIZARD_HEIGHT:int = 100;
		
		public static const WIZARD_KILL_DELAY:int = 1000;
		
		public static const SUMMONING_LINE_DURATION:int = 300;
		
		public static const END_POINT:int = 30;
		
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
		private var playerWizardKillerTimer:Timer;
		private var opponentWizardKiller:Actor;
		private var opponentWizardKillerTimer:Timer;
		
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
			for (index = 0; index < 0; index++) {
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
		
		public function go(playerWizard:Wizard, opponentWizard:Wizard):void {
			

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
			
			this.playerWizard = playerWizard;
			playerWizard.sprite.x = 220;
			playerWizard.sprite.y = WIZARD_HEIGHT - playerWizard.sprite.height;
			arena.addChild(playerWizard.sprite);
			
			this.opponentWizard = opponentWizard;
			opponentWizard.sprite.x = ARENA_WIDTH - 270;
			opponentWizard.sprite.y = WIZARD_HEIGHT - opponentWizard.sprite.height;
			arena.addChild(opponentWizard.sprite);
			
			playerWizardKiller = null;
			playerWizardKillerTimer = null;
			opponentWizardKiller = null;
			opponentWizardKillerTimer = null;
			
			playerActors.push(playerShield);
			opponentActors.push(opponentShield);
			
			//Set up background/foreground.
			var playerTower:Bitmap = (new TowerImage() as Bitmap);
			background.addChild(playerTower);
			playerTower.x = 0; playerTower.y = 0;
			
			var playerTowerFore:Bitmap = (new TowerForeImage() as Bitmap);
			foreground.addChild(playerTowerFore);
			playerTowerFore.x = 0; playerTowerFore.y = 0;
			
			var opponentTower:Bitmap = (new TowerFlippedImage() as Bitmap);
			background.addChild(opponentTower);
			opponentTower.x = ARENA_WIDTH - opponentTower.width; opponentTower.y = 0;
			
			var opponentTowerFore:Bitmap = (new TowerForeFlippedImage() as Bitmap);
			foreground.addChild(opponentTowerFore);
			opponentTowerFore.x = ARENA_WIDTH - opponentTowerFore.width; opponentTowerFore.y = 0;
			
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
			if (playerWizardKillerTimer != null) {
				playerWizardKillerTimer.stop();
				playerWizardKillerTimer = null;
			}
			opponentWizardKiller = null;
			if (opponentWizardKillerTimer != null) {
				opponentWizardKillerTimer.stop();
				opponentWizardKillerTimer = null;
			}
		}
		
		public function playerSummon(actor : Actor):void {
			var position : Number = Math.random() * (SHIELD_POSITION - 80) + 50;
			arena.addChild(actor.sprite);
			actor.setPosition(new Point(position, Actor.Y_POSITION - actor.sprite.height));
			
			createSummoningLine(actor, playerWizard);
			
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
			
			createSummoningLine(actor, opponentWizard);
			
			actor.sprite.animate(Status.SUMMONING, function():void {
				
				minimap.addChild(actor.miniSprite);
				opponentActors.push(actor);
				
				actor.go();
			});
		}
		
		private function createSummoningLine(actor:Actor, wizard:Wizard):void {
			var line:Shape = new Shape();
			
			var wizardPoint:Point = wizard.getPosition();
			var actorPoint:Point = actor.getPosition();
			
			line.graphics.lineStyle(3, 0xB5FFFC);
			line.graphics.moveTo(wizardPoint.x, wizardPoint.y);
			line.graphics.lineTo(actorPoint.x, actorPoint.y);
			
			foreground.addChild(line);
			
			var removeLine:Function = function(event:Event):void {
				foreground.removeChild(line);
				(event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, removeLine);
			}
			var timer:Timer = new Timer(SUMMONING_LINE_DURATION, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, removeLine);
			timer.start();
		}
		
		/**
		 * Prepare this actor for killing a wizard, namely, move it into position behind the wizard.
		 * @param	actor
		 */
		public function wizardKillMode(actor:Actor):void {
			arena.removeChild(actor.sprite);
			minimap.removeChild(actor.miniSprite);
			
			//TODO kill actor?
			
			var actorClass:Class;
			if (actor is Archer)
				actorClass = Archer;
			else if (actor is Assassin)
				actorClass = Assassin;
			else
				actorClass = Cleric;
			
			var wizardKiller:Actor = new actorClass(actor.isPlayerActor, !actor.isPlayerActor);
			
			
			wizardKiller.sprite.y = WIZARD_HEIGHT - actor.sprite.height;
			
			if (actor.isPlayerActor) {
				playerWizardKiller = wizardKiller;
				wizardKiller.sprite.x = ARENA_WIDTH + 100;
				
				playerWizardKillerTimer = new Timer(WIZARD_KILL_DELAY, 1);
				playerWizardKillerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					arena.addChild(wizardKiller.sprite);
					wizardKiller.go();
					
					playerWizardKillerTimer = null;
				});
				playerWizardKillerTimer.start();
				
			} else {
				opponentWizardKiller = wizardKiller;
				wizardKiller.sprite.x = -100 - wizardKiller.sprite.width;
				
				opponentWizardKillerTimer = new Timer(WIZARD_KILL_DELAY, 1);
				opponentWizardKillerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					arena.addChild(wizardKiller.sprite);
					wizardKiller.go();
					
					opponentWizardKillerTimer = null;
				});
				opponentWizardKillerTimer.start();
			}
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
				wizardList[0] = opponentWizard;
				playerWizardKiller.act(EMPTY_ACTOR_LIST, wizardList);
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
				wizardList[0] = playerWizard;
				opponentWizardKiller.act(EMPTY_ACTOR_LIST, wizardList);
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