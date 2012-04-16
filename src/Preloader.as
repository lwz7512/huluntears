package {
	
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author lwz
	 */
	public class Preloader extends MovieClip 
	{
		
		public function Preloader() 
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO show loader
		}
		
		private function ioError(e:IOErrorEvent):void 
		{
			trace(e.text);
		}
		
		private function progress(e:ProgressEvent):void 
		{
			// update loader
			//在浏览器顶部header的位置绘制矩形长条，长条充满浏览器宽度即加载完成
			//高度2个像素够了，使用lineto绘制
			//屏幕中央放置loading...
			var percent:Number = e.bytesLoaded/e.bytesTotal;
			
			if(this.stage){
				var pbWidh:Number = this.stage.stageWidth;
				this.graphics.clear();
				//草绿
				this.graphics.beginFill(0x00BC12);
				this.graphics.drawRect(0,0,pbWidh*percent,2);
				this.graphics.endFill();
			}
			
		}
		
		private function checkFrame(e:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
			
		}
		
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// hide loader
			this.graphics.clear();
			
			startup();
		}
		
		private function startup():void 
		{
			var mainClass:Class = getDefinitionByName("Startup") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}