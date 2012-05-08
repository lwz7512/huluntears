package com.ybcx.huluntears.data{
	
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	/**
	 * 道具管理器，保存道具的名称和路径关系，维持一个对象池<br/>
	 * 
	 * 2012/05/08
	 */ 
	public class ItemManager{
		
		//道具信息对象池，用于保存各类道具路径和索引
		private var itemPool:Dictionary;		
		private var itemVOs:Array;
		
		public function ItemManager(){
			itemPool = new Dictionary();	
			itemVOs = [];
		}	
		
		
		public function cacheItemVOs(items:Array):void{
			//每次只存放一关的道具
			clear();
			itemVOs = items;
			for each(var item:ItemVO in items){
				itemPool[item.itemName] = item;
			}
		}
		
		public function getAllItems():Array{
			return itemVOs;
		}
		
		public function getItemVO(itemName:String):ItemVO{
			return itemPool[itemName];
		}
		
		private function clear():void{
			for each(var key:String in itemPool){
				delete itemPool[key];
			}
			itemVOs = null;
		}
		
	} //end of class
}