package com.ybcx.huluntears.animation{
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	
	/**
	 * 淡出，逐渐消失
	 */ 
	public class FadeOut{
		
		public function FadeOut(target:DisplayObject, duration:Number=0.6, onComplete:Function=null){
			var tween:Tween = new Tween(target,duration);
			tween.animate("alpha", 0);
			if(onComplete!=null) tween.onComplete = onComplete; 
			Starling.juggler.add(tween);
		}
		
	} //end of class
}