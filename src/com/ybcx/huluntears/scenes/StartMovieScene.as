package com.ybcx.huluntears.scenes{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.data.XMLoader;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.STProgressBar;
	import com.ybcx.huluntears.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	/**
	 * 点击开始游戏后，游戏背景故事（四格漫画）
	 * 
	 * 2012/04/28
	 */ 
	public class StartMovieScene extends BaseScene{
		
		private var storyImgPath_1:String = "assets/startmovie/story_1.jpg";
		private var storyImgPath_2:String = "assets/startmovie/story_2.jpg";
		private var storyImgPath_3:String = "assets/startmovie/story_3.jpg";
		
		
		private var storyImg_1:Image;
		private var storyImg_2:Image;
		private var storyImg_3:Image;
		
		
		private var _storyCounter:int;
		private var stories:Array;
		private var playingFlag:Boolean;
		
		
		
		
		
		public function StartMovieScene(){
			super();	
			stories = [];
		}
		
		
		override protected function initScene():void{				
			
			addDownloadTask(storyImgPath_1);
			addDownloadTask(storyImgPath_2);
			addDownloadTask(storyImgPath_3);
			
			download();
		}
		
		override protected function detached():void{			
			this.dispose();
			trace("start movie scene destroyed!");
		}
		
		override protected function  onTouching(touch:Touch):void{
			if(!touch) return;
			
			var inLeft:Boolean;
			if(touch.phase==TouchPhase.ENDED){
				if(touch.globalX>this.stage.stageWidth/2){
					inLeft = false;
				}else{
					inLeft = true;
				}
				if(inLeft){
					playPrev()
				}else{
					playNext();
				}
			}
		}
		
		
		
		private function playNext():void{
			if(playingFlag) return;
			
			playingFlag = true;
						
			_storyCounter++;
			//下边界
			if(_storyCounter>stories.length-1){
				_storyCounter = stories.length;
			}
			
			if(_storyCounter>stories.length-1){
				var nextScene:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(nextScene);
			}else{
				var distance:Number = this.stage.stageWidth;
				
				var lastStory:Image = stories[_storyCounter-1] as Image;
				var goOut:Tween = new Tween(lastStory,0.6);
				goOut.onComplete = function():void{
					removeChild(Image(stories[_storyCounter-1]));
					playingFlag = false;
				};
				goOut.animate("x",-distance);
				Starling.juggler.add(goOut);
				
				var curtStory:Image = stories[_storyCounter] as Image;
				this.addChild(curtStory);
				
				curtStory.x = distance;
				var goIn:Tween = new Tween(curtStory,0.6);
				goIn.animate("x",0);
				Starling.juggler.add(goIn);
				
			}
		}
		private function playPrev():void{
			if(playingFlag) return;
			
			playingFlag = true;
			
			_storyCounter--;			
			//上边界
			if(_storyCounter<0){
				_storyCounter = 0;
				//FIXME, 恢复初始状态
				playingFlag = false
				return;
			}
			
			var distance:Number = this.stage.stageWidth;
			
			var lastStory:Image = stories[_storyCounter] as Image;
			lastStory.x = -distance;
			this.addChild(lastStory);
			
			var goIn:Tween = new Tween(lastStory,0.6);
			goIn.animate("x",0);
			Starling.juggler.add(goIn);
			
						
			var curtStory:Image = stories[_storyCounter+1] as Image;		
			var goOut:Tween = new Tween(curtStory,0.6);
			goOut.onComplete = function():void{
				removeChild(Image(stories[_storyCounter+1]));
				playingFlag = false;
			};
			goOut.animate("x",distance);
			Starling.juggler.add(goOut);
			
		}
		
		override protected function readyToShow():void{			
			storyImg_1 = getImageByUrl(storyImgPath_1);
			stories.push(storyImg_1);
			storyImg_2 = getImageByUrl(storyImgPath_2);
			stories.push(storyImg_2);
			storyImg_3 = getImageByUrl(storyImgPath_3);
			stories.push(storyImg_3);
			
			//show the first story...
			storyImg_1.alpha = 0;
			this.addChild(storyImg_1);
			
			var fadeIn:Tween = new Tween(storyImg_1,0.6);
			fadeIn.animate("alpha",1);
			Starling.juggler.add(fadeIn);
		}
		

		
		override public function dispose():void{
			super.dispose();
			
			this.removeChildren(0,-1,true);
					
		}
		
	} //end of class
}