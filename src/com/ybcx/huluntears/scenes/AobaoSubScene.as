package com.ybcx.huluntears.scenes{
	
	
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.animation.FadeSequence;
	import com.ybcx.huluntears.data.ItemManager;
	import com.ybcx.huluntears.data.ItemVO;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.items.PickupImage;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.BottomToolBar;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	
	public class AobaoSubScene extends BaseScene{
		
		//---------- 图片路径 ----------------------
		private var _aobaoFocusPath:String = "assets/sceaobao/aobao_focus.jpg";
		//进入大地图场景箭头
		private var _toolReturnPath:String = "assets/sceaobao/tool_return.png";
		//宝石
		private var _jewelPath:String = "assets/sceaobao/jewel_s.png";
		//隐藏地图
		private var _hidedMapPath:String = "assets/sceaobao/hidedmap_s.png";

		
		/**
		 * 大部分场景图形，包括道具，景物，都放在前景层中，方便统一移动
		 */ 
		private var frontScenaryLayer:Sprite;
		
		//--------- 图片对象 -------------------
		//敖包图
		private var aobaoFocus:Image;
		//返回按钮
		private var goMap:Image;
		//宝石
		private var jewel:Image;
		//隐藏攻略图
		private var hidedMap:Image;		
		
		
		//点击宝石遮盖在地图上的黑色遮罩
		private var _mask:Image;
		//道具栏		
		private var _toolBar:BottomToolBar;
		//闪烁动画
		private var _fadeInOut:FadeSequence;
		
		//只有点击了宝石才打开移动地图开关
		private var _moveOpenFlag:Boolean;
		//宝石与敖包Y值差
		private var _jewelYDiff:Number = 0;
		//隐藏攻略图与敖包Y值差
		private var _hideMapYDiff:Number = 0;
		

		//拖拽用参数
		private var _lastTouchX:Number;
		private var _lastTouchY:Number;
		
		/**
		 * 道具管理，获得道具信息
		 */ 
		private var _itemManager:ItemManager;
		
		
		
		
		/**
		 * ----------- 敖包特写场景 ---------------------------
		 */ 
		public function AobaoSubScene(manager:ItemManager){
			super();
			_itemManager = manager;
		}
		
		override public function get itemsToPickup():Array{
			return ["dinggan_8","dinggan_9","tianchuang_1","zhuzi_right","weibi_backright"];
		}		
		
		override protected function initScene():void{			
			
			addDownloadTask(_aobaoFocusPath);			
			addDownloadTask(_toolReturnPath);
			addDownloadTask(_jewelPath);
			addDownloadTask(_hidedMapPath);
			
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
		
		override protected function detached():void{			
			trace("aobao scene removed!");
		}
		
		/**
		 * 处理返回按钮
		 */
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
				aobaoFocus.y += movedY;
				jewel.y += movedY;
				hidedMap.y += movedY;				
				frontScenaryLayer.y += movedY;
				
				//-------------- 移动结束，记下上一个位置 -------------------
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;
			}
			
		}
		
		private function onJewelTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(jewel);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				if(_mask) return;
				//允许地图上下移动
				_moveOpenFlag = true;
				//给宝石下面的东西加遮盖，使之变暗
				var bd:BitmapData = new BitmapData(AppConfig.VIEWPORT_WIDTH,AppConfig.VIEWPORT_HEIGHT+100,true,0xCC000000);
				_mask = new Image(Texture.fromBitmapData(bd));
				//宝石的下面
				this.addChildAt(_mask,this.getChildIndex(jewel));
				//反复闪烁隐藏攻略图		
				fadeinHideMap();
			}
		}		

		
		private function fadeinHideMap():void{
			hidedMap.x = aobaoFocus.x+504;
			hidedMap.y = aobaoFocus.y+472;
			this.addChild(hidedMap);			
			
			//不停的闪烁攻略
//			_fadeInOut = new FadeSequence(hidedMap,0.2);
//			_fadeInOut.start();
		}		
		
			
		override protected function readyToShow():void{
			//底图
			aobaoFocus = getImageByUrl(_aobaoFocusPath);
			this.addChild(aobaoFocus);								
			
			//添加一个前景层，用于放散落道具
			frontScenaryLayer = new Sprite();
			this.addChild(frontScenaryLayer);
			
			jewel = getImageByUrl(_jewelPath);
			//宝石点击触发地图移动和隐藏攻略
			jewel.addEventListener(TouchEvent.TOUCH, onJewelTouched);
			this.addChild(jewel);
			jewel.x = 374;
			jewel.y = 88;	
			_jewelYDiff = 88;
			
			hidedMap = getImageByUrl(_hidedMapPath);
			//加点击事件
			hidedMap.addEventListener(TouchEvent.TOUCH, onHideMapTouched);					
			
			//点亮宝石				
//			_fadeInOut = new FadeSequence(jewel,0.2,2);
//			_fadeInOut.start();
			
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
		
		private function onHideMapTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(hidedMap);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){				
				
				var move:Tween = new Tween(hidedMap,0.8);
				move.animate("x", AppConfig.VIEWPORT_WIDTH-40);
				move.animate("y", this.stage.stageHeight-60);
				move.animate("alpha",0.2);
				move.animate("scaleX",0.2);
				move.animate("scaleY",0.2);
				move.onComplete = function():void{
					shakeReel();
				};
				Starling.juggler.add(move);
				//停止闪烁
				//				_fadeInOut.dispose();
				//移除黑色遮罩
				this.removeChild(_mask);
			}
		}
		//晃动卷轴
		private function shakeReel():void{
			toolbar.shakeReel();
			hidedMap.visible = false;
		}	
		
		private function onMapTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(goMap);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(end);
			}
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		

		
		override public function dispose():void{
			super.dispose();
			
			_toolBar = null;
		}
		

		
	} //end of class
}