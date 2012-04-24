package com.ybcx.huluntears.ui{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.events.GameEvent;
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * 底部道具栏，需要与各游戏场景交互，所以作为一个参数传递到场景中
	 * 道具栏在开场动画开始时，进行加载，在进入场景时即可使用
	 * 
	 * 2012/04/22
	 */ 
	public class BottomToolBar extends Sprite{
		
		//道具栏背景
		private var _toolBackgroundPath:String = "assets/sceaobao/Toolbar.png";
		//卷轴
		private var _toolReelUpPath:String = "assets/sceaobao/Toolbar_Reel_1.png";
		private var _toolReelDownPath:String = "assets/sceaobao/Toolbar_Reel_2.png";
		//左右箭头
		private var _toolLeftArrowPath:String = "assets/sceaobao/toolbar_left.png";
		private var _toolRightArrowPath:String = "assets/sceaobao/toolbar_right.png";
		
		private var toolBackground:Image;
		private var toolReelUp:Image;
		private var toolReelDown:Image;
		private var toolLeftArrow:Image;
		private var toolRightArrow:Image;
		
		private var _reelTool:Button;
		
		//下载队列
		private var _queLoader:QueueLoader;					
		private var _loadCompleted:Boolean;
		
		//晃动参数
		private var _shakeFlag:Boolean;
		
		public function BottomToolBar(shake:Boolean=false){
			super();
			_shakeFlag = shake;
			
			//下载队列
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		
		/**
		 * 处理返回按钮
		 */ 
		private function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if (touch == null) return;
			
		}
		
		private  function onStage(evt:Event):void{
			
			if(_loadCompleted) return;
			
			_queLoader.addItem(_toolBackgroundPath,null, {title : _toolBackgroundPath});
			_queLoader.addItem(_toolReelUpPath,null, {title : _toolReelUpPath});
			_queLoader.addItem(_toolReelDownPath,null, {title : _toolReelDownPath});
			_queLoader.addItem(_toolLeftArrowPath,null, {title : _toolLeftArrowPath});
			_queLoader.addItem(_toolRightArrowPath,null, {title : _toolRightArrowPath});
			
			//发出请求
			_queLoader.execute();
						
		}
		
		/**
		 * 由各场景调用，需要的时候让道具栏显示
		 */ 
		public function showToolbar():void{
			if(!this.parent) return;
			//move top
			this.parent.setChildIndex(this,this.parent.numChildren-1);
			this.visible = true;
		}
		
		/**
		 * 晃动卷轴
		 */ 
		public function shakeReel():void{						
			
			var rotateRight:Tween = new Tween(_reelTool,0.1);
			rotateRight.animate("rotation",Math.PI/36);
			rotateRight.onComplete = function():void{
				var rotateBack:Tween = new Tween(_reelTool,0.1);
				rotateBack.animate("rotation",-Math.PI/36);
				rotateBack.onComplete = function():void{
					_reelTool.x = AppConfig.VIEWPORT_WIDTH-70;
					_reelTool.y = 464;
					_reelTool.rotation = 0;
				}
				Starling.juggler.add(rotateBack);
			};
			Starling.juggler.add(rotateRight);
		}
		
		//单个图片加载完成
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			
			if(evt.title==_toolBackgroundPath){
				toolBackground = new Image(Texture.fromBitmap(evt.content));
				//道具栏
				toolBackground.x = 0;
				//这个位置刚合适
				toolBackground.y = 452;
				this.addChild(toolBackground);
			}
			if(evt.title==_toolReelUpPath){
				toolReelUp = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolReelUpPath);
			}
			if(evt.title==_toolReelDownPath){
				toolReelDown = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolReelDownPath);
			}
			if(evt.title==_toolLeftArrowPath){
				toolLeftArrow = new Image(Texture.fromBitmap(evt.content));
				//左右箭头
				toolLeftArrow.x = 10;
				toolLeftArrow.y = 540;
				this.addChild(toolLeftArrow);
			}
			if(evt.title==_toolRightArrowPath){
				toolRightArrow = new Image(Texture.fromBitmap(evt.content));
				toolRightArrow.x = AppConfig.VIEWPORT_WIDTH-90;
				toolRightArrow.y = 540;
				this.addChild(toolRightArrow);
			}
			
		}
		
		//加载队列完成
		private function onQueComplete(evt:QueueLoaderEvent):void{
			//清理队列
			while(_queLoader.getLoadedItems().length){
				_queLoader.removeItemAt(_queLoader.getLoadedItems().length-1);
			}
			//加载完成标志
			_loadCompleted = true;							
			
			//卷轴
			var upTexture:Texture = toolReelUp.texture;
			var downTexture:Texture = toolReelDown.texture;
			_reelTool = new Button(upTexture,"",downTexture);
			_reelTool.y = 464;
			_reelTool.x = AppConfig.VIEWPORT_WIDTH-70;
			this.addChild(_reelTool);
					
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		
		override public function dispose():void{
			super.dispose();
			
			_queLoader.dispose();
		}
		
		
		
	} //end of class
}