package{
	
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.AobaoScene;
	import com.ybcx.huluntears.scenes.FirstMapScene;
	import com.ybcx.huluntears.scenes.StartMovieScene;
	import com.ybcx.huluntears.scenes.WelcomeScene;
	import com.ybcx.huluntears.ui.AboutUsLayer;
	import com.ybcx.huluntears.ui.BottomToolBar;
	import com.ybcx.huluntears.ui.ImagePopup;
	import com.ybcx.huluntears.ui.RaidersLayer;
	import com.ybcx.huluntears.ui.STLoadingView;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
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
		private var _raiderLayer:RaidersLayer;
		//第一个攻略图路径
		private var _firstRaiderMapPath:String = "assets/sceaobao/1_tool_Raiders_1_l.png";
		//关于
		private var aboutusLayer:AboutUsLayer;
		
		
		private var startScene:StartMovieScene;
		private var aobaoScene:AobaoScene;
		private var firstMapScene:FirstMapScene;
		
		
		
		public function Game(){
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		
		private function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if (touch == null) return;
			
			if(touch.phase==TouchPhase.ENDED){
				
			}
		}
		
		private function onStage(evt:Event):void{
			this.removeEventListeners(Event.ADDED_TO_STAGE);
			
			//加载画面
			_loadingView = new STLoadingView();
			_loadingView.addEventListener(GameEvent.START_GAME, onStartGame);
			_loadingView.addEventListener(GameEvent.OPEN_ABOUTUS, onAboutUs);
			this.addChild(_loadingView);
			
		}
		private function onLoadingProgress(evt:GameEvent):void{
			_loadingView.progress = evt.context as Number;
		}
		
		private function onStartGame(evt:GameEvent):void{
			//LOADING START MOVIE SCENE...
			_loadingView.loading("加载故事情节...");
			
			startScene = new StartMovieScene();
			startScene.addEventListener(GameEvent.LOADING_PROGRESS,onLoadingProgress);
			startScene.addEventListener(GameEvent.LOADING_COMPLETE,onSceneLoaded);
			startScene.addEventListener(GameEvent.SWITCH_SCENE, gotoAobao);
			this.addChild(startScene);	
		}
		
		
		private function onSceneLoaded(evt:GameEvent):void{
			this.removeChild(_loadingView);
			
			//如果道具栏已经加载，就显示
			if(_uniToolBar) return;
			
			//开始加载道具栏
			startLoadToolbar();
		}
		
		private function moveToTop(display:DisplayObject):void{
			this.setChildIndex(display,this.numChildren-1);
		}
		
		//故事加载结束后，就加载道具，这样节省时间
		private function startLoadToolbar():void{
			
			_uniToolBar = new BottomToolBar();
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
			_raiderLayer = new RaidersLayer(145,454);
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
		
		private function gotoAobao(evt:Event):void{
			
			//FIXME, 加黑色背景，解决场景切换闪烁的问题
			//2012/04/25
			var blackBg:Quad = new Quad(this.stage.stageWidth,this.stage.stageHeight,0x000000);
			this.addChild(blackBg);
			
			
			aobaoScene = new AobaoScene();
			//必须在显示前添加道具栏
			aobaoScene.toolbar = _uniToolBar;
			aobaoScene.addEventListener(GameEvent.SWITCH_SCENE, gotoFirstMap);
			aobaoScene.addEventListener(GameEvent.LOADING_PROGRESS,onLoadingProgress);
			aobaoScene.addEventListener(GameEvent.LOADING_COMPLETE,onSceneLoaded);
			this.addChild(aobaoScene);
			
			//显示加载画面。。。
			this.addChild(_loadingView);
			_loadingView.loading("加载敖包场景...");
		}
		
		//去第一关大地图
		private function gotoFirstMap(evt:Event):void{
			this.removeChild(aobaoScene);
						
			if(!firstMapScene){
				firstMapScene = new FirstMapScene();
				firstMapScene.toolbar = _uniToolBar;
				firstMapScene.addEventListener(GameEvent.SWITCH_SCENE, backtoAobao);				
			}
			this.addChild(firstMapScene);
			
			//新出的淡入
			firstMapScene.alpha = 0;
			var fadeIn:Tween = new Tween(firstMapScene,0.6);
			fadeIn.animate("alpha",1);
			Starling.juggler.add(fadeIn);
			
			
			_uniToolBar.showToolbar();			
		}
		//从大地图返回敖包特写
		private function backtoAobao(evt:Event):void{
			this.removeChild(firstMapScene);
			
			this.addChild(aobaoScene);
			
			//新出的淡入
			aobaoScene.alpha = 0;
			var fadeIn:Tween = new Tween(aobaoScene,0.6);
			fadeIn.animate("alpha",1);
			Starling.juggler.add(fadeIn);
			
			_uniToolBar.showToolbar();
		}
		
	} //end of class
}