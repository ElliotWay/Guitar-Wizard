package src 
{
	/**
	 * Enum class. Contains various statuses that an Actor may have.
	 */
	public class Status 
	{
		public static const DYING : int = 0;
		public static const SUMMONING:int = 1
		public static const STANDING : int = 2;
		public static const MOVING : int = 3;
		public static const RETREATING : int = 4;
		public static const FIGHTING : int = 5;
		public static const SHOOTING : int = 6;
		public static const ASSASSINATING : int = 7;
		
		public static const PLAY_LOW:int = 6;
		public static const PLAY_MID:int = 7;
		public static const PLAY_HIGH:int = 8;
		
		public static function toString(status:int):String {
			switch (status) {
				case DYING:
					return "dying";
				case SUMMONING:
					return "summoning";
				case STANDING:
					return "standing";
				case MOVING:
					return "moving";
				case RETREATING:
					return "retreating";
				case FIGHTING:
					return "fighting";
				case SHOOTING:
					return "shooting";
				case ASSASSINATING:
					return "assassinating";
			}
			
			return "bad status";
		}
	}

}