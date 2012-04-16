package com.ybcx.huluntears.scenes.base{
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * 游戏场景父类，实现基础功能
	 * 
	 * 2012/04/06
	 */ 
	public class BaseScene extends Sprite implements IScene{
		
		public function BaseScene(){
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		/**
		 * 延迟生成子对象方法
		 */ 
		protected function onStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);
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