package test 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import src.FrameAnimation;
	/**
	 * ...
	 * @author 
	 */
	public class FrameAnimationTest 
	{
		
		private var frameAnimation:FrameAnimation;
		private var newAnimation:FrameAnimation;
		
		private static var imageData:BitmapData = new BitmapData(7, 4);
		
		
		private static const FLAG:uint = 0xFF000000 | FrameAnimation.FLAG_COLOR;
		private static const BLACK:uint = 0xFF000000;
		private static const CYAN:uint = 0xFF00FFFF;
		
		private static const GREEN:uint = 0xFF00FF00;
		
		private static const FRAME_WIDTH:int = 2;
		private static const FRAME_HEIGHT:int = 3;
		private static const NUM_FRAMES:int = 3;
		
		private static var pixels:Vector.<uint>
			= new <uint> [	FLAG,  BLACK,	 	BLACK, BLACK, 	CYAN,  FLAG,
							FLAG,  FLAG,		FLAG, CYAN,		BLACK, CYAN,
							CYAN,  FLAG,		FLAG, CYAN,		BLACK, BLACK];

		imageData.setVector(new Rectangle(1, 1, 6, 3), pixels);
		
		[Before]
		public function setup():void {
			
		}
		
		[Test]
		public function loadsFrames():void {
			frameAnimation = FrameAnimation.create(imageData, new Point(1, 1),
					FRAME_WIDTH, FRAME_HEIGHT, NUM_FRAMES, FrameAnimation.EVERY_FRAME);
					
			var frames:Vector.<Bitmap> = frameAnimation.frames;
			
			assertThat(frames.length, 3);
			
			var firstFrame:BitmapData = frames[0].bitmapData;
			var secondFrame:BitmapData = frames[1].bitmapData;
			var thirdFrame:BitmapData = frames[2].bitmapData;
			
			assertThat(firstFrame.width, FRAME_WIDTH * 2);
			assertThat(firstFrame.height, FRAME_HEIGHT * 2);
			
			var frameBounds:Rectangle = firstFrame.rect;
			
			assertThat(firstFrame.getVector(frameBounds),
					array(	FLAG,  FLAG,  BLACK, BLACK,
							FLAG,  FLAG,  BLACK, BLACK,
							FLAG,  FLAG,  FLAG,  FLAG,
							FLAG,  FLAG,  FLAG,  FLAG,
							CYAN,  CYAN,  FLAG,  FLAG,
							CYAN,  CYAN,  FLAG,  FLAG));
							
			assertThat(secondFrame.getVector(frameBounds),
					array(	BLACK, BLACK, BLACK, BLACK,
							BLACK, BLACK, BLACK, BLACK,
							FLAG,  FLAG,  CYAN,  CYAN,
							FLAG,  FLAG,  CYAN,  CYAN,
							FLAG,  FLAG,  CYAN,  CYAN,
							FLAG,  FLAG,  CYAN,  CYAN));
							
			assertThat(thirdFrame.getVector(frameBounds),
					array(	CYAN,  CYAN,  FLAG,  FLAG,
							CYAN,  CYAN,  FLAG,  FLAG,
							BLACK, BLACK, CYAN,  CYAN,
							BLACK, BLACK, CYAN,  CYAN,
							BLACK, BLACK, BLACK, BLACK,
							BLACK, BLACK, BLACK, BLACK));
		}
		
		[Test(order = 1)]
		public function changesFlagColor():void {
			frameAnimation = FrameAnimation.create(imageData, new Point(1, 1),
					FRAME_WIDTH, FRAME_HEIGHT, NUM_FRAMES, FrameAnimation.EVERY_FRAME,
					GREEN);
					
			var frames:Vector.<Bitmap> = frameAnimation.frames;
			
			assertThat(frames.length, 3);
			
			var firstFrame:BitmapData = frames[0].bitmapData;
			var secondFrame:BitmapData = frames[1].bitmapData;
			var thirdFrame:BitmapData = frames[2].bitmapData;
			
			assertThat(firstFrame.width, FRAME_WIDTH * 2);
			assertThat(firstFrame.height, FRAME_HEIGHT * 2);
			
			var frameBounds:Rectangle = firstFrame.rect;
			
			assertThat(firstFrame.getVector(frameBounds),
					array(	GREEN,  GREEN,  BLACK, BLACK,
							GREEN,  GREEN,  BLACK, BLACK,
							GREEN,  GREEN,  GREEN, GREEN,
							GREEN,  GREEN,  GREEN, GREEN,
							CYAN,   CYAN,   GREEN, GREEN,
							CYAN,   CYAN,   GREEN, GREEN));
							
			assertThat(secondFrame.getVector(frameBounds),
					array(	BLACK, BLACK, BLACK, BLACK,
							BLACK, BLACK, BLACK, BLACK,
							GREEN, GREEN, CYAN,  CYAN,
							GREEN, GREEN, CYAN,  CYAN,
							GREEN, GREEN, CYAN,  CYAN,
							GREEN, GREEN, CYAN,  CYAN));
							
			assertThat(thirdFrame.getVector(frameBounds),
					array(	CYAN,  CYAN,  GREEN, GREEN,
							CYAN,  CYAN,  GREEN, GREEN,
							BLACK, BLACK, CYAN,  CYAN,
							BLACK, BLACK, CYAN,  CYAN,
							BLACK, BLACK, BLACK, BLACK,
							BLACK, BLACK, BLACK, BLACK));
		}
		
		[Test(order = 1)]
		public function flipsHorizontally():void {
			frameAnimation = FrameAnimation.create(imageData, new Point(1, 1),
					FRAME_WIDTH, FRAME_HEIGHT, NUM_FRAMES, FrameAnimation.EVERY_FRAME,
					GREEN, true);
					
			var frames:Vector.<Bitmap> = frameAnimation.frames;
			
			assertThat(frames.length, 3);
			
			var firstFrame:BitmapData = frames[0].bitmapData;
			var secondFrame:BitmapData = frames[1].bitmapData;
			var thirdFrame:BitmapData = frames[2].bitmapData;
			
			assertThat(firstFrame.width, FRAME_WIDTH * 2);
			assertThat(firstFrame.height, FRAME_HEIGHT * 2);
			
			var frameBounds:Rectangle = firstFrame.rect;
			
			assertThat(firstFrame.getVector(frameBounds),
					array(	BLACK, BLACK, GREEN, GREEN,
							BLACK, BLACK, GREEN, GREEN,
							GREEN, GREEN, GREEN, GREEN,
							GREEN, GREEN, GREEN, GREEN,
							GREEN, GREEN, CYAN,  CYAN,
							GREEN, GREEN, CYAN,  CYAN));
							
			assertThat(secondFrame.getVector(frameBounds),
					array(	BLACK, BLACK, BLACK, BLACK,
							BLACK, BLACK, BLACK, BLACK,
							CYAN,  CYAN,  GREEN, GREEN,
							CYAN,  CYAN,  GREEN, GREEN,
							CYAN,  CYAN,  GREEN, GREEN,
							CYAN,  CYAN,  GREEN, GREEN));
							
			assertThat(thirdFrame.getVector(frameBounds),
					array(	GREEN, GREEN, CYAN,  CYAN,
							GREEN, GREEN, CYAN,  CYAN,
							CYAN,  CYAN,  BLACK, BLACK,
							CYAN,  CYAN,  BLACK, BLACK,
							BLACK, BLACK, BLACK, BLACK,
							BLACK, BLACK, BLACK, BLACK));
		}
		
		[Test(order = 1)]
		public function deepCopies():void {
			frameAnimation = FrameAnimation.create(imageData, new Point(1, 1),
					FRAME_WIDTH, FRAME_HEIGHT, 3, FrameAnimation.EVERY_FRAME,
					GREEN, true);
			
			newAnimation = FrameAnimation.copy(frameAnimation);
			
			var oldFrames:Vector.<Bitmap> = frameAnimation.frames;
			var newFrames:Vector.<Bitmap> = newAnimation.frames;
			
			//The bitmaps should be new, but the internal data should be the same.
			for (var index:int = 0; index < NUM_FRAMES; index++) {
				assertThat(oldFrames[index] != newFrames[index]);
				assertThat(oldFrames[index].bitmapData == newFrames[index].bitmapData);
			}
		}
		
		[After]
		public function tearDown():void {
			if (frameAnimation != null)
				frameAnimation.stop();
				
			if (newAnimation != null)
				frameAnimation.stop();
		}
	}

}