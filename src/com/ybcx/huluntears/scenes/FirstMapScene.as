package com.ybcx.huluntears.scenes{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.data.XMLoader;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.map.MapLayer;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.BottomToolBar;
	import com.ybcx.huluntears.ui.RaidersLayer;
	
	import flash.events.Event;
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
		
		private var _firstMapConfig:String = "assets/sceaobao/firstmap.xml";
		private var _tilePath:String = "assets/sceaobao/tiles/";
		private var _aobaoHeadPath:String = "assets/sceaobao/aobao_head.png";
		private var _backToAobaoPath:String = "assets/firstmap/tool_back.png";
		
		
		private var _xmlLoader:XMLoader;
		private var _loadingTF:TextField;
		
		private var _backgroundMap:MapLayer;		

		//敖包特写缩影
		private var aobaoHead:Image;
		//返回按钮
		private var back:Image;
		//道具栏
		private var _toolBar:BottomToolBar;
		
		//下载队列
		private var _queLoader:QueueLoader;
		private var _loadCompleted:Boolean;
		
		//卷轴打开的攻略地图
		private var _raiderLayer:RaidersLayer;
		
		
		public function FirstMapScene(){
			super();
			
		}
		
		//判断返回箭头的是否出现
		override protected function onTouching(touch:Touch):void{
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
		}
		
		public function set toolbar(tb:BottomToolBar):void{
			_toolBar = tb;
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
			
			_queLoader.addItem(_aobaoHeadPath,null, {title : _aobaoHeadPath});
			_queLoader.addItem(_backToAobaoPath,null, {title : _backToAobaoPath});
			
			
			_queLoader.execute();
						
			
			//显示道具栏
			_toolBar.showToolbar();
		}

		
		//单个图片加载完成
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			if(evt.title==_aobaoHeadPath){
				aobaoHead = new Image(Texture.fromBitmap(evt.content));
			}
			if(evt.title==_backToAobaoPath){
				back = new Image(Texture.fromBitmap(evt.content));
				back.addEventListener(TouchEvent.TOUCH,onBackTouch);
				this.addChild(back);
				back.visible = false;
				back.y = AppConfig.VIEWPORT_HEIGHT >> 1;
			}
		}
		
		private function onBackTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(back);
			if (touch == null) return;
			
			if(touch.phase==TouchPhase.ENDED){
				var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(end);				
			}
		}
		
		//清理队列
		private function onQueComplete(evt:QueueLoaderEvent):void{
			while(_queLoader.getLoadedItems().length){
				_queLoader.removeItemAt(_queLoader.getLoadedItems().length-1);
			}
			
			_loadCompleted = true;
			
			//放到地图中
			_backgroundMap.addItemAt(aobaoHead,new Point(390,181));
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
			trace("map xml loaded, to init mapLayer...");
			//初始化地图数据，这样地图引擎才能自己工作
			_backgroundMap.urls = urls;
		}
		
		
		
	} //end of class
}