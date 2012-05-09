package com.ybcx.huluntears.ui{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.animation.FadeOut;
	import com.ybcx.huluntears.animation.ZoomOut;
	import com.ybcx.huluntears.data.ItemManager;
	import com.ybcx.huluntears.data.ItemVO;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.items.BaseItem;
	import com.ybcx.huluntears.items.ItemPlaceHolder;
	import com.ybcx.huluntears.items.PickupImage;
	import com.ybcx.huluntears.utils.ImageQueLoader;
	
	import flash.display.Bitmap;
	import flash.geom.Point;
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
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
		private var _queLoader:ImageQueLoader;				
		private var _loadCompleted:Boolean;
		
		//依靠这个值，来显示攻略图
		private var _raiderIndex:int = 0;
				
		//道具显示层
		private var _itemsLayer:Sprite;
		//道具数据管理器
		private var _manager:ItemManager;
		
		
		public function BottomToolBar(manager:ItemManager){
			super();			
			
			_manager = manager;
			
			//下载队列
			_queLoader = new ImageQueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		
		/**
		 * 移除使用过的道具
		 */ 
		public function removeUsedItem(itemName:String):void{
			var target:DisplayObject = _itemsLayer.getChildByName(itemName);
			new FadeOut(target,1, function():void{
				_itemsLayer.removeChild(target,true);				
				relayoutItems();
			});
		}
		
		//TODO, 重新排列道具栏道具，以动画的形式，像左移动
		private function relayoutItems():void{
			
		}
		
		/**
		 * 查找道具印记位置
		 */ 
		public function getItemBGPosByName(itemName:String):Point{
			var result:DisplayObject = _itemsLayer.getChildByName(itemName);
			if(result) return result.localToGlobal(new Point(0,0));
			return null;
		}
		
		/**
		 * 由Game调用，需要的时候让道具栏显示
		 */ 
		public function showToolbar():void{
			if(!this.parent) return;
			//move top
			this.parent.setChildIndex(this,this.parent.numChildren-1);
			this.visible = true;
		}		
		
		/**
		 * 显示新找到的道具图片，放到相应的占位符上，形成道具<br/>
		 * 场景中都是普通的可拾起的图片，点击后可自动飞入道具栏
		 */ 
		public function showItemFound(img:PickupImage):void{			
			//创建道具对象
			var item:BaseItem = new BaseItem();
			item.content = img.bitmap;
			item.name = img.name;
			//放置在道具栏中
			putItemOnItsbg(item);
						
		}
		
		private function putItemOnItsbg(item:BaseItem):void{
			var target:DisplayObject = _itemsLayer.getChildByName(item.name);
			if(!target){
				trace("item not found while put in toolbar: "+item.name);
				return;
			}
			item.x = target.x;
			item.y = target.y;
			
			//先删除道具占位符
			_itemsLayer.removeChild(target);
			//显示新道具
			_itemsLayer.addChild(item);
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

		
		/**
		 * 处理左右滚动道具按钮
		 */ 
		private function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if (touch == null) return;
			
		}
		
		private  function onStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);			
			if(_loadCompleted) return;
			
			//道具显示容器
			_itemsLayer = new Sprite();
			_itemsLayer.x = 20;
			_itemsLayer.y = this.stage.stageHeight-50;
			this.addChild(_itemsLayer);
			
			//加载道具栏背景图
			_queLoader.addImageByUrl(_toolBackgroundPath);
						
			_queLoader.addImageByUrl(_toolReelUpPath);
			_queLoader.addImageByUrl(_toolReelDownPath);
						
			_queLoader.addImageByUrl(_toolLeftArrowUpPath);
			_queLoader.addImageByUrl(_toolLeftArrowDownPath);

			_queLoader.addImageByUrl(_toolRightArrowUpPath);
			_queLoader.addImageByUrl(_toolRightArrowDownPath);
			
			//加载当第一关道具
			loadItemBGs();
			
			//发出请求
			_queLoader.execute();
			
		}
		
		/**
		 * 载入道具印记图片
		 */
		//FIXME, 将来可以载入其他关的道具
		private function loadItemBGs():void{
			_itemsLayer.removeChildren(0,1);
			
			var items:Array = _manager.getAllItems();			
			for(var i:int=0; i<items.length; i++){
				var item:ItemVO = items[i] as ItemVO;
				_queLoader.addImageByUrl(item.bgImagePath);
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
			
			showToolbarAssets();
			
			//显示道具印记
			showItemBgs();
			
			//将道具层置顶
			moveTop(_itemsLayer);
		}
		
		private function showItemBgs():void{
			var items:Array = _manager.getAllItems();	
			var itemHGap:Number = 20;
			var itemStartX:Number = 20;
			for(var i:int=0; i<items.length; i++){
				var item:ItemVO = items[i] as ItemVO;
				
				var imgBG:ItemPlaceHolder = new ItemPlaceHolder(_queLoader.getTextrByUrl(item.bgImagePath));
				imgBG.x = itemStartX;
				imgBG.name = item.itemName;
				_itemsLayer.addChild(imgBG);
				
				itemStartX += imgBG.width+itemHGap;
			}
			
		}
		
		private function moveTop(view:DisplayObject):void{
			this.setChildIndex(view, this.numChildren-1);
		}
		
		private function showToolbarAssets():void{
			toolReelUp = _queLoader.getTextrByUrl(_toolReelUpPath);
			toolReelDown = _queLoader.getTextrByUrl(_toolReelDownPath);
			toolLeftUpTxtr = _queLoader.getTextrByUrl(_toolLeftArrowUpPath);
			toolLeftDownTxtr = _queLoader.getTextrByUrl(_toolLeftArrowDownPath);
			toolRightUpTxtr = _queLoader.getTextrByUrl(_toolRightArrowUpPath);
			toolRightDownTxtr = _queLoader.getTextrByUrl(_toolRightArrowDownPath);
			
			//背景图
			toolBackground = _queLoader.getImageByUrl(_toolBackgroundPath);
			//道具栏
			toolBackground.x = 0;
			//应用底部
			toolBackground.y = this.stage.stageHeight-toolBackground.height;
			this.addChild(toolBackground);						
			
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