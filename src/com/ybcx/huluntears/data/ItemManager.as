package com.ybcx.huluntears.data{
	
	import com.ybcx.huluntears.items.PickupImage;
	
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * 道具管理器，保存道具的名称和路径关系，维持一个对象池<br/>
	 * 
	 * 2012/05/08
	 */ 
	public class ItemManager{
		
		private var itemVOs:Array;
		//道具信息对象池，用于保存各类道具路径和索引
		private var itemPool:Dictionary;		
		//缓存搭建道具图片
		private var buildingImgPool:Dictionary;
		
		//似乎应该保存一个数据配置引用
		private var _itemConfig:ItemConfig;
		
		public function ItemManager(cfg:ItemConfig){
			_itemConfig = cfg;
			itemPool = new Dictionary();	
			buildingImgPool = new Dictionary();
			itemVOs = [];
		}
		
		public function get config():ItemConfig{
			return _itemConfig;
		}
		
		/**
		 * 缓存用于搭建蒙古包等建筑物用的真实图片
		 */ 
		public function cacheBuildingImgBy(itemName:String, img:Image):void{
			buildingImgPool[itemName] = img;
		}
		
		/**
		 * 得到缓存的搭建道具图片
		 */ 
		public function getCahcedBuildingImgBy(itemName:String):Image{
			return buildingImgPool[itemName];
		}
		
		public function createPickupByData(data:ItemVO,bitmap:Bitmap):PickupImage{
			var img:PickupImage = new PickupImage(Texture.fromBitmap(bitmap));
			img.bitmap = bitmap;
			img.name = data.itemName;
			img.x = data.itemX;
			img.y = data.itemY;
			//组合数，要传递过去
			img.groupItemNum = data.groupItemNum;
			
			return img;
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
			for each(var name:String in buildingImgPool){
				delete buildingImgPool[name];
			}
			itemVOs = null;
		}
		
	} //end of class
}