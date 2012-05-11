package com.ybcx.huluntears.scenes{
	
	import com.ybcx.huluntears.data.ItemManager;
	import com.ybcx.huluntears.data.ItemVO;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.items.PickupImage;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	
	import flash.display.Bitmap;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	
	public class RiverSubScene extends BaseScene{
		
		private var _riverBGPath:String = "assets/river/river_bg.jpg";
		//进入大地图场景箭头
		private var _toolReturnPath:String = "assets/sceaobao/tool_return.png";
		
		/**
		 * 大部分场景图形，包括道具，景物，都放在前景层中，方便统一移动
		 */ 
		private var frontScenaryLayer:Sprite;
		
		private var riverBg:Image;
		//返回按钮
		private var goMap:Image;
		
		//拖拽用参数
		private var _lastTouchX:Number;
		private var _lastTouchY:Number;
		
		/**
		 * 道具管理，获得道具信息
		 */ 
		private var _itemManager:ItemManager;
		
		
		
		
		/**
		 * ------------ 河流子场景 ---------------
		 */ 
		public function RiverSubScene(manager:ItemManager){
			super();
			_itemManager = manager;
		}
		
		override public function get itemsToPickup():Array{
			return ["dinggan_1","dinggan_2","dinggan_3","weibi_backleft","weibi_frontleft","gaizhan","men","zhuzi_left"];
		}		
		
		override protected function initScene():void{
			addDownloadTask(_riverBGPath);
			addDownloadTask(_toolReturnPath);
			
			//加载散落道具图片
			addItems();
			
			download();
		}
		
		private function addItems():void{
			for(var i:int=0; i<itemsToPickup.length; i++){
				var item:ItemVO = _itemManager.getItemVO(itemsToPickup[i]);
				if(!item) {
					trace("item not found: "+itemsToPickup[i]);
					continue;
				}
				addDownloadTask(item.inToolbarPath);				
			}
		}
		
		override protected function readyToShow():void{
			riverBg = this.getImageByUrl(_riverBGPath);
			this.addChild(riverBg);
			
			//添加一个前景层，用于放散落道具
			frontScenaryLayer = new Sprite();
			this.addChild(frontScenaryLayer);
			
			//到大地图场景
			goMap = getImageByUrl(_toolReturnPath);
			goMap.x = AppConfig.VIEWPORT_WIDTH-40;
			goMap.y = AppConfig.VIEWPORT_HEIGHT >> 1;
			this.addChild(goMap);
			
			//默认先隐藏，鼠标移动到附近，才显示
			goMap.visible = false;
			goMap.addEventListener(TouchEvent.TOUCH, onMapTouched);
			
			//当前场景的散落道具
			for(var i:int=0; i<itemsToPickup.length; i++){
				var item:ItemVO = _itemManager.getItemVO(itemsToPickup[i]);
				var bitmap:Bitmap = getBitmapByUrl(item.inToolbarPath);
				//显示要被拾起的道具		
				var image:PickupImage = _itemManager.createPickupByData(item,bitmap);
				frontScenaryLayer.addChild(image);				
			}
		}
		
		private function onMapTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(goMap);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(end);
			}
		}
		
		override protected function onTouching(touch:Touch):void{
			if (touch == null) {
				if(goMap) goMap.visible = false;
				return;
			}
			
			//在一个矩形区域内
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-100 && touch.globalY<AppConfig.VIEWPORT_HEIGHT){
				if(goMap) goMap.visible = true;
			}else{
				if(goMap) goMap.visible = false;
			}			
			//如果贴近右边缘，就隐藏
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-10){
				if(goMap) goMap.visible = false;
			}
			
			//改为拖拽了，鼠标感应移动太难用了
			dragMap(touch);
			
		}
		
		private function dragMap(touch:Touch):void{
			//记下初始鼠标位置
			if(touch.phase == TouchPhase.BEGAN){
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;							
			}
			
			//当前移动的按下状态鼠标位置
			if(touch.phase == TouchPhase.MOVED){
				var movedX:Number = touch.globalX-_lastTouchX;
				var movedY:Number = touch.globalY-_lastTouchY;
				
				//移动各个元素
				riverBg.y += movedY;
				frontScenaryLayer.y += movedY;
				
				//-------------- 移动结束，记下上一个位置 -------------------
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;
			}
			
		}
		
		
		
		
	} //end of class
}