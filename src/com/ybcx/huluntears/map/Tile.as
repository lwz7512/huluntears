package com.ybcx.huluntears.map{
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * 带行列数的图片，方便地图布局
	 * 
	 * 2012/04/10
	 */ 
	public class Tile extends Image{
		
		/**
		 * 大小尺寸，默认正方形，100像素
		 */ 
		public static const SIZE:Number = 100;
		/**
		 * 行索引决定Y位置
		 */ 
		private var _rowIndex:int;
		/**
		 * 列索引，决定X位置
		 */ 
		private var _columnIndex:int;
		
		//对应的图片地址
		private var _url:String;
		
		//是否被初始化地图数据，默认只是个框框
		private var _initialized:Boolean;
		
		
		public function Tile(rowIndex:int, columnIndex:int, size:Number=100){						
			var border:Shape = new Shape();
			//FIXME, 这里至少2个像素宽才看得见
			//2012/04/15
			border.graphics.lineStyle(1,0x000000);
			border.graphics.drawRect(0,0,size,size);
			var bd:BitmapData = new BitmapData(SIZE,SIZE,true,0x000000);
			bd.draw(border);
			
			var blankTX:Texture = Texture.fromBitmapData(bd);
			super(blankTX);
			
			_rowIndex = rowIndex;
			_columnIndex = columnIndex;
						
		}
		
		public function get topLeftX():Number{
			return _columnIndex*SIZE;
		}
		public function get topLeftY():Number{
			return _rowIndex*SIZE;
		}
		
		public function set url(v:String):void{
			_url = v;			
		}
		public function get url():String{
			return _url;
		}
		
		public function get initialized():Boolean{
			return _initialized;
		}
				
		/**
		 * 得到行数，从而计算出在地图中的Y值
		 */ 
		public function get rowIndex():int{
			return _rowIndex;
		}
		/**
		 * 得到列数，从而计算出在地图中的X值
		 */ 
		public function get columnIndex():int{
			return _columnIndex;
		}
		
		/**
		 * 放在大地图的背景下比较
		 */ 
		public function contain(pt:Point):Boolean{
			var rect:Rectangle = new Rectangle(_columnIndex*SIZE,_rowIndex*SIZE,SIZE,SIZE);
			
			if(rect.containsPoint(pt)) return true;
			return false;
		}
		/**
		 * 放在大地图的背景下比较
		 */ 
		public function intersectWith(viewport:Rectangle):Boolean{
			var rect:Rectangle = new Rectangle(_columnIndex*SIZE,_rowIndex*SIZE,SIZE,SIZE);
			if(rect.intersects(viewport)) return true;
			return false;
		}
		
		/**
		 * 判断两个纹理是否位置相同，做替换处理
		 */ 
		public function equalWith(row:int, col:int):Boolean{
			if(row==_rowIndex && col==_columnIndex) return true;
			return false;
		}		

		
		override public function set texture(value:Texture):void{
			if(_initialized) return;
			super.texture = value;
			_initialized = true;
		}
		
		
	} //end of class
}