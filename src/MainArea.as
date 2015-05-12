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
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.Timer;
	import mx.controls.List;
	
	
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
		
		[Embed(source="../assets/arch.png")]
		private static const ArchImage:Class;
		
		[Embed(source="../assets/arch_fore.png")]
		private static const ArchForeImage:Class;
		
		//TODO replace this; am I even still using this?
		public static var mainArea:MainArea;
		
		public static const WIDTH:int = 600;
		public static const HEIGHT:int = Main.HEIGHT - MusicArea.HEIGHT;
		
		public static const ARENA_WIDTH:int = 2000;
		public static const SHIELD_POSITION:int = 450;
		
		public static const WIZARD_Y:int = 100;
		
		public static const WIZARD_KILL_DELAY:int = 1000;
		
		public static const SUMMONING_LINE_DURATION:int = 300;
		
		public static const END_POINT:int = 30;
		
		public static const MINIMAP_WIDTH:int = Main.WIDTH - WIDTH;
		public static const MINIMAP_HEIGHT:int = 50;
		
		
		public static const PLAYER_ACTORS:int = 1;
		public static const OPPONENT_ACTORS:int = 2;
		
		// (1 / BPM) * 60 * 1000, 500 is 120BPM
		public static const MILLISECONDS_PER_BEAT:int = 450; //500
		
		private static const EMPTY_ACTOR_LIST:Vector.<Actor> = new Vector.<Actor>(0, true);
		
		private static const NO_COLOR_CHANGE:ColorTransform = new ColorTransform();
		
		
		public static const AUTO_SCROLL_DELAY:int = 3000;
		public static const REPEATED_SCROLL_DELAY:int = 3000;
		
		public static const MASSIVE_DAMAGE:Number = 9001;
		
		public static const MAX_LIGHTNING_DISTANCE:Number = SHIELD_POSITION + 20;
		public static const LIGHTNING_DAMAGE:Number = 5;
		
		private var actorFactory:ActorFactory;
		
		private var playerActors:Vector.<Actor>;
		private var opponentActors:Vector.<Actor>;
		
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
		
		private var gameUI:GameUI;
		private var repeater:Repeater;
		
		
		public static function create(gameUI:GameUI):MainArea {
			use namespace factory;
			
			var out:MainArea = new MainArea(gameUI);
			out.setScrollable(new ScrollArea(ARENA_WIDTH - WIDTH));
			
			return out;
		}
		
		public function MainArea(gameUI:GameUI) 
		{
			this.gameUI = gameUI;
			mainArea = this;
			repeater = gameUI.repeater;
			actorFactory = gameUI.actorFactory;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		factory function setScrollable(scrollable:ScrollArea):void {
			this.scrollable = scrollable;
			this.addChild(scrollable);
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
			
			prepMinimap(minimap);
			
			//Create scrolling timers
			
			autoScrollTimer = new Timer(AUTO_SCROLL_DELAY, 1);
			autoScrollTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
				repeatedScrollTimer.start();
			});
			
			repeatedScrollTimer = new Timer(REPEATED_SCROLL_DELAY, 0);
			repeatedScrollTimer.addEventListener(TimerEvent.TIMER, function():void {
				var rightMost:Number = 0;
				
				var actor:Actor;
				for each (actor in playerActors) {
					if (!(actor is Shield) && actor.getPosition().x > rightMost)
						rightMost = actor.getPosition().x;
				}
				
				scrollable.scrollTo(rightMost - WIDTH / 3);
			});
		}
		
		private function prepMinimap(minimap:Sprite):void {
			minimap.graphics.beginFill(0xFFFFB0);
			minimap.graphics.drawRect(0, 0, MINIMAP_WIDTH, MINIMAP_HEIGHT);
			minimap.graphics.endFill();
			
			minimap.x = WIDTH;
			minimap.y = 0;
		}
		
		private function hardCode():void {
			
			var index:int;
			var actor:Actor;
			
			for (index = 0; index < 2; index++) {
				actor = actorFactory.create(ActorFactory.ARCHER, Actor.OPPONENT, Actor.LEFT_FACING);
				opponentSummon(actor);
			}
			for (index = 0; index < 2; index++) {
				actor = actorFactory.create(ActorFactory.ASSASSIN, Actor.OPPONENT, Actor.LEFT_FACING);
				opponentSummon(actor);
			}
			for (index = 0; index < 2; index++) {
				actor = actorFactory.create(ActorFactory.CLERIC, Actor.OPPONENT, Actor.LEFT_FACING);
				opponentSummon(actor);
			}
			
			for (index = 0; index < 2; index++) {
				actor = actorFactory.create(ActorFactory.ARCHER, Actor.PLAYER, Actor.RIGHT_FACING);
				playerSummon(actor);
			}
			for (index = 0; index < 2; index++) {
				actor = actorFactory.create(ActorFactory.ASSASSIN, Actor.PLAYER, Actor.RIGHT_FACING);
				playerSummon(actor)
			}
			for (index = 0; index < 2; index++) {
				actor = actorFactory.create(ActorFactory.CLERIC, Actor.PLAYER, Actor.RIGHT_FACING);
				playerSummon(actor);
			}
			
		}
		
		public function go(playerWizard:Wizard, opponentWizard:Wizard, playerShield:Shield, opponentShield:Shield):void {
			Actor.resetPlayerBuff();
			trace("approx actors on start: " + arena.numChildren);

			playerShield.position();
			arena.addChild(playerShield.sprite);
			minimap.addChild(playerShield.miniSprite);
			
			playerShieldIsUp = true;
			
			opponentShield.position();
			arena.addChild(opponentShield.sprite);
			minimap.addChild(opponentShield.miniSprite);
			
			opponentShieldIsUp = true;
			
			
			this.playerWizard = playerWizard;
			playerWizard.sprite.x = 170;
			playerWizard.sprite.y = WIZARD_Y - playerWizard.sprite.height;
			arena.addChild(playerWizard.sprite);
			playerWizard.playTrack(Main.MID, repeater);
			
			this.opponentWizard = opponentWizard;
			opponentWizard.sprite.x = ARENA_WIDTH - 220;
			opponentWizard.sprite.y = WIZARD_Y - opponentWizard.sprite.height;
			arena.addChild(opponentWizard.sprite);
			opponentWizard.playTrack(Main.MID, repeater);
			
			
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
			
			var arch:Bitmap = (new ArchImage() as Bitmap);
			background.addChild(arch);
			arch.x = ARENA_WIDTH / 2 - 20; arch.y = HEIGHT - arch.height + 16;
			
			var archFore:Bitmap = (new ArchForeImage() as Bitmap);
			foreground.addChild(archFore);
			archFore.x = ARENA_WIDTH / 2 - 20; archFore.y = HEIGHT - arch.height + 16;
			
			hardCode();
			
			autoScrollTimer.start();
			
			repeater.setBeat(MILLISECONDS_PER_BEAT);
			
			repeater.runEveryFrame(step);
		}
		
		public function stop():void {
			repeater.stopRunningEveryFrame(step);
			
			//Remove remaining actors.
			var actor:Actor;
			for each (actor in playerActors) {
				arena.removeChild(actor.sprite);
				minimap.removeChild(actor.miniSprite);
				
				actorFactory.destroy(actor);
			}
			for each (actor in opponentActors) {
				arena.removeChild(actor.sprite);
				minimap.removeChild(actor.miniSprite);
				
				actorFactory.destroy(actor);
			}
			
			playerActors.splice(0, playerActors.length);
			opponentActors.splice(0, opponentActors.length);
			
			/*scrollable.removeChild(arena);
			arena = new Sprite();
			scrollable.addChildAt(arena, 1);
			
			this.removeChild(minimap);
			minimap = new Sprite();
			this.addChild(minimap);
			prepMinimap(minimap);*/
			
			//Remove remaining projectiles.
			var projectile:Projectile;
			
			for each (projectile in projectiles) {
				projectile.forceFinish();
			}
			projectiles.splice(0, projectiles.length);
			
			//Remove wizards.
			if (arena.contains(playerWizard.sprite)) {
				arena.removeChild(playerWizard.sprite);
			}
			actorFactory.destroy(playerWizard);
			playerWizard = null;
			
			if (arena.contains(opponentWizard.sprite)) {
				arena.removeChild(opponentWizard.sprite);
			}
			actorFactory.destroy(opponentWizard);
			opponentWizard = null;
			
			//Remove wizard killers.
			if (playerWizardKiller != null) {
				arena.removeChild(playerWizardKiller.sprite);
				actorFactory.destroy(playerWizardKiller);
				playerWizardKiller = null;
			}
			
			if (playerWizardKillerTimer != null) {
				playerWizardKillerTimer.stop();
				playerWizardKillerTimer = null;
			}
			
			if (opponentWizardKiller != null) {
				arena.removeChild(opponentWizardKiller.sprite);
				actorFactory.destroy(opponentWizardKiller);
				opponentWizardKiller = null;
			}
			
			if (opponentWizardKillerTimer != null) {
				opponentWizardKillerTimer.stop();
				opponentWizardKillerTimer = null;
			}
			
			//Stop scrolling.
			scrollable.jumpLeft();
			autoScrollTimer.stop();
			repeatedScrollTimer.stop();
		}
		
		public function playerSummon(actor : Actor):void {
			if (playerWizard == null || playerWizard.isDead)
				return;
			
			var position : Number = Math.random() * (SHIELD_POSITION - 80) + 50;
			arena.addChild(actor.sprite);
			actor.setPosition(new Point(position, Actor.Y_POSITION - actor.sprite.height));
			
			createSummoningLine(actor, playerWizard);
			
			actor.sprite.animate(Status.SUMMONING, repeater, function():void {
				
				minimap.addChild(actor.miniSprite);
				playerActors.push(actor);
				
				actor.go(repeater);
			});
		}
		
		public function opponentSummon(actor : Actor):void {
			var position : Number = ARENA_WIDTH - (Math.random() * (SHIELD_POSITION - 80) + 50);
			arena.addChild(actor.sprite);
			actor.setPosition(new Point(position, Actor.Y_POSITION - actor.sprite.height));
			
			createSummoningLine(actor, opponentWizard);
			
			actor.sprite.animate(Status.SUMMONING, repeater, function():void {
				
				minimap.addChild(actor.miniSprite);
				opponentActors.push(actor);
				
				actor.go(repeater);
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
		
		/**
		 * Destroys both the player's and the opponent's shields.
		 * Doesn't actually immediately destroy them, but they will be removed on the next frame.
		 */
		public function killShields():void {
			//Shields are always in the first position if they still exist.
			var actor:Actor;
			
			if (playerActors.length > 0) {
				actor = playerActors[0];
				if (actor is Shield)
					actor.hit(MASSIVE_DAMAGE);
			}
			
			if (opponentActors.length > 0) {
				actor = opponentActors[0];
				if (actor is Shield)
					actor.hit(MASSIVE_DAMAGE);
			}
		}
		
		/**
		 * Have lightning strike the nearest target.
		 * @param	fromPlayer whether the lightning is from the player's wizard
		 */
		public function doLightning(fromPlayer:Boolean, forced:Boolean = false):void {
			var nearest:Actor;
			
			var target:Actor = null;
			var nearPoint:Point;
			var targetPoint:Point;
			
			if (fromPlayer) {
				nearPoint = new Point(ARENA_WIDTH, 0);
				
				for each (target in opponentActors) {
					targetPoint = target.getPosition();
					if (targetPoint.x < nearPoint.x) {
						nearest = target;
						nearPoint = targetPoint;
					}
				}
			} else {
				nearPoint = new Point(0, 0);
				
				for each (target in playerActors) {
					targetPoint = target.getPosition();
					if (targetPoint.x > nearPoint.x) {
						nearest = target;
						nearPoint = targetPoint;
					}
				}
			}
			
			if (nearest == null)
				return;
				
			if (!forced && fromPlayer && nearPoint.x > MAX_LIGHTNING_DISTANCE)
				return;
			else if (!forced && !fromPlayer && nearPoint.x < ARENA_WIDTH - MAX_LIGHTNING_DISTANCE)
				return;
			
			var wizardPoint:Point;
			if (fromPlayer) {
				wizardPoint = playerWizard.getPosition();
				
			} else {
				wizardPoint = opponentWizard.getPosition();
			}
			
			
			var lightning:Lightning = new Lightning(wizardPoint, nearPoint);
			
			foreground.addChild(lightning);
			
			lightning.go(repeater);
			
			nearest.hit(LIGHTNING_DAMAGE);
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
		private function wizardKillMode(actor:Actor):void {
			arena.removeChild(actor.sprite);
			minimap.removeChild(actor.miniSprite);
			
			var wizardKiller:Actor;
			
			var actorClass:int = -1;
			if (actor is Archer)
				actorClass = ActorFactory.ARCHER;
			else if (actor is Assassin)
				actorClass = ActorFactory.ASSASSIN;
			else // (actor is Cleric)
				actorClass = ActorFactory.CLERIC;
			
			wizardKiller = actorFactory.create(actorClass,
					(actor.isPlayerActor ? Actor.PLAYER : Actor.OPPONENT),
					(actor.facesRight ? Actor.LEFT_FACING : Actor.RIGHT_FACING));
				
			wizardKiller.sprite.y = WIZARD_Y - actor.sprite.height;
			
			if (actor.isPlayerActor) {
				playerWizardKiller = wizardKiller;
				wizardKiller.sprite.x = ARENA_WIDTH + 100;
				
				playerWizardKillerTimer = new Timer(WIZARD_KILL_DELAY, 1);
				playerWizardKillerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					arena.addChild(wizardKiller.sprite);
					wizardKiller.go(repeater);
					
					playerWizardKillerTimer = null;
				});
				playerWizardKillerTimer.start();
				
			} else {
				opponentWizardKiller = wizardKiller;
				wizardKiller.sprite.x = -100 - wizardKiller.sprite.width;
				
				opponentWizardKillerTimer = new Timer(WIZARD_KILL_DELAY, 1);
				opponentWizardKillerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
					arena.addChild(wizardKiller.sprite);
					wizardKiller.go(repeater);
					
					opponentWizardKillerTimer = null;
				});
				opponentWizardKillerTimer.start();
			}
			
			//Don't destroy the actor until we're completely finished with it.
			actorFactory.destroy(actor);
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
			
			//Tell actors to act.
			for each (actor in playerActors) {
				actor.act(playerActors, opponentActors, repeater);
			}
			for each (actor in opponentActors) {
				actor.act(opponentActors, playerActors, repeater);
			}
			
			
			checkProjectiles();
			updateMinimap();
			
			//Tell actors to check if they've died.
			for each (actor in playerActors) {
				actor.checkIfDead(repeater, fadeActor);
			}
			for each (actor in opponentActors) {
				actor.checkIfDead(repeater, fadeActor);
			}
			
			//Collect dead actors and actors over the edge.
			playerActors = playerActors.filter(removeFinished);
			
			opponentActors = opponentActors.filter(removeFinished);
			
			//Tell the wizard killers to act.
			var wizardList:Vector.<Actor>;
			if (playerWizardKiller != null && !opponentWizard.isDead) {
				wizardList = new Vector.<Actor>(1, true);
				wizardList[0] = opponentWizard;
				playerWizardKiller.act(EMPTY_ACTOR_LIST, wizardList, repeater);
				
				opponentWizard.checkIfDead(repeater, finishWizard);
			}
			
			if (opponentWizardKiller != null && !playerWizard.isDead) {
				wizardList = new Vector.<Actor>(1, true);
				wizardList[0] = playerWizard;
				opponentWizardKiller.act(EMPTY_ACTOR_LIST, wizardList, repeater);
				
				playerWizard.checkIfDead(repeater, finishWizard);
			}
		}
		
		/**
		 * For use with the filter function of each actor list.
		 * @param	actor
		 * @param	index
		 * @param	vector
		 * @return
		 */
		private function removeFinished(actor:Actor, index:int, vector:Vector.<Actor>):Boolean {
			if (actor.isDead) {
				minimap.removeChild(actor.miniSprite);
				
				return false;
			} else {
				if (actor.isPlayerActor && actor.getPosition().x > ARENA_WIDTH - END_POINT) {
					
					//The first actor to do this attempts to kill the wizard.
					if (playerWizardKiller == null) {
						wizardKillMode(actor);
					} else {
						arena.removeChild(actor.sprite);
						minimap.removeChild(actor.miniSprite);
					}
					
					return false;
					
				} else if (!actor.isPlayerActor && actor.getPosition().x < END_POINT) {
					
					if (opponentWizardKiller == null) {
						wizardKillMode(actor);
					} else {
						arena.removeChild(actor.sprite);
						minimap.removeChild(actor.miniSprite);
					}
					
					return false;
					
				} else {
					return true;
				}
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
					if (projectile.hitTest(playerWizard))
						projectile.collide(playerWizard);
				}
				
				if ((projectile.targets & OPPONENT_ACTORS) > 0) {
					for each (target in opponentActors) {
						if (projectile.hitTest(target)) {
							projectile.collide(target);
						}
					}
					if (projectile.hitTest(opponentWizard))
						projectile.collide(opponentWizard);
				}
				
				if (!projectile.finished) {
					projectile.askIfFinished();
				}
			}
			
			projectiles = projectiles.filter(function(projectile:Projectile, index:int, vector:Vector.<Projectile>):Boolean {
				return !projectile.finished;
			});
		}
		
		private function fadeActor(actor:Actor):void {
			var	fading:TweenLite = new TweenLite(actor.sprite, 5, { tint : 0xB0D090,
					onComplete:removeActor, onCompleteParams:[actor] });
		}
		
		private function removeActor(actor:Actor):void {
			//Restore the sprite to unfaded.
			actor.sprite.transform.colorTransform = NO_COLOR_CHANGE;
			
			arena.removeChild(actor.sprite);
			
			if (actor is Wizard) {
				if (actor.isPlayerActor) {
					gameUI.playerWizardDead();
				} else {
					gameUI.opponentWizardDead();
				}
			} else {
				actorFactory.destroy(actor);
			}
		}
		
		private function finishWizard(wizard:Wizard):void {
			SoundPlayer.playScream();
			
			if (wizard.isPlayerActor) 
				scrollable.jumpLeft();
			else
				scrollable.jumpRight();
				
			repeatedScrollTimer.reset();
			autoScrollTimer.reset();
			autoScrollTimer.start();
			
			fadeActor(wizard);
		}
		
		private var scrollDirection:int = 0;
		
		/**
		 * Forces the scrollable area to scroll left or right.
		 * It will never scroll past the boundaries.
		 * @param	scrollRight whether to scroll to the right
		 */
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
		
		/**
		 * Stop scrolling in a given direction. If we weren't scolling in that direction, this does nothing.
		 * Starts the timer for autoscrolling to begin.
		 * @param	scrollRight whether to stop scrolling right
		 */
		public function stopScroll(scrollRight:Boolean):void {
			autoScrollTimer.start();
			
			if (scrollRight && scrollDirection == 1 || !scrollRight && scrollDirection == 2) {
				scrollable.stopScrolling();
				scrollDirection = 0;
			}
		}
		
	}

}