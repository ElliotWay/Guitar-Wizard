package src 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Elliot Way
	 */
	public class MainArea extends Sprite 
	{
		public static var mainArea:MainArea;
		
		public static const WIDTH:int = 600;
		public static const HEIGHT:int = Main.HEIGHT - MusicArea.HEIGHT;
		
		public static const ARENA_WIDTH:int = 2000;
		
		public static const MINIMAP_WIDTH:int = Main.WIDTH - WIDTH;
		public static const MINIMAP_HEIGHT:int = 50;
		
		public static const SCROLL_SPEED:Number = 600; //pixels per second
		
		public static const PLAYER_ACTORS:int = 1;
		public static const OPPONENT_ACTORS:int = 2;
		
		private var playerActors : Vector.<Actor>;
		private var opponentActors : Vector.<Actor>;
		
		private var projectiles:Vector.<Projectile>;

		private var playerHP : int;
		private var opponentHP : int;
		
		private var arena : Sprite;
		private var scroller:TweenLite;
		
		private var minimap:Sprite;
		
		public function MainArea() 
		{
			mainArea = this;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			
			this.width = WIDTH;
			this.height = HEIGHT;
			
			playerActors = new Vector.<Actor>();
			opponentActors = new Vector.<Actor>();
			
			projectiles = new Vector.<Projectile>();
			
			arena = null;
			scroller = null;
			minimap = null;
			
			this.graphics.beginFill(0xD0D0FF);
			this.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			this.graphics.endFill();
			
			//TODO remove these later.
			
		}
		
		public function addProjectile(projectile:Projectile):void {
			
			projectiles.push(projectile);
						
			projectile.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
				projectile.go();
			});
			
			arena.addChild(projectile);
		}
		
		public function hardCode():void {
			
			//prep arena
			arena = new Sprite();
			this.addChild(arena);
			
			arena.graphics.beginFill(0xB0D090);
			arena.graphics.drawRect(0, 0, ARENA_WIDTH, HEIGHT);
			arena.graphics.endFill();
			
			arena.graphics.beginFill(0x909000);
			arena.graphics.drawRect(0, Actor.Y_POSITION, ARENA_WIDTH, 3);
			
			//minimap
			minimap = new Sprite();
			this.addChild(minimap);
			
			minimap.graphics.beginFill(0xFFFFB0);
			minimap.graphics.drawRect(0, 0, MINIMAP_WIDTH, MINIMAP_HEIGHT);
			minimap.graphics.endFill();
			
			minimap.x = WIDTH;
			minimap.y = 0;
			
			//create stuff
			playerHP = 100;
			opponentHP = 100;
			for (var i:int = 0; i < 1; i++) {
				var playerActor:Actor = new Assassin(true);
				playerSummon(playerActor);
			}
			for (var j:int = 0; j < 1; j++) {
				var opponentActor:Actor = new Archer(false);
				opponentSummon(opponentActor);
			}
			
			this.addEventListener(Event.ENTER_FRAME, step);
		}
		
		public function setPlayerHP(hp : int):void {
			playerHP = hp;
		}
		
		public function playerSummon(actor : Actor):void {
			var position : Number = Math.random() * 00;
			playerActors.push(actor);
			arena.addChild(actor.sprite);
			
			minimap.addChild(actor.miniSprite);
			
			actor.setPosition(position); //Also updates the minimap.
			actor.go();
		}
		
		public function opponentSummon(actor : Actor):void {
			var position : Number = ARENA_WIDTH - Math.random() * 600;
			opponentActors.push(actor);
			arena.addChild(actor.sprite);
			
			minimap.addChild(actor.miniSprite);
			
			actor.setPosition(position);
			actor.go();
		}
		
		/**
		 * Tell all the actors to act.
		 * @param	e an enter frame event
		 */
		public function step(e:Event):void {
			//TODO if slowdown occurs, limit to every n frames OR maybe we can get some sort of prediction system going
			var actor:Actor;
			
			for each (actor in playerActors) {
				actor.reactToTargets(opponentActors);
			}
			
			for each (actor in opponentActors) {
				actor.reactToTargets(playerActors);
			}
			
			checkProjectiles();
			updateMinimap();
			
			//Collect the dead.
			filterDead(playerActors);
			playerActors = playerActors.filter(checkAlive, this);
			
			filterDead(opponentActors);
			opponentActors = opponentActors.filter(checkAlive, this);
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
				arena.removeChild(actor.sprite);
				minimap.removeChild(actor.miniSprite);
				actor.clean();
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
					distance = arena.x - (-(ARENA_WIDTH - WIDTH));
					scroller = new TweenLite(arena, distance / SCROLL_SPEED, { x : -(ARENA_WIDTH - WIDTH), ease:Linear.easeInOut, onComplete:stopScrolling } );
				} else {
					distance = -arena.x;
					scroller = new TweenLite(arena, distance / SCROLL_SPEED, { x : 0, ease:Linear.easeInOut, onComplete:stopScrolling} );
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