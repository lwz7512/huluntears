package com.ybcx.huluntears.scenes{
	
	
	import com.ybcx.huluntears.data.XMLoader;
	import com.ybcx.huluntears.map.MapEngine;
	import com.ybcx.huluntears.map.MapLayer;
	import com.ybcx.huluntears.map.Tile;
	import com.ybcx.huluntears.map.TileGrid;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	
	public class AobaoScene extends BaseScene{
		
		private var _firstMapConfig:String = "assets/sceaobao/firstmap.xml";
		private var _tilePath:String = "assets/sceaobao/tiles/";
		
		private var _xmlLoader:XMLoader;
		private var _loadingTF:TextField;
		
		private var _backgroundMap:MapLayer;
		
		
		//------- constructor -------------------------
		public function AobaoScene(){
			super();
		}
		
		//FIXME, 该场景有两类Event，所以要加包名
		override protected function onStage(evt:starling.events.Event):void{
			super.onStage(evt);
			
	
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