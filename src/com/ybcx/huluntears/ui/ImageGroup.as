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
		
		[Embed(source="assets/mgb/mgb_frame.png")]
		private var MgbFrame:Class;
		
		private var hilite:Image;
		private var base:Image;
		private var flareOnce:FadeSequence;
		
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
			//考虑到层移动
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
						
		}
		
		//TODO, 放蒙古包水印图片进去...
		private function drawBackground():void{
			
			hilite = new Image(Texture.fromBitmap(new MgbFrame()));
			this.addChild(hilite);
			hilite.scaleX = 1.02;
			hilite.scaleY = 1.02;
			//先隐藏了
			hilite.alpha = 0;	
			hilite.x = -1;
			hilite.y = -1;
									
			base = new Image(Texture.fromBitmap(new MgbFrame()));
			this.addChild(base);
			base.alpha = 0.1;
			
			//椭圆就是碰撞检测区域
			_hitTestRect = new Rectangle(0,0,base.width,base.height);
		}
		
		
	} //end of class
}