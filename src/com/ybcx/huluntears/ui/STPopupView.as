package com.ybcx.huluntears.ui{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
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
	 * 弹出窗口的基础类，可以是提示、对话框、介绍内容等等
	 * 
	 * 2012/04/10
	 */ 
	public class STPopupView extends Sprite{
		
		private var _width:Number;
		private var _height:Number;
		
		private var _loadingTF:TextField;
		
		private var _bgBm:Bitmap;
		private var _bg:Image;
		private var _maskLayer:Image;
		
				
		
		
		public function STPopupView(width:Number, heigh:Number){
			super();
			
			_width = width;
			_height = heigh;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);
			var maskColor:uint = 0x01FFFFFF;
			var maskBitmapData:BitmapData = new BitmapData(this.stage.stageWidth,this.stage.stageHeight,true,maskColor);
			_maskLayer = new Image(Texture.fromBitmapData(maskBitmapData));
			_maskLayer.x = -this.localToGlobal(new Point(0,0)).x;
			_maskLayer.y = -this.localToGlobal(new Point(0,0)).y;
			this.addChild(_maskLayer);
			
			_loadingTF = new TextField(200,20,"加载窗口...","宋体",12,0x666666);
			_loadingTF.x = _width - 200 >> 1;
			_loadingTF.y = _height - 20 >> 1;
			this.addChild(_loadingTF);
			
		}
		
		//点击移除
		private function onTouch(evt:TouchEvent):void{
			if(!_bg) return;
			
			var touch:Touch = evt.getTouch(this);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				this.removeChildren(0,-1,true);
				this.removeFromParent(true);				
			}
		}
		
		public function set background(bm:Bitmap):void{
			if(!bm) return;
			
			_bgBm = bm;					
			
			_bg = new Image(Texture.fromBitmap(_bgBm));
			_bg.addEventListener(Event.ADDED_TO_STAGE, onBGReady);
			this.addChild(_bg);
		}
		public function get background():Bitmap{
			return _bgBm;
		}
		
		override public function get width():Number{
			return _width;
		}
		override public function get height():Number{
			return _height;
		}
		
		private function onBGReady(evt:Event):void{
			evt.target.removeEventListener(evt.type, arguments.callee);
			this.removeChild(_loadingTF);
			createPopupContent();
		}
		
		/**
		 * 子类用来重载创建可视内容
		 */ 
		public function createPopupContent():void{
			
		}
		
		/**
		 * 子类最好也重载这个方法
		 */ 
		override public function dispose():void{
			super.dispose();
			
			_loadingTF = null;
			_bg = null;
			_maskLayer = null;
		}
		
	} //end of class
}