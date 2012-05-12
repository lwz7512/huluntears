package com.ybcx.huluntears.data{
	
	/**
	 * 道具对应的数据：使用顺序、素材路径等等<br/>
	 * 
	 * 2012/05/08
	 */ 
	public class ItemVO{
		
		/**
		 * 道具位置
		 */ 
		public var itemX:Number = 0;
		public var itemY:Number = 0;
		
		/**
		 * 放置在场景中搭建物体时的使用顺序，索引小的先放置，索引大的后放置<br/>
		 * 这个顺序检测在ImageGroup中做
		 */
		public var index:int;
		
		/**
		 * 道具名称
		 */ 
		public var itemName:String;
		
		/**
		 * 在道具栏中的黑色道具占位符图片
		 */ 
		public var bgImagePath:String;
		/**
		 * 丢在场景中，准备拾起的准道具，也是道具栏中的道具用图片
		 */ 
		public var inToolbarPath:String;
		
		/**
		 * 该类道具需要组合时，需要的数目，默认都是一个，即不需要组合
		 */ 
		public var groupItemNum:int = 1;
		
		
		
		public function ItemVO(){
			
		}
		
	} //end of class
}