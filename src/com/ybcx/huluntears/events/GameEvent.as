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
		
		//开始游戏，载入剧情介绍场景
		public static const START_GAME:String = "startGame";
		//打开关于我们
		public static const OPEN_ABOUTUS:String = "aboutUs";
		//场景派发的单项加载进度事件
		public static const LOADING_PROGRESS:String = "progress";
		//场景派发的加载结束事件
		public static const LOADING_COMPLETE:String = "complete";		
		//消息提示
		public static const HINT_USER:String = "hintUser";
		
		
		/**
		 * 事件携带的数据
		 */ 
		public var context:Object;		
		
		public function GameEvent(type:String, context:Object=null){
			super(type, true);
			this.context = context;
		}
		

		
	} //end of class
}