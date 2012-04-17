package com.ybcx.huluntears.scenes{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.data.XMLoader;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.STProgressBar;
	
	import flash.display.Bitmap;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	
	public class StartMovieScene extends BaseScene{
		
		private var _movieData:String = "assets/startmovie/movie.xml";
		private var _moviePath:String = "assets/startmovie/frames/";
		
		private var _xmlLoader:XMLoader;
		//用来加载图片
		private var _queLoader:QueueLoader;
		
		//最终生成的影片片段
		private var _movieByImages:MovieClip;
		//构建影片片段需要的素材集
		private var _frames:Vector.<Texture>;
		
		//loading...
		private var _progressbar:STProgressBar;
		
		
		public function StartMovieScene(){
			super();
									
		}
		
		override protected function onStage(evt:Event):void{
			super.onStage(evt);
			
			_xmlLoader = new XMLoader(_movieData);
			_xmlLoader.addEventListener(flash.events.Event.COMPLETE, onXMLComplete);			
			
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemComplete);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR, onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onQueueProgress);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueueComplete);
			
			_frames = new Vector.<Texture>();
		}
		
		public function stop():void{
			_movieByImages.stop();
		}
		
		private function onXMLComplete(evt:flash.events.Event):void{
			var frames:XMLList = _xmlLoader.nodes;
			for each(var frame:XML in frames){
				var imagePath:String =  _moviePath+frame.attribute("src");
				_queLoader.addItem(imagePath, null, {title:"mv_"+imagePath});				
			}
			if(frames.length()){
				_queLoader.execute();
				trace("start loading "+_movieData);
			}
			
			_progressbar = new STProgressBar(0x666666,this.stage.stageWidth,2,"载入片头动画...");
			//放在舞台中央
			_progressbar.x = 0;
			_progressbar.y = this.stage.stageHeight >>1;
			this.addChild(_progressbar);
		}
				
		
		private function onItemComplete(evt:QueueLoaderEvent):void{
			var bitmap:Bitmap = evt.content as Bitmap;
			if(bitmap)
				_frames.push(Texture.fromBitmap(bitmap));
		}
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error: "+evt.title);
		}
		private function onQueueProgress(evt:QueueLoaderEvent):void{
			_progressbar.progress = evt.queuepercentage;
		}
		private function onQueueComplete(evt:QueueLoaderEvent):void{
			this.removeChild(_progressbar);
			//FIXME, ....TO MODIFY FRAMERATE...
			_movieByImages = new MovieClip(_frames,24);
			_movieByImages.addEventListener(Event.COMPLETE, onSceneComplete);
			this.addChild(_movieByImages);
			//播放
			Starling.juggler.add(_movieByImages);
		}
		
		
		private function onSceneComplete(evt:Event):void{
			_movieByImages.stop();			
			var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
			this.dispatchEvent(end);
			
		}
		
		override public function dispose():void{
			super.dispose();
			
			_frames = null;
			this.removeChild(_movieByImages);
			_movieByImages = null;
			_queLoader.dispose();
			
		}
		
	} //end of class
}