package com.ybcx.huluntears.items{
	
	import com.ybcx.huluntears.events.GameEvent;
	
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * 道具栏中的道具基础类，负责通用功能：<br/>
	 * 点击可以触发道具克隆，生成跟随鼠标道具<br/>
	 * 被克隆道具在道具栏内重新点击，销毁克隆道具<br/>
	 * 道具可以被添加到场景中，用于完成任务<br/>
	 * 
	 * 2012/05/08
	 */ 
	public class BaseItem extends Sprite implements Iitem{
		
		private var _content:Bitmap;
		private var _touched:Boolean;
		private var _followable:Boolean;
		//碰撞检查位置
		private var _hitTestRect:Rectangle;
		//碰撞检测结果
		private var hitted:Boolean;
		
		
		public function BaseItem(){
			super();			
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, clearUp);
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function set globalHitTestRect(target:Rectangle):void{
			_hitTestRect = target;
		}
		
		private function onStage(evt:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, onStage);
			//FIXME, 只能在这个时候来添加对舞台的事件监听			
			this.stage.addEventListener(TouchEvent.TOUCH, onScreenTouch);
			
			if(this.name==null){
				trace("Warning, item must have a name !!!");
			}
		}
		
		private function clearUp(evt:Event):void{
			this.removeEventListeners(Event.REMOVED_FROM_STAGE);
			this.removeEventListeners(TouchEvent.TOUCH);
			this.stage.removeEventListener(TouchEvent.TOUCH, onScreenTouch);
		}
		
		private function onScreenTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this.stage);
			if(!touch) return;
			if(!_content) return;
			
			var centerX:Number = _content.width/2;
			var centerY:Number = _content.height/2;
			if(_followable && touch.phase==TouchPhase.HOVER){
				//让该对象跟随鼠标移动
				this.x = touch.globalX-centerX;
				this.y = touch.globalY-centerY;
				
				if(!_hitTestRect) return;
				
				if(this.bounds.intersects(_hitTestRect)){
					hitted = true;
					//FIXME, VISUAL FEEDBACK
//					this.alpha = 0.6;
				}else{
					hitted = false;
//					this.alpha = 1;
				}
				
			}// end of hover
		}
		
		private function onTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if(!touch) return;
			
			if(touch.phase==TouchPhase.ENDED){
				_touched = !_touched;
				var gmevt:GameEvent;
								
				
				//非跟随道具才能派发选中事件
				if(!_followable){					
					gmevt = new GameEvent(GameEvent.ITEM_SELECTED,this);
					this.dispatchEvent(gmevt);
					return;
				}
				
				if(_followable && touch.globalY>520){//在道具栏上点击时，移除道具
					gmevt = new GameEvent(GameEvent.ITEM_DESTROYED,this);
					this.dispatchEvent(gmevt);
					return;
				}
				
				//处于跟随鼠标状态...
				if(hitted){//碰撞成功
					gmevt = new GameEvent(GameEvent.HITTEST_SUCCESS,this);
					this.dispatchEvent(gmevt);					
				}else{//碰撞不成功，颤动
					gmevt = new GameEvent(GameEvent.HITTEST_FAILED,this);
					this.dispatchEvent(gmevt);
				}
				
			}
		}
				
		public function set content(bp:Bitmap):void{
			_content = bp;
			
			var img:Image = new Image(Texture.fromBitmap(bp));
			this.addChild(img);
		}
		
		public function get content():Bitmap{
			return _content;
		}
		
		public function get img():Image{
			if(this.numChildren) {
				return this.getChildAt(0) as Image;
			}
			return null;
		}
		
		public function set followable(follow:Boolean):void{
			_followable = follow;
		}
		
		public function clone():BaseItem{
			if(!_content) return new BaseItem();
			
			var cloned:BaseItem = new BaseItem();
			cloned.name = this.name;
			cloned.content = new Bitmap(_content.bitmapData.clone(),"auto",true);
			cloned.followable = true;

			return cloned;
		}
		
	} //end of class
}