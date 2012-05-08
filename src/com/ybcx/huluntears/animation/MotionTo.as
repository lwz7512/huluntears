package com.ybcx.huluntears.animation{
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	
	public class MotionTo{
				
		
		public function MotionTo(target:DisplayObject, endX:Number, endY:Number, complete:Function=null, duration:Number=1, fromRBcorner:Boolean=false){			
			//从右下角出发
			if(target.stage && fromRBcorner){
				target.x = target.stage.stageWidth;
				target.y = target.stage.stageHeight;
			}			
			
			var tween:Tween = new Tween(target, duration);
			tween.animate("x", endX);
			tween.animate("y", endY);
			if(complete!=null) tween.onComplete = complete;
			Starling.juggler.add(tween);
		}
				
		
	} //end of class
}