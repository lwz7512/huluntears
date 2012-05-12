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
	import flash.geom.Rectangle;
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.ClippedSprite;
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
				
		//道具显示层，有遮罩功能
		private var _itemsLayer:ClippedSprite;
		//道具数据管理器
		private var _manager:ItemManager;
				
		//道具滚动步伐
		private var _itemsMoveStep:int = 20;
		
		
		/**
		 * 内部元素位置均为相对位置，不再计算全局位置<br/>
		 * 显示对象结构尽量简单，不嵌套多层<br/>
		 */ 
		public function BottomToolBar(manager:ItemManager){
			super();			
			
			_manager = manager;
			
			//下载队列
			_queLoader = new ImageQueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
				
		private  function onStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);			
			if(_loadCompleted) return;
			
			//道具显示容器
			_itemsLayer = new ClippedSprite();
			_itemsLayer.y = 30;
			_itemsLayer.x = 20;		
			//设置全局剪裁区域...
			this.addChild(_itemsLayer);
			var origin:Point = _itemsLayer.localToGlobal(new Point(10,0));			
			_itemsLayer.clipRect = new Rectangle(origin.x,origin.y,660,60);
			
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
		 * 移除使用过的道具
		 */ 
		public function removeUsedItem(itemName:String):void{
			var target:DisplayObject = _itemsLayer.getChildByName(itemName);
			new FadeOut(target,1, function():void{
				_itemsLayer.removeChild(target,true);				
				relayoutItems();
			});
		}
		
		/**
		 * 查找道具印记位置
		 */ 
		public function getItemBGPosByName(itemName:String):Point{
			var result:DisplayObject = _itemsLayer.getChildByName(itemName);
			var target:Point;
			if(result) {
				target = result.localToGlobal(new Point(0,0));
				var rightBoundary:Number = 630;
				var leftBoundary:Number = 60;
				if(target.x>rightBoundary){
					pullbackItems(rightBoundary-target.x);
					target.offset(rightBoundary-target.x,0);
					return target;
				}else if(target.x<leftBoundary){
					pullbackItems(leftBoundary-target.x);
					target.offset(leftBoundary-target.x,0);
					return target;
				}else{
					return target;
				}
			}
			return new Point(0,0);
		}
		
		/**
		 * 让舞台之外的道具会到显示区域中
		 */ 
		private function pullbackItems(offset:Number):void{
			for(var i:int=0; i<_itemsLayer.numChildren; i++){
				_itemsLayer.getChildAt(i).x += offset;
			}
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
			item.groupItemNum = img.groupItemNum;
			
			//放置在道具栏中，并删除印记
			putItemOnItsbg(item);
			//检查是否有道具合并
			mergeItemsFound(item);		
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
		 * 使用过一个道具后，重新排列道具栏道具<br/>
		 * 新载入组合道具后，重新排列<br/>
		 * 按照子对象索层级，层级小的排最左边<br/>
		 */
		private function relayoutItems():void{
			var itemNum:int = _itemsLayer.numChildren;
			var itemHGap:Number = 4;
			var itemStartX:Number = 10;
			//先排列标准道具
			for(var i:int=0; i<itemNum; i++){
				if(_itemsLayer.getChildAt(i) is BaseItem){
					//水平重排
					_itemsLayer.getChildAt(i).x = itemStartX;
					//垂直重排
					if(_itemsLayer.getChildAt(i).height<30){
						_itemsLayer.getChildAt(i).y = 20;
					}
					itemStartX += _itemsLayer.getChildAt(i).width+itemHGap;
				}
			}
			//占位道具排在后面
			for(var j:int=0; j<itemNum; j++){
				if(_itemsLayer.getChildAt(j) is ItemPlaceHolder){
					_itemsLayer.getChildAt(j).x = itemStartX;
					//垂直重排
					if(_itemsLayer.getChildAt(j).height<30){
						_itemsLayer.getChildAt(j).y = 20;
					}
					itemStartX += _itemsLayer.getChildAt(j).width+itemHGap;
				}
			}
		}
		
		
		/**
		 * 每次找到一个道具，就判断是否该组合道具了
		 */ 	
		private function mergeItemsFound(item:BaseItem):void{
			//判断是否找齐道具？
			var mergable:Boolean = needToMerge(item);
			if(!mergable) return;
			
			//移除即将组合的道具
			var groupName:String = item.groupName;
			var itemNum:int = _itemsLayer.numChildren;
			var collectedItem:DisplayObject;
			for(var i:int=itemNum-1; i>-1; i--){
				collectedItem = _itemsLayer.getChildAt(i) as DisplayObject;
				if(collectedItem.name.indexOf(groupName)>-1){
					_itemsLayer.removeChildAt(i,true);					
				}
			}
			
			//如果有道具被合并，则载入组合道具
			var groupItemPath:String = _manager.config.groupItemPath(item.groupName);
			if(!groupItemPath){
				trace("can not load group: "+groupItemPath);
				return;
			}
			_queLoader.addItem(groupItemPath,null,{title : item.groupName});
			trace("to load group: "+groupItemPath);
			_queLoader.execute();
		}
		
		/**
		 * 从道具容器中查找给定名称的BaseItem，统计他们的数目，是否达到组合数
		 */		
		private function needToMerge(item:BaseItem):Boolean{
			if(item.groupItemNum==1) return false;
			if(!item.name){
				trace("tamade...item name is null!");
				return false;
			}
			var groupName:String = item.groupName;			
			//遍历查找名字，做统计
			var itemCounter:int = 0;
			var itemNum:int = _itemsLayer.numChildren;
			var collectedItem:BaseItem;
			for(var i:int=0; i<itemNum; i++){
				if(_itemsLayer.getChildAt(i) is BaseItem){
					collectedItem = _itemsLayer.getChildAt(i) as BaseItem;					
					if(collectedItem.name.indexOf(groupName)>-1) {
						itemCounter++;						
					}
				}
			}
//			trace("collected item is : "+itemCounter+" for group "+groupName);
			if(itemCounter==item.groupItemNum) {
				return true;
//				trace("collect all....");
			}
			
			return false;
		}
		
		/**
		 * 一把载入当前关的，所有子场景的道具印记图片
		 */		
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
			_queLoader.reset();
			
			//判断是否为再次载入组合道具
			showGroupItem(evt);
			
			//显示背景和按钮
			showToolbarAssets();
			
			//显示占位道具
			showItemBgs();
			
			//将道具层置顶
			moveTop(_itemsLayer);
			
			//加载完成标志
			_loadCompleted = true;
		}
		/**
		 * 第二次查询才初始化组合道具，置于道具栏头部，并重新排列道具位置，恢复滚动前状态
		 */ 
		private function showGroupItem(evt:QueueLoaderEvent):void{
			//基础道具已经被载入，才生成组合道具
			if(_loadCompleted && _itemsLayer.numChildren){
				//构建新的组合后道具BaseItem
				var item:BaseItem = new BaseItem();
				item.content = evt.content as Bitmap;
				item.name = evt.title;
				trace("group item loaded: "+evt.title);
				//放在头部
				_itemsLayer.addChildAt(item,0);
				//重新排列所有道具位置。。。
				relayoutItems();
			}
		}
		
		private function showItemBgs():void{
			
			if(_loadCompleted) return;
			
			var items:Array = _manager.getAllItems();	
			var itemHGap:Number = 4;
			var itemStartX:Number = 10;
			var itemStartY:Number = 0;
			for(var i:int=0; i<items.length; i++){
				var item:ItemVO = items[i] as ItemVO;
				
				var imgBG:ItemPlaceHolder = new ItemPlaceHolder(_queLoader.getTextrByUrl(item.bgImagePath));
				imgBG.x = itemStartX;
				if(imgBG.height<30){//特殊处理道具比较矮的情况
					imgBG.y = 20;
				}else{
					imgBG.y = itemStartY;					
				}
				//必须记住名字，做道具匹配用
				imgBG.name = item.itemName;
				//这块先淡化透明度吧，没有单独做图片
				imgBG.alpha = 0.4;
				//显示
				_itemsLayer.addChild(imgBG);
				
				itemStartX += imgBG.width+itemHGap;
			}
			
		}
		
		private function moveTop(view:DisplayObject):void{			
			this.setChildIndex(view, this.numChildren-1);
		}
		
		private function showToolbarAssets():void{
			
			if(_loadCompleted) return;
			
			toolReelUp = _queLoader.getTextrByUrl(_toolReelUpPath);
			toolReelDown = _queLoader.getTextrByUrl(_toolReelDownPath);
			toolLeftUpTxtr = _queLoader.getTextrByUrl(_toolLeftArrowUpPath);
			toolLeftDownTxtr = _queLoader.getTextrByUrl(_toolLeftArrowDownPath);
			toolRightUpTxtr = _queLoader.getTextrByUrl(_toolRightArrowUpPath);
			toolRightDownTxtr = _queLoader.getTextrByUrl(_toolRightArrowDownPath);
			
			//背景图
			toolBackground = _queLoader.getImageByUrl(_toolBackgroundPath);			
			this.addChild(toolBackground);						
			
			//卷轴			
			_reelTool = new Button(toolReelUp,"",toolReelDown);
			_reelTool.x = AppConfig.VIEWPORT_WIDTH-36;
			_reelTool.y = 30;
			_reelTool.addEventListener(Event.TRIGGERED,function():void{
				var reelOpen:GameEvent = new GameEvent(GameEvent.REEL_TRIGGERD,_raiderIndex);
				dispatchEvent(reelOpen);
			});
			this.addChild(_reelTool);
			
			//左箭头
			toolLeftArrow = new Button(toolLeftUpTxtr,"",toolLeftDownTxtr);
			toolLeftArrow.x = 10;
			toolLeftArrow.y = 50;
			toolLeftArrow.addEventListener(TouchEvent.TOUCH, onLeftArrowTouch);
			this.addChild(toolLeftArrow);
			
			//右箭头
			toolRightArrow = new Button(toolRightUpTxtr,"",toolRightDownTxtr);
			toolRightArrow.x = AppConfig.VIEWPORT_WIDTH-60;
			toolRightArrow.y = 50;
			toolRightArrow.addEventListener(TouchEvent.TOUCH, onRightArrowTouch);
			this.addChild(toolRightArrow);
			
		}
		
		private function onLeftArrowTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(toolLeftArrow);
			if(!touch) return;
			
			if(touch.phase==TouchPhase.BEGAN){
				this.addEventListener(Event.ENTER_FRAME, function():void{
					scrollItemsRight();
				});
			}
			if(touch.phase==TouchPhase.ENDED){
				this.removeEventListeners(Event.ENTER_FRAME);
			}
			
		}
		private function onRightArrowTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(toolRightArrow);
			if(!touch) return;
			
			if(touch.phase==TouchPhase.BEGAN){
				this.addEventListener(Event.ENTER_FRAME, function():void{
					scrollItemsLeft();
				});
			}
			if(touch.phase==TouchPhase.ENDED){
				this.removeEventListeners(Event.ENTER_FRAME);
			}
			
		}
		
		/**
		 * 所有道具向左滚动
		 */ 
		private function scrollItemsLeft():void{
			var step:Number = -_itemsMoveStep;
			for(var i:int=0; i<_itemsLayer.numChildren; i++){
				_itemsLayer.getChildAt(i).x += step;
			}
		}
		/**
		 * 所有道具向右滚动
		 */ 
		private function scrollItemsRight():void{
			var step:Number = _itemsMoveStep;
			for(var i:int=0; i<_itemsLayer.numChildren; i++){
				_itemsLayer.getChildAt(i).x += step;
			}
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