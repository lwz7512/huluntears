package com.ybcx.huluntears.ui{
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	
	
	public class AutoDisappearTip extends STPopupView{
		
		private var _message:String = "hi";
		private var onStageCounter:int;
		
		private var durationSeconds:int = 3;
		
		public function AutoDisappearTip(width:Number=200, heigh:Number=20){
			super(width, heigh);
			//不要背景图了
			this.useBackground = false;
			this.addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function onFrame(evt:Event):void{
			onStageCounter++;
			var frameRate:int = Starling.current.nativeStage.frameRate;
			if(onStageCounter>durationSeconds*frameRate){
				this.removeFromParent(true);
			}
		}
		
		/**
		 * 设置显示内容
		 */ 
		public function set message(msg:String):void{
			_message = msg;
		}
				
		override protected function createPopupContent():void{
			var _text:TextField = new TextField();
			_text.text = _message;			
			_text.autoSize = "left";
			_text.x = 4;
			_text.y = 4;
			var toastWidth:Number = _text.textWidth+12;
			var toastHeight:Number = _text.textHeight+12;
			this.updateSize(toastWidth,toastHeight);
			
			var origTFContainer:Sprite = new Sprite();
			origTFContainer.addChild(_text);
			//边框清晰模式
			origTFContainer.graphics.lineStyle(1, 0x666666, 1, true);
			origTFContainer.graphics.beginFill(0xfff143,0.8);
			origTFContainer.graphics.drawRoundRect(0,0,toastWidth, toastHeight,6,6);
			origTFContainer.graphics.endFill();
			
			origTFContainer.filters = [new DropShadowFilter(4,45,0x666666,0.8)];
			//FIXME, 留出阴影的大小
			//2012/05/06
			var textBD:BitmapData = new BitmapData(toastWidth+4,toastHeight+4,true,0x00000000);
			textBD.draw(origTFContainer);
			var textBlock:Image = new Image(Texture.fromBitmapData(textBD));
			textBlock.x = 0;
			this.addChild(textBlock);
		}
		
	} //end of class
}