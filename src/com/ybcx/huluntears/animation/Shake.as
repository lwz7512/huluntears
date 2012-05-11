package com.ybcx.huluntears.animation{
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	
	/**
	 * 左右晃动
	 */ 
	public class Shake{
		
		
		public function Shake(target:DisplayObject, duration:Number=0.1, offset:Number=10){
			var startX:Number = target.x;			
			var left:Tween = new Tween(target,duration);
			left.animate("x", startX-offset);
			left.onComplete = function():void{
				var back:Tween = new Tween(target,duration);
				back.animate("x", startX);
				Starling.juggler.add(back);
			};
			Starling.juggler.add(left);
		}
		
	} //end of class
}