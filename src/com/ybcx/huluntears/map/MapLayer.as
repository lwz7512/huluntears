package com.ybcx.huluntears.map{
	
	import com.ybcx.huluntears.data.XMLoader;
	import com.ybcx.huluntears.map.MapEngine;
	import com.ybcx.huluntears.map.Tile;
	import com.ybcx.huluntears.map.TileGrid;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	/**
	 * 用于鼠标交互和展示的游戏地图容器
	 * 
	 * 2012/04/12
	 */ 
	public class MapLayer extends Sprite{
		
		
		
		private var _tileEngine:MapEngine;
		private var _tileGrid:TileGrid;
		private var _touchBoard:Image;
		
		private var _lastTouchX:Number;
		private var _lastTouchY:Number;
		
		//记下偏移方向，好做鼠标释放后的滑动逻辑
		//		-1,-1		|	1,-1
		//------------|----------
		//		-1,1	   |		1,1
		//_lastDiffX大于0表示向右移动，小于0向左移动
		private var _lastDiffX:Number;
		//_lastDiffY大于0表示向下移动，小于0向上移动
		private var _lastDiffY:Number;
		private var _florceStop:Boolean;
		
		private var _initViewportX:Number = AppConfig.INIT_VIEWPORT_X;
		private var _initViewportY:Number = AppConfig.INIT_VIEWPORT_Y;
		//地图操作区域大小
		private var _viewportWidth:Number = AppConfig.VIEWPORT_WIDTH;
		private var _viewportHeight:Number = AppConfig.VIEWPORT_HEIGHT;
		
		//随鼠标拖拽不断更新的视窗大小，即地图看见窗口在整个地图中的位置
		//这个区域作为瓦片网格显示内容的范围
		private var _currentViewport:Rectangle;
		
		private var _loadCompleted:Boolean;
		
		public function MapLayer(){
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);			
		}
		
		private function onStage(evt:Event):void{
			
			if(_loadCompleted) return;
			
			//黑色背景色
			var background:Quad = new Quad(_viewportWidth,_viewportHeight+100,0x000000);
			this.addChild(background);
			
			//建立地图视窗大小，默认在地图左上角
			//鼠标拖动时改变这个对象
			_currentViewport = new Rectangle(_initViewportX,_initViewportY,_viewportWidth,_viewportHeight);
			//添加交互逻辑
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			
			//后添加玻璃板，铺满整个应用
			var bd:BitmapData = new BitmapData(this.stage.stageWidth,this.stage.stageHeight,true,0x01FFFFFF);						
			var tx:Texture = Texture.fromBitmapData(bd);
			_touchBoard = new Image(tx);
			this.addChild(_touchBoard);
		}
		
		public function set urls(titleUrls:Vector.<String>):void{			
			_tileEngine = new MapEngine(titleUrls);
			//先添加TileGrid，模拟手势移动
			_tileGrid = new TileGrid(_tileEngine.boundary);
			//SHOW THE INIT VIEWPORT...
			moveMap(0,0);
			//FIXME, 放在背景之上
			this.addChildAt(_tileGrid,1);
			
			_loadCompleted = true;
		}
		
		private function onTouch(evt:TouchEvent):void{
			
			var touch:Touch = evt.getTouch(this);
			if (touch == null) return;
			
			//记下初始鼠标位置
			if(touch.phase == TouchPhase.BEGAN){
				
				if(checkTouchBeyondViewport(touch.globalX,touch.globalY))
					return;
				
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;
				
				_lastDiffX = 0;
				_lastDiffY = 0;
				
				_florceStop = true;
			}
			//当前移动的按下状态鼠标位置
			if(touch.phase == TouchPhase.MOVED){
				
				if(checkTouchBeyondViewport(touch.globalX,touch.globalY))
					return;
				
				var movedX:Number = touch.globalX-_lastTouchX;
				var movedY:Number = touch.globalY-_lastTouchY;				
				
				//移动地图的逻辑都在该方法中了				
				moveMap(movedX, movedY);
				
				//之后记下移动位置
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;
				//记下移动方向
				_lastDiffX = movedX;
				_lastDiffY = movedY;
			}
			//TODO, 鼠标离开后，依据鼠标位置变化趋势，地图滑动一段距离
			if(touch.phase == TouchPhase.ENDED){
				
			}
		}
		
		/**
		 * 通过鼠标移动地图，主要是改变视窗大小，然后瓦片网格重新渲染
		 * 渲染的前提是地图引擎能根据视窗的大小获得相应的材质图片
		 */ 
		private function moveMap(diffX:Number, diffY:Number):void{
			//重新计算视窗
			var newvpX:Number = _currentViewport.x-diffX;
			var newvpY:Number = _currentViewport.y-diffY;
			
			//边界校准，防止拖拽出现丢失BUG
			if(newvpX<0) newvpX = 0;
			if(newvpY<0) newvpY = 0;			
			if(newvpX+_viewportWidth>_tileEngine.boundary.right) 
				newvpX=_tileEngine.boundary.right-_viewportWidth;
			if(newvpY+_viewportHeight>_tileEngine.boundary.bottom)
				newvpY = _tileEngine.boundary.bottom-_viewportHeight;
			
			//新的视图
			_currentViewport = new Rectangle(newvpX,newvpY,_viewportWidth,_viewportHeight);						
			//搜索到新瓦片
			var searchedTiles:Vector.<Tile> = _tileEngine.searchTilesSyncBy(_currentViewport);
			//不移动_tileGrid位置，只修改视窗对象，重新渲染
			_tileGrid.show(searchedTiles,_currentViewport);
		}
		
		/**
		 * 超出边界返回true，没有超出返回false;
		 */ 
		private function checkTouchBeyondViewport(tx:Number,ty:Number):Boolean{
			//目前只检查垂直边界
			if(ty>_viewportHeight) return true;
			return false;
		}
		
		//TODO, ADD MORE...
		override public function dispose():void{
			super.dispose();
			
			_tileEngine.dispose();
			_tileGrid.dispose();
		}
		
	} //end of class
}