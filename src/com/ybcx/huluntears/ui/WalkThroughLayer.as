package com.ybcx.huluntears.ui{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.events.GameEvent;
	
	import flash.display.Bitmap;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	
	/**
	 * 攻略弹出层
	 * 
	 * 2012/04/25
	 */ 
	public class WalkThroughLayer extends STPopupView{
		//攻略图背景
		private var totalRaiderPath:String = "assets/sceaobao/Raiders Preview_bg.png";
		
		private var firstRaiderPath:String = "assets/sceaobao/1_tool_Raiders_1_s.png";
		private var firstRaiderImg:Image;
		
		//下载队列
		private var _queLoader:QueueLoader;					
		private var _loadCompleted:Boolean;
		
		//指定那个详细攻略可以启用了
		private var _showRaiderIndex:int;
		
		
		
		
		
		public function WalkThroughLayer(width:Number, heigh:Number){
			super(width, heigh);
			
			//下载队列
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);
			
			//黑色背景
			this.maskColor = 0xCC000000;
		}
		
		
		override protected function onStage(evt:Event):void{
			super.onStage(evt);
			
			if(_loadCompleted) return;
			
			//FIXME, 目前只能看第一关攻略图，后面捡到地图后可以看剩余攻略图
			//2012/04/25
			_queLoader.addItem(totalRaiderPath,null, {title : totalRaiderPath});
			_queLoader.addItem(firstRaiderPath,null, {title : firstRaiderPath});
			
			//发出请求
			_queLoader.execute();
		}
		
		/**
		 * 显示哪个攻略
		 */ 
		public function availableRaider(index:int):void{
			_showRaiderIndex = index;
		}
		
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			if(evt.title==totalRaiderPath){
				this.background = evt.content as Bitmap;
			}
			if(evt.title==firstRaiderPath){
				
				firstRaiderImg = new Image(Texture.fromBitmap(evt.content as Bitmap));
				firstRaiderImg.x = 4;
				firstRaiderImg.y = 214;
				this.addChild(firstRaiderImg);
				firstRaiderImg.addEventListener(TouchEvent.TOUCH, onFirstRaiderTouched);
				if(_showRaiderIndex>=1){
					firstRaiderImg.visible = true;
				}else{
					firstRaiderImg.visible = false;
				}				
				
			}
		}
		
		private function onFirstRaiderTouched(evt:TouchEvent):void{
			//FIXME, 监听第一关攻略图
			var touch:Touch = evt.getTouch(firstRaiderImg);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				var gameEvent:GameEvent = new GameEvent(GameEvent.RAIDER_TOUCHED,1);
				dispatchEvent(gameEvent);
			}
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		private function onQueComplete(evt:QueueLoaderEvent):void{
			while(_queLoader.getLoadedItems().length){
				_queLoader.removeItemAt(_queLoader.getLoadedItems().length-1);
			}
			
			_loadCompleted = true;
			
		}
		
	} //end of class
}