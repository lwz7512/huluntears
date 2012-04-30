package com.ybcx.huluntears.ui{
	
	import com.ybcx.huluntears.animation.FadeSequence;
	import com.ybcx.huluntears.events.GameEvent;
	
	import starling.animation.Tween;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	/**
	 * 加载画面，也是欢迎画面，当加载其他场景时，按钮都不可见
	 * 
	 * 2012/04/28
	 */ 
	public class STLoadingView extends Sprite{
		
		[Embed(source="assets/loading/loading_base.jpg")]
		private var baseImg:Class;
		[Embed(source="assets/loading/loading_mgseye.png")]
		private var mgsEye:Class;
		
		[Embed(source="assets/loading/aboutus_normal.png")]
		private var aboutUsNormal:Class;
		[Embed(source="assets/loading/aboutus_clicked.png")]
		private var aboutUsClicked:Class;
		
		[Embed(source="assets/loading/startgame_normal.png")]
		private var startGameNormal:Class;
		[Embed(source="assets/loading/startgame_clicked.png")]
		private var startGameClicked:Class;
		
		private var _baseImg:Image;
		private var _mgsEye:Image;
		
		private var _aboutUSBtn:Button;
		private var _startGameBtn:Button;
		
		private var _initCompleted:Boolean;
		
		//loading bar
		private var _progressbar:STProgressBar;
		//loading text
		private var _loadingSceneTxt:TextField;
		
		//眼睛闪烁动画
		private var _eyeAnimation:FadeSequence;
		
		
		
		
		public function STLoadingView(){
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE,offStage);
		}
		
		private function onStage(evt:Event):void{
			this.removeEventListener(evt.type,arguments.callee);
			
			//重新显示加载画面时，继续闪烁
			if(_eyeAnimation) _eyeAnimation.start();
			
			if(_initCompleted) return;
			
			
			//第一次初始化加载画面
			
			_baseImg = new Image(Texture.fromBitmap(new baseImg()));
			this.addChild(_baseImg);
			
			_mgsEye = new Image(Texture.fromBitmap(new mgsEye()));
			_mgsEye.x = 284;
			_mgsEye.y = 49;
			this.addChild(_mgsEye);
			
			_eyeAnimation = new FadeSequence(_mgsEye,0.2);
			_eyeAnimation.start();
			
			_progressbar = new STProgressBar(0x333333,this.stage.stageWidth,8,null);
			//放在底部
			_progressbar.y = this.stage.stageHeight-8;
			this.addChild(_progressbar);
			
			//先创建，不显示，加载时改变文字内容，并显示
			_loadingSceneTxt = new TextField(200,20,"loading...");
//			_loadingSceneTxt.color = 0xFFFFFF;
			_loadingSceneTxt.x = 350;
			_loadingSceneTxt.y = 520;
			
			var aboutUsUpTexture:Texture = Texture.fromBitmap(new aboutUsNormal());
			var aboutUsDownTexture:Texture = Texture.fromBitmap(new aboutUsClicked());
			_aboutUSBtn = new Button(aboutUsUpTexture,"",aboutUsDownTexture);
			_aboutUSBtn.x = 414;
			_aboutUSBtn.y = 515;
			_aboutUSBtn.addEventListener(Event.TRIGGERED,onAboutUs);
			this.addChild(_aboutUSBtn);
			
			var startGameUpTexture:Texture = Texture.fromBitmap(new startGameNormal());
			var startGameDownTexture:Texture = Texture.fromBitmap(new startGameClicked());
			_startGameBtn = new Button(startGameUpTexture,"",startGameDownTexture);
			_startGameBtn.x = 229;
			_startGameBtn.y = 372;
			_startGameBtn.addEventListener(Event.TRIGGERED,onStartGame);
			this.addChild(_startGameBtn);
			
			
			_initCompleted = true;
		}
		
		private function offStage(evt:Event):void{
			this.removeEventListener(evt.type,arguments.callee);
			trace("loading view removed...");
			//清理舞台
			_progressbar.progress = 0;
			_loadingSceneTxt.text = "";
			_eyeAnimation.pauseToInvisible();
			_startGameBtn.visible = false;
			_aboutUSBtn.visible = false;
		}
		
		private function onAboutUs(evt:Event):void{
			var about:GameEvent = new GameEvent(GameEvent.OPEN_ABOUTUS);
			this.dispatchEvent(about);
		}
		private function onStartGame(evt:Event):void{
			var start:GameEvent = new GameEvent(GameEvent.START_GAME);
			this.dispatchEvent(start);
			//禁用掉按钮
			_startGameBtn.enabled = false;
			_aboutUSBtn.enabled = false;
		}
		
		public function set progress(percent:Number):void{
			if(!_initCompleted) return;
			
			_progressbar.progress = percent;
		}
		
		/**
		 * 在其他场景使用加载画面时，要设置按钮状态
		 */ 
		public function loading(scene:String):void{
			if(!_initCompleted) return;
			
			_aboutUSBtn.visible = false;
			_startGameBtn.visible = false;
			
			_loadingSceneTxt.text = scene;
			
			if(!this.contains(_loadingSceneTxt)){
				this.addChild(_loadingSceneTxt);				
			}
			
		}
		
		/**
		 * 在其他场景使用加载画面时，同时要隐藏眼睛
		 */ 
		public function hideEye():void{
			if(!_initCompleted) return;
			
			_eyeAnimation.pauseToInvisible();
		}
		
		public function showEye():void{
			if(!_initCompleted) return;
			
			_eyeAnimation.start();
		}
		
	} //end of class
}