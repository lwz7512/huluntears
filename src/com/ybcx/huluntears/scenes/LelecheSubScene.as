package com.ybcx.huluntears.scenes{
	
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	
	public class LelecheSubScene extends BaseScene{
		
		private var _lelecheBGPath:String = "assets/leleche/leleche_bg.jpg";
		//进入大地图场景箭头
		private var _toolReturnPath:String = "assets/sceaobao/tool_return.png";
		
		private var lelecheBg:Image;
		//返回按钮
		private var goMap:Image;
		
		//拖拽用参数
		private var _lastTouchX:Number;
		private var _lastTouchY:Number;
		
		
		
		
		public function LelecheSubScene(){
			super();
		}
		
		override protected function initScene():void{
			addDownloadTask(_lelecheBGPath);
			addDownloadTask(_toolReturnPath);
			
			download();
		}
		
		override protected function readyToShow():void{
			lelecheBg = this.getImageByUrl(_lelecheBGPath);
			this.addChild(lelecheBg);
			
			//到大地图场景
			goMap = getImageByUrl(_toolReturnPath);
			goMap.x = AppConfig.VIEWPORT_WIDTH-40;
			goMap.y = AppConfig.VIEWPORT_HEIGHT >> 1;
			this.addChild(goMap);
			
			//默认先隐藏，鼠标移动到附近，才显示
			goMap.visible = false;
			goMap.addEventListener(TouchEvent.TOUCH, onMapTouched);
			
		}
		
		private function onMapTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(goMap);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(end);
			}
		}
		
		override protected function onTouching(touch:Touch):void{
			if (touch == null) {
				if(goMap) goMap.visible = false;
				return;
			}
			
			//在一个矩形区域内
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-100 && touch.globalY<AppConfig.VIEWPORT_HEIGHT){
				if(goMap) goMap.visible = true;
			}else{
				if(goMap) goMap.visible = false;
			}			
			//如果贴近右边缘，就隐藏
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-10){
				if(goMap) goMap.visible = false;
			}
			
			//改为拖拽了，鼠标感应移动太难用了
			dragMap(touch);
			
		}
		
		private function dragMap(touch:Touch):void{
			//记下初始鼠标位置
			if(touch.phase == TouchPhase.BEGAN){
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;							
			}
			
			//当前移动的按下状态鼠标位置
			if(touch.phase == TouchPhase.MOVED){
				var movedX:Number = touch.globalX-_lastTouchX;
				var movedY:Number = touch.globalY-_lastTouchY;
				
				//移动各个元素
				lelecheBg.y += movedY;
				
				
				//-------------- 移动结束，记下上一个位置 -------------------
				_lastTouchX = touch.globalX;
				_lastTouchY = touch.globalY;
			}
			
		}
		
		

		
		
	} //end of class
}