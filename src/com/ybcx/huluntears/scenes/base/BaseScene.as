package com.ybcx.huluntears.scenes.base{
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * 游戏场景父类，实现基础功能
	 * 
	 * 2012/04/06
	 */ 
	public class BaseScene extends Sprite implements IScene{
		
		public function BaseScene(){
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, offStage);
			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		/**
		 * 延迟生成子对象方法
		 */ 
		protected function onStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);
		}
		/**
		 * 清理资源方法
		 */
		protected function offStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);
		}
		
		/**
		 * 处理返回按钮
		 */ 
		protected function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			onTouching(touch);			
		}
		
		/**
		 * 一次点击场景结束
		 */ 
		protected function onTouching(touch:Touch):void{
			
		}
		
		/**
		 * 暂时没用处
		 */ 
		public function onStart():void{
			
		}
		/**
		 * 暂时没用处
		 */
		public function onStop():void{
			
		}
		
	} //end of class
}