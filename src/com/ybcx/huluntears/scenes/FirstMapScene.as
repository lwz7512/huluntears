package com.ybcx.huluntears.scenes{
	
	import com.ybcx.huluntears.animation.FadeSequence;
	import com.ybcx.huluntears.data.*;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.items.PickupImage;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.ItemsBuilding;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * 第一关大场景，点击隐藏热点可以分别进入子场景<br/>
	 * 
	 * 2012/05/04
	 */ 
	public class FirstMapScene extends BaseScene{
		
		
		[Embed(source="assets/firstmap/jewel_xs.png")]
		private var JewelSmall:Class;
		[Embed(source="assets/firstmap/jewel_light.png")]
		private var JewelLight:Class;
		
		private var _remoteScenaryPath:String = "assets/firstmap/remote_scenary.jpg";
		private var _nearScenaryPath:String = "assets/firstmap/near_scenary.png";
		private var _maskScenaryPath:String = "assets/firstmap/mask_scenary.png";
		
		//地图细节，放在近景之上
		private var _mapDetailsPath:String = "assets/firstmap/details_firstmap.png";			
		
		
		/**
		 * 大部分场景图形，包括道具，景物，都放在前景层中，方便统一移动
		 */ 
		private var frontScenaryLayer:Sprite;
		
		/**
		 * 尝试使用远景层
		 */ 
		private var remoteScenaryLayer:Sprite;
		
		
		//进入子场景入口热点图
		private var aobaoHotspot:Image;
		private var lelecheHotspot:Image;
		private var riverHotspot:Image;		

		//假3D场景用背景图
		private var remoteScenary:Image;
		private var nearScenary:Image;
		private var mapDetails:Image;
		private var maskScenary:Image;		
		private var lelecheScenary:Image;
		
		
		//远景比较特殊，要制造假3D效果，所以保留起始位置
		private var remoteSceneryStartX:Number = 0;
		
		private var mapDetailsX:Number = 21;
		private var mapDetailsY:Number = 230;
		
		//蒙古包底座，在上面搭建蒙古包
		private var _mgbBase:ItemsBuilding;
		private var _mgbX:Number = 400;
		private var _mgbY:Number = 450;
		
		//敖包珠宝位置		
		private var aoboLinkX:Number = 445;
		private var aoboLinkY:Number = 72;
		//茶壶热点
		private var lelecheLinkX:Number = 740;
		private var lelecheLinkY:Number = 358;
		//河流石头链接
		private var riverLinkX:Number = 120;
		private var riverLinkY:Number = 178;				
		
		//拖拽用参数
		private var _lastTouchX:Number;
		private var _lastTouchY:Number;		
		
		/**
		 * 道具管理，获得道具信息
		 */ 
		private var _itemManager:ItemManager;
		
		/**
		 * 构建蒙古包用图片素材
		 */ 
		private var _itemConfig:ItemConfig;
		
		//宝石闪烁
		private var flare:FadeSequence;
		
		
		/**
		 * ------------ 第一关主场景，包含4个子场景 --------------
		 */ 
		public function FirstMapScene(manager:ItemManager){
			super();	
			
			_itemManager = manager;
			_itemConfig = manager.config;
		}
		
		override public function get itemsToPickup():Array{
			return ["dinggan_10","dinggan_11","weibi_frontright","menzhan","dingzhan"];
		}
		
		
		override public function allowToPut(itemName:String):Boolean{
			return _mgbBase.acceptItem(itemName);
		}
		
		/**
		 * 碰撞检查成功了，而且符合顺序，可以放了在场景中搭建蒙古包了
		 */
		override public function putItemHitted(itemName:String,where:Point):void{
			//这里不能直接放在场景中，作为搭建蒙古包的素材，而应该从道具缓存中，
			//查找相应的搭建道具，然后放在适当位置上
			trace("put building: "+itemName);
			var targetItem:Image = _itemManager.getCahcedBuildingImgBy(itemName);
			if(targetItem) _mgbBase.addChild(targetItem);
		}
		
		override public function get hitTestRect():Rectangle{			
			return _mgbBase.hitTestRect;
		}
				
		override protected function initScene():void{			
												
			addDownloadTask(_remoteScenaryPath);
			addDownloadTask(_nearScenaryPath);
			addDownloadTask(_maskScenaryPath);			
			addDownloadTask(_mapDetailsPath);		
			
			//加载散落道具图片
			addItems();					
			
			//开始下载所有素材
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
			//FIXME, 宝石太小了，弄大好点
			var aobaoRect:Rectangle = new Rectangle(aobaoLinkGlobalX,aobaoLinkGlobalY,aobaoHotspot.width,aobaoHotspot.height);
			aobaoRect.inflate(10,10);
			aobaoRect.x -= 10;
			aobaoRect.y -= 10;			
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
				var speedDiff:Number = 2;
				var tempRemoteX:Number = remoteScenaryLayer.x-speedDiff*movedX;
				
				var leftBoundary:Number = AppConfig.VIEWPORT_WIDTH-frontScenaryLayer.width+20;
				var topBoundary:Number = AppConfig.VIEWPORT_HEIGHT-frontScenaryLayer.height+100;
				
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
				
				//---------------- 远景图，水平相对运动 ---------------------------
				remoteScenaryLayer.x = tempRemoteX;
				//移动河流石头热点
//				riverHotspot.x = tempRemoteX+riverLinkX-remoteSceneryStartX;				
				
				//-------------- 移动结束，记下上一个位置 -------------------
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;
			}
		}
		
		
		override protected function readyToShow():void{			
			
			//显示各个图层
			showFirstScenary();			
			
			//蒙古包底座初始化完成，设置碰撞检测对象
			this.hitTestDO = _mgbBase;					
			
			//显示游戏提示
			showGameHint("首先找到第一张任务图");
			
			//加载搭建蒙古包图片
			addMGBBuilding();
		}
		
		override protected function lazyLoaded():void{
			super.lazyLoaded();
			//缓存搭建蒙古包用到的图片
			cacheMGBImgs();
		}
		
		
		private function addMGBBuilding():void{
			var buildings:Array = _itemConfig.buildingMGBImgs;
			for(var i:int=0; i<buildings.length; i++){
				var building:BuildingVO = buildings[i] as BuildingVO;
				addDownloadTask(building.buildingPath);
			}
			download();
		}
		
		private function showFirstScenary():void{
			
			remoteScenary = getImageByUrl(_remoteScenaryPath);			
			remoteScenaryLayer = new Sprite();
			//------------ 远景层内容，大小和位置比较特殊，不放在单独的层中处理移动----------
			//计算起点位置，远景的右边缘与舞台右边缘对齐
			remoteSceneryStartX = this.stage.stageWidth-remoteScenary.width;
			remoteScenaryLayer.x = remoteSceneryStartX;
			remoteScenaryLayer.y = 0;
			remoteScenaryLayer.addChild(remoteScenary);
			this.addChild(remoteScenaryLayer);
			
			//添加交互，远景层的河流热点
			riverHotspot = createHotspot(15);
			riverHotspot.x = riverLinkX;
			riverHotspot.y = riverLinkY;
			remoteScenaryLayer.addChild(riverHotspot);
			
			//------------ 近景层内容，放在近景层中统一移动 ------------------------------------
			frontScenaryLayer = new Sprite();
			this.addChild(frontScenaryLayer);
						
			nearScenary = getImageByUrl(_nearScenaryPath);
			nearScenary.x = 0;
			nearScenary.y = 0;
			frontScenaryLayer.addChild(nearScenary);
			
			mapDetails = getImageByUrl(_mapDetailsPath);
			mapDetails.x = mapDetailsX;
			mapDetails.y = mapDetailsY;
			frontScenaryLayer.addChild(mapDetails);
			
			maskScenary = getImageByUrl(_maskScenaryPath);
			maskScenary.x = 0;
			maskScenary.y = 0;
			frontScenaryLayer.addChild(maskScenary);
			
			var jewelLightImg:Image = new Image(Texture.fromBitmap(new JewelLight()));
			jewelLightImg.x = aoboLinkX-40;
			jewelLightImg.y = aoboLinkY-38;
			frontScenaryLayer.addChild(jewelLightImg);
			flare = new FadeSequence(jewelLightImg,0.2);
			flare.start();
			
			//创建热点并添加交互
			aobaoHotspot = new Image(Texture.fromBitmap(new JewelSmall()));
//			aobaoHotspot = createHotspot(10);
			aobaoHotspot.x = aoboLinkX;
			aobaoHotspot.y = aoboLinkY;
			aobaoHotspot.alpha = 0.01;
			frontScenaryLayer.addChild(aobaoHotspot);
			
			//创建热点并添加交互
			lelecheHotspot = createHotspot(15);
			lelecheHotspot.x = lelecheLinkX;
			lelecheHotspot.y = lelecheLinkY;
			frontScenaryLayer.addChild(lelecheHotspot);
			
			//蒙古包组合图片
			_mgbBase = new ItemsBuilding();
			_mgbBase.x = _mgbX;
			_mgbBase.y = _mgbY;
			//设置接收的道具，用于放置顺序检查
			_mgbBase.acceptNames = _itemConfig.mgbBuildingNames;
			frontScenaryLayer.addChild(_mgbBase);			
			
			//当前场景的散落道具
			for(var i:int=0; i<itemsToPickup.length; i++){
				var item:ItemVO = _itemManager.getItemVO(itemsToPickup[i]);
				var bitmap:Bitmap = getBitmapByUrl(item.inToolbarPath);
				//显示要被拾起的道具		
				var image:PickupImage = _itemManager.createPickupByData(item,bitmap);
				//要区分是放在远景层还是近景层，绝大部分都是在近景层
				frontScenaryLayer.addChild(image);				
			}
			
		}		
		
		/**
		 * 缓存搭建道具用图片
		 */ 
		private function cacheMGBImgs():void{
			var buildings:Array = _itemConfig.buildingMGBImgs;
			var cacheCounter:int;
			for(var i:int=0; i<buildings.length; i++){
				var building:BuildingVO = buildings[i] as BuildingVO;				
				var buildingImg:Image = getImageByUrl(building.buildingPath);
				buildingImg.x = building.buildingX;
				buildingImg.y = building.buildingY;				
				_itemManager.cacheBuildingImgBy(building.buildingName,buildingImg);
				cacheCounter ++;
			}
		}		
		
		//创建透明热点
		private function createHotspot(size:Number):Image{
//			var bd:BitmapData = new BitmapData(size,size,true,0xFFFF0000);
			var bd:BitmapData = new BitmapData(size,size,true,0x01FFFFFF);
			return new Image(Texture.fromBitmapData(bd));
		}
		
		override public function dispose():void{
			super.dispose();
			
			flare.dispose();
			
		}
		
	} //end of class
}