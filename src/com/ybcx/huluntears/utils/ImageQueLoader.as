package com.ybcx.huluntears.utils{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * 扩展的图片队列加载器
	 * 
	 * 2012/04/30~05/03
	 */ 
	public class ImageQueLoader extends QueueLoader{
		
		private var _imagePool:Dictionary;
		
		
		public function ImageQueLoader(ignoreErrors:Boolean=false, loaderContext:LoaderContext=null, bandwidthMonitoring:Boolean=false, id:String=""){
			super(ignoreErrors, loaderContext, bandwidthMonitoring, id);
			_imagePool = new Dictionary();
			addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemComplete);
		}
		
		/**
		 * 将图片添加到查询队列中<br/>
		 * 
		 * @param src 图片的地址
		 * 
		 */ 
		public function addImageByUrl(src:String):void{
			this.addItem(src,null,{title : src});					
		}
		
		public function getImageByUrl(src:String):Image{
			if(_imagePool[src]) return _imagePool[src] as Image;
			return null;
		}
		
		
		public function getTextrByUrl(src:String):Texture{
			if(_imagePool[src]) return Image(_imagePool[src]).texture;
			return null;
		}
		
		private function onItemComplete(evt:QueueLoaderEvent):void{
			var bitmap:Bitmap = evt.content as Bitmap;
			_imagePool[evt.title] = new Image(Texture.fromBitmap(evt.content));
		}
		
		override public function dispose():void{
			super.dispose();
			
			_imagePool = null;
		}
		
	} //end of class
}