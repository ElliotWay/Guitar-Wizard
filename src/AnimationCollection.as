package src 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author ...
	 */
	public class AnimationCollection 
	{
		private var anim:Object;
		
		/**
		 * Create several animations that can be referenced through the find method.
		 * @param	data bitmap data to draw the animations from
		 * @param	width width of most frames
		 * @param	height height of all frames
		 * @param	...args these should be formatted:
			 * 			status, y position, num frames, framesPerBeat, loops,
			 * 		OR
			 * 			status, y position, num frames, framesPerBeat, loops, true, different width
		 */
		public function AnimationCollection(data:BitmapData, width:int, height:int, ...args) {
			anim = new Dictionary(false);
			
			var status:int, yPosition:Number, numFrames:int, framesPerBeat:int;
			var loops:Boolean, localWidth:int;
			
			var index:int = 0;
			while (index < args.length) {
				status = args[index] as int;
				yPosition = args[index + 1] as Number;
				numFrames = args[index + 2] as int;
				framesPerBeat = args[index + 3] as int;
				loops = args[index + 4] as Boolean;
				
				if (args[index + 5] is Boolean) {
					localWidth = args[index + 6] as int;
					
					anim[status] = createAnimations(data, new Point(0, yPosition),
						localWidth, height, numFrames, framesPerBeat, loops);
						
					index += 7;
				} else {
					
					anim[status] = createAnimations(data, new Point(0, yPosition),
						width, height, numFrames, framesPerBeat, loops);
						
					index += 5;
				}
			}
		}
		
		private static function createAnimations(data:BitmapData, position:Point,
				width:int, height:int, numFrames:int, framesPerBeat:int, loops:Boolean):Vector.<Vector.<FrameAnimation>> {
			
			var out:Vector.<Vector.<FrameAnimation>> =
					new Vector.<Vector.<FrameAnimation>>(2, true);
					
			var player:Vector.<FrameAnimation> =
					new Vector.<FrameAnimation>(2, true);
					
			player[ActorSprite.RIGHT_FACING] = FrameAnimation.create(data, position, width, height,
					numFrames, framesPerBeat, ActorSprite.PLAYER_COLOR, false, loops);
			player[ActorSprite.LEFT_FACING] = FrameAnimation.create(data, position, width, height,
					numFrames, framesPerBeat, ActorSprite.PLAYER_COLOR, true, loops);
					
			out[ActorSprite.PLAYER] = player;
			
			var opponent:Vector.<FrameAnimation> =
					new Vector.<FrameAnimation>(2, true);
					
			opponent[ActorSprite.RIGHT_FACING] = FrameAnimation.create(data, position, width, height,
					numFrames, framesPerBeat, ActorSprite.OPPONENT_COLOR, false, loops);
			opponent[ActorSprite.LEFT_FACING] = FrameAnimation.create(data, position, width, height,
					numFrames, framesPerBeat, ActorSprite.OPPONENT_COLOR, true, loops);
			
			out[ActorSprite.OPPONENT] = opponent;
			
			return out;
		}
		
		/**
		 * Get the indicated animation.
		 * @param	status the status of the animation, as a Status constant
		 * @param	owner either PLAYER or OPPONENT, as an ActorSprite constant
		 * @param	facing either RIGHT_FACING or LEFT_FACING, as an ActorSprite constant
		 */
		public function find(status:int, owner:int, facing:int):FrameAnimation {
			return (anim[status] as Vector.<Vector.<FrameAnimation>>)[owner][facing];
		}
		
		/**
		 * Add copies of all animations in this collection with the associated owner and facing
		 * to the map, with the statuses as keys.
		 * @param	animationMap
		 */
		public function initializeMap(animationMap:Object, owner:int, facing:int):void {
			var key:*;
			
			for (key in anim) {
				animationMap[key] = find((key as int), owner, facing).copy();
			}
		}
		
	}

}