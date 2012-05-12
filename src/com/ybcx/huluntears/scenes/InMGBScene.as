package com.ybcx.huluntears.scenes{
	
	import com.ybcx.huluntears.data.ItemManager;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	
	import starling.display.Image;
	
	
	public class InMGBScene extends BaseScene{
		
		private var _mapBGPath:String = "assets/inmgb/innermgb.jpg";
		
		private var mgbIndoorIMg:Image;
		
		/**
		 * 道具管理，获得道具信息
		 */ 
		private var _itemManager:ItemManager;
		
		
		
		public function InMGBScene(manager:ItemManager){
			super();
			_itemManager = manager;
		}
		
		override protected function initScene():void{	
			addDownloadTask(_mapBGPath);
			
			download();
		}
		
		override protected function readyToShow():void{
			//底图
			mgbIndoorIMg = getImageByUrl(_mapBGPath);
			this.addChild(mgbIndoorIMg);
			
			//显示游戏提示
			showGameHint("下一关，敬请期待......");
		}
		
	} //end of class
}