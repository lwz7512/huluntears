package com.ybcx.huluntears.items{
	
	import com.ybcx.huluntears.animation.MotionTo;
	import com.ybcx.huluntears.events.GameEvent;
	
	import flash.display.Bitmap;
	import flash.geom.Point;
	
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * 准道具，散落在场景中，可以被点击后自动飞到道具栏中的相应占位符上<br/>
	 * 到目标位置上后，生成道具对象，然后该图片消失，占位符消失<br/>
	 * 要在道具移动层中使用
	 * 
	 * 2012/05/08
	 */ 
	public class PickupImage extends Image{
		
		//保存一个位图对象，好方便给道具栏用
		private var _bitmap:Bitmap;
		
		private var _destinationX:Number = 0;
		private var _destinationY:Number = 0;
		
		//即将要做碰撞检查的点
		private var _hitTestPoint:Point;
		
		public function PickupImage(texture:Texture){
			super(texture);			
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function set bitmap(bp:Bitmap):void{
			_bitmap = bp;
		}
		
		public function get bitmap():Bitmap{
			return _bitmap;
		}
		
		/**
		 * 准道具要运动到的目的地位置
		 */ 
		public function disppearedPos(dx:Number, dy:Number):void{
			_destinationX = dx;
			_destinationY = dy;
		}
		
		private function onTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this,TouchPhase.ENDED);			
			if(!touch) return;				
			
			var foundEvt:GameEvent = new GameEvent(GameEvent.ITEM_FOUND,this);
			dispatchEvent(foundEvt);
			
		}
		
		public function flying(onStop:Function):void{
			new MotionTo(this,_destinationX,_destinationY,onStop, 0.6);		
		}
				
		
		
	} //end of class
}