package com.ybcx.huluntears.scenes{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.map.MapLayer;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.BottomToolBar;
	import com.ybcx.huluntears.ui.WalkThroughLayer;
	import com.ybcx.huluntears.utils.ImageQueLoader;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	/**
	 * 第一关大场景，点击隐藏热点可以分别进入子场景<br/>
	 * 
	 * 2012/05/04
	 */ 
	public class FirstMapScene extends BaseScene{
				
		private var _remoteScenaryPath:String = "assets/firstmap/remote_scenary.jpg";
		private var _nearScenaryPath:String = "assets/firstmap/near_scenary.png";
		private var _maskScenaryPath:String = "assets/firstmap/mask_scenary.png";
		private var _lelechePath:String = "assets/firstmap/leleche.png";
		
		//道具栏
		private var _toolBar:BottomToolBar;
		private var frontScenaryLayer:Sprite;
		
		//进入子场景入口热点图
		private var aobaoHotspot:Image;
		private var lelecheHotspot:Image;
		private var riverHotspot:Image;
		
		private var aoboLinkX:Number = 442;
		private var aoboLinkY:Number = 70;
		private var lelecheLinkX:Number = 450;
		private var lelecheLinkY:Number = 510;
		private var riverLinkX:Number = -80;
		private var riverLinkY:Number = 224;
		

		//假3D场景用背景图
		private var remoteScenary:Image;
		private var nearScenary:Image;
		private var maskScenary:Image;		
		private var lelecheScenary:Image;
		
		private var remoteSceneryStartX:Number = 0;
		private var _lelecheX:Number = 400;
		private var _lelecheY:Number = 500;			
		
		//拖拽用参数
		private var _lastTouchX:Number;
		private var _lastTouchY:Number;		
		
		
		/**
		 * 下载完成，也就是场景初始化完成的标志，场景场景再次显示时据此跳过加载过程
		 */ 
		private var _loadCompleted:Boolean;
		//下载队列
		private var _queLoader:ImageQueLoader;
		
		//总下载数
		private var queLength:int;
		//已下载数
		private var loadedCount:int;
		
		
		
		
		/**
		 * 第一关主场景，包含4个子场景
		 */ 
		public function FirstMapScene(){
			super();		
		}
		
		
		/**
		 * 是否加载图片完成，用来判断是否在显示场景时出加载画面
		 */ 
		public function get initialized():Boolean{
			return _loadCompleted;
		}
		
		public function set toolbar(tb:BottomToolBar):void{
			_toolBar = tb;
		}
				
		override protected function onStage(evt:Event):void{
			super.onStage(evt);
			
			if(_toolBar) _toolBar.showToolbar();
			
			if(_loadCompleted) return;
									
			//下载队列
			_queLoader = new ImageQueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onQueueProgress);		
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);		
			
			_queLoader.addImageByUrl(_remoteScenaryPath);
			_queLoader.addImageByUrl(_nearScenaryPath);
			_queLoader.addImageByUrl(_maskScenaryPath);
			_queLoader.addImageByUrl(_lelechePath);
			
			queLength = _queLoader.getQueuedItems().length;
			
			_queLoader.execute();			
						
		}

		override protected function offStage(evt:Event):void{
			super.offStage(evt);
			trace("first map scene removed!");
		}
		
		override protected function onTouching(touch:Touch):void{
			//超出触摸范围
			if(!touch) return;
			
			dragMap(touch);
		}
		override protected function onTouched(touch:Touch):void{
			drillDown(touch);
			//todo more...
		}
		/**
		 * 根据点击位置，来判断是否该进子场景
		 */ 
		private function drillDown(touch:Touch):void{
			var switchTo:GameEvent;
			
			var currentMouseX:Number = touch.globalX;
			var currentMouseY:Number = touch.globalY;
			
			var riverLinkGlobalX:Number = riverHotspot.localToGlobal(new Point(0,0)).x;
			var riverLinkGlobalY:Number = riverHotspot.localToGlobal(new Point(0,0)).y;
			var riverRect:Rectangle = new Rectangle(riverLinkGlobalX,riverLinkGlobalY,riverHotspot.width,riverHotspot.height);
			var hitRiverLinkResult:Boolean = hitRectTestByXY(riverRect,currentMouseX,currentMouseY);
			if(hitRiverLinkResult){
				switchTo = new GameEvent(GameEvent.SWITCH_SCENE,SubSceneNames.FIRST_SUB_RIVER);
				this.dispatchEvent(switchTo);
			}
			
			var aobaoLinkGlobalX:Number = aobaoHotspot.localToGlobal(new Point(0,0)).x;
			var aobaoLinkGlobalY:Number = aobaoHotspot.localToGlobal(new Point(0,0)).y;
			var aobaoRect:Rectangle = new Rectangle(aobaoLinkGlobalX,aobaoLinkGlobalY,aobaoHotspot.width,aobaoHotspot.height);
			var hitAobaoLinkResult:Boolean = hitRectTestByXY(aobaoRect,currentMouseX,currentMouseY);
			if(hitAobaoLinkResult){
				switchTo = new GameEvent(GameEvent.SWITCH_SCENE,SubSceneNames.FIRST_SUB_AOBAO);
				this.dispatchEvent(switchTo);
			}
			
			var lelecheLinkGlobalX:Number = lelecheHotspot.localToGlobal(new Point(0,0)).x;
			var lelecheLinkGlobalY:Number = lelecheHotspot.localToGlobal(new Point(0,0)).y;
			var lelecheRect:Rectangle = new Rectangle(lelecheLinkGlobalX,lelecheLinkGlobalY,lelecheHotspot.width,lelecheHotspot.height);
			var hitLelecheLinkResult:Boolean = hitRectTestByXY(lelecheRect,currentMouseX,currentMouseY);
			if(hitLelecheLinkResult){
				switchTo = new GameEvent(GameEvent.SWITCH_SCENE,SubSceneNames.FIRST_SUB_LELECHE);
				this.dispatchEvent(switchTo);
			}
		}
		
		private function hitRectTestByXY(rect:Rectangle, ptX:Number,ptY:Number):Boolean{
			if(rect.contains(ptX,ptY)) return true;
			return false;
		}
		
		/**
		 * 拖拽整个场景移动
		 */ 
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
				
				//近景移动边界检测
				var tempX:Number = frontScenaryLayer.x+movedX;
				var tempY:Number = frontScenaryLayer.y+movedY;
				
				//移动速度不一致
				var speedDiff:Number = 1.8;
				var tempRemoteX:Number = remoteScenary.x-speedDiff*movedX;
				
				var leftBoundary:Number = AppConfig.VIEWPORT_WIDTH-frontScenaryLayer.width;
				var topBoundary:Number = AppConfig.VIEWPORT_HEIGHT-frontScenaryLayer.height;
				
				//近景移动校验
				if(tempX>0) tempX = 0;
				if(tempX<leftBoundary) tempX = leftBoundary;
				if(tempY>0) tempY = 0;
				if(tempY<topBoundary) tempY = topBoundary;
				
				//远景移动校验
				if(tempRemoteX<remoteSceneryStartX) tempRemoteX = remoteSceneryStartX;
				if(tempRemoteX>0) tempRemoteX = 0;
				
				//-------------近景层物体移动 ---------------------------------
				frontScenaryLayer.x = tempX;
				frontScenaryLayer.y = tempY;							
				
				//---------------- 远景图，相对运动 ---------------------------
				remoteScenary.x = tempRemoteX;
				//移动河流石头热点
				riverHotspot.x = tempRemoteX+riverLinkX-remoteSceneryStartX;
														
				
				//-------------- 移动结束，记下上一个位置 -------------------
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;
			}
		}

		
		//单个图片加载完成
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			//累加
			loadedCount++;
		}		
		
		private function onQueueProgress(evt:QueueLoaderEvent):void{
			var totalPercent:Number = (evt.percentage+loadedCount)/queLength;
			var progress:GameEvent = new GameEvent(GameEvent.LOADING_PROGRESS,totalPercent);
			this.dispatchEvent(progress);
		}
		
		//清理队列
		private function onQueComplete(evt:QueueLoaderEvent):void{
			while(_queLoader.getLoadedItems().length){
				_queLoader.removeItemAt(_queLoader.getLoadedItems().length-1);
			}
			
			_loadCompleted = true;
			
			var complete:GameEvent = new GameEvent(GameEvent.LOADING_COMPLETE);
			this.dispatchEvent(complete);
			
			//显示各个图层
			showFirstScenary();
		}
		
		private function showFirstScenary():void{
			
			remoteScenary = _queLoader.getImageByUrl(_remoteScenaryPath);
			
			//------------ 远景层内容，大小和位置比较特殊，不放在单独的层中处理移动----------
			//计算起点位置，远景的右边缘与舞台右边缘对齐
			remoteSceneryStartX = this.stage.stageWidth-remoteScenary.width;
			remoteScenary.x = remoteSceneryStartX;
			remoteScenary.y = 0;
			this.addChild(remoteScenary);
			
			//添加交互，远景层的河流热点
			riverHotspot = createHotspot(10);
			riverHotspot.x = riverLinkX;
			riverHotspot.y = riverLinkY;
			this.addChild(riverHotspot);
			
			//------------ 近景层内容，放在近景层中统一移动 ------------------------------------
			frontScenaryLayer = new Sprite();
			this.addChild(frontScenaryLayer);
						
			nearScenary = _queLoader.getImageByUrl(_nearScenaryPath);
			nearScenary.x = 0;
			nearScenary.y = 0;
			frontScenaryLayer.addChild(nearScenary);
			
			maskScenary = _queLoader.getImageByUrl(_maskScenaryPath);
			maskScenary.x = 0;
			maskScenary.y = 0;
			frontScenaryLayer.addChild(maskScenary);
			
			lelecheScenary = _queLoader.getImageByUrl(_lelechePath);
			lelecheScenary.x = _lelecheX;
			lelecheScenary.y = _lelecheY;
			frontScenaryLayer.addChild(lelecheScenary);
			
			//创建热点并添加交互
			aobaoHotspot = createHotspot(10);
			aobaoHotspot.x = aoboLinkX;
			aobaoHotspot.y = aoboLinkY;
			frontScenaryLayer.addChild(aobaoHotspot);
			
			//创建热点并添加交互
			lelecheHotspot = createHotspot(15);
			lelecheHotspot.x = lelecheLinkX;
			lelecheHotspot.y = lelecheLinkY;
			frontScenaryLayer.addChild(lelecheHotspot);
			
			
			
		}
		
		private function touchRiverHotspot(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(riverHotspot);
			if(!touch) return;
			
			if(touch.phase==TouchPhase.ENDED){
				trace("river hotspot touched!");				
			}
		}
		private function touchAobaoHotspot(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(aobaoHotspot);
			if(!touch) return;
			
			if(touch.phase==TouchPhase.ENDED){
				trace("aobao hotspot touched!");
				
			}
		}
		private function touchLelecheHotspot(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(lelecheHotspot);
			if(!touch) return;
			
			if(touch.phase==TouchPhase.ENDED){
				trace("leleche hotspot touched!");				
			}
		}
				
		
		
		
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}		
		
		//创建透明热点
		private function createHotspot(size:Number):Image{
			var bd:BitmapData = new BitmapData(size,size,true,0xFFFF0000);
//			var bd:BitmapData = new BitmapData(size,size,true,0x01FFFFFF);
			return new Image(Texture.fromBitmapData(bd));
		}
		
	} //end of class
}