package com.ybcx.huluntears.data{
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flash.events.EventDispatcher;
	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	public class XMLoader extends EventDispatcher{
		
		private var _path:String;
		private var _loader:URLLoader;
		private var _xml:XML;
		private var _children:XMLList;
		
		public function XMLoader(path:String){
			super();
			
			_path = path;
			//fetch immediately...
			_loader = new URLLoader(new URLRequest(path));
			_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.addEventListener(Event.COMPLETE, onComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		}
		
		public function get xml():XML{
			return _xml;
		}
		public function get nodes():XMLList{
			if(!_xml) return new XMLList();
			return _xml.elements();
		}
		
		private function onProgress(evt:ProgressEvent):void{
			this.dispatchEvent(evt);
		}
		
		private function onComplete(evt:Event):void{
			//parse xml data...
			_xml = XML(_loader.data);
			
			this.dispatchEvent(evt);
		}
		
		private function onError(evt:IOErrorEvent):void{
			this.dispatchEvent(evt);
			trace("Error to load xml: "+_path);
		}
		
	} //end of class
}