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
	 * 普通的图片组合，不能交互，用于放置道具时，做碰撞检测<br/>
	 * 作为搭建物体时的基础图形提示<br/>
	 * 此外还保存着道具放置时的顺序规则
	 * 
	 * 2012/05/09
	 */ 
	public class ImageGroup extends Sprite{
		
		private var hilite:Image;
		private var base:Image;
		private var flareOnce:FadeSequence;
		
		private var baseW:Number = 350;
		private var baseH:Number = 350;
		
		private var ellipseX:Number = 50;
		private var ellipseY:Number = 150;
		private var ellipseW:Number = 250;
		private var ellipseH:Number = 100;
		
		private var _hitTestRect:Rectangle;
		
		//可以接收的道具名称，按顺序放置，相应的有个计数器来保持放置的状态
		private var buildingBlocks:Array = [];
		//保持当前待放置道具的索引，放置成功后加一
		private var buildingIndex:int = 0;
		
		
		
		
		public function ImageGroup(){
			super();
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			drawBackground();
		}
		
		/**
		 * 接收的道具名称，按顺序放置
		 */ 
		public function set acceptNames(names:Array):void{
			buildingBlocks = names;
		}
		
		/**
		 * 接收一个道具
		 */ 
		public function acceptItem(itemName:String):Boolean{
			if(!buildingBlocks.length) return false;
			
			var result:int = buildingBlocks.indexOf(itemName);
			if(result==buildingIndex){
//				trace("to put item: "+itemName);
				//成功接受，准备放下一个
				buildingIndex ++;
				return true;
			}else{
				return false;
			}
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
					flareOnce = new FadeSequence(hilite,0.2,4,false);
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
			surface.graphics.beginFill(0xF5F5F5, 0.6);
			surface.graphics.drawEllipse(ellipseX,ellipseY,ellipseW,ellipseH);
			surface.graphics.endFill();
			
			//椭圆就是碰撞检测区域
			_hitTestRect = new Rectangle(ellipseX,ellipseY,ellipseW,ellipseH);
			
			var surfacebd:BitmapData = new BitmapData(baseW,baseH,true,0x0200FF00);
			surfacebd.draw(surface);
			base = new Image(Texture.fromBitmapData(surfacebd));
			this.addChild(base);
		}
		
		
	} //end of class
}