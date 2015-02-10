package src 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FrameAnimation extends Sprite
	{
		
		private var frames:Vector.<Bitmap>;
		
		private var frameIndex:int;
		
		private var frameToFrameRatio:uint;
		
		private var frameCount:int;
		private var runner:Function;
		
		public function FrameAnimation(image:BitmapData, position:Point, frameWidth:uint, frameHeight:uint, numFrames:uint, frameToFrameRatio:uint)
		{
			if (numFrames == 0)
				return;
			
			if (position.x + numFrames * frameWidth > image.width ||
					position.y + frameHeight > image.height)
				throw new Error("Bad bounds on image for frame animation.");
			
			frames = new Vector.<Bitmap>(numFrames, true);
			
			for (var frameNumber:int = 0; frameNumber < numFrames; frameNumber++) {
				//Initialize a bitmap to transparent black.
				var innerBitmapData:BitmapData = new BitmapData(frameWidth, frameHeight, true, 0x00000000);
				
				//Copy the data from the image into this smaller bitmap.
				var selfRectangle:Rectangle = new Rectangle(0, 0, frameWidth, frameHeight);
				var targetRectangle:Rectangle =
						new Rectangle(position.x + frameWidth * frameNumber, position.y,
								frameWidth, frameHeight);
								
				var bytes:ByteArray = image.getPixels(targetRectangle);
				bytes.position = 0; //I don't really understand why this is necessary.
				
				innerBitmapData.setPixels(selfRectangle, bytes);
				
				//Create a Bitmap for this frame
				var bmpFrame:Bitmap = new Bitmap(innerBitmapData);
				
				frames[frameNumber] = bmpFrame;
				
				this.addChild(bmpFrame);
				bmpFrame.visible = false;
			}
			
			this.frameToFrameRatio = frameToFrameRatio;
			
			frames[0].visible = true;
		}
		
		public function go():void {
			frameCount = 0;
			
			runner = function():void {
				frameCount++;
				
				if (frameCount >= frameToFrameRatio) {
					nextFrame();
					
					frameCount = 0;
				}
			}
			
			Main.runEveryFrame(runner);
		}
		
		private function nextFrame():void {
			
			frames[frameIndex].visible = false;
			
			frameIndex++;
			
			if (frameIndex >= frames.length) {
				frameIndex = 0;
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