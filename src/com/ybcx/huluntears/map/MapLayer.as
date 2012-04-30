package com.ybcx.huluntears.map{
	
	import com.ybcx.huluntears.data.XMLoader;
	import com.ybcx.huluntears.map.MapEngine;
	import com.ybcx.huluntears.map.Tile;
	import com.ybcx.huluntears.map.TileGrid;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import starling.display.DisplayObject;
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
		
		//初始化结束标志
		private var _loadCompleted:Boolean;
		
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
		//上一次视窗位置，移动道具时计算偏移量
		private var _lastViewport:Rectangle;
		
		
		//道具容器，位于顶部
		private var _itemsContainer:Sprite;
		//道具位置管理
		private var _itemsPositions:Dictionary;
		
		
		
		public function MapLayer(){
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);		
			//FIXME, 暂时不用鼠标拖动操作了，而是感应鼠标位置
			//2012/04/23
			//还是拖拽比较方便
			//2012/04/30
			this.addEventListener(TouchEvent.TOUCH, onDragMap);
		}
		
		private function onStage(evt:Event):void{
			
			if(_loadCompleted) return;
			
			_itemsPositions = new Dictionary();
			
			//黑色背景色
			var background:Quad = new Quad(_viewportWidth,_viewportHeight+100,0x000000);
			this.addChild(background);
			
			//建立地图视窗大小，默认在地图左上角
			//鼠标拖动时改变这个对象
			_currentViewport = new Rectangle(_initViewportX,_initViewportY,_viewportWidth,_viewportHeight);			
			
			//后添加玻璃板，铺满整个应用
			var bd:BitmapData = new BitmapData(this.stage.stageWidth,this.stage.stageHeight,true,0x01FFFFFF);						
			var tx:Texture = Texture.fromBitmapData(bd);
			_touchBoard = new Image(tx);
			this.addChild(_touchBoard);
			
			//添加道具层
			//2012/04/24
			_itemsContainer = new Sprite();
			this.addChild(_itemsContainer);
			
			
		}
		
		/**
		 * 添加道具，使得道具与地图背景同时移动
		 */ 
		public function addItemAt(item:DisplayObject, pos:Point):void{
			item.x = pos.x-_currentViewport.x;
			item.y = pos.y-_currentViewport.y;
			//放到道具容器中
			_itemsContainer.addChild(item);
			//记下位置，其实也没用到
			_itemsPositions[item] = new Point(pos.x-_currentViewport.x,pos.y-_currentViewport.y);			
		}
		
		public function set urls(titleUrls:Vector.<String>):void{			
			_tileEngine = new MapEngine(titleUrls);
			//先添加TileGrid，模拟手势移动
			_tileGrid = new TileGrid(_tileEngine.boundary);
			//开始放置时，静止，没有偏移量
			moveMap(0,0);
			//FIXME, 放在背景之上
			this.addChildAt(_tileGrid,1);
			
			_loadCompleted = true;
			
			//参考线
//			var bd:BitmapData = new BitmapData(this.stage.stageWidth,2);			
//			var ref:Image = new Image(Texture.fromBitmapData(bd));
//			ref.y = _viewportHeight;
//			this.addChild(ref);
		}
		
		/**
		 * @deprecated at 2012/04/30
		 */ 
		private function onTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if (touch == null) {
//				trace("do not touched ...");
				this.removeEventListeners(Event.ENTER_FRAME);
				return;
			}
			//检测边缘宽度
			var detectWidth:Number = 50;
			var stepLength:Number = 2;
			var hSpeed:Number = 0;
			var vSpeed:Number = 0;
			
			//右侧区域
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-detectWidth && 
				touch.globalY<AppConfig.VIEWPORT_HEIGHT-detectWidth &&
				touch.globalY>detectWidth){
				hSpeed = -stepLength;
				vSpeed = 0;
			}
			//左侧区域
			if(touch.globalX<detectWidth && touch.globalY>detectWidth &&
				touch.globalY<AppConfig.VIEWPORT_HEIGHT-detectWidth){
				hSpeed = stepLength;
				vSpeed = 0;
			}
			//顶部区域
			if(touch.globalY<detectWidth){
				hSpeed = 0;
				vSpeed = stepLength;
			}
			//底部区域
			if(touch.globalY>AppConfig.VIEWPORT_HEIGHT-detectWidth*1.5){
				hSpeed = 0;
				vSpeed = -stepLength;
			}
			
			this.addEventListener(Event.ENTER_FRAME,function():void{
				//移动地图的逻辑都在该方法中了				
				moveMap(hSpeed, vSpeed);				
			});
			
			//中间区域，停止运动
			if(touch.globalX>detectWidth && touch.globalX<AppConfig.VIEWPORT_WIDTH-detectWidth &&
				touch.globalY>detectWidth && touch.globalY<AppConfig.VIEWPORT_HEIGHT-detectWidth*1.5){
				//必须移除监听，才能停止运动
				this.removeEventListeners(Event.ENTER_FRAME);
				hSpeed = 0;
				vSpeed = 0;
			}								
			
		}//end of onTouch function
		
		/**
		 * 鼠标拖动地图移动，暂时不用了
		 * @deprecated
		 * 
		 * 2012/04/23
		 */ 
		private function onDragMap(evt:TouchEvent):void{
			
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
			
		}
		
		/**
		 * 通过鼠标移动地图，主要是改变视窗大小，然后瓦片网格重新渲染
		 * 渲染的前提是地图引擎能根据视窗的大小获得相应的材质图片
		 */ 
		private function moveMap(diffX:Number, diffY:Number):void{
			//先记下上次的视窗位置
			_lastViewport = new Rectangle(_currentViewport.x,_currentViewport.y,_viewportWidth,_viewportHeight);
			
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
			
			var moveDiffX:Number = _lastViewport.x-_currentViewport.x;
			var moveDiffY:Number = _lastViewport.y-_currentViewport.y;			
			//为道具改变位置
			moveItems(moveDiffX, moveDiffY);
		}
		
		private function moveItems(moveDiffX:Number, moveDiffY:Number):void{
			for(var image:Object in _itemsPositions){
				image.x += moveDiffX;
				image.y += moveDiffY;
			}
		}
		
		/**
		 * 超出边界返回true，没有超出返回false;
		 */ 
		private function checkTouchBeyondViewport(tx:Number,ty:Number):Boolean{
//			trace("ty: "+ty+"/vpheight:"+_viewportHeight);
			//目前只检查垂直边界
			if(ty>_viewportHeight-30) return true;
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