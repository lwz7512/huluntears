package com.ybcx.huluntears.scenes{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.data.XMLoader;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.map.MapLayer;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	
	import flash.events.Event;
	
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
		
		private var _firstMapConfig:String = "assets/sceaobao/firstmap.xml";
		private var _tilePath:String = "assets/sceaobao/tiles/";
		
		//道具栏背景
		private var _toolBackgroundPath:String = "assets/sceaobao/Toolbar.png";
		//卷轴
		private var _toolReelUpPath:String = "assets/sceaobao/Toolbar_Reel_1.png";
		private var _toolReelDownPath:String = "assets/sceaobao/Toolbar_Reel_2.png";
		//左右箭头
		private var _toolLeftArrowPath:String = "assets/sceaobao/toolbar_left.png";
		private var _toolRightArrowPath:String = "assets/sceaobao/toolbar_right.png";
		
		private var _backAobaoPath:String = "assets/firstmap/tool_back.png";
		
		private var _xmlLoader:XMLoader;
		private var _loadingTF:TextField;
		
		private var _backgroundMap:MapLayer;
		
		private var _reelTool:Button;
		private var toolBackground:Image;
		private var toolReelUp:Image;
		private var toolReelDown:Image;
		private var toolLeftArrow:Image;
		private var toolRightArrow:Image;
		
		private var backAobao:Image;
		
		//下载队列
		private var _queLoader:QueueLoader;
		private var _loadCompleted:Boolean;
		
		
		
		public function FirstMapScene(){
			super();
		}
		
		//FIXME, 该场景有两类Event，所以要加包名
		override protected function onStage(evt:starling.events.Event):void{
			super.onStage(evt);
			
			if(_loadCompleted) return;
			
			//加载地图图片名称配置文件
			_xmlLoader = new XMLoader(_firstMapConfig);
			_xmlLoader.addEventListener(flash.events.Event.COMPLETE, onXMLComplete);
			
			_loadingTF = new TextField(200,20,"loading data...");
			_loadingTF.x = this.stage.stageWidth - 200 >> 1;
			_loadingTF.y = this.stage.stageHeight - 20 >> 1;
			this.addChild(_loadingTF);	
			
			//初始化地图
			_backgroundMap = new MapLayer();
			this.addChild(_backgroundMap);
			
			//下载队列
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);
			
			_queLoader.addItem(_toolBackgroundPath,null, {title : _toolBackgroundPath});
			_queLoader.addItem(_toolReelUpPath,null, {title : _toolReelUpPath});
			_queLoader.addItem(_toolReelDownPath,null, {title : _toolReelDownPath});
			_queLoader.addItem(_toolLeftArrowPath,null, {title : _toolLeftArrowPath});
			_queLoader.addItem(_toolRightArrowPath,null, {title : _toolRightArrowPath});
			_queLoader.addItem(_backAobaoPath,null, {title : _backAobaoPath});
			
			_queLoader.execute();
			
			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		
		/**
		 * 处理返回按钮
		 */ 
		private function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if (touch == null) return;
			
			if(touch.globalX<100 && touch.globalY<AppConfig.VIEWPORT_HEIGHT){
				if(backAobao) backAobao.visible = true;
			}else{
				if(backAobao) backAobao.visible = false;
			}
		}
		
		//单个图片加载完成
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			if(evt.title==_toolBackgroundPath){
				toolBackground = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolBackgroundPath);
			}
			if(evt.title==_toolReelUpPath){
				toolReelUp = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolReelUpPath);
			}
			if(evt.title==_toolReelDownPath){
				toolReelDown = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolReelDownPath);
			}
			if(evt.title==_toolLeftArrowPath){
				toolLeftArrow = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolLeftArrowPath);
			}
			if(evt.title==_toolRightArrowPath){
				toolRightArrow = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolRightArrowPath);
			}
			if(evt.title==_backAobaoPath){
				backAobao = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_backAobaoPath);
			}
		}
		
		//清理队列
		private function onQueComplete(evt:QueueLoaderEvent):void{
			while(_queLoader.getLoadedItems().length){
				_queLoader.removeItemAt(_queLoader.getLoadedItems().length-1);
			}
			
			_loadCompleted = true;
			
			//道具栏
			toolBackground.x = 0;
			//这个位置刚合适
			toolBackground.y = 452;
			this.addChild(toolBackground);
			
			//卷轴
			var upTexture:Texture = toolReelUp.texture;
			var downTexture:Texture = toolReelDown.texture;
			_reelTool = new Button(upTexture,"",downTexture);
			_reelTool.y = 482;
			_reelTool.x = AppConfig.VIEWPORT_WIDTH-70;
			this.addChild(_reelTool);
			
			//左右箭头
			toolLeftArrow.x = 10;
			toolLeftArrow.y = 550;
			this.addChild(toolLeftArrow);
			
			toolRightArrow.x = AppConfig.VIEWPORT_WIDTH-90;
			toolRightArrow.y = 540;
			this.addChild(toolRightArrow);
			
			//返回箭头
			backAobao.x = 10;
			backAobao.y = AppConfig.VIEWPORT_HEIGHT >> 1;
			this.addChild(backAobao);
			
			backAobao.visible = false;
			
			backAobao.addEventListener(TouchEvent.TOUCH, onBackTouched);
			
		}
		
		private function onBackTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(backAobao);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(end);
			}
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		
		private function onXMLComplete(evt:flash.events.Event):void{
			this.removeChild(_loadingTF);
			
			//trace("node size: "+_xmlLoader.nodes.length());
			var urls:Vector.<String> = new Vector.<String>;
			for each(var tile:XML in _xmlLoader.nodes){				
				urls.push(_tilePath+tile.attribute("src"));
			}
			//初始化地图数据，这样地图引擎才能自己工作
			_backgroundMap.urls = urls;
		}
		
		
		
	} //end of class
}