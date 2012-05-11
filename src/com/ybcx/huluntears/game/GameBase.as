package com.ybcx.huluntears.game{
	
	import com.ybcx.huluntears.animation.FadeIn;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class GameBase extends Sprite{
		
		public function GameBase(){
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		private function onStage(evt:Event):void{
			this.removeEventListeners(Event.ADDED_TO_STAGE);
			init();
		}
		
		/**
		 * 初始化游戏各种对象
		 */ 
		protected function init():void{
			
		}
		
		/**
		 * 不要加运动效果，否则居中弹出层有问题
		 */ 
		protected function centerMessage(view:DisplayObject):void{
			var endX:Number = this.stage.stageWidth-view.width >>1;
			var endY:Number = this.stage.stageHeight-view.height >>1;
			new FadeIn(view);
			view.x = endX;
			view.y = endY;
		}
		
		protected function clearContainer(cntinr:DisplayObjectContainer):void{
			cntinr.removeChildren(0,-1,true);
		}
		
		protected function moveToTop(display:DisplayObject):void{
			this.setChildIndex(display,this.numChildren-1);
		}
		
	} //end of class
}