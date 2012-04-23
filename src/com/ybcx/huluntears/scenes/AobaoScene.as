package com.ybcx.huluntears.scenes{
	
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.animation.FadeSequence;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.BottomToolBar;
	import com.ybcx.huluntears.ui.STProgressBar;
	
	import flash.display.BitmapData;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	
	public class AobaoScene extends BaseScene{
		
		//---------- 图片路径 ----------------------
		private var _aobaoFocusPath:String = "assets/sceaobao/aobao_focus.png";
		//返回大地图场景箭头
		private var _toolReturnPath:String = "assets/sceaobao/tool_return.png";
		//宝石
		private var _jewelPath:String = "assets/sceaobao/jewel.png";
		//隐藏地图
		private var _hidedMapPath:String = "assets/sceaobao/hidedmap.png";
		
		//--------- 图片对象 -------------------
		private var aobaoFocus:Image;
		private var toolReturn:Image;
		private var jewel:Image;
		private var hidedMap:Image;
		
		//玻璃板
		private var _touchBoard:Image;
		
		//loading...
		private var _progressbar:STProgressBar;
		//下载队列
		private var _queLoader:QueueLoader;					
		private var _loadCompleted:Boolean;
		
		private var _mask:Image;
				
		private var _toolBar:BottomToolBar;
		
		private var _fadeInOut:FadeSequence;
		
		
		/**
		 * 敖包特写场景
		 */ 
		public function AobaoScene(){
			super();
			
			//下载队列
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS,onQueueProgress);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);
			
			//全局鼠标移动判断
			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		
		public function set toolbar(tb:BottomToolBar):void{
			_toolBar = tb;
		}
		
		/**
		 * 处理返回按钮
		 */ 
		private function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if (touch == null) return;
			//在一个矩形区域内
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-100 && touch.globalY<AppConfig.VIEWPORT_HEIGHT){
				if(toolReturn) toolReturn.visible = true;
			}else{
				if(toolReturn) toolReturn.visible = false;
			}
			
			//如果贴近右边缘，就隐藏
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-10){
				if(toolReturn) toolReturn.visible = false;
			}
		}
		
		override protected function onStage(evt:Event):void{
			super.onStage(evt);
			
			if(_loadCompleted) return;
			
			//加个玻璃板，好响应鼠标动作
			//后添加玻璃板，铺满整个应用
			var bd:BitmapData = new BitmapData(this.stage.stageWidth,this.stage.stageHeight,true,0x01FFFFFF);						
			var tx:Texture = Texture.fromBitmapData(bd);
			_touchBoard = new Image(tx);
			this.addChild(_touchBoard);
			
			_queLoader.addItem(_aobaoFocusPath,null, {title : _aobaoFocusPath});

			_queLoader.addItem(_toolReturnPath,null, {title : _toolReturnPath});
			_queLoader.addItem(_jewelPath,null, {title : _jewelPath});
			_queLoader.addItem(_hidedMapPath,null, {title : _hidedMapPath});
			
			//发出请求
			_queLoader.execute();
			
			_progressbar = new STProgressBar(0x666666,this.stage.stageWidth,2,"载入敖包场景...");
			//放在舞台中央
			_progressbar.x = 0;
			_progressbar.y = this.stage.stageHeight >>1;
			this.addChild(_progressbar);
			
			
		}
		
		//单个图片加载完成
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			if(evt.title==_aobaoFocusPath){
				aobaoFocus = new Image(Texture.fromBitmap(evt.content));
				this.addChild(aobaoFocus);
				
				aobaoFocus.y = -aobaoFocus.height;
				
				//从上而下滑出
				var tween:Tween = new Tween(aobaoFocus, 3);
				tween.animate("y",-20);		
				tween.onComplete = function():void{
					jewel.visible = true;
					startToPlay();
				}
				Starling.juggler.add(tween);				
			}

			if(evt.title==_toolReturnPath){
				toolReturn = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolReturnPath);
			}
			if(evt.title==_jewelPath){
				jewel = new Image(Texture.fromBitmap(evt.content));
				jewel.addEventListener(TouchEvent.TOUCH, onJewelTouched);
				this.addChild(jewel);
				jewel.x = 388;
				jewel.y = 78;
				jewel.visible = false;
			}
			if(evt.title==_hidedMapPath){
				hidedMap = new Image(Texture.fromBitmap(evt.content));
				//加点击事件
				hidedMap.addEventListener(TouchEvent.TOUCH, onHideMapTouched);
			}
		}
		
		private function onJewelTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(jewel);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				if(_mask) return;
				//给宝石下面的东西加遮盖，使之变暗
				var bd:BitmapData = new BitmapData(AppConfig.VIEWPORT_WIDTH,AppConfig.VIEWPORT_HEIGHT+100,true,0xCC000000);
				_mask = new Image(Texture.fromBitmapData(bd));
				this.addChildAt(_mask,this.getChildIndex(jewel));
				//卷起大地图
				moveBgMap();
				jewel.visible = false;
			}
		}
		

		
		private function moveBgMap():void{
			var tween:Tween = new Tween(aobaoFocus, 0.6);
			tween.animate("y",-300);		
			tween.onComplete = function():void{
				fadeinHideMap();
			}
			Starling.juggler.add(tween);	
		}
		
		private function fadeinHideMap():void{
			hidedMap.x = 570;
			hidedMap.y = 336;
			this.addChild(hidedMap);
			//先隐藏
			hidedMap.alpha = 0;
			
			//加三次闪烁效果
			_fadeInOut = new FadeSequence(hidedMap,0.2,2);
			_fadeInOut.start();
		}
		
		private function onHideMapTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(hidedMap);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				var move:Tween = new Tween(hidedMap,0.4);
				move.animate("x", 700);
				move.animate("y", 450);
				move.animate("alpha",0);
				move.animate("scaleX",0.2);
				move.animate("scaleY",0.2);
				move.onComplete = function():void{
					shakeReel();
				};
				Starling.juggler.add(move);
			}
		}
		//晃动卷轴
		private function shakeReel():void{
			_toolBar.shakeReel();
			hidedMap.visible = false;
		}
		
		private function startToPlay():void{				
			
			//到大地图场景
			toolReturn.x = AppConfig.VIEWPORT_WIDTH-60;
			toolReturn.y = AppConfig.VIEWPORT_HEIGHT >> 1;
			this.addChild(toolReturn);
			
			//默认先隐藏，鼠标移动到附近，才显示
			toolReturn.visible = false;
			toolReturn.addEventListener(TouchEvent.TOUCH, onReturnTouched);
			
		}
		
		private function onReturnTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(toolReturn);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(end);
			}
		}
		

		
		private function onQueueProgress(evt:QueueLoaderEvent):void{
			_progressbar.progress = evt.queuepercentage;
		}
		
		
		//清理队列
		private function onQueComplete(evt:QueueLoaderEvent):void{
			while(_queLoader.getLoadedItems().length){
				_queLoader.removeItemAt(_queLoader.getLoadedItems().length-1);
			}
			
			_loadCompleted = true;
			this.removeChild(_progressbar);
			
			//显示道具栏
			_toolBar.showToolbar();
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		
		override public function dispose():void{
			super.dispose();
			
			_queLoader.dispose();
			_toolBar = null;
		}
		

		
	} //end of class
}