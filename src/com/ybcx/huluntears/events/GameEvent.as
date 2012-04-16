package com.ybcx.huluntears.events{
	
	import starling.events.Event;
	
	
	public class GameEvent extends Event{
		
		//转换场景
		public static const SWITCH_SCENE:String = "switchScene";
		//瓦片搜索到
		public static const TILE_SEARCHED:String = "tileSearched";
		
		public var context:Object;
		
		
		public function GameEvent(type:String, context:Object=null){
			super(type, true);
		}
		

		
	} //end of class
}