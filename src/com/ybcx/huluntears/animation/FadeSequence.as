package com.ybcx.huluntears.animation{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * 闪烁动画，即反复淡入淡出
	 * 
	 * 2012/04/23
	 */ 
	public class FadeSequence extends EventDispatcher{
		
		//闪烁对象
		private var _target:DisplayObject;
		
		//一个淡入淡出耗时，单位秒
		private var _roundTime:Number;
		//透明度变化幅度
		private var _alphaDelta:Number;		
		//上一次透明度
		private var _lastAlpha:Number = 0;
		
		//淡入淡出次数
		private var _roundNum:int;
		private var _roundCounter:int;
		
		//定时器
		private var _timer:Timer;
		
		
		/**
		 * @param target 闪烁的对象
		 * @param roundTime 一次闪烁经历的时长，秒为单位
		 * @param roundNum 闪烁次数
		 */ 
		public function FadeSequence(target:DisplayObject, roundTime:Number, roundNum:int){
			_target = target;
			_roundTime = roundTime;
			_roundNum = roundNum;
			//透明度从0到1，再从1到0,经历两个阶段
			_alphaDelta = 10/(2*roundTime*1000);
			
			_timer = new Timer(10);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		private function onTimer(evt:TimerEvent):void{
			_lastAlpha += _alphaDelta;
			if(_lastAlpha>1 || _lastAlpha<0){
				_alphaDelta = -_alphaDelta;
				_roundCounter ++
			}
			if(_roundCounter>0 && _roundCounter/2==_roundNum){
				_timer.stop();				
			}
			//更新透明度
			_target.alpha = _lastAlpha;
			
			//恢复可见性，准备交互
			if(!_timer.running){
				_target.alpha = 1;
				var end:Event = new Event("complete");
				this.dispatchEvent(end);
				dispose();
			}
		}
								
		/**
		 * 闪烁开始
		 */ 
		public function start():void{
			_timer.start();
			_target.alpha = 0;
		}
		
		/**
		 * 销毁
		 */ 
		public function dispose():void{
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer = null;
			_target = null;
		}
		
	} //end of class
}