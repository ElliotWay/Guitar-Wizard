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
		public static const WIDTH:int = 600;
		public static const HEIGHT:int = 350;
		
		public static const ARENA_WIDTH:int = 2000;
		
		public static const SCROLL_SPEED:Number = 300; //pixels per seconds
		
		private var playerActors : Vector.<Actor>;
		private var opponentActors : Vector.<Actor>;

		private var playerHP : int;
		private var opponentHP : int;
		
		private var arena : Sprite;
		private var scroller:TweenLite;
		
		public function MainArea() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			
			this.width = WIDTH;
			this.height = HEIGHT;
			
			playerActors = new Vector.<Actor>();
			opponentActors = new Vector.<Actor>();
			
			arena = null;
			scroller = null;
			
			this.graphics.beginFill(0xD0D0FF);
			this.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			this.graphics.endFill();
			
			//TODO remove these later.
			
		}
		
		public function hardCode():void {
			
			//prep arena
			arena = new Sprite();
			this.addChild(arena);
			
			arena.graphics.beginFill(0xD0FFB0);
			arena.graphics.drawRect(0, 0, ARENA_WIDTH, HEIGHT);
			arena.graphics.endFill();
			
			playerHP = 100;
			opponentHP = 100;
			for (var i:int = 0; i < 4; i++) {
				var playerActor:Actor = new DefaultActor(true);
				playerSummon(playerActor);
			}
			for (var j:int = 0; j < 8; j++) {
				var opponentActor:Actor = new DefaultActor(false);
				opponentSummon(opponentActor);
			}
			
			this.addEventListener(Event.ENTER_FRAME, step);
		}
		
		public function setPlayerHP(hp : int):void {
			playerHP = hp;
		}
		
		public function playerSummon(actor : Actor):void {
			var position : Number = Math.random() * 500;
			playerActors.push(actor);
			arena.addChild(actor.sprite);
			actor.setPosition(position);
			actor.go();
		}
		
		public function opponentSummon(actor : Actor):void {
			var position : Number = ARENA_WIDTH - Math.random() * 500;
			opponentActors.push(actor);
			arena.addChild(actor.sprite);
			actor.setPosition(position);
			
			actor.go();
		}
		
		public function step(e:Event):void {
			//TODO if slowdown occurs, limit to every n frames
			var actor:Actor;
			
			for each (actor in playerActors) {
				actor.reactToTargets(opponentActors);
			}
			
			for each (actor in opponentActors) {
				actor.reactToTargets(playerActors);
			}
			
			//Collect the dead.
			for each (actor in playerActors.filter(checkDead, this)) {
				arena.removeChild(actor.sprite);
			}
			
			playerActors = playerActors.filter(checkAlive, this);
			
			for each (actor in opponentActors.filter(checkDead, this)) {
				arena.removeChild(actor.sprite);
			}
			
			opponentActors = opponentActors.filter(checkAlive, this);
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