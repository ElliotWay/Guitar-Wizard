package src 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author ...
	 */
	public class NoteSpriteAnimationCreator 
	{
		private static const PULSE_BRIGHTNESS:uint = 0x60;//0x25
		
		private static const MAX_RADIUS:Number = 23;
		
		private static const CENTER_X:Number = 25.5;
		private static const CENTER_Y:Number = 25.5;
		
		private static const LETTER_X:Number = 18.5;
		private static const LETTER_Y:Number = 13.5;
		
		private static const ENGULF_FRAMES:int = 5;
		private static const SHINE_FRAMES:int = 2;
		private static const FADE_FRAMES:int = 5;
		
		private static const FADE_RADIUS:Number = 14;
		
		/**
		 * Create a pulsing note animation.
		 * @param	color the base color of the note
		 * @param	letter the letter of the note
		 * @return  the animation
		 */
		public static function pulseAnimation(color:uint, letter:String):FrameAnimation {
			var frameData:Vector.<BitmapData> = new Vector.<BitmapData>(4, true);
			
			var bitmapData:BitmapData;
			
			
			var brighterColor:uint = brighten(color, PULSE_BRIGHTNESS);
			var largeCircle:Sprite = new Sprite();
			largeCircle.graphics.beginFill(brighterColor);
			largeCircle.graphics.drawCircle(CENTER_X, CENTER_Y, MAX_RADIUS);
			
			var largeCircleText:TextField = new TextField();
			largeCircleText.text = letter;
			largeCircleText.setTextFormat(new TextFormat("Arial", 18, 0xFFFFFF - brighterColor, true));
			largeCircle.addChild(largeCircleText);
			largeCircleText.x = LETTER_X;
			largeCircleText.y = LETTER_Y;
			
			bitmapData = getBitmapData(largeCircle);
			frameData[0] = bitmapData;
			
			
			var middleColor:uint = brighten(color, PULSE_BRIGHTNESS / 2);
			var middleCircle:Sprite = new Sprite();
			middleCircle.graphics.beginFill(middleColor);
			middleCircle.graphics.drawCircle(CENTER_X, CENTER_Y, MAX_RADIUS - 3);
			
			var middleCircleText:TextField = new TextField();
			middleCircleText.text = letter;
			middleCircleText.setTextFormat(new TextFormat("Arial", 18, 0xFFFFFF - middleColor, true));
			middleCircle.addChild(middleCircleText);
			middleCircleText.x = LETTER_X;
			middleCircleText.y = LETTER_Y;
			
			bitmapData = getBitmapData(middleCircle);
			frameData[1] = bitmapData;
			frameData[3] = bitmapData;
			
			var smallCircle:Sprite = new Sprite();
			smallCircle.graphics.beginFill(color);
			smallCircle.graphics.drawCircle(CENTER_X, CENTER_Y, MAX_RADIUS - 4);
			
			var smallCircleText:TextField = new TextField();
			smallCircleText.text = letter;
			smallCircleText.setTextFormat(new TextFormat("Arial", 18, 0xFFFFFF - color, true));
			smallCircle.addChild(smallCircleText);
			smallCircleText.x = LETTER_X;
			smallCircleText.y = LETTER_Y;
			
			bitmapData = getBitmapData(smallCircle);
			frameData[2] = bitmapData;
			
			
			return FrameAnimation.createFromFrames(frameData, FrameAnimation.FOUR_PER_BEAT,
					FrameAnimation.FLAG_COLOR, false, true, false);
		}
		
		public static function hitAnimation(color:uint, letter:String):FrameAnimation {
			var frameData:Vector.<BitmapData> = new Vector.<BitmapData>(ENGULF_FRAMES + SHINE_FRAMES + FADE_FRAMES, true);
			
			var count:int;
			var currentColor:uint, currentTextColor:uint;
			var currentColorRadius:Number, currentFlashRadius:Number;
			var currentSprite:Sprite, extraLayer:Shape;
			var currentText:TextField;
			var bitmapData:BitmapData;
			
			for (count = 0; count < ENGULF_FRAMES; count++) {
				currentColor = brighten(color,
						(ENGULF_FRAMES - count) * (PULSE_BRIGHTNESS / ENGULF_FRAMES));
				
				currentColorRadius = MAX_RADIUS - ((count + 1) / (ENGULF_FRAMES + 1)) * 6;
				currentFlashRadius = ((count + 1) / (ENGULF_FRAMES + 1)) * MAX_RADIUS;
				
				currentSprite = new Sprite();
				currentSprite.graphics.beginFill(currentColor);
				currentSprite.graphics.drawCircle(CENTER_X, CENTER_Y, currentColorRadius);
				
				currentText = new TextField();
				currentText.text = letter;
				currentText.setTextFormat(new TextFormat("Arial", 18, 0xFFFFFF - currentColor, true));
				currentSprite.addChild(currentText);
				currentText.x = LETTER_X;
				currentText.y = LETTER_Y;
				
				extraLayer = new Shape();
				extraLayer.graphics.beginFill(0xFFFFFF);
				extraLayer.graphics.drawCircle(CENTER_X, CENTER_Y, currentFlashRadius);
				currentSprite.addChild(extraLayer);
				
				bitmapData = getBitmapData(currentSprite);
				frameData[count] = bitmapData;
			}
			
			
			currentSprite = new Sprite();
			currentSprite.graphics.beginFill(0xFFFFFF);
			currentSprite.graphics.drawCircle(CENTER_X, CENTER_Y, MAX_RADIUS);
			
			bitmapData = getBitmapData(currentSprite);
			for (count = 0; count < SHINE_FRAMES; count++) {
				frameData[ENGULF_FRAMES + count] = bitmapData;
			}
			
			
			var maxBrightnessDistance:uint = Math.max(	(0xFF - ((color & 0xFF0000) >> 16)),
														(0xFF - ((color & 0x00FF00) >> 8)),
														(0xFF - ((color & 0x0000FF))));
			var baseTextColor:uint = 0xFFFFFF - color;
			var maxTextBrightnessDistance:uint =
					Math.max(	(0xFF - ((baseTextColor & 0xFF0000) >> 16)),
								(0xFF - ((baseTextColor & 0x00FF00) >> 8)),
								(0xFF - ((baseTextColor & 0x0000FF))));
								
			for (count = 0; count < FADE_FRAMES; count++) {
				currentColor = brighten(color,
						((FADE_FRAMES - count - 1) / (FADE_FRAMES)) * maxBrightnessDistance);
				currentTextColor = brighten(baseTextColor,
						((FADE_FRAMES - count - 1) / (FADE_FRAMES)) * maxTextBrightnessDistance);
						
				currentSprite = new Sprite();
				currentSprite.graphics.beginFill(0xFFFFFF);
				currentSprite.graphics.drawCircle(CENTER_X, CENTER_Y, MAX_RADIUS);
				
				currentSprite.graphics.beginFill(currentColor);
				currentSprite.graphics.drawCircle(CENTER_X, CENTER_Y, FADE_RADIUS);
				
				currentText = new TextField();
				currentText.text = letter;
				currentText.setTextFormat(new TextFormat("Arial", 18, currentTextColor, true));
				currentSprite.addChild(currentText);
				currentText.x = LETTER_X;
				currentText.y = LETTER_Y;
				
				bitmapData = getBitmapData(currentSprite);
				frameData[ENGULF_FRAMES + SHINE_FRAMES + count] = bitmapData;
			}
			
			
			return FrameAnimation.createFromFrames(frameData, FrameAnimation.EVERY_FRAME,
					FrameAnimation.FLAG_COLOR, false, false, false);
		}
		
		public static function missAnimation(color:uint, letter:String):FrameAnimation {
			//This code is the same as the hit animation with 0xFFFFFF switched for 0x0
			//and a couple of signs changed.
			var frameData:Vector.<BitmapData> = new Vector.<BitmapData>(ENGULF_FRAMES + SHINE_FRAMES + FADE_FRAMES, true);
			
			var count:int;
			var currentColor:uint, currentTextColor:uint;
			var currentColorRadius:Number, currentFlashRadius:Number;
			var currentSprite:Sprite, extraLayer:Shape;
			var currentText:TextField;
			var bitmapData:BitmapData;
			
			for (count = 0; count < ENGULF_FRAMES; count++) {
				currentColor = brighten(color,
						(ENGULF_FRAMES - count) * (PULSE_BRIGHTNESS / ENGULF_FRAMES));
				
				currentColorRadius = MAX_RADIUS - ((count + 1) / (ENGULF_FRAMES + 1)) * 6;
				currentFlashRadius = ((count + 1) / (ENGULF_FRAMES + 1)) * MAX_RADIUS;
				
				currentSprite = new Sprite();
				currentSprite.graphics.beginFill(currentColor);
				currentSprite.graphics.drawCircle(CENTER_X, CENTER_Y, currentColorRadius);
				
				currentText = new TextField();
				currentText.text = letter;
				currentText.setTextFormat(new TextFormat("Arial", 18, 0xFFFFFF - currentColor, true));
				currentSprite.addChild(currentText);
				currentText.x = LETTER_X;
				currentText.y = LETTER_Y;
				
				extraLayer = new Shape();
				extraLayer.graphics.beginFill(0x0);
				extraLayer.graphics.drawCircle(CENTER_X, CENTER_Y, currentFlashRadius);
				currentSprite.addChild(extraLayer);
				
				bitmapData = getBitmapData(currentSprite);
				frameData[count] = bitmapData;
			}
			
			
			currentSprite = new Sprite();
			currentSprite.graphics.beginFill(0x0);
			currentSprite.graphics.drawCircle(CENTER_X, CENTER_Y, MAX_RADIUS);
			
			bitmapData = getBitmapData(currentSprite);
			for (count = 0; count < SHINE_FRAMES; count++) {
				frameData[ENGULF_FRAMES + count] = bitmapData;
			}
			
			
			var maxBrightnessDistance:uint = Math.max(	((color & 0xFF0000) >> 16),
														((color & 0x00FF00) >> 8),
														((color & 0x0000FF)));
			var baseTextColor:uint = 0xFFFFFF - color;
			var maxTextBrightnessDistance:uint =
					Math.max(	((baseTextColor & 0xFF0000) >> 16),
								((baseTextColor & 0x00FF00) >> 8),
								((baseTextColor & 0x0000FF)));
								
			for (count = 0; count < FADE_FRAMES; count++) {
				currentColor = darken(color,
						((FADE_FRAMES - count - 1) / (FADE_FRAMES)) * maxBrightnessDistance);
				currentTextColor = darken(baseTextColor,
						((FADE_FRAMES - count - 1) / (FADE_FRAMES)) * maxTextBrightnessDistance);
						
				currentSprite = new Sprite();
				currentSprite.graphics.beginFill(0x0);
				currentSprite.graphics.drawCircle(CENTER_X, CENTER_Y, MAX_RADIUS);
				
				currentSprite.graphics.beginFill(currentColor);
				currentSprite.graphics.drawCircle(CENTER_X, CENTER_Y, FADE_RADIUS);
				
				currentText = new TextField();
				currentText.text = letter;
				currentText.setTextFormat(new TextFormat("Arial", 18, currentTextColor, true));
				currentSprite.addChild(currentText);
				currentText.x = LETTER_X;
				currentText.y = LETTER_Y;
				
				bitmapData = getBitmapData(currentSprite);
				frameData[ENGULF_FRAMES + SHINE_FRAMES + count] = bitmapData;
			}
			
			
			return FrameAnimation.createFromFrames(frameData, FrameAnimation.EVERY_FRAME,
					FrameAnimation.FLAG_COLOR, false, false, false);
		}
		
		private static function brighten(color:uint, brightness:uint):uint {
			return (Math.min(0xFF0000, (color & 0xFF0000) + (brightness << 16))) +
					(Math.min(0x00FF00, (color & 0x00FF00) + (brightness << 8))) +
					(Math.min(0x0000FF, (color & 0x0000FF) + (brightness)));
		}
		
		private static function darken(color:uint, darkness:uint):uint {
			return (Math.max(0x0, (color & 0xFF0000) - (darkness << 16))) +
					(Math.max(0x0, (color & 0x00FF00) - (darkness << 8))) +
					(Math.max(0x0, (color & 0x0000FF) - (darkness)));
		}
		
		private static function getBitmapData(thing:DisplayObject):BitmapData {
			//Create a transparent black bitmap.
			var blankData:BitmapData = new BitmapData(50, 50, true, 0x0);
			
			//Draw the thing onto the bitmap.
			blankData.draw(thing);
			
			return blankData;
		}
		
	}

}