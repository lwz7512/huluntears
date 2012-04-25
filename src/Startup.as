package{
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import net.hires.debug.Stats;
	
	import starling.core.Starling;
	
	[Frame(factoryClass="Preloader")]
	[SWF(width="760", height="580", frameRate="24", backgroundColor="#FFFFFF")]
	public class Startup extends Sprite{
		
		
		private var mStarling:Starling;
		
		public function Startup(){			
			
			addChild (new Stats());
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStageReady);
		}
		
		private function onStageReady(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);
			
			setupStage();			
			
			//build engine...
			mStarling = new Starling(Game, this.stage);
			mStarling.start();
		}
		
		
		private function setupStage():void{
			//不允许图形缩放
			this.stage.scaleMode =StageScaleMode.NO_SCALE;
			//从左上角开始绘制
			this.stage.align = StageAlign.TOP_LEFT;
			//隐藏所有默认右键菜单
			this.stage.showDefaultContextMenu = false;
			
		}
		

		
	} //end of class
}