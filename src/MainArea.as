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
	import mx.controls.List;
	import util.LinkedList;
	import util.ListIterator;
	
	
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
		
		
		public static const PLAYER_ACTORS:int = 1;
		public static const OPPONENT_ACTORS:int = 2;
		
		// (1 / BPM) * 60 * 1000, 500 is 120BPM
		public static const MILLISECONDS_PER_BEAT:int = 450; //500
		
		private static const EMPTY_ACTOR_LIST:LinkedList = new LinkedList(Actor);
		
		private static const AUTO_SCROLL_DELAY:int = 3000;
		private static const REPEATED_SCROLL_DELAY:int = 3000;
		
		private var playerActors:LinkedList;
		private var opponentActors:LinkedList;
		
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
		
		private var scrollable:ScrollArea;
		private var autoScrollTimer:Timer;
		private var repeatedScrollTimer:Timer;
		
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
			
			playerActors = new LinkedList(Actor);
			opponentActors = new LinkedList(Actor);
			
			projectiles = new Vector.<Projectile>();
			
			//prep arena
			scrollable = new ScrollArea(ARENA_WIDTH - WIDTH);
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
			
			autoScrollTimer = new Timer(AUTO_SCROLL_DELAY, 1);
			autoScrollTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
				repeatedScrollTimer.start();
			});
			
			repeatedScrollTimer = new Timer(REPEATED_SCROLL_DELAY, 0);
			repeatedScrollTimer.addEventListener(TimerEvent.TIMER, function():void {
				var rightMost:Number = 0;
				
				var actor:Actor;
				var iter:ListIterator = playerActors.head();
				while (iter.hasNext()) {
					actor = iter.next();
					if (!(actor is Shield) && actor.sprite.x > rightMost)
						rightMost = actor.sprite.x;
				}
				
				scrollable.scrollTo(rightMost - WIDTH / 3);
			});
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
			playerWizard.sprite.x = 170;
			playerWizard.sprite.y = WIZARD_HEIGHT - playerWizard.sprite.height;
			arena.addChild(playerWizard.sprite);
			playerWizard.playTrack(Main.MID);
			
			this.opponentWizard = opponentWizard;
			opponentWizard.sprite.x = ARENA_WIDTH - 220;
			opponentWizard.sprite.y = WIZARD_HEIGHT - opponentWizard.sprite.height;
			arena.addChild(opponentWizard.sprite);
			opponentWizard.playTrack(Main.MID);
			
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
			
			autoScrollTimer.start();
			
			Main.setBeat(MILLISECONDS_PER_BEAT);
			
			Main.runEveryFrame(step);
		}
		
		
		public function stop():void {
			Main.stopRunningEveryFrame(step);
			
			var actor:Actor;
			
			var iter:ListIterator = playerActors.head();
			while (iter.hasNext()) {
				actor = iter.next();
				
				actor.clean();
				arena.removeChild(actor.sprite);
				minimap.removeChild(actor.miniSprite);
			}
			playerActors = new LinkedList(Actor);
			
			iter = opponentActors.head();
			while (iter.hasNext()) {
				actor = iter.next();
				
				actor.clean();
				arena.removeChild(actor.sprite);
				minimap.removeChild(actor.miniSprite);
			}
			opponentActors = new LinkedList(Actor);
			
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
			
			autoScrollTimer.stop();
			repeatedScrollTimer.stop();
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
			trace(actor.isDead);
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
			
			//trace("player: " + playerActors);
			//trace("opponent: " + opponentActors);
			
			var iter:ListIterator = playerActors.head();
			while (iter.hasNext()) {
				actor = iter.next();
				actor.act(playerActors, opponentActors);
			}
			
			iter = opponentActors.head();
			while (iter.hasNext()) {
				actor = iter.next();
				actor.act(opponentActors, playerActors);
			}
			
			checkProjectiles();
			updateMinimap();
			
			//Collect the dead.
			iter = playerActors.head();
			while (iter.hasNext()) {
				actor = iter.next();
				if (actor.isDead) {
					minimap.removeChild(actor.miniSprite);
					
					iter.remove();
				}
			}
			
			iter = opponentActors.head();
			while (iter.hasNext()) {
				actor = iter.next();
				if (actor.isDead) {
					minimap.removeChild(actor.miniSprite);
					
					iter.remove();
				}
			}
			
			//Collect actors that have reached the edge.
			iter = playerActors.head();
			while (iter.hasNext()) {
				actor = iter.next();
				
				if (actor.getPosition().x > ARENA_WIDTH - END_POINT) {
					iter.remove();
					
					//The first actor to do this attempts to kill the wizard.
					if (playerWizardKiller == null) {
						wizardKillMode(actor);
					} else {
						arena.removeChild(actor.sprite);
						minimap.removeChild(actor.miniSprite);
					}
				}
			}
			
			iter = opponentActors.head();
			while (iter.hasNext()) {
				actor = iter.next();
				
				if (actor.getPosition().x < END_POINT) {
					iter.remove();
					
					if (opponentWizardKiller == null) {
						wizardKillMode(actor);
					} else {
						arena.removeChild(actor.sprite);
						minimap.removeChild(actor.miniSprite);
					}
				}
			}
			
			//Tell the wizard killers to act.
			var wizardList:LinkedList;
			if (playerWizardKiller != null && !opponentWizard.isDead) {
				wizardList = new LinkedList(Actor);
				wizardList.push(opponentWizard);
				playerWizardKiller.act(EMPTY_ACTOR_LIST, wizardList);
				
				opponentWizard.checkIfDead();
				if (opponentWizard.isDead) {
					SoundPlayer.playScream();
					
					scrollable.jumpRight();
					repeatedScrollTimer.reset();
					autoScrollTimer.reset();
					autoScrollTimer.start();
					
					opponentWizard.sprite.animate(Status.DYING,
							function():void { opponentWizard.sprite.freeze(); } );
					
					playerWizardKiller.sprite.animate(Status.STANDING);
				}
			}
			
			if (opponentWizardKiller != null && !playerWizard.isDead) {
				wizardList = new LinkedList(Actor);
				wizardList.push(playerWizard);
				opponentWizardKiller.act(EMPTY_ACTOR_LIST, wizardList);
				
				playerWizard.checkIfDead();
				if (playerWizard.isDead) {
					SoundPlayer.playScream();
					
					scrollable.jumpLeft();
					repeatedScrollTimer.reset();
					autoScrollTimer.reset();
					autoScrollTimer.start();
					
					playerWizard.sprite.animate(Status.DYING,
							function():void { playerWizard.sprite.freeze(); } );
							
					opponentWizardKiller.sprite.animate(Status.STANDING);
				}
			}
		}
		
		private function updateMinimap():void {
			var actor:Actor;
			var iter:ListIterator = playerActors.head();
			while (iter.hasNext()) {
				(iter.next() as Actor).updateMiniMap();
			}
			
			iter = opponentActors.head();
			while (iter.hasNext()) {
				(iter.next() as Actor).updateMiniMap();
			}
		}
		
		/**
		 * Checks if the projectiles have hit anything.
		 */
		private function checkProjectiles():void {
			var projectile:Projectile;
			var target:Actor;
			var iter:ListIterator;
			
			for each (projectile in projectiles) {
				if ((projectile.targets & PLAYER_ACTORS) > 0) {
					iter = playerActors.head();
					while (iter.hasNext()) {
						target = iter.next();
						if (projectile.hitTest(target)) {
							projectile.collide(target);
						}
					}
				}
				
				if ((projectile.targets & OPPONENT_ACTORS) > 0) {
					iter = opponentActors.head();
					while (iter.hasNext()) {
						target = iter.next();
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
		
		private var scrollDirection:int = 0;
		
		public function forceScroll(scrollRight:Boolean):void {
			autoScrollTimer.reset();
			repeatedScrollTimer.reset();
			
			if (scrollRight) {
				scrollable.scrollRight();
				scrollDirection = 1;
			} else {
				scrollable.scrollLeft();
				scrollDirection = 2;
			}
		}
		
		public function stopScroll(scrollRight:Boolean):void {
			autoScrollTimer.start();
			
			if (scrollRight && scrollDirection == 1 || !scrollRight && scrollDirection == 2) {
				scrollable.stopScrolling();
				scrollDirection = 0;
			}
		}
		
	}

}