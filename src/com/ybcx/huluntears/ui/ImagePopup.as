package com.ybcx.huluntears.ui{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	
	import flash.display.Bitmap;
	
	import starling.events.Event;
	
	
	/**
	 * 简单的弹出图片
	 * 
	 * 2012/04/25
	 */ 
	public class ImagePopup extends STPopupView{
		
		private var _imgPath:String;
		
		//下载队列
		private var _queLoader:QueueLoader;					
		private var _loadCompleted:Boolean;
		
		
		
		public function ImagePopup(width:Number, heigh:Number){
			super(width, heigh);
			
			//下载队列
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
		}
		
		override protected function onStage(evt:Event):void{
			super.onStage(evt);
			
			if(_loadCompleted) return;
			
			if(!_imgPath) return;
			
			_queLoader.addItem(_imgPath,null, {title : _imgPath});
			
			//发出请求
			_queLoader.execute();
		}			
		
		/**
		 * 指定要显示的图片路径
		 */ 
		public function set imgPath(path:String):void{
			_imgPath = path;
		}
		
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			if(evt.title==_imgPath){
				this.background = evt.content as Bitmap;	
				_loadCompleted = true;
			}
			
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		
	} //end of class
}