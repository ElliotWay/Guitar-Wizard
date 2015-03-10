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
	 * ...
	 * @author ...
	 */
	public class FrameAnimation extends Sprite
	{
		public static const FLAG_COLOR:uint = 0xFF0000;
		
		private var frames:Vector.<Bitmap>;
		
		private var frameIndex:int;
		
		private var frameToFrameRatio:uint;
		
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
		 * @param	frameToFrameRatio  ratio between actual frames and frames in this animation
		 * @param	color  color to set pixels of the flag color to. Ignores the alpha channel.
		 * @param	whether to flip the animation horizontally
		 * @return  the constructed FrameAnimation
		 */
		public static function create(image:BitmapData, position:Point, frameWidth:uint, frameHeight:uint, numFrames:uint, frameToFrameRatio:uint,  color:uint = 0xFF0000, flipped:Boolean = false):FrameAnimation
		{
			var output:FrameAnimation = new FrameAnimation();
			
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
				
				//Horizontal flip, if requested.
				var finalData:BitmapData;
				if (flipped) {
					finalData = new BitmapData(frameWidth, frameHeight, true, 0x0);
					finalData.draw(innerBitmapData, new Matrix( -1, 0, 0, 1, innerBitmapData.width, 0));
				} else {
					finalData = innerBitmapData;
				}
				
				
				//Create a Bitmap for this frame
				var bmpFrame:Bitmap = new Bitmap(finalData);
				
				output.frames[frameNumber] = bmpFrame;
				
				output.addChild(bmpFrame);
				bmpFrame.visible = false;
			}
			
			output.frameToFrameRatio = frameToFrameRatio;
			
			output.frames[0].visible = true;
			
			return output;
		}
		
		/**
		 * Copy a frame animation without creating new bitmaps
		 * @param	animation the animation to copy
		 * @return  a FrameAnimation that acts the same as the original
		 */
		public static function copy(animation:FrameAnimation):FrameAnimation {
			var output:FrameAnimation = new FrameAnimation();
			
			var numFrames:int = animation.frames.length;
			
			output.frames = new Vector.<Bitmap>(numFrames);
			
			for (var index:int = 0; index < numFrames; index++) {
				output.frames[index] = new Bitmap(animation.frames[index].bitmapData);
				
				output.addChild(output.frames[index]);
				output.frames[index].visible = false;
			}
			
			output.frameToFrameRatio = animation.frameToFrameRatio;
			
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
		
		public function go():void {
			if (frameIndex >= 0) {
				frames[frameIndex].visible = false;
				frames[0].visible = true;
			}
			
			frameCount = 0;
			
			frameIndex = 0;
			
			runner = function():void {
				frameCount++;
				
				if (frameCount >= frameToFrameRatio) {
					nextFrame();
					
					frameCount = 0;
				}
			}
			
			Main.runEveryFrame(runner);
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
			if (runner != null)
				Main.stopRunningEveryFrame(runner);
			
			runner = null;
		}
		
	}

}