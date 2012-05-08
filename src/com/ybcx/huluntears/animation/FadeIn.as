package com.ybcx.huluntears.animation{
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	
	import starling.core.Starling;
	
	import starling.display.DisplayObject;
	
	/**
	 * 淡入，逐渐显现
	 */ 
	public class FadeIn{
		
		public function FadeIn(target:DisplayObject, duration:Number=1){
			target.alpha = 0;
			var tween:Tween = new Tween(target,duration);
			tween.animate("alpha", 1);
			Starling.juggler.add(tween);
		}
		
	} //end of class
}