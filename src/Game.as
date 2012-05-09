package{
	
	import com.ybcx.huluntears.animation.FadeIn;
	import com.ybcx.huluntears.animation.MotionTo;
	import com.ybcx.huluntears.animation.Shake;
	import com.ybcx.huluntears.animation.ZoomOut;
	import com.ybcx.huluntears.data.ItemConfig;
	import com.ybcx.huluntears.data.ItemManager;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.game.GameBase;
	import com.ybcx.huluntears.items.BaseItem;
	import com.ybcx.huluntears.items.PickupImage;
	import com.ybcx.huluntears.scenes.*;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.*;
	
	import flash.geom.Point;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.*;
	import starling.events.*;
	
	/**
	 * 主控各个场景切换的类，监听场景切换事件<br/>
	 * 该类父类必须是starling.display.Sprite
	 * 这里不能有FLASH原生事件
	 * 
	 * 2012/04/06
	 */ 
	public class Game extends GameBase{
		
		//道具配置
		private var itemConfig:ItemConfig;
		
		//道具管理器
		private var itemManager:ItemManager;
		
		/**
		 * 道具临时容器，供道具跟随鼠标移动，以及道具飞入道具栏使用
		 */ 
		private var _itemMoveLayer:Sprite;
		
		//加载画面
		private var _loadingView:STLoadingView;
		
		//全局的道具栏
		private var _uniToolBar:BottomToolBar;
		//卷轴打开的攻略地图
		private var _raiderLayer:WalkThroughLayer;
		//第一个攻略图路径
		private var _firstRaiderMapPath:String = "assets/sceaobao/1_tool_Raiders_1_l.png";
		//关于
		private var aboutusLayer:AboutUsLayer;
		
		
		private var startScene:StartMovieScene;
		private var firstMapScene:FirstMapScene;
		private var aobaoScene:AobaoSubScene;
		private var riverScene:RiverSubScene;
		private var lelecheScene:LelecheSubScene;
		
		
		//保存当前的场景，准备场景切换时清除
		private var currentScene:BaseScene;
		
		
		
		public function Game(){
									
			this.addEventListener(GameEvent.LOADING_PROGRESS, onLoadingProgress);
			this.addEventListener(GameEvent.LOADING_COMPLETE, onSceneLoaded);
			
			this.addEventListener(GameEvent.HINT_USER, onMessage);
			
			this.addEventListener(GameEvent.ITEM_SELECTED, onItemSelected);
			this.addEventListener(GameEvent.ITEM_DESTROYED, onItemDestroy);
			this.addEventListener(GameEvent.ITEM_FOUND, onItemFound);
			this.addEventListener(GameEvent.HITTEST_SUCCESS, onItemHitted);
			this.addEventListener(GameEvent.HITTEST_FAILED, onItemFailed);
		}
				
		override protected function init():void{			
			
			//FIXME, 加黑色背景，解决场景切换闪烁的问题
			//2012/04/25
			var blackBg:Quad = new Quad(this.stage.stageWidth,this.stage.stageHeight,0x000000);
			this.addChild(blackBg);					
						
			//加载道具栏
			initLoadToolbar();
			
			//道具移动层，使用时要置顶
			_itemMoveLayer = new Sprite();
			this.addChild(_itemMoveLayer);
			
			//显示欢迎画面
			_loadingView = new STLoadingView();
			_loadingView.addEventListener(GameEvent.START_GAME, onStartGame);
			_loadingView.addEventListener(GameEvent.OPEN_ABOUTUS, onAboutUs);
			this.addChild(_loadingView);
			
		}

		//故事加载结束后，就加载道具，这样节省时间
		private function initLoadToolbar():void{
			itemConfig = new ItemConfig();
			//道具管理器
			itemManager = new ItemManager();
			//先放第一关的道具
			itemManager.cacheItemVOs(itemConfig.getFirstScenaryItems());
			
			_uniToolBar = new BottomToolBar(itemManager);
			//FIXME, 先隐藏，因为故事场景不需要看到道具栏
			_uniToolBar.visible = false;
			//道具栏一直在舞台上，只是有时隐藏了
			this.addChild(_uniToolBar);
			_uniToolBar.addEventListener(GameEvent.REEL_TRIGGERD,onWalkThroughOpen);
		}
		
		private function onStartGame(evt:GameEvent):void{
			//这时欢迎画面已经在舞台上了，切换为加载状态
			_loadingView.loading("加载故事情节...");
			
			//现在是透明的
			startScene = new StartMovieScene();
			startScene.addEventListener(GameEvent.SWITCH_SCENE, gotoFirstMap);
			showScene(startScene);
		}		

		
		private function onAboutUs(evt:GameEvent):void{
			aboutusLayer = new AboutUsLayer();
			aboutusLayer.addEventListener(Event.REMOVED_FROM_STAGE,aboutOffStage);
			
			if(!this.contains(aboutusLayer)){
				aboutusLayer.x = 330;
				aboutusLayer.y = 49;
				_loadingView.hideEye();
				this.addChild(aboutusLayer);
			}
		}
		
		private function aboutOffStage(evt:Event):void{
			_loadingView.showEye();
		}		
		
		private function onWalkThroughOpen(evt:GameEvent):void{
			if(_raiderLayer && this.contains(_raiderLayer)) return;
			
			var index:int = evt.context as int;
			_raiderLayer = new WalkThroughLayer(145,454);
			_raiderLayer.y = 50;
			_raiderLayer.x = this.stage.stageWidth-_raiderLayer.width >> 1;
			//显示第一个攻略
			_raiderLayer.availableRaider(index);
			_raiderLayer.addEventListener(GameEvent.RAIDER_TOUCHED,onSubMapTouched);
			this.addChild(_raiderLayer);
		}
		
		
		private function onSubMapTouched(evt:GameEvent):void{
			if(evt.context==1){//打开第一个地图
				var firstWalkThrough:ImagePopup = new ImagePopup(482,530);
				firstWalkThrough.imgPath = _firstRaiderMapPath;
				firstWalkThrough.x = this.stage.stageWidth-firstWalkThrough.width >> 1;
				firstWalkThrough.y = 20;
				firstWalkThrough.maskColor = 0xCC000000;
				this.addChild(firstWalkThrough);
			}
		}		
		
		//去第一关大地图
		private function gotoFirstMap(evt:Event):void{
			clearCurrentScene();
			
			if(!firstMapScene){
				firstMapScene = new FirstMapScene(itemManager);
				firstMapScene.toolbar = _uniToolBar;
				firstMapScene.addEventListener(GameEvent.SWITCH_SCENE,goSubScene);	
			}
			showScene(firstMapScene);
			
			if(!firstMapScene.initialized){
				showLoadingView("加载主场景...");		
			}else{
				fadeInScene(firstMapScene);
			}	
								
		}

		/**
		 * 根据事件传值，来决定转向哪个子场景
		 */
		//TODO, ADD MORE SUB SCENE...
		private function goSubScene(evt:GameEvent):void{
			var subScene:String = evt.context as String;
			if(subScene==SubSceneNames.FIRST_SUB_AOBAO){
				gotoAobao();
			}
			if(subScene==SubSceneNames.FIRST_SUB_RIVER){
				gotoRiver();
			}
			if(subScene==SubSceneNames.FIRST_SUB_LELECHE){
				gotoLeleche();
			}
		}
		
		
		private function gotoAobao():void{
			clearCurrentScene();			
			
			if(!aobaoScene){
				aobaoScene = new AobaoSubScene();
				//必须在显示前添加道具栏
				aobaoScene.toolbar = _uniToolBar;
				aobaoScene.addEventListener(GameEvent.SWITCH_SCENE, gotoFirstMap);
			}
			showScene(aobaoScene);
			
			if(!aobaoScene.initialized){
				showLoadingView("加载敖包场景...");		
			}else{
				fadeInScene(aobaoScene);
			}					
			
		}
		
		//TODO, ...RIVER SCENE...
		private function gotoRiver():void{
			clearCurrentScene();
			
			if(!riverScene){
				riverScene = new RiverSubScene();
				riverScene.toolbar = _uniToolBar;
				riverScene.addEventListener(GameEvent.SWITCH_SCENE, gotoFirstMap);
			}
			showScene(riverScene);
			
			if(!riverScene.initialized){
				showLoadingView("加载河流场景...");		
			}else{
				fadeInScene(riverScene);
			}
		}
		
		private function gotoLeleche():void{
			clearCurrentScene();
			
			if(!lelecheScene){
				lelecheScene = new LelecheSubScene();
				lelecheScene.toolbar = _uniToolBar;
				lelecheScene.addEventListener(GameEvent.SWITCH_SCENE, gotoFirstMap);
			}
			showScene(lelecheScene);
			
			if(!lelecheScene.initialized){
				showLoadingView("加载勒勒车场景...");		
			}else{
				fadeInScene(lelecheScene);
			}
		}
		
		//--------------- 其他导航 ----------------------------------
		
		
		
		
		
		
		
		

//		---------------  道具操作 -------------------------------------
		private function onItemFailed(evt:GameEvent):void{
			var item:BaseItem = evt.context as BaseItem;
			new Shake(item);
		}
		
		//TODO, 这里要考虑如何处理道具添加顺序的问题
		private function onItemHitted(evt:GameEvent):void{
			var item:BaseItem = evt.context as BaseItem;
			
			//判断是否可以放置
			if(!currentScene.allowToPut(item.name)){
//				trace("not allow to put: "+item.name);
				new Shake(item);
				return;
			}
			
			//放道具到场景中
			currentScene.putItemHitted(item.img, new Point(item.x,item.y));
			
			//清理用过的对象
			clearContainer(_itemMoveLayer);
			_uniToolBar.removeUsedItem(item.name);
		}
		
		private function onItemSelected(evt:GameEvent):void{
			var item:BaseItem = evt.context as BaseItem;
			//生成克隆的道具
			var cloned:BaseItem = item.clone();
			cloned.globalHitTestRect = currentScene.hitTestRect;
			_itemMoveLayer.addChild(cloned);
		}		
		private function onItemDestroy(evt:GameEvent):void{			
			clearContainer(_itemMoveLayer);
		}
		
		private function onItemFound(evt:GameEvent):void{
			var pickup:PickupImage = evt.context as PickupImage;
			//移动过后的位置
			var movePickupPos:Point = pickup.localToGlobal(new Point(0,0));
			//从原来所在的容器中移除
			pickup.removeFromParent();			
			
			var itemPosInToolbar:Point = _uniToolBar.getItemBGPosByName(pickup.name);
			if(!itemPosInToolbar){
				trace("not found item for: "+pickup.name);
				return;
			}
			//设置目标位置
			pickup.disppearedPos(itemPosInToolbar.x,itemPosInToolbar.y);
			//新的起始位置
			pickup.x = movePickupPos.x;
			pickup.y = movePickupPos.y;					
			
			//显示临时道具到容器中，准备飞行
			_itemMoveLayer.addChild(pickup);
			
			pickup.flying(function():void{
				_uniToolBar.showItemFound(pickup);
				clearContainer(_itemMoveLayer);
			});
			
		}
		

		
//		--------------------  common operation --------------------------------------------				
		
		
		/**
		 * 每个场景加载完成，都要做这个清理进度画面的工作<br/>
		 * 动态调整各层顺序：<br/>
		 * ------------- blackBg -----------------------<br/>
		 * ------------- currentScene ------------------<br/>
		 * ------------- toolbar ------------------------<br/>
		 * ------------- itemMoveLayer ---------------<br/>
		 * <br/>
		 * 2012/05/09
		 */
		private function onSceneLoaded(evt:GameEvent):void{
			this.removeChild(_loadingView);
			
			//除了故事场景外，其他场景都有道具栏
			if(currentScene!=startScene) {
				//道具置顶
				_uniToolBar.showToolbar();
				//道具临时容器置顶
				moveToTop(_itemMoveLayer);
			}else{
				_uniToolBar.visible = false;
			}
			
		}
		
		private function onLoadingProgress(evt:GameEvent):void{
			_loadingView.progress = evt.context as Number;
		}
		
		private function onMessage(evt:GameEvent):void{
			var hint:AutoDisappearTip = new AutoDisappearTip();
			hint.message = evt.context as String;
			//先定位
			this.centerMessage(hint);
			//后显示
			this.addChild(hint);
		}
		
		/**
		 * 显示进度画面
		 */ 
		private function showLoadingView(msg:String):void{
			//显示加载画面。。。
			this.addChild(_loadingView);
			_loadingView.loading(msg);
		}
		
		/**
		 * 显示场景
		 */ 
		private function showScene(scene:BaseScene):void{
			//新场景添加到道具栏的下面，黑色背景的上面
			this.addChildAt(scene,1);
			
			//保存当前场景，准备下次删除
			this.currentScene = scene;
		}
		
		/**
		 * 切换场景前，先清理当前的场景
		 */ 
		private function clearCurrentScene():void{
			if(!currentScene) return;
			if(this.contains(currentScene)){
				this.removeChild(currentScene);
			}
		}		
		
		/**
		 * 淡出要显示的场景
		 */ 
		private function fadeInScene(scene:BaseScene):void{
			//新出的淡入
			new FadeIn(scene,0.6);			
		}
		
	} //end of class
}