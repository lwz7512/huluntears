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
		//卷轴图片
		private var _toolReelUpPath:String = "assets/sceaobao/Toolbar_Reel_1.png";
		private var _toolReelDownPath:String = "assets/sceaobao/Toolbar_Reel_2.png";
		//左右箭头
		private var _toolLeftArrowUpPath:String = "assets/sceaobao/toolbar_left_normal.png";
		private var _toolLeftArrowDownPath:String = "assets/sceaobao/toolbar_left_down.png";
		private var _toolRightArrowUpPath:String = "assets/sceaobao/toolbar_right_normal.png";
		private var _toolRightArrowDownPath:String = "assets/sceaobao/toolbar_right_down.png";
		
		private var toolBackground:Image;
		
		//卷轴纹理
		private var toolReelUp:Texture;
		private var toolReelDown:Texture;		
		//卷轴按钮
		private var _reelTool:Button;
		
		//按钮纹理
		private var toolLeftUpTxtr:Texture;
		private var toolLeftDownTxtr:Texture;
		private var toolRightUpTxtr:Texture;
		private var toolRightDownTxtr:Texture;
		
		private var toolLeftArrow:Button;
		private var toolRightArrow:Button;
		
		
		//下载队列
		private var _queLoader:QueueLoader;					
		private var _loadCompleted:Boolean;
		
		//依靠这个值，来显示攻略图
		private var _raiderIndex:int = 0;
				
		
		
		public function BottomToolBar(){
			super();			
			
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
			
			_queLoader.addItem(_toolLeftArrowUpPath,null, {title : _toolLeftArrowUpPath});
			_queLoader.addItem(_toolLeftArrowDownPath,null, {title : _toolLeftArrowDownPath});
			
			_queLoader.addItem(_toolRightArrowUpPath,null, {title : _toolRightArrowUpPath});
			_queLoader.addItem(_toolRightArrowDownPath,null, {title : _toolRightArrowDownPath});
			
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
			_raiderIndex ++;
			var rotateRight:Tween = new Tween(_reelTool,0.1);
			rotateRight.animate("rotation",Math.PI/36);
			rotateRight.onComplete = function():void{
				var rotateBack:Tween = new Tween(_reelTool,0.1);
				rotateBack.animate("rotation",-Math.PI/36);
				rotateBack.onComplete = function():void{
					//恢复初始状态
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
				//应用底部
				toolBackground.y = this.stage.stageHeight-toolBackground.height;
				this.addChild(toolBackground);
			}
			if(evt.title==_toolReelUpPath){
				toolReelUp = Texture.fromBitmap(evt.content);				
			}
			if(evt.title==_toolReelDownPath){
				toolReelDown = Texture.fromBitmap(evt.content);				
			}
			if(evt.title==_toolLeftArrowUpPath){
				toolLeftUpTxtr = Texture.fromBitmap(evt.content);				
			}
			if(evt.title==_toolLeftArrowDownPath){
				toolLeftDownTxtr = Texture.fromBitmap(evt.content);				
			}
			if(evt.title==_toolRightArrowUpPath){
				toolRightUpTxtr = Texture.fromBitmap(evt.content);				
			}
			if(evt.title==_toolRightArrowDownPath){
				toolRightDownTxtr = Texture.fromBitmap(evt.content);				
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
			_reelTool = new Button(toolReelUp,"",toolReelDown);
			_reelTool.y = this.stage.stageHeight-60;
			_reelTool.x = AppConfig.VIEWPORT_WIDTH-40;
			_reelTool.addEventListener(Event.TRIGGERED,function():void{
				var reelOpen:GameEvent = new GameEvent(GameEvent.REEL_TRIGGERD,_raiderIndex);
				dispatchEvent(reelOpen);
			});
			this.addChild(_reelTool);
			
			//左箭头
			toolLeftArrow = new Button(toolLeftUpTxtr,"",toolLeftDownTxtr);
			toolLeftArrow.x = 10;
			toolLeftArrow.y = 540;
			this.addChild(toolLeftArrow);
			
			//右箭头
			toolRightArrow = new Button(toolRightUpTxtr,"",toolRightDownTxtr);
			toolRightArrow.x = AppConfig.VIEWPORT_WIDTH-60;
			toolRightArrow.y = 540;
			this.addChild(toolRightArrow);
			
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