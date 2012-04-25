package com.ybcx.huluntears.events{
	
	import starling.events.Event;
	
	
	public class GameEvent extends Event{
		
		//转换场景
		public static const SWITCH_SCENE:String = "switchScene";
		//瓦片搜索到
		public static const TILE_SEARCHED:String = "tileSearched";
		//片头动画开始
		public static const MOVIE_STARTED:String = "movieStarted";
		//卷轴被点击
		public static const REEL_TRIGGERD:String = "reelTriggerd";
		//子攻略被点击
		public static const RAIDER_TOUCHED:String = "raiderTouched";
		
		
		
		
		public var context:Object;
		
		
		public function GameEvent(type:String, context:Object=null){
			super(type, true);
			this.context = context;
		}
		

		
	} //end of class
}