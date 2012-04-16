package com.ybcx.huluntears.map{
	
	import com.ybcx.huluntears.map.Tile;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * 瓦片容器<br/>
	 * 
	 * 2012/04/15
	 */ 
	public class TileGrid extends Sprite{
		
		private var _boundingRect:Rectangle;
		
		//当前显示区域内的瓦片
		private var _currTiles:Vector.<Tile>;			
				
		
		/**
		 * @param boundingRect, 总的地图大小，视窗变化时要与此比较
		 */ 
		public function TileGrid(boundingRect:Rectangle){
			super();
			
			_boundingRect = boundingRect;
			_currTiles = new Vector.<Tile>;
			
		}
		
		/**
		 * @param textures, 当前地图需要的位图
		 * @param viewport, 可见区域，可能被移动过的
		 * 
		 * 将新区域与老区域相比较，重叠的移动，区域外的剔除（culling），新区域的加载
		 */ 
		public function show(tiles:Vector.<Tile>, viewport:Rectangle):void{									
			//扩大显示范围
			viewport.bottom += 100;
			viewport.right += 100;
			
			//先显示
			for each(var tileToShow:Tile in tiles){				
				if(!this.contains(tileToShow)) {
					this.addChild(tileToShow);
					_currTiles.push(tileToShow);
				}
			}
			
			//后定位
			//相交的瓦片区域
			var intersection:Rectangle = viewport.intersection(_boundingRect);
			//相交区域的左上角位置
			var startPt:Point = new Point(intersection.x,intersection.y);
			
			//这个是难点，好费劲
			for each(var img:Tile in _currTiles){				
				img.x = img.topLeftX-startPt.x;
				img.y = img.topLeftY-startPt.y;
			}
			
			//剔除已显示的相对于新视窗外瓦片
			for (var i:int=_currTiles.length-1; i>0; i--){
				var tileShowed:Tile = _currTiles[i];
				if(!tileShowed.intersectWith(viewport)){
					//从数据集剔除
					_currTiles.splice(i,1);
					if(this.contains(tileShowed)){
						//从显示对象中剔除
						this.removeChild(tileShowed);						
					}
				}
			}
		}
		
		
		override public function dispose():void{
			super.dispose();
			
			_currTiles = null;
			this.removeChildren(1,-1,true);
		}
		
	} //end of class
}