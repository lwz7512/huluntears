package com.ybcx.huluntears.scenes{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.data.ItemManager;
	import com.ybcx.huluntears.data.ItemVO;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.items.BaseItem;
	import com.ybcx.huluntears.items.PickupImage;
	import com.ybcx.huluntears.map.MapLayer;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.BottomToolBar;
	import com.ybcx.huluntears.ui.ImageGroup;
	import com.ybcx.huluntears.ui.WalkThroughLayer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
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
		
		
		[Embed(source="assets/firstmap/jewel_s.png")]
		private var JewelSmall:Class;
		
		private var _remoteScenaryPath:String = "assets/firstmap/remote_scenary.jpg";
		private var _nearScenaryPath:String = "assets/firstmap/near_scenary.png";
		private var _maskScenaryPath:String = "assets/firstmap/mask_scenary.png";
		private var _lelechePath:String = "assets/firstmap/leleche.png";
		
		//蒙古包底座，在上面搭建蒙古包
		private var _mgbBase:ImageGroup;
		private var _mgbX:Number = 200;
		private var _mgbY:Number = 400;
		
		/**
		 * 大部分场景图形，包括道具，景物，都放在前景层中，方便统一移动
		 */ 
		private var frontScenaryLayer:Sprite;
		
		//进入子场景入口热点图
		private var aobaoHotspot:Image;
		private var lelecheHotspot:Image;
		private var riverHotspot:Image;		

		//假3D场景用背景图
		private var remoteScenary:Image;
		private var nearScenary:Image;
		private var maskScenary:Image;		
		private var lelecheScenary:Image;
		
		private var remoteSceneryStartX:Number = 0;
		private var _lelecheX:Number = 600;
		private var _lelecheY:Number = 550;			
		
		private var aoboLinkX:Number = 443;
		private var aoboLinkY:Number = 70;
		private var lelecheLinkX:Number = 650;
		private var lelecheLinkY:Number = 560;
		private var riverLinkX:Number = -80;
		private var riverLinkY:Number = 224;				
		
		//拖拽用参数
		private var _lastTouchX:Number;
		private var _lastTouchY:Number;		
		
		/**
		 * 道具管理，获得道具信息
		 */ 
		private var _itemManager:ItemManager;
		
		
		/**
		 * 第一关主场景，包含4个子场景
		 */ 
		public function FirstMapScene(manager:ItemManager){
			super();	
			
			_itemManager = manager;
		}
		
		
		
		override public function get itemsToPickup():Array{
			return ["zhuzi_left","zhuzi_right","zhanlu"];
		}
		
		/**
		 * 碰撞检查成功了，可以放了在场景中了
		 */ 
		//TODO, 后面要处理正确叠放的状态，比如添加道具后，应该切换成什么中间状态
		override public function putItemHitted(img:Image,where:Point):void{
			frontScenaryLayer.addChild(img);
			//FIXME, 前景层移动的偏差要考虑			
			img.x = where.x-frontScenaryLayer.x;
			img.y = where.y-frontScenaryLayer.y;
			
		}
		
		override public function allowToPut(itemName:String):Boolean{
			return _mgbBase.acceptItem(itemName);
		}
		
		override public function get hitTestRect():Rectangle{			
			return _mgbBase.hitTestRect;
		}
				
		override protected function initScene():void{			
												
			addDownloadTask(_remoteScenaryPath);
			addDownloadTask(_nearScenaryPath);
			addDownloadTask(_maskScenaryPath);
			addDownloadTask(_lelechePath);
			//加载道具图片
			addItems();
			//下载所有素材
			download();
		}
		
		private function addItems():void{
			for(var i:int=0; i<itemsToPickup.length; i++){
				var item:ItemVO = _itemManager.getItemVO(itemsToPickup[i]);
				addDownloadTask(item.inToolbarPath);
			}
		}

		override protected function detached():void{			
			trace("first map scene removed!");
		}
		
		override protected function onTouching(touch:Touch):void{
			//超出触摸范围
			if(!touch) return;
			
			dragMap(touch);
		}
		override protected function onTouched(touch:Touch):void{
			drillDown(touch);			
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

					
		override protected function readyToShow():void{			
			
			//显示各个图层
			showFirstScenary();
			
			//显示游戏提示
			showGameHint("首先找到第一张任务图");
		}
		
		private function showFirstScenary():void{
			
			remoteScenary = getImageByUrl(_remoteScenaryPath);
			
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
						
			nearScenary = getImageByUrl(_nearScenaryPath);
			nearScenary.x = 0;
			nearScenary.y = 0;
			frontScenaryLayer.addChild(nearScenary);
			
			maskScenary = getImageByUrl(_maskScenaryPath);
			maskScenary.x = 0;
			maskScenary.y = 0;
			frontScenaryLayer.addChild(maskScenary);
			
			lelecheScenary = getImageByUrl(_lelechePath);
			lelecheScenary.x = _lelecheX;
			lelecheScenary.y = _lelecheY;
			frontScenaryLayer.addChild(lelecheScenary);
			
			//创建热点并添加交互
			aobaoHotspot = new Image(Texture.fromBitmap(new JewelSmall()));
//			aobaoHotspot = createHotspot(10);
			aobaoHotspot.x = aoboLinkX;
			aobaoHotspot.y = aoboLinkY;
			frontScenaryLayer.addChild(aobaoHotspot);
			
			//创建热点并添加交互
			lelecheHotspot = createHotspot(15);
			lelecheHotspot.x = lelecheLinkX;
			lelecheHotspot.y = lelecheLinkY;
			frontScenaryLayer.addChild(lelecheHotspot);
			
			//TODO, 添加碰撞检测，是否可以放置道具上去
			_mgbBase = new ImageGroup();
			_mgbBase.x = _mgbX;
			_mgbBase.y = _mgbY;
			//设置接收的道具，用于放置顺序检查
			_mgbBase.acceptNames = itemsToPickup;
			frontScenaryLayer.addChild(_mgbBase);
			
			//设置碰撞检测对象
			this.hitTestDO = _mgbBase;
			
			//显示要被拾起的道具			
			for(var i:int=0; i<itemsToPickup.length; i++){
				var item:ItemVO = _itemManager.getItemVO(itemsToPickup[i]);
				var bitmap:Bitmap = getBitmapByUrl(item.inToolbarPath);
				var image:PickupImage = _itemManager.createPickupByData(item,bitmap);
					frontScenaryLayer.addChild(image);
			}
			
		}
		

		//Game to listen...
		private function showGameHint(msg:String):void{
			var hint:GameEvent = new GameEvent(GameEvent.HINT_USER,msg);
			this.dispatchEvent(hint);
		}		
		
		//创建透明热点
		private function createHotspot(size:Number):Image{
//			var bd:BitmapData = new BitmapData(size,size,true,0xFFFF0000);
			var bd:BitmapData = new BitmapData(size,size,true,0x01FFFFFF);
			return new Image(Texture.fromBitmapData(bd));
		}
		
	} //end of class
}