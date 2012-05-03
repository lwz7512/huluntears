package com.ybcx.huluntears.scenes{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.data.XMLoader;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.map.MapLayer;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.BottomToolBar;
	import com.ybcx.huluntears.ui.WalkThroughLayer;
	import com.ybcx.huluntears.utils.ImageQueLoader;
	
	import flash.geom.Point;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class FirstMapScene extends BaseScene{
		
		
		private var _remoteScenaryPath:String = "assets/firstmap/remote_scenary.jpg";
		private var _nearScenaryPath:String = "assets/firstmap/near_scenary.png";
		private var _maskScenaryPath:String = "assets/firstmap/mask_scenary.png";


		//假3D场景用背景图
		private var remoteScenary:Image;
		private var nearScenary:Image;
		private var maskScenary:Image;
		
		private var remoteSceneryStartX:Number = 0;
		
		private var _lastTouchX:Number;
		private var _lastTouchY:Number;
		private var _lastDiffX:Number;
		private var _lastDiffY:Number;
		
		//TODO, 导航图标
		private var back:Image;
		
		//道具栏
		private var _toolBar:BottomToolBar;
		
		//下载队列
		private var _queLoader:ImageQueLoader;
		private var _loadCompleted:Boolean;
		
		
		
		public function FirstMapScene(){
			super();
			
		}
		
		//判断返回箭头的是否出现
		override protected function onTouching(touch:Touch):void{
			//超出触摸范围
			if(!touch){
				if(back) back.visible = false;
				return;
			}
			
			//在一个矩形区域内
			if(touch.globalX<100 && touch.globalY<AppConfig.VIEWPORT_HEIGHT){
				if(back) back.visible = true;
			}else{
				if(back) back.visible = false;
			}			
			//如果贴近右边缘，就隐藏
			if(touch.globalX<10){
				if(back) back.visible = false;
			}
			
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
				
				//边界检测
				var tempX:Number = nearScenary.x+movedX;
				var tempY:Number = nearScenary.y+movedY;
				//移动速度不一致
				var speedDiff:Number = 1.8;
				var tempRemoteX:Number = remoteScenary.x-speedDiff*movedX;
				 
				var leftBoundary:Number = AppConfig.VIEWPORT_WIDTH-nearScenary.width;
				var topBoundary:Number = AppConfig.VIEWPORT_HEIGHT-nearScenary.height;
				if(tempX>0){
					tempX = 0;
				}
				if(tempX<leftBoundary){
					tempX = leftBoundary;
				}
				if(tempY>0){
					tempY = 0;
				}
				if(tempY<topBoundary){
					tempY = topBoundary;
				}
				if(tempRemoteX<remoteSceneryStartX){
					tempRemoteX = remoteSceneryStartX;
				}
				if(tempRemoteX>0){
					tempRemoteX = 0;
				}
				
				//遮罩与近景地图，同时移动
				nearScenary.x = tempX;
				nearScenary.y = tempY;
				maskScenary.x = tempX;
				maskScenary.y = tempY;
				
				//远景图，相对运动
				remoteScenary.x = tempRemoteX;
				
				//记下上一个位置
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;
			}
		}
		
		public function set toolbar(tb:BottomToolBar):void{
			_toolBar = tb;
		}
		
		//FIXME, 该场景有两类Event，所以要加包名
		override protected function onStage(evt:starling.events.Event):void{
			super.onStage(evt);	
			
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
						
			_queLoader.execute();						
			
			//显示道具栏
			_toolBar.showToolbar();
		}

		override protected function offStage(evt:Event):void{
			super.offStage(evt);
			trace("first map scene removed!");
		}
		
		//单个图片加载完成
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			trace(evt.title+" loaded...");
		}
		
		private function onBackTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(back);
			if (touch == null) return;
			
			if(touch.phase==TouchPhase.ENDED){
				var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(end);				
			}
		}
		
		private function onQueueProgress(evt:QueueLoaderEvent):void{
			var progress:GameEvent = new GameEvent(GameEvent.LOADING_PROGRESS,evt.percentage);
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
			
			showFirstScenary();
		}
		
		private function showFirstScenary():void{
			remoteScenary = _queLoader.getImageByUrl(_remoteScenaryPath);
			//计算起点位置，远景的右边缘与舞台右边缘对齐
			remoteSceneryStartX = this.stage.stageWidth-remoteScenary.width;
			remoteScenary.x = remoteSceneryStartX;
			remoteScenary.y = 0;
			this.addChild(remoteScenary);
			
			nearScenary = _queLoader.getImageByUrl(_nearScenaryPath);
			nearScenary.x = 0;
			nearScenary.y = 0;
			this.addChild(nearScenary);
			
			maskScenary = _queLoader.getImageByUrl(_maskScenaryPath);
			maskScenary.x = 0;
			maskScenary.y = 0;
			this.addChild(maskScenary);
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		
	
		/**
		 * 是否加载图片完成，用来判断是否在显示场景时出加载画面
		 */ 
		public function get initialized():Boolean{
			return _loadCompleted;
		}
		
	} //end of class
}