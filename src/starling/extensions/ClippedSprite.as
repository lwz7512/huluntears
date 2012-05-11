package starling.extensions
{
    import flash.display3D.Context3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    import starling.errors.MissingContextError;
    
	/**
	 * http://wiki.starling-framework.org/extensions/clippedsprite
	 * 
	 * var sprite:ClippedSprite = new ClippedSprite(); 
		// the sprite works line you're used to
		sprite.addChild(anObject);
		sprite.addChild(anotherObject);
 
		// set the mask rectangle in stage coordinates
		// 妈的，全局坐标...
		sprite.clipRect = new Rectangle(10, 10, 380, 280);
	 * 
	 */ 
    public class ClippedSprite extends Sprite{
		
        private var mClipRect:Rectangle;
                
        public override function render(support:RenderSupport, alpha:Number):void{
            if (mClipRect == null) super.render(support, alpha);
            else
            {
                var context:Context3D = Starling.context;
                if (context == null) throw new MissingContextError();
                
                support.finishQuadBatch();
                context.setScissorRectangle(mClipRect);

                super.render(support, alpha);
                
                support.finishQuadBatch();
                context.setScissorRectangle(null);
            }
        }

        public override function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject{
            // on a touch test, invisible or untouchable objects cause the test to fail
            if (forTouch && (!visible || !touchable)) return null;
            
            var scale:Number = Starling.current.contentScaleFactor;
            var globalPoint:Point = localToGlobal(localPoint);
			
            //FIXME, DO NOT CONTINUE WHILE NULL...
			//2012/05/11
			if(!mClipRect) return null;
			
            if (mClipRect.contains(globalPoint.x * scale, globalPoint.y * scale))
                return super.hitTest(localPoint, forTouch);
            else
                return null;
        }
        
        public function get clipRect():Rectangle{ 
            var scale:Number = Starling.current.contentScaleFactor;
            return new Rectangle(mClipRect.x     / scale, mClipRect.y      / scale, 
                                 mClipRect.width / scale, mClipRect.height / scale);
        }
        
        public function set clipRect(value:Rectangle):void{ 
            var scale:Number = Starling.current.contentScaleFactor;
            if (mClipRect == null) mClipRect = new Rectangle();
            mClipRect.x     = scale * value.x;     mClipRect.y      = scale * value.y;
            mClipRect.width = scale * value.width; mClipRect.height = scale * value.height;
        }
    }
}