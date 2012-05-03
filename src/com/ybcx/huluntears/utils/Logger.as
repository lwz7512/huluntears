package com.ybcx.huluntears.utils{
	
	import com.gaiaframework.debug.GaiaDebug;
		
	public class Logger{
		
		public function Logger(){
		}
		
		public static function debug(info:String):void{
			GaiaDebug.log(">D>: "+info);			
		}
		
		public static function warn(info:String):void{
			GaiaDebug.warn(">W>: "+info);
		}
		
		public static function error(info:String):void{
			GaiaDebug.error(">E>: "+info);
		}
		
	}
	
}