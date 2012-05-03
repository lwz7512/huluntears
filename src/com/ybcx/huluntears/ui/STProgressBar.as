package com.ybcx.huluntears.ui{
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	/**
	 * Starling框架下的简单进度条
	 * 取名STxxx，意思是基于Starling引擎
	 * 
	 * 2012/04/09
	 */ 
	public class STProgressBar extends Sprite{
		
		private var _color:uint;
		private var _width:int;
		private var _height:int;
		
		private var _progress:Number;
		
		private var _shape:Shape;
		private var _bufferBitmap:BitmapData;
		
		private var _texture:Texture;
		private var _image:Image;
		
		private var _title:starling.text.TextField;
		
		
		public function STProgressBar(rgb:uint=0xCCCCCC, width:Number=100, height:Number=2, title:String="loading..."){
			super();
			
			_color = rgb;
			//绘制的最终长度，每次绘制都要用百分比乘以这个数得到当前的宽度
			_width = width;
			//进度条高度
			_height = height;
			//初始化时，有一个画满的背景条
			_bufferBitmap = new BitmapData(width,height,true, 0x33F5F5F5);
			_texture = Texture.fromBitmapData(_bufferBitmap);
			_image = new Image(_texture);				
			this.addChild(_image);
			
			//提示
			if(title){				
				_title = new starling.text.TextField(200, 20,title);	
//				_title.color = 0x00FF00;
				_title.x = _width-200 >> 1;
				_title.y = -20;
				this.addChild(_title);
			}
		}
		
		/**
		 * 实时更新百分比，绘制进度条
		 */ 
		public function set progress(percent:Number):void{
			_progress = percent;
			//redraw ...
			redraw();
		}
		
		private function redraw():void{
			var currentWidth:Number = _progress*_width;
			//如果为0时，清空
			if(_progress<=0){
				_bufferBitmap = new BitmapData(width,height,true, 0x33F5F5F5);
				_texture = Texture.fromBitmapData(_bufferBitmap);
				_image.texture = _texture;
				return;
			}
			
			_shape = new Shape();
			_shape.graphics.beginFill(_color);
			_shape.graphics.drawRect(0,0,currentWidth,_height);
			_shape.graphics.endFill();
			
			_bufferBitmap.draw(_shape);
			_texture = Texture.fromBitmapData(_bufferBitmap);
			_image.texture = _texture;
		}
		
	} //end of class
}