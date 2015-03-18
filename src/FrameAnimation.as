package src 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * An animation consisting of several frames, that are moved through on the beat.
	 */
	public class FrameAnimation extends Sprite
	{
		public static const FLAG_COLOR:uint = 0xFF0000;
		
		public static const SCALE:int = 2;
		
		public static const ONE_PER_BEAT:int = -1;
		public static const TWO_PER_BEAT:int = -2;
		public static const THREE_PER_BEAT:int = -3;
		public static const FOUR_PER_BEAT:int = -4;
		public static const THREE_HALVES_PER_BEAT:int = -5;
		public static const ONE_HALF_PER_BEAT:int = -6;
		public static const ONE_THIRD_PER_BEAT:int = -7;
		public static const ON_STEP:int = -8;
		
		private var frames:Vector.<Bitmap>;
		
		private var frameIndex:int;
		
		private var framesPerBeat:int;
		
		private var frameCount:int;
		private var runner:Function;
		
		private var onComplete:Function;
		
		/**
		 * Create an empty frame animation.
		 * Don't call this, use FrameAnimation.create or FrameAnimation.copy or FrameAnimation.flip instead.
		 */
		public function FrameAnimation() {
			onComplete = null;
			runner = null;
			frameIndex = 0;
		}
		
		/**
		 * Create a new frame animation from a source image.
		 * @param	image  source image with bitmap data
		 * @param	position  position of the first frame in the source image
		 * @param	frameWidth  width of each frame
		 * @param	frameHeight  height of each frame
		 * @param	numFrames  number of frames in this animation
		 * @param	framesPerBeat  using <b>FrameAnimation CONSTANTS</b> how many frames per beat
		 * @param	color  color to set pixels of the flag color to. Ignores the alpha channel.
		 * @param	flipped whether to flip the animation horizontally
		 * @return  the constructed FrameAnimation
		 */
		public static function create(image:BitmapData, position:Point, frameWidth:uint, frameHeight:uint, numFrames:uint, framesPerBeat:int,  color:uint = 0xFF0000, flipped:Boolean = false):FrameAnimation
		{
			var output:FrameAnimation = new FrameAnimation();
			
			if (framesPerBeat >= 0)
				throw new Error("Error: use FrameAnimation constants to define frames per beat");
			else 
				output.framesPerBeat = framesPerBeat;
			
			if (position.x + numFrames * frameWidth > image.width ||
					position.y + frameHeight > image.height)
				throw new Error("Bad bounds on image for frame animation.");
			
			output.frames = new Vector.<Bitmap>(numFrames, true);
			
			for (var frameNumber:int = 0; frameNumber < numFrames; frameNumber++) {
				//Initialize a bitmap to transparent black.
				var innerBitmapData:BitmapData = new BitmapData(frameWidth, frameHeight, true, 0x00000000);
				
				//Copy the data from the image into this smaller bitmap.
				var selfRectangle:Rectangle = new Rectangle(0, 0, frameWidth, frameHeight);
				var targetRectangle:Rectangle =
						new Rectangle(position.x + frameWidth * frameNumber, position.y,
								frameWidth, frameHeight);
								
				var bytes:ByteArray = image.getPixels(targetRectangle);
				bytes.position = 0;
				
				innerBitmapData.setPixels(selfRectangle, bytes);
				
				//Change pixels of the flag color to the requested color.
				for (var x:int = 0; x < innerBitmapData.width; x++) {
					for (var y:int = 0; y < innerBitmapData.height; y++) {
						var pixel:int = innerBitmapData.getPixel(x, y);
						if (pixel == FLAG_COLOR) {
							innerBitmapData.setPixel(x, y, color);
						}
					}
				}
				
				//Matrix transformations: scaling and horizontal flip, if requested
				var finalData:BitmapData = new BitmapData(frameWidth * SCALE, frameHeight * SCALE, true, 0x0);
				if (flipped) {
					finalData.draw(innerBitmapData, new Matrix( -SCALE, 0, 0, SCALE, frameWidth * SCALE, 0));
				} else {
					finalData.draw(innerBitmapData, new Matrix( SCALE, 0, 0, SCALE, 0, 0));
				}
				
				
				//Create a Bitmap for this frame
				var bmpFrame:Bitmap = new Bitmap(finalData);
				
				output.frames[frameNumber] = bmpFrame;
				
				output.addChild(bmpFrame);
				bmpFrame.visible = false;
			}
			
			
			output.frames[0].visible = true;
			
			output.visible = false;
			
			return output;
		}
		
		/**
		 * Copy a frame animation without creating new bitmaps.
		 * The animation will start with visible = false.
		 * @param	animation the animation to copy
		 * @return  a FrameAnimation that acts the same as the original
		 */
		public static function copy(animation:FrameAnimation):FrameAnimation {
			var output:FrameAnimation = new FrameAnimation();
			
			var numFrames:int = animation.frames.length;
			
			output.frames = new Vector.<Bitmap>(numFrames);
			
			output.visible = false;
			
			for (var index:int = 0; index < numFrames; index++) {
				output.frames[index] = new Bitmap(animation.frames[index].bitmapData);
				
				output.addChild(output.frames[index]);
				output.frames[index].visible = false;
			}
			
			output.framesPerBeat = animation.framesPerBeat;
			
			output.frames[0].visible = true;
			
			output.onComplete = animation.onComplete;
			
			return output;
		}
		
		/**
		 * Copy this animation without creating new bitmaps.
		 * @return  a FrameAnimation that acts the same as this one.
		 */
		public function copy():FrameAnimation {
			return FrameAnimation.copy(this);
		}
		
		public function setOnComplete(func:Function):void {
			onComplete = func;
		}
		
		/**
		 * Change this animation's frame rate. This can be changed while stopped or playing.
		 * Remember to use FrameAnimation constants.
		 * @param	framesPerBeat how frequently to advance frames, expressed in FrameAnimation constants
		 */
		public function setFramesPerBeat(framesPerBeat:int):void {
			if (runner != null) {
				this.stop();
				this.framesPerBeat = framesPerBeat;
				this.go();
			} else {
				this.framesPerBeat = framesPerBeat;
			}
		}
		
		public function go():void {
			if (frameIndex >= 0) {
				frames[frameIndex].visible = false;
				frames[0].visible = true;
			}
			
			frameCount = 0;
			
			frameIndex = 0;
			
			var countMax:int = 1;
			
			switch (framesPerBeat) {
				case ONE_PER_BEAT:
					countMax = 3;
					break;
				case TWO_PER_BEAT:
					countMax = 2;
					break;
				case THREE_PER_BEAT:
					countMax = 1;
					break;
				case FOUR_PER_BEAT:
					countMax = 1;
					break;
				case THREE_HALVES_PER_BEAT:
					countMax = 2;
					break;
				case ONE_HALF_PER_BEAT:
					countMax = 6;
					break;
				case ONE_THIRD_PER_BEAT:
					countMax = 9;
					break;
				case ON_STEP:
					//Wait for the user to call nextFrame()
					return;
			}
			
			if (runner != null)
				stop();
			
			runner = function():void {
				frameCount++;
				
				if (frameCount >= countMax) {
					nextFrame();
					
					frameCount = 0;
				}
			}
			
			if (framesPerBeat == TWO_PER_BEAT || framesPerBeat == FOUR_PER_BEAT) {
				Main.runEveryQuarterBeat(runner);
			} else {
				Main.runEveryThirdBeat(runner);
			}
		}
		
		/**
		 * Advances to the next frame. If we're on the last frame, also runs the onComplete function.
		 * TODO remove check for runner after onComplete, for usage without runner
		 */
		public function nextFrame():void {
			
			frames[frameIndex].visible = false;
			
			frameIndex++;
			
			if (frameIndex >= frames.length) {
				if (onComplete != null) {
					onComplete.call();
					
					//The onComplete function may have stopped the animation at the end,
					//so we need to show the last frame.
					if (runner == null) {
						frameIndex--;
					} else {
						frameIndex = 0;
					}
				} else {
					frameIndex = 0;
				}
			}
			
			frames[frameIndex].visible = true;
		}
		
		public function stop():void {
			if (runner != null){
				if (framesPerBeat == TWO_PER_BEAT || framesPerBeat == FOUR_PER_BEAT)
					Main.stopRunningEveryQuarterBeat(runner);
				else
					Main.stopRunningEveryThirdBeat(runner);
			}
			
			runner = null;
		}
		
	}

}