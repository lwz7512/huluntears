package com.ybcx.huluntears.scenes{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.AboutUsLayer;
	import com.ybcx.huluntears.ui.STProgressBar;
	
	import flash.display.Bitmap;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	
	public class WelcomeScene extends BaseScene{
		
		private var _queLoader:QueueLoader;		
		//loading...
		private var _progressbar:STProgressBar;
		
		private var bg:Image;
		private var bgFile:String = "assets/welcome/47.jpg";
		
		private var aboutusBtn:Button;
		private var aboutusX:Number = 453;
		private var aboutusY:Number = 245;
		private var aboutusNormal:String = "assets/welcome/aboutus_normal.png";
		private var aboutusNTexture:Bitmap;		
		private var aboutusHilite:String = "assets/welcome/aboutus_hilite.png";
		private var aboutusHTexture:Bitmap;
		
		private var playgameBtn:Button;
		private var playgameX:Number = 453;
		private var playgameY:Number = 193;
		private var playgameNormal:String = "assets/welcome/playgame_normal.png";
		private var playgameNTexture:Bitmap;
		private var playgameHilite:String = "assets/welcome/playgame_hilite.png";
		private var playgameHTexture:Bitmap;
				
		private var aboutusBgFile:String = "assets/welcome/dialogbg.png";			
		private var aboutusBM:Bitmap;
		private var aboutusLayer:AboutUsLayer;
		
		
		
		
		public function WelcomeScene(){
			super();
			
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemComplete);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR, onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onQueueProgress);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueueComplete);
			
			_queLoader.addItem(bgFile,null, {title : bgFile});
			_queLoader.addItem(aboutusNormal,null, {title : aboutusNormal});
			_queLoader.addItem(aboutusHilite,null, {title : aboutusHilite});
			_queLoader.addItem(playgameNormal,null, {title : playgameNormal});
			_queLoader.addItem(playgameHilite,null, {title : playgameHilite});
			
			_queLoader.addItem(aboutusBgFile,null, {title : aboutusBgFile});
		}
		
		override protected function onStage(evt:Event):void{
			
			_queLoader.execute();
			
//			_progressbar = new STProgressBar(0x666666,this.stage.stageWidth,2,"载入欢迎画面...");
			//放在舞台中央
//			_progressbar.x = 0;
//			_progressbar.y = this.stage.stageHeight >>1;
//			this.addChild(_progressbar);
		}
		
		private function onItemComplete(evt:QueueLoaderEvent):void{
			if(evt.title==bgFile){//放背景图
				bg = new Image(Texture.fromBitmap(evt.content as Bitmap));
				this.addChildAt(bg,0);
			}
			if(evt.title==aboutusNormal){
				aboutusNTexture = evt.content as Bitmap;
			}
			if(evt.title==aboutusHilite){
				aboutusHTexture = evt.content as Bitmap;
			}
			//放aboutus按钮
			if(aboutusNTexture && aboutusHTexture){
				aboutusBtn = new Button(Texture.fromBitmap(aboutusNTexture),"",Texture.fromBitmap(aboutusHTexture));
				aboutusBtn.x = aboutusX;
				aboutusBtn.y = aboutusY;
				this.addChild(aboutusBtn);
				aboutusBtn.addEventListener(Event.TRIGGERED, openAboutus);
			}
			
			if(evt.title==playgameNormal){
				playgameNTexture = evt.content as Bitmap;
			}
			if(evt.title==playgameHilite){
				playgameHTexture =  evt.content as Bitmap;
			}
			//放playgame按钮
			if(playgameNTexture && playgameHTexture){
				playgameBtn = new Button(Texture.fromBitmap(playgameNTexture),"",Texture.fromBitmap(playgameHTexture));
				playgameBtn.x = playgameX;
				playgameBtn.y = playgameY;
				this.addChild(playgameBtn);
			}
			
			//关于我们窗口需要的背景图
			if(evt.title==aboutusBgFile){
				aboutusBM = evt.content as Bitmap;
				//如果在图片下载完成前打开了，就赋值
				if(aboutusLayer) aboutusLayer.background = aboutusBM;
			}
			
		}
		
		private function openAboutus(evt:Event):void{
			aboutusLayer = new AboutUsLayer(300,250);
			aboutusLayer.x = this.stage.stageWidth-aboutusLayer.width >> 1;
			aboutusLayer.y = this.stage.stageHeight-aboutusLayer.height >>1;
			if(aboutusBM){
				aboutusLayer.background = aboutusBM;
			}
			this.addChild(aboutusLayer);
		}
		
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error: "+evt.title);
		}
		private function onQueueProgress(evt:QueueLoaderEvent):void{
//			_progressbar.progress = evt.queuepercentage;
		}
		private function onQueueComplete(evt:QueueLoaderEvent):void{
//			this.removeChild(_progressbar);
			
		}
		
	} //end of class
}