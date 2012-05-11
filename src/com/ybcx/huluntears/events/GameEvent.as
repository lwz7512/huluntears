package com.ybcx.huluntears.events{
	
	import starling.events.Event;
	
	
	public class GameEvent extends Event{
		
		/**
		 * 转换场景
		 */ 
		public static const SWITCH_SCENE:String = "switchScene";
		/**
		 * 瓦片搜索到，该事件已经废弃
		 */ 
		public static const TILE_SEARCHED:String = "tileSearched";
		/**
		 * 片头动画开始
		 */ 
		public static const MOVIE_STARTED:String = "movieStarted";
		/**
		 * 卷轴被点击
		 */ 
		public static const REEL_TRIGGERD:String = "reelTriggerd";
		/**
		 * 子攻略被点击
		 */ 
		public static const RAIDER_TOUCHED:String = "raiderTouched";
		
		/**
		 * 开始游戏，载入剧情介绍场景
		 */ 
		public static const START_GAME:String = "startGame";
		/**
		 * 打开关于我们
		 */ 
		public static const OPEN_ABOUTUS:String = "aboutUs";
		/**
		 * 场景派发的单项加载进度事件
		 */ 
		public static const LOADING_PROGRESS:String = "progress";
		/**
		 * 场景派发的加载结束事件
		 */ 
		public static const LOADING_COMPLETE:String = "complete";		
		/**
		 * 消息提示
		 */ 
		public static const HINT_USER:String = "hintUser";
		/**
		 * 道具栏内的道具被选择，即将去场景中使用
		 */ 
		public static const ITEM_SELECTED:String = "itemSelected";
		/**
		 * 跟随鼠标的道具在道具栏点击，销毁道具
		 */ 
		public static const ITEM_DESTROYED:String = "itemDestroyed";
		/**
		 * 场景中的道具被点击发现，触发一系列动作
		 */ 
		public static const ITEM_FOUND:String = "itemFound";
		/**
		 * 道具与场景物体碰撞成功
		 */ 
		public static const HITTEST_SUCCESS:String = "itemHitted";
		/**
		 * 道具与场景舞台碰撞失败，颤抖吧
		 */ 
		public static const HITTEST_FAILED:String = "itemOffHitted";
		
		
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