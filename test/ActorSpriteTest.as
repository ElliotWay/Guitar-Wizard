package test 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import mockolate.received;
	import mockolate.runner.MockolateRule;
	import org.hamcrest.assertThat;
	import src.ActorSprite;
	import src.FrameAnimation;
	import src.Status;
	
	/**
	 * ActorSprite's methods only work if extended, so it makes sense to extend the class here.
	 */
	public class ActorSpriteTest extends ActorSprite
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		private var actorSprite:ActorSprite;
		
		[Mock]
		public var moving:FrameAnimation, fighting:FrameAnimation, retreating:FrameAnimation;
		
		public function onCompleteFunction():void {
			var thing:int = 1 + 2;
		}
		
		[Before]
		public function setup():void {
			
			actorSprite = this;
			
			super.animations[Status.MOVING] = moving;
			super.animations[Status.FIGHTING] = fighting;
			super.animations[Status.RETREATING] = retreating;
			
			super.currentAnimation = fighting;
			super.defaultAnimation = moving;
		}
		
		//I could plausibly test blessing, but that would involve setting the bless effect
		//externally instead of in the constructor, and it's really not worth that.
		
		
		[Test]
		public function stopsAndHidesCurrentAnimation():void {
			actorSprite.animate(Status.RETREATING);
			
			assertThat(fighting, received().method("stop"));
			assertThat(fighting, received().setter("visible").arg(false));
		}
		
		[Test]
		public function startsAndShowsNewAnimation():void {
			actorSprite.animate(Status.RETREATING);
			
			assertThat(retreating, received().method("go"));
			assertThat(retreating, received().setter("visible").arg(true));
		}
		
		[Test]
		public function usesDefaultOnUnusedKey():void {
			actorSprite.animate(Status.ASSASSINATING);
			
			assertThat(moving, received().method("go"));
			assertThat(moving, received().setter("visible").arg(true));
		}
		
		[Test]
		public function doesNotRestartOnSameAnimation():void {
			actorSprite.animate(Status.FIGHTING);
			
			assertThat(fighting, received().method("go").never());
			assertThat(fighting, received().setter("visible").never());
		}
		
		[Test]
		public function setsOnComplete():void {
			actorSprite.animate(Status.RETREATING, onCompleteFunction);
			
			assertThat(retreating, received().method("setOnComplete").arg(onCompleteFunction));
		}
		
		[Test]
		public function stepAdvancesToNextFrame():void {
			actorSprite.step();
			
			assertThat(fighting, received().method("nextFrame"));
		}
		
		[Test]
		public function freezeStops():void {
			actorSprite.freeze();
			
			assertThat(fighting, received().method("stop"));
		}
		
		[Test]
		public function movesToBottom():void {
			var container:Sprite = new Sprite();
			container.addChild(new Shape());
			container.addChild(new Shape());
			container.addChild(actorSprite);
			
			actorSprite.moveToBottom();
			
			assertThat(container.getChildIndex(actorSprite), 0);
		}
		
		[Test]
		public function getsValidCenter():void {
			var center:Point = actorSprite.center;
			
			assertThat(actorSprite.getBounds(actorSprite).contains(center.x, center.y));
		}
		
	}

}