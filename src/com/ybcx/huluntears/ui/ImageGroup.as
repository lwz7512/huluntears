package com.ybcx.huluntears.ui{
	
	import com.ybcx.huluntears.animation.FadeSequence;
	import com.ybcx.huluntears.items.BaseItem;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * 普通的图片组合，不能交互
	 */ 
	public class ImageGroup extends Sprite{
		
		private var hilite:Image;
		private var base:Image;
		
		private var baseW:Number = 350;
		private var baseH:Number = 350;
		
		private var ellipseX:Number = 50;
		private var ellipseY:Number = 150;
		private var ellipseW:Number = 250;
		private var ellipseH:Number = 100;
		
		private var buildingBlocks:Array = [];		
		
		
		private var flareOnce:FadeSequence;
		
		private var _hitTestRect:Rectangle;
		
		
		public function ImageGroup(){
			super();
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			drawBackground();
		}
		
		/**
		 * 全局区域
		 */ 
		public function get hitTestRect():Rectangle{
			var global:Point = this.localToGlobal(new Point(0,0));
			var rect:Rectangle = new Rectangle(global.x+_hitTestRect.x,global.y+_hitTestRect.y,
				_hitTestRect.width, _hitTestRect.height);
			return rect;
		}
		
		private function onTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if(!touch) return;
			
			if(touch.phase==TouchPhase.HOVER){
				if(!flareOnce) {
					flareOnce = new FadeSequence(hilite,0.2,3,false);
					flareOnce.start();
				}
			}
			
			if(touch.phase==TouchPhase.ENDED){
				
			}
		}
		
		private function drawBackground():void{
			var border:Shape = new Shape();
			//葱青：淡淡的青绿色
			border.graphics.lineStyle(1,0x0EB83A,0.8);
			border.graphics.beginFill(0xF5F5F5, 0.2);
			border.graphics.drawEllipse(ellipseX-2,ellipseY-2,ellipseW+4,ellipseH+4);
			border.graphics.endFill();
			
			var hilitebd:BitmapData = new BitmapData(baseW,baseH,true,0x020000FF);
			hilitebd.draw(border);
			hilite = new Image(Texture.fromBitmapData(hilitebd));
			this.addChild(hilite);
			//先隐藏了
			hilite.alpha = 0;
			
			var surface:Shape = new Shape();
			surface.graphics.beginFill(0xF5F5F5, 0.4);
			surface.graphics.drawEllipse(ellipseX,ellipseY,ellipseW,ellipseH);
			surface.graphics.endFill();
			
			//椭圆就是碰撞检测区域
			_hitTestRect = new Rectangle(ellipseX,ellipseY,ellipseW,ellipseH);
			
			var surfacebd:BitmapData = new BitmapData(baseW,baseH,true,0x0200FF00);
			surfacebd.draw(surface);
			base = new Image(Texture.fromBitmapData(surfacebd));
			this.addChild(base);
		}
		
		public function putBuildingBlock(item:BaseItem):void{
			buildingBlocks.push(item);
			this.addChild(item);
		}
		
		
	} //end of class
}