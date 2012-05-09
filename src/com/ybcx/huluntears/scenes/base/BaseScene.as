package com.ybcx.huluntears.scenes.base{
	
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.ui.BottomToolBar;
	import com.ybcx.huluntears.utils.ImageQueLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * 游戏场景父类，实现基础功能
	 * 
	 * 2012/04/06
	 */ 
	public class BaseScene extends Sprite implements IScene{
		
		/**
		 * 下载完成，也就是场景初始化完成的标志，场景场景再次显示时据此跳过加载过程
		 */ 
		private var _loadCompleted:Boolean;
		
		//下载队列
		private var _queLoader:ImageQueLoader;
		
		//玻璃板
		private var _touchBoard:Image;		
		//道具栏
		private var _toolBar:BottomToolBar;
		
		//总下载数
		private var queLength:int;
		//已下载数
		private var loadedCount:int;
		
		//碰撞监测对象
		protected var hitTestDO:DisplayObject;
		
		
		//------------- begin to build scene ------------------
		public function BaseScene(){
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, offStage);
			
			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		
		/**
		 * 当前场景中散落的道具列表，子类需要重载
		 */ 
		public function get itemsToPickup():Array{
			return [];
		}
		
		/**
		 * 是否允许放置当前选择的道具，需要子类重载
		 */ 
		public function allowToPut(itemName:String):Boolean{
			return false;
		}
		
		/**
		 * 子类要重载，实现碰撞检测后的动作
		 */ 
		public function putItemHitted(img:Image, where:Point):void{
			
		}
		
		/**
		 * 每个场景，当前只激活一个待碰撞检查对象，用于道具与之交互
		 */ 
		public function get hitTestItem():DisplayObject{
			return hitTestDO;
		}
		
		/**
		 * 碰撞检查矩形
		 */
		public function get hitTestRect():Rectangle{
			return null;
		}
		
		/**
		 * 是否加载图片完成，用来判断是否在显示场景时出加载画面
		 */ 
		public function get initialized():Boolean{
			return _loadCompleted;
		}
		
		
		public function set toolbar(tb:BottomToolBar):void{
			_toolBar = tb;
		}
		public function get toolbar():BottomToolBar{
			return _toolBar;
		}
		
		/**
		 * 延迟生成子对象方法
		 */ 
		private function onStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);
			
			if(_loadCompleted) return;					
			
			//玻璃板只创建一次
			//场景底部加个透明玻璃板，好响应鼠标动作
			//后添加玻璃板，铺满整个应用
			var bd:BitmapData = new BitmapData(this.stage.stageWidth,this.stage.stageHeight,true,0x01FFFFFF);						
			var tx:Texture = Texture.fromBitmapData(bd);
			_touchBoard = new Image(tx);
			this.addChild(_touchBoard);				
			
			//下载队列
			_queLoader = new ImageQueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onQueueProgress);		
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueueComplete);
			
			//可以初始化场景其他元素了
			initScene();
		}
		
		/**
		 * 清理资源方法
		 */
		private function offStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);
			detached();
		}
		
		/**
		 * 供子类去实现初始化，不需要判断是否已经初始化过了
		 */ 
		protected function initScene():void{
			
		}
		/**
		 * 添加下载任务
		 */ 
		protected function addDownloadTask(src:String):void{
			_queLoader.addImageByUrl(src);
		}
		/**
		 * 获得下载的图片
		 */ 
		protected function getImageByUrl(src:String):Image{
			return _queLoader.getImageByUrl(src);
		}
		
		/**
		 * 获得下载的位图对象
		 */ 
		protected function getBitmapByUrl(src:String):Bitmap{
			return _queLoader.getBitmapByUrl(src);
		}
		
		/**
		 * 获得下载的材质
		 */ 
		protected function getTextrByUrl(src:String):Texture{
			return _queLoader.getTextrByUrl(src);
		}
		
		
		/**
		 * 开始下载图片
		 */
		protected function download():void{
			queLength = _queLoader.getQueuedItems().length;			
			_queLoader.execute();
		}
		
		
		/**
		 * 从舞台移除后执行的动作 
		 */
		protected function detached():void{
			
		}
		
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			//累加
			loadedCount++;
		}
		
		private function onQueueProgress(evt:QueueLoaderEvent):void{
			var totalPercent:Number = (evt.percentage+loadedCount)/queLength;
			var progress:GameEvent = new GameEvent(GameEvent.LOADING_PROGRESS,totalPercent);
			this.dispatchEvent(progress);
		}
		/**
		 * 子类必须重载此方法，以完成状态更改和资源清理
		 */ 
		private function onQueueComplete(evt:QueueLoaderEvent):void{
			var complete:GameEvent = new GameEvent(GameEvent.LOADING_COMPLETE);
			this.dispatchEvent(complete);
			
			//不能销毁加载器，但是可以移除事件监听
			//因为还要从加载器中取图片对象
			while(_queLoader.getLoadedItems().length){
				_queLoader.removeItemAt(_queLoader.getLoadedItems().length-1);
			}
			_queLoader.removeEventListener("ITEM_COMPLETE",onItemLoaded);
			_queLoader.removeEventListener("QUEUE_COMPLETE",onQueueComplete);
			_queLoader.removeEventListener("QUEUE_PROGRESS",onQueueProgress);
			_queLoader.removeEventListener("ITEM_ERROR",onItemError);
			
			_loadCompleted = true;
			
			readyToShow();
		}
		
		/**
		 * 可以显示已经下载的资源了
		 */
		protected function readyToShow():void{
			
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		
		/**
		 * 处理返回按钮
		 */ 
		private function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			onTouching(touch);
			if(!touch) return;
			
			if(touch.phase==TouchPhase.ENDED){
				onTouched(touch);
			}
		}
		
		/**
		 * 鼠标在场景中的动作
		 */ 
		protected function onTouching(touch:Touch):void{
			
		}
		/**
		 * 点击一次
		 */
		protected function onTouched(touch:Touch):void{
			
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