package src 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * Actor interface. I originally intended to just use the base Actor class,
	 * but I eventually went with an interface as well.
	 * @author Elliot Way
	 */
	public interface AbstractActor 
	{
		function createSprites(isPlayerPiece:Boolean):void;
		
		function get sprite():Sprite;
		
		function get miniSprite():Sprite;
		
		function reactToTargets(others:Vector.<Actor>):void;
		
		function get isDead():Boolean;
		
		function isValidTarget():Boolean;
		
		function get hitpoints():int;
		function set hitpoints(hp:int):void;
		
		function getPosition():Point;
		function setPosition(position:Number):void;
		
		function updateMiniMap():void;
		
		function go():void;
		function halt():void;
		
		function clean():void;
	}
	
}