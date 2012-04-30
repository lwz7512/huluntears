package com.ybcx.huluntears.scenes{
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.data.XMLoader;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.STProgressBar;
	
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
		
		//用来加载图片
		private var _queLoader:QueueLoader;
		
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
		
		override protected function  onTouching(touch:Touch):void{
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
		
		override protected function onStage(evt:Event):void{
			super.onStage(evt);
			
			
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemComplete);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR, onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onQueueProgress);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueueComplete);
			
			_queLoader.addItem(storyImgPath_1,null,{title:storyImgPath_1});
			_queLoader.addItem(storyImgPath_2,null,{title:storyImgPath_2});
			_queLoader.addItem(storyImgPath_3,null,{title:storyImgPath_3});
			
			_queLoader.execute();
		}
		
				
		
		private function onItemComplete(evt:QueueLoaderEvent):void{
			var bitmap:Bitmap = evt.content as Bitmap;
			
			if(evt.title==storyImgPath_1){
				storyImg_1 = new Image(Texture.fromBitmap(evt.content));
				stories.push(storyImg_1);
			}
			if(evt.title==storyImgPath_2){
				storyImg_2 = new Image(Texture.fromBitmap(evt.content));
				stories.push(storyImg_2);
			}
			if(evt.title==storyImgPath_3){
				storyImg_3 = new Image(Texture.fromBitmap(evt.content));
				stories.push(storyImg_3);
			}
		}
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error: "+evt.title);
		}
		private function onQueueProgress(evt:QueueLoaderEvent):void{
			var progress:GameEvent = new GameEvent(GameEvent.LOADING_PROGRESS,evt.percentage);
			this.dispatchEvent(progress);
		}
		private function onQueueComplete(evt:QueueLoaderEvent):void{
			var complete:GameEvent = new GameEvent(GameEvent.LOADING_COMPLETE);
			this.dispatchEvent(complete);
			
			//show the first story...
			storyImg_1.alpha = 0;
			this.addChild(storyImg_1);
			
			var fadeIn:Tween = new Tween(storyImg_1,0.6);
			fadeIn.animate("alpha",1);
			Starling.juggler.add(fadeIn);
		}
		

		
		override public function dispose():void{
			super.dispose();
			
		
			_queLoader.dispose();
			
		}
		
	} //end of class
}