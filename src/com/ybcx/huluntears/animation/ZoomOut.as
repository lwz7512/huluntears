package com.ybcx.huluntears.animation{
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	
	/**
	 * 放大
	 */ 
	public class ZoomOut{
		
		public function ZoomOut(target:DisplayObject, duration:Number=1, onComplete:Function=null){
			target.scaleX = 0.4;
			target.scaleY = 0.4;
			var tween:Tween = new Tween(target,duration);
			tween.animate("scaleX", 1);
			tween.animate("scaleY", 1);
			if(onComplete!=null) tween.onComplete = onComplete;
			Starling.juggler.add(tween);
		}
		
	} //end of class
}