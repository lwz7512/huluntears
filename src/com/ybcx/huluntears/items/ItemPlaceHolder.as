package com.ybcx.huluntears.items{
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * 道具栏中，预先放好的道具占位符，表示要在场景中捡到该形状的道具<br/>
	 * 当道具放到该占位符上后，该占位符要消失；
	 * 
	 * 2012/05/08
	 */ 
	public class ItemPlaceHolder extends Image{
				
		
		public function ItemPlaceHolder(texture:Texture){
			super(texture);
			
		}
		
		public function disappear():void{
			this.removeFromParent(true);
		}
		
	} //end of class
}