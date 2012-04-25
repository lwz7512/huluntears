package{
	
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.AobaoScene;
	import com.ybcx.huluntears.scenes.FirstMapScene;
	import com.ybcx.huluntears.scenes.StartMovieScene;
	import com.ybcx.huluntears.scenes.WelcomeScene;
	import com.ybcx.huluntears.ui.BottomToolBar;
	import com.ybcx.huluntears.ui.ImagePopup;
	import com.ybcx.huluntears.ui.RaidersLayer;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
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
		
		//第一个攻略图路径
		private var _firstRaiderMapPath:String = "assets/sceaobao/1_tool_Raiders_1_l.png";
		
		//全局的道具栏
		private var _uniToolBar:BottomToolBar;
		
		private var startScene:StartMovieScene;
		private var welcomeScene:WelcomeScene;
		private var aobaoScene:AobaoScene;
		private var firstMapScene:FirstMapScene;
		
		//卷轴打开的攻略地图
		private var _raiderLayer:RaidersLayer;
		
		
		public function Game(){
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
//			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		
		private function onStage(evt:Event):void{
								
			//1、显示开场动画场景
			
			startScene = new StartMovieScene();
			startScene.addEventListener(GameEvent.SWITCH_SCENE, gotoWelcome);
			startScene.addEventListener(GameEvent.MOVIE_STARTED, startLoadToolbar);
			this.addChild(startScene);	
						
		}
		
		private function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if (touch == null) return;
			
			if(touch.phase==TouchPhase.ENDED){
				
			}
		}
		
		//2，开场动画结束，进入主菜单
		private function gotoWelcome(evt:Event):void{
						
			this.removeChild(startScene,true);			
						
			welcomeScene = new WelcomeScene();
			welcomeScene.addEventListener(GameEvent.SWITCH_SCENE, gotoAobao);
			this.addChild(welcomeScene);
		}
		
		private function startLoadToolbar(evt:Event):void{
		
			_uniToolBar = new BottomToolBar();
			this.addChild(_uniToolBar);
			//FIXME, 先隐藏
			_uniToolBar.visible = false;
			_uniToolBar.addEventListener(GameEvent.REEL_TRIGGERD,onWalkThroughOpen);
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
			this.removeChild(welcomeScene,true);
			
			aobaoScene = new AobaoScene();
			//必须在显示前添加道具栏
			aobaoScene.toolbar = _uniToolBar;
			this.addChild(aobaoScene);
			aobaoScene.addEventListener(GameEvent.SWITCH_SCENE, gotoFirstMap);
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