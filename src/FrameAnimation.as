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
		public static const EVERY_FRAME:int = -9;
		
		private var _frames:Vector.<Bitmap>;
		private var frameIndex:int;
		
		private var counterMax:int;
		private var counter:int;
		
		private var frequency:int;
		private var _loops:Boolean;
		
		private var onComplete:Function;
		private var onCompleteArgs:Array;
		
		private var _isRunning:Boolean;
		
		public function get frames():Vector.<Bitmap> 
		{
			return _frames;
		}
		
		/**
		 * Whether the animation restarts when it reaches its end.
		 */
		public function get loops():Boolean 
		{
			return _loops;
		}
		
		public function get isRunning():Boolean 
		{
			return _isRunning;
		}
		
		/**
		 * Create an empty frame animation.
		 * Don't call this, use FrameAnimation.create or FrameAnimation.copy instead.
		 */
		public function FrameAnimation() {
			onComplete = null;
			frameIndex = 0;
			_isRunning = false;
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
		 * @param   loops whether the animation restarts when it ends
		 * @return  the constructed FrameAnimation
		 */
		public static function create(image:BitmapData, position:Point, frameWidth:uint, frameHeight:uint, numFrames:uint, frequency:int,  color:uint = FLAG_COLOR, flipped:Boolean = false, loops:Boolean = true):FrameAnimation
		{
			var output:FrameAnimation = new FrameAnimation();
			
			if (frequency >= 0)
				throw new Error("Error: use FrameAnimation constants to define frames per beat");
			else 
				output.setFrequency(frequency);
				
			output._loops = loops;
			
			if (position.x + numFrames * frameWidth > image.width ||
					position.y + frameHeight > image.height)
				throw new Error("Bad bounds on image for frame animation.");
			
			output._frames = new Vector.<Bitmap>(numFrames, true);
			
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
				
				output._frames[frameNumber] = bmpFrame;
				
				output.addChild(bmpFrame);
				bmpFrame.visible = false;
			}
			
			output._frames[0].visible = true;
			
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
			
			var numFrames:int = animation._frames.length;
			
			output._frames = new Vector.<Bitmap>(numFrames);
			
			output.visible = false;
			
			for (var index:int = 0; index < numFrames; index++) {
				output._frames[index] = new Bitmap(animation._frames[index].bitmapData);
				
				output.addChild(output._frames[index]);
				output._frames[index].visible = false;
			}
			
			output.setFrequency(animation.frequency);
			
			output._loops = animation._loops;
			
			output._frames[0].visible = true;
			
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
		
		/**
		 * Set a function to be called whenever the end of the animation occurs.
		 * The function is called when as the animation returns to the first frame,
		 * or advancing past the last frame if the animation does not loop.
		 * @param	func the function to call
		 * @param   args arguments with which to call the function
		 */
		public function setOnComplete(func:Function, args:Array = null):void {
			onComplete = func;
			onCompleteArgs = args;
		}
		
		/**
		 * Change this animation's frame rate. This can be changed while stopped or playing.
		 * Remember to use FrameAnimation constants.
		 * @param	framesPerBeat how frequently to advance frames, expressed in FrameAnimation constants
		 */
		public function setFrequency(freq:int, repeater:Repeater = null):void {
			
			switch (freq) {
				case ONE_PER_BEAT:
					counterMax = 3;
					break;
				case TWO_PER_BEAT:
					counterMax = 2;
					break;
				case THREE_PER_BEAT:
					counterMax = 1;
					break;
				case FOUR_PER_BEAT:
					counterMax = 1;
					break;
				case THREE_HALVES_PER_BEAT:
					counterMax = 2;
					break;
				case ONE_HALF_PER_BEAT:
					counterMax = 6;
					break;
				case ONE_THIRD_PER_BEAT:
					counterMax = 9;
					break;
				case EVERY_FRAME:
					counterMax = 1;
					break;
				//If it's ON_STEP, it doesn't matter.
			}
			
			if (_isRunning) {
				
				if (repeater == null)
					throw new GWError("Can't change frequency of ongoing animation without repeater access.");

				this.stop(repeater);
				this.frequency = freq;
				this.go(repeater);
			} else {
				this.frequency = freq;
			}
		}
		
		/**
		 * Play animation.
		 * @param	repeater repeater to control frame stepping (this can be null if the animation is on_step)
		 */
		public function go(repeater:Repeater):void {
			if (frameIndex >= 0) {
				frames[frameIndex].visible = false;
				frames[0].visible = true;
			}
			
			if (frequency == ON_STEP) {
				return;
			}
			
			counter = 0;
			frameIndex = 0;
			
			if (_isRunning)
				stop(repeater);
			
			if (frequency == EVERY_FRAME) {
				repeater.runEveryFrame(step);
			} else if (frequency == TWO_PER_BEAT || frequency == FOUR_PER_BEAT) {
				repeater.runEveryQuarterBeat(step);
			} else {
				repeater.runEveryThirdBeat(step);
			}
			
			_isRunning = true;
		}
		
		private function step():void {
			counter++;
			
			if (counter >= counterMax) {
				nextFrame();
				
				counter = 0;
			}
		}
		
		/**
		 * Advances to the next frame. If we're on the last frame, also runs the onComplete function.
		 */
		public function nextFrame():void {
			
			frames[frameIndex].visible = false;
			
			frameIndex++;
			
			if (frameIndex >= frames.length) {
				if (onComplete != null) {
					onComplete.apply(null, onCompleteArgs);
				}
					
				if (loops) {
					frameIndex = 0;
				} else {
					onComplete = null;
					frameIndex--;
				}
				
			}
			
			frames[frameIndex].visible = true;
		}
		
		public function stop(repeater:Repeater):void {
			if (_isRunning) {
				if (frequency == EVERY_FRAME) {
					repeater.stopRunningEveryFrame(step);
				} else if (frequency == TWO_PER_BEAT || frequency == FOUR_PER_BEAT)
					repeater.stopRunningEveryQuarterBeat(step);
				else
					repeater.stopRunningEveryThirdBeat(step);
			}
			
			_isRunning = false;
		}
		
		public function unload(repeater:Repeater):void {
			this.stop(repeater);
			
			for each (var bm:Bitmap in _frames) {
				this.removeChild(bm);
			}
			
			_frames.splice(0, _frames.length); //Removes internal references.
			_frames = null;
			
			_isRunning = false;
			onComplete = null;
		}
	}

}