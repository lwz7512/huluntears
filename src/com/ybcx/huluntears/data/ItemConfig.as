package com.ybcx.huluntears.data{
	
	/**
	 * 所有道具用到的图片素材配置
	 */ 
	public class ItemConfig{
				
		
		public function ItemConfig(){
			
		}
		
		/**
		 * 第一关所用到的全部道具，具体用在哪个子场景<br/>
		 * 在各自场景中实现get itemsToPickup()方法
		 */ 
		public function getFirstScenaryItems():Array{
			var items:Array = [];
			
			var zhuzi_1:ItemVO = new ItemVO();
			zhuzi_1.itemName = "zhuzi_left";
			zhuzi_1.index = 0;
			zhuzi_1.bgImagePath = "assets/firstitems/1_Toolbar_zhuzi_1.1.png";
			zhuzi_1.inToolbarPath = "assets/firstitems/1_Toolbar_zhuzi_1.png";
			zhuzi_1.inScenePath = "assets/firstitems/1_Toolbar_zhuzi_1.png";
			zhuzi_1.itemX = 100;
			zhuzi_1.itemY = 350;
			
			var zhuzi_2:ItemVO = new ItemVO();
			zhuzi_2.itemName = "zhuzi_right";
			zhuzi_2.index = 1;
			zhuzi_2.bgImagePath = "assets/firstitems/1_Toolbar_zhuzi_2.1.png";
			zhuzi_2.inToolbarPath = "assets/firstitems/1_Toolbar_zhuzi_2.png";
			zhuzi_2.inScenePath = "assets/firstitems/1_Toolbar_zhuzi_2.png";
			zhuzi_2.itemX = 200;
			zhuzi_2.itemY = 400;
			
			var zhanlu:ItemVO = new ItemVO();
			zhanlu.itemName = "zhanlu";
			zhanlu.index = 2;
			zhanlu.bgImagePath = "assets/firstitems/1_Toolbar_zhanlu_4.1.png";
			zhanlu.inToolbarPath = "assets/firstitems/1_Toolbar_zhanlu_4.png";
			zhanlu.inScenePath = "assets/firstitems/1_Toolbar_zhanlu_4.png";
			zhanlu.itemX = 150;
			zhanlu.itemY = 380;
			
			items.push(zhuzi_1);
			items.push(zhuzi_2);
			items.push(zhanlu);
			
			return items;
		}
		
		//剩余关用到的道具...
		
		
	} //end of class
}