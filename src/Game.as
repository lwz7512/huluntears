package{
	
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.AobaoScene;
	import com.ybcx.huluntears.scenes.FirstMapScene;
	import com.ybcx.huluntears.scenes.StartMovieScene;
	import com.ybcx.huluntears.scenes.WelcomeScene;
	import com.ybcx.huluntears.ui.BottomToolBar;
	
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
		
		//全局的道具栏
		private var _uniToolBar:BottomToolBar;
		
		private var startScene:StartMovieScene;
		private var welcomeScene:WelcomeScene;
		private var aobaoScene:AobaoScene;
		private var firstMapScene:FirstMapScene;
		
		
		
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
		}
		

		
		private function gotoAobao(evt:Event):void{
			this.removeChild(welcomeScene,true);
			
			aobaoScene = new AobaoScene();
			//必须在显示前添加道具栏
			aobaoScene.toolbar = _uniToolBar;
			this.addChild(aobaoScene);
			aobaoScene.addEventListener(GameEvent.SWITCH_SCENE, gotoFirstMap);
		}
		
		private function gotoFirstMap(evt:Event):void{
			this.removeChild(aobaoScene);
						
			if(!firstMapScene){
				firstMapScene = new FirstMapScene();
				firstMapScene.toolbar = _uniToolBar;
				firstMapScene.addEventListener(GameEvent.SWITCH_SCENE, backtoAobao);				
			}
			this.addChild(firstMapScene);
			_uniToolBar.showToolbar();			
		}
		
		private function backtoAobao(evt:Event):void{
			this.removeChild(firstMapScene);
			
			this.addChild(aobaoScene);
			_uniToolBar.showToolbar();
		}
		
	} //end of class
}