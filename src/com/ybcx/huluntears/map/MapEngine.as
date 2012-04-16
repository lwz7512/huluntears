package com.ybcx.huluntears.map{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.map.Tile;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import starling.events.EventDispatcher;
	import starling.textures.Texture;
	
	/**
	 * 地图tile下载和查找引擎
	 * 
	 * 2012/04/10
	 */ 
	public class MapEngine extends EventDispatcher{
		
		private var _titleUrls:Vector.<String>;
		private var _matrix:Vector.<Rectangle>;
		
		private var _tileSize:Number = 100;
		private var _maxRow:int = 0;
		private var _maxCol:int = 0;
		
		//总地图边界
		private var _boundary:Rectangle;
		
		//贴图对象池
		private var _tilePool:Dictionary;
		
		//新得到的贴图
		private var _searchedTile:Vector.<Tile>;				
		
		//下载队列
		private var _queLoader:QueueLoader;
		
		/**
		 * 这里的tile图片必须是这样的格式：xxxx_xxxx_00_00.png<br/>
		 * 即：英文图片名_行索引_列索引.png
		 * 
		 * 2012/04/10
		 */ 
		public function MapEngine(titleUrls:Vector.<String>){
			_titleUrls = titleUrls;
			_tilePool = new Dictionary();
			
			//构建瓦片池
			buildMesh();			
			
			//下载队列
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);
		}
		
		private function buildMesh():void{
			if(!_titleUrls) return;
			var tile:Tile;
			for each(var imgUrl:String in _titleUrls){
				var rowIndex:Number = Number(imgUrl.split("_")[2]);
				//xx.png
				var colPointImg:String = imgUrl.split("_")[3];
				var colIndex:Number = Number(colPointImg.split(".")[0]);
				
				if(rowIndex>_maxRow) _maxRow = rowIndex;
				if(colIndex>_maxCol) _maxCol = colIndex;
				
				tile = new Tile(rowIndex,colIndex,_tileSize);
				tile.url = imgUrl;
				//FIXME, 这个KEY必须是字符串，否则字典中找不到值
				//2012/04/16
				var key:String = rowIndex+"_"+colIndex;
				_tilePool[key] = tile;
				
			}
			//FIXME, 这个行列数与宽高老搞反
			//2012/04/17
			_boundary = new Rectangle(0,0,(_maxCol+1)*_tileSize,(_maxRow+1)*_tileSize);								
		}
		
		public function get boundary():Rectangle{
			return _boundary;
		}
		

		
		/**
		 * 同步获取瓦片方法，在缓存中找，没找着返回框框；
		 * synchronous
		 */ 
		public function searchTilesSyncBy(drawArea:Rectangle):Vector.<Tile>{
						
			//相交的瓦片区域
			var intersection:Rectangle = drawArea.intersection(_boundary);
			
			_searchedTile = new Vector.<Tile>;
			var tile:Tile;
			for(var rowcol:String in _tilePool){
				tile = Tile(_tilePool[rowcol]);
				if(tile.intersectWith(intersection)){
					//找到了，要显示的瓦片
					_searchedTile.push(tile);										
				}
			}
			//检查是否已经获取到图片，没有的话发起请求
			searchTilesAsycBy(_searchedTile);
			
			
			return _searchedTile;
		}
		
		/**
		 * 异步获取瓦片方法，从远程获取，找到后更新对象；
		 * asynchronous
		 */
		private function searchTilesAsycBy(targets:Vector.<Tile>):void{
			if(targets.length==0){
				trace("warning! to searched tile set is blank....");
				return;
			}
			//加载状态下不再搜索
			if(_queLoader.loading) return;
			
			for each(var tile:Tile in targets){
				if(!tile) trace("warning, tile to searched is null!");
				if(tile && !tile.initialized && !_queLoader.getItemByTitle(tile.url)){//如果没有初始化图片纹理
					_queLoader.addItem(tile.url,null, {title : tile.url});					
				}
			}
			if(_queLoader.getQueuedItems().length && !_queLoader.loading)
				_queLoader.execute();
		}
		
		//更新瓦片显示
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			for each(var tile:Tile in _searchedTile){
				if(tile.url==evt.title) {
					tile.texture = Texture.fromBitmap(evt.content);					
				}				
			}			
		}
		//清理队列
		private function onQueComplete(evt:QueueLoaderEvent):void{
			while(_queLoader.getLoadedItems().length){
				_queLoader.removeItemAt(_queLoader.getLoadedItems().length-1);
			}
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		
		public function dispose():void{
			_tilePool = null;
		}
		
		
	} //end of class
}