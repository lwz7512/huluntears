package{
	
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.AobaoScene;
	import com.ybcx.huluntears.scenes.FirstMapScene;
	import com.ybcx.huluntears.scenes.StartMovieScene;
	import com.ybcx.huluntears.scenes.WelcomeScene;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * 主控各个场景切换的类，监听场景切换事件<br/>
	 * 该类父类必须是starling.display.Sprite
	 * 这里不能有FLASH原生事件
	 * 
	 * 2012/04/06
	 */ 
	public class Game extends Sprite{
		
		private var startScene:StartMovieScene;
		private var welcomeScene:WelcomeScene;
		private var aobaoScene:AobaoScene;
		private var firstMapScene:FirstMapScene;
		
		
		public function Game(){
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		private function onStage(evt:Event):void{
			//1、显示开场动画场景
			//FIXME, release here...
			startScene = new StartMovieScene();
			startScene.addEventListener(GameEvent.SWITCH_SCENE, gotoWelcome);
			this.addChild(startScene);	
		}
		
		//2，开场动画结束，进入主菜单
		private function gotoWelcome(evt:Event):void{
						
			this.removeChild(startScene,true);			
						
			welcomeScene = new WelcomeScene();
			welcomeScene.addEventListener(GameEvent.SWITCH_SCENE, gotoAobao);
			this.addChild(welcomeScene);
		}
		
		private function gotoAobao(evt:Event):void{
			this.removeChild(welcomeScene,true);
			
			aobaoScene = new AobaoScene();
			this.addChild(aobaoScene);
			aobaoScene.addEventListener(GameEvent.SWITCH_SCENE, gotoFirstMap);
		}
		
		private function gotoFirstMap(evt:Event):void{
			this.removeChild(aobaoScene);
						
			if(!firstMapScene){
				firstMapScene = new FirstMapScene();
				firstMapScene.addEventListener(GameEvent.SWITCH_SCENE, backtoAobao);				
			}
			this.addChild(firstMapScene);
						
		}
		
		private function backtoAobao(evt:Event):void{
			this.removeChild(firstMapScene);
			
			this.addChild(aobaoScene);
		}
		
	} //end of class
}