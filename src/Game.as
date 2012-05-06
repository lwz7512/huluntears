package{
	
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.*;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.*;
	
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
	public class Game extends Sprite{
				
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
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(GameEvent.HINT_USER, onMessage);
			
			this.addEventListener(GameEvent.LOADING_PROGRESS, onLoadingProgress);
			this.addEventListener(GameEvent.LOADING_COMPLETE, onSceneLoaded);			
		}
		
		
		
		private function onStage(evt:Event):void{
			this.removeEventListeners(Event.ADDED_TO_STAGE);					
			
			//FIXME, 加黑色背景，解决场景切换闪烁的问题
			//2012/04/25
			var blackBg:Quad = new Quad(this.stage.stageWidth,this.stage.stageHeight,0x000000);
			this.addChild(blackBg);
			
			//显示欢迎画面
			_loadingView = new STLoadingView();
			_loadingView.addEventListener(GameEvent.START_GAME, onStartGame);
			_loadingView.addEventListener(GameEvent.OPEN_ABOUTUS, onAboutUs);
			this.addChild(_loadingView);
						
		}

		
		private function onStartGame(evt:GameEvent):void{
			//这时欢迎画面已经在舞台上了，切换为加载状态
			_loadingView.loading("加载故事情节...");
			
			//现在是透明的
			startScene = new StartMovieScene();
			startScene.addEventListener(GameEvent.SWITCH_SCENE, gotoFirstMap);
			showScene(startScene);
		}		

		
		//故事加载结束后，就加载道具，这样节省时间
		private function startLoadToolbar():void{
			
			_uniToolBar = new BottomToolBar();
			//道具栏一直在舞台上，只是有时隐藏了
			this.addChild(_uniToolBar);
			//FIXME, 先隐藏
			_uniToolBar.visible = false;
			_uniToolBar.addEventListener(GameEvent.REEL_TRIGGERD,onWalkThroughOpen);
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
				firstMapScene = new FirstMapScene();
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
		
		
		
		
		
		
		
		
		
		
//		--------------------  common operation --------------------------------------------
		
		private function onMessage(evt:GameEvent):void{
			var hint:AutoDisappearTip = new AutoDisappearTip();
			hint.message = evt.context as String;
			this.addChild(hint);
			this.centerView(hint);
		}
		
		
		private function centerView(view:DisplayObject):void{
			view.x = this.stage.stageWidth-view.width >>1;
			view.y = this.stage.stageHeight-view.height >>1;
		}
		
		
		private function onLoadingProgress(evt:GameEvent):void{
			_loadingView.progress = evt.context as Number;
		}
		
		/**
		 * 每个场景加载完成，都要做这个清理进度画面的工作
		 */ 
		private function onSceneLoaded(evt:GameEvent):void{
			this.removeChild(_loadingView);
			
			//如果道具栏已经加载，就不重复加载
			if(_uniToolBar) return;
			
			//开始加载道具栏
			startLoadToolbar();
		}
		
		private function moveToTop(display:DisplayObject):void{
			this.setChildIndex(display,this.numChildren-1);
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
			//显示道具栏，因为有可能被隐藏了
			if(_uniToolBar) _uniToolBar.showToolbar();
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
			scene.alpha = 0;
			var fadeIn:Tween = new Tween(scene,0.6);
			fadeIn.animate("alpha",1);
			Starling.juggler.add(fadeIn);
		}
		
	} //end of class
}