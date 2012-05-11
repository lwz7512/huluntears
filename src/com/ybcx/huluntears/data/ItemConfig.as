package com.ybcx.huluntears.data{
	
	/**
	 * 所有道具用到的图片素材配置
	 */ 
	public class ItemConfig{
				
		
		public function ItemConfig(){
			
		}
		
		/**
		 * 工具栏组合道具图片的路径
		 */ 
		public function groupItemPath(groupName:String):String{
			if(groupName=="dinggan"){
				return "assets/firstitems/dinggan_group.png";
			}else if(groupName=="tianchuang"){
				return "assets/firstitems/tianchuang_group.png";
			}
			return null;
		}
		
		/**
		 * 按顺序排列需要用到的蒙古包道具名称13个，这个顺序决定了选择的道具是否能正确放置
		 */ 
		public function get mgbBuildingNames():Array{
			var names:Array = [];
			names.push("weibi_backright");
			names.push("weibi_backleft");
			names.push("zhuzi_left");
			names.push("zhuzi_right");
			names.push("tianchuang");
			names.push("weibi_frontleft");
			names.push("weibi_frontright");
			names.push("men");
			names.push("dinggan");
			names.push("weizhan");
			names.push("dingzhan");
			names.push("gaizhan");
			names.push("menzhan");
			
			return names;
		}
		
		/**
		 * 第一个关搭建蒙古包用到的道具：搭建道具13个<br/>
		 * 大地图场景用到此配置
		 */ 		
		public function get buildingMGBImgs():Array{
			var paths:Array = [];
			
			//围壁_后左
			var weibi_backleft:BuildingVO = new BuildingVO();
			weibi_backleft.buildingX = 5;
			weibi_backleft.buildingY = 40;
			weibi_backleft.buildingName = "weibi_backleft";
			weibi_backleft.buildingPath = "assets/mgb/weibi_backleft.png";
			paths.push(weibi_backleft);
			//围壁_后右
			var weibi_backright:BuildingVO = new BuildingVO();
			weibi_backright.buildingX = 107;
			weibi_backright.buildingY = 40;
			weibi_backright.buildingName = "weibi_backright";
			weibi_backright.buildingPath = "assets/mgb/weibi_backright.png";
			paths.push(weibi_backright);
			//柱子_左
			var zhuzi_left:BuildingVO = new BuildingVO();
			zhuzi_left.buildingX = 76;
			zhuzi_left.buildingY = 9;
			zhuzi_left.buildingName = "zhuzi_left";
			zhuzi_left.buildingPath = "assets/mgb/zhuzi_left.png";
			paths.push(zhuzi_left);
			//柱子_右
			var zhuzi_right:BuildingVO = new BuildingVO();
			zhuzi_right.buildingX = 120;
			zhuzi_right.buildingY = 9;
			zhuzi_right.buildingName = "zhuzi_right";
			zhuzi_right.buildingPath = "assets/mgb/zhuzi_right.png";
			paths.push(zhuzi_right);
			//天窗
			var tianchuang:BuildingVO = new BuildingVO();
			tianchuang.buildingX = 78;
			tianchuang.buildingY = 0;
			tianchuang.buildingName = "tianchuang";
			tianchuang.buildingPath = "assets/mgb/tianchuang.png";
			paths.push(tianchuang);
			
			//围壁_前左
			var weibi_frontleft:BuildingVO = new BuildingVO();
			weibi_frontleft.buildingX = 0;
			weibi_frontleft.buildingY = 76;
			weibi_frontleft.buildingName = "weibi_frontleft";
			weibi_frontleft.buildingPath = "assets/mgb/weibi_frontleft.png";
			paths.push(weibi_frontleft);
			//围壁_前右
			var weibi_frontright:BuildingVO = new BuildingVO();
			weibi_frontright.buildingX = 128;
			weibi_frontright.buildingY = 69;
			weibi_frontright.buildingName = "weibi_frontright";
			weibi_frontright.buildingPath = "assets/mgb/weibi_frontright.png";
			paths.push(weibi_frontright);
			//门
			var men:BuildingVO = new BuildingVO();
			men.buildingX = 82;
			men.buildingY = 91;
			men.buildingName = "men";
			men.buildingPath = "assets/mgb/men.png";
			paths.push(men);
			//顶杆
			var dinggan:BuildingVO = new BuildingVO();
			dinggan.buildingX = 7;
			dinggan.buildingY = 12;
			dinggan.buildingName = "dinggan";
			dinggan.buildingPath = "assets/mgb/dinggan.png";
			paths.push(dinggan);
			//围毡
			var weizhan:BuildingVO = new BuildingVO();
			weizhan.buildingX = 1;
			weizhan.buildingY = 69;
			weizhan.buildingName = "weizhan";
			weizhan.buildingPath = "assets/mgb/weizhan.png";
			paths.push(weizhan);
			//顶毡
			var dingzhan:BuildingVO = new BuildingVO();
			dingzhan.buildingX = 4;
			dingzhan.buildingY = 16;
			dingzhan.buildingName = "dingzhan";
			dingzhan.buildingPath = "assets/mgb/dingzhan.png";
			paths.push(dingzhan);
			//盖毡
			var gaizhan:BuildingVO = new BuildingVO();
			gaizhan.buildingX = 8;
			gaizhan.buildingY = 17;
			gaizhan.buildingName = "gaizhan";
			gaizhan.buildingPath = "assets/mgb/gaizhan.png";
			paths.push(gaizhan);
			//门毡
			var menzhan:BuildingVO = new BuildingVO();
			menzhan.buildingX = 86;
			menzhan.buildingY = 91;
			menzhan.buildingName = "menzhan";
			menzhan.buildingPath = "assets/mgb/menzhan.png";
			paths.push(menzhan);
			
			return paths;
		}
		
		/**
		 * 第一关所用到的全部道具，具体用在哪个子场景<br/>
		 * 在各自场景中实现get itemsToPickup()方法<br/>
		 * <br/>
		 * 总共道具统计：11个顶杆、4个毡子、4个围壁、2个柱子、2半截天窗、1个门
		 * 
		 */		
		public function getFirstScenaryItems():Array{
			var items:Array = [];
			
			//---------- 主场景散落的道具 5个------------------------
			var dinggan_10:ItemVO = new ItemVO();
			dinggan_10.itemX = 430;
			dinggan_10.itemY = 270;			
			dinggan_10.index = 0;
			dinggan_10.itemName = "dinggan_10";
			dinggan_10.bgImagePath = "assets/firstitems/dinggan_s_10.png";
			dinggan_10.inToolbarPath = "assets/firstitems/dinggan_s_10.png";
			dinggan_10.groupItemNum = 11;
			items.push(dinggan_10);
			
			
			var dinggan_11:ItemVO = new ItemVO();
			dinggan_11.itemX = 198;
			dinggan_11.itemY = 227;			
			dinggan_11.index = 0;
			dinggan_11.itemName = "dinggan_11";
			dinggan_11.bgImagePath = "assets/firstitems/dinggan_s_11.png";
			dinggan_11.inToolbarPath = "assets/firstitems/dinggan_s_11.png";
			dinggan_11.groupItemNum = 11;
			items.push(dinggan_11);
			
			
			var weibi_1:ItemVO = new ItemVO();
			weibi_1.itemX = 44;
			weibi_1.itemY = 305;			
			weibi_1.index = 0;
			weibi_1.itemName = "weibi_frontright";
			weibi_1.bgImagePath = "assets/firstitems/weibi_s_1.png";
			weibi_1.inToolbarPath = "assets/firstitems/weibi_s_1.png";
			weibi_1.groupItemNum = 4;
			items.push(weibi_1);
			
			
			var zhanzi_1:ItemVO = new ItemVO();
			zhanzi_1.itemX = 607;
			zhanzi_1.itemY = 329;
			zhanzi_1.index = 0;
			zhanzi_1.itemName = "menzhan";
			zhanzi_1.bgImagePath = "assets/firstitems/zhanzi_s_1.png";
			zhanzi_1.inToolbarPath = "assets/firstitems/zhanzi_s_1.png";
			items.push(zhanzi_1);
			
			
			var zhanzi_2:ItemVO = new ItemVO();
			zhanzi_2.itemX = 53;
			zhanzi_2.itemY = 402;			
			zhanzi_2.index = 0;
			zhanzi_2.itemName = "dingzhan";
			zhanzi_2.bgImagePath = "assets/firstitems/zhanzi_s_2.png";
			zhanzi_2.inToolbarPath = "assets/firstitems/zhanzi_s_2.png";			
			items.push(zhanzi_2);
			
			
			//---------- 敖包场景散落的道具 5个------------------------
			//TODO, 调位置
			var dinggan_8:ItemVO = new ItemVO();
			dinggan_8.itemX = 161;
			dinggan_8.itemY = 282;			
			dinggan_8.index = 0;
			dinggan_8.itemName = "dinggan_8";
			dinggan_8.bgImagePath = "assets/firstitems/dinggan_s_8.png";
			dinggan_8.inToolbarPath = "assets/firstitems/dinggan_s_8.png";
			dinggan_8.groupItemNum = 11;
			items.push(dinggan_8);
			
			var dinggan_9:ItemVO = new ItemVO();
			dinggan_9.itemX = 554;
			dinggan_9.itemY = 267;			
			dinggan_9.index = 0;
			dinggan_9.itemName = "dinggan_9";
			dinggan_9.bgImagePath = "assets/firstitems/dinggan_s_9.png";
			dinggan_9.inToolbarPath = "assets/firstitems/dinggan_s_9.png";
			dinggan_9.groupItemNum = 11;
			items.push(dinggan_9);
			
			var tianchuang_1:ItemVO = new ItemVO();
			tianchuang_1.itemX = 167;
			tianchuang_1.itemY = 504;			
			tianchuang_1.index = 0;
			tianchuang_1.itemName = "tianchuang_1";
			tianchuang_1.bgImagePath = "assets/firstitems/tianchuang_s_1.png";
			tianchuang_1.inToolbarPath = "assets/firstitems/tianchuang_s_1.png";
			tianchuang_1.groupItemNum = 2;
			items.push(tianchuang_1);
			
			var zhuzi_1:ItemVO = new ItemVO();
			zhuzi_1.itemX = 332;
			zhuzi_1.itemY = 577;			
			zhuzi_1.index = 0;
			zhuzi_1.itemName = "zhuzi_right";
			zhuzi_1.bgImagePath = "assets/firstitems/zhuzi_s_1_bg.png";
			zhuzi_1.inToolbarPath = "assets/firstitems/zhuzi_s_1_bg.png";
			items.push(zhuzi_1);
			
			var weibi_2:ItemVO = new ItemVO();
			weibi_2.itemX = 557;
			weibi_2.itemY = 100;			
			weibi_2.index = 0;
			weibi_2.itemName = "weibi_backright";
			weibi_2.bgImagePath = "assets/firstitems/weibi_s_2_bg.png";
			weibi_2.inToolbarPath = "assets/firstitems/weibi_s_2_bg.png";
			items.push(weibi_2);
			
			
			//-------- 河流子场景道具 8个----------------
			//TODO, 调位置
			var dinggan_1:ItemVO = new ItemVO();
			dinggan_1.itemX = 485;
			dinggan_1.itemY = 201;			
			dinggan_1.index = 0;
			dinggan_1.itemName = "dinggan_1";
			dinggan_1.bgImagePath = "assets/firstitems/dinggan_s_1.png";
			dinggan_1.inToolbarPath = "assets/firstitems/dinggan_s_1.png";
			dinggan_1.groupItemNum = 11;
			items.push(dinggan_1);
			
			var dinggan_2:ItemVO = new ItemVO();
			dinggan_2.itemX = 491;
			dinggan_2.itemY = 201;			
			dinggan_2.index = 0;
			dinggan_2.itemName = "dinggan_2";
			dinggan_2.bgImagePath = "assets/firstitems/dinggan_s_2.png";
			dinggan_2.inToolbarPath = "assets/firstitems/dinggan_s_2.png";
			dinggan_2.groupItemNum = 11;
			items.push(dinggan_2);
			
			var dinggan_3:ItemVO = new ItemVO();
			dinggan_3.itemX = 553;
			dinggan_3.itemY = 208;			
			dinggan_3.index = 0;
			dinggan_3.itemName = "dinggan_3";
			dinggan_3.bgImagePath = "assets/firstitems/dinggan_s_3.png";
			dinggan_3.inToolbarPath = "assets/firstitems/dinggan_s_3.png";
			dinggan_3.groupItemNum = 11;
			items.push(dinggan_3);
			
			var weibi_3:ItemVO = new ItemVO();
			weibi_3.itemX = 693;
			weibi_3.itemY = 234;			
			weibi_3.index = 0;
			weibi_3.itemName = "weibi_backleft";
			weibi_3.bgImagePath = "assets/firstitems/weibi_s_3.png";
			weibi_3.inToolbarPath = "assets/firstitems/weibi_s_3.png";
			items.push(weibi_3);
			
			var weibi_4:ItemVO = new ItemVO();
			weibi_4.itemX = 693;
			weibi_4.itemY = 240;			
			weibi_4.index = 0;
			weibi_4.itemName = "weibi_frontleft";
			weibi_4.bgImagePath = "assets/firstitems/weibi_s_4.png";
			weibi_4.inToolbarPath = "assets/firstitems/weibi_s_4.png";
			items.push(weibi_4);
			
			var zhanzi_3:ItemVO = new ItemVO();
			zhanzi_3.itemX = 683;
			zhanzi_3.itemY = 383;			
			zhanzi_3.index = 0;
			zhanzi_3.itemName = "gaizhan";
			zhanzi_3.bgImagePath = "assets/firstitems/zhanzi_s_3.png";
			zhanzi_3.inToolbarPath = "assets/firstitems/zhanzi_s_3.png";
			items.push(zhanzi_3);
			
			var men:ItemVO = new ItemVO();
			men.itemX = 443;
			men.itemY = 513;			
			men.index = 0;
			men.itemName = "men";
			men.bgImagePath = "assets/firstitems/men_s_bg.png";
			men.inToolbarPath = "assets/firstitems/men_s_bg.png";
			items.push(men);
			
			var zhuzi_2:ItemVO = new ItemVO();
			zhuzi_2.itemX = 54;
			zhuzi_2.itemY = 257;			
			zhuzi_2.index = 0;
			zhuzi_2.itemName = "zhuzi_left";
			zhuzi_2.bgImagePath = "assets/firstitems/zhuzi_s_2.png";
			zhuzi_2.inToolbarPath = "assets/firstitems/zhuzi_s_2.png";
			items.push(zhuzi_2);
			
			//----------- 帐篷子场景道具 6个-----------------
			//TODO, 调位置
			var dinggan_4:ItemVO = new ItemVO();
			dinggan_4.itemX = 322;
			dinggan_4.itemY = 134;			
			dinggan_4.index = 0;
			dinggan_4.itemName = "dinggan_4";
			dinggan_4.bgImagePath = "assets/firstitems/dinggan_s_4.png";
			dinggan_4.inToolbarPath = "assets/firstitems/dinggan_s_4.png";
			dinggan_4.groupItemNum = 11;
			items.push(dinggan_4);
			
			var dinggan_5:ItemVO = new ItemVO();
			dinggan_5.itemX = 308;
			dinggan_5.itemY = 135;			
			dinggan_5.index = 0;
			dinggan_5.itemName = "dinggan_5";
			dinggan_5.bgImagePath = "assets/firstitems/dinggan_s_5.png";
			dinggan_5.inToolbarPath = "assets/firstitems/dinggan_s_5.png";
			dinggan_5.groupItemNum = 11;
			items.push(dinggan_5);
			
			var dinggan_6:ItemVO = new ItemVO();
			dinggan_6.itemX = 298;
			dinggan_6.itemY = 137;			
			dinggan_6.index = 0;
			dinggan_6.itemName = "dinggan_6";
			dinggan_6.bgImagePath = "assets/firstitems/dinggan_s_6.png";
			dinggan_6.inToolbarPath = "assets/firstitems/dinggan_s_6.png";
			dinggan_6.groupItemNum = 11;
			items.push(dinggan_6);
			
			var dinggan_7:ItemVO = new ItemVO();
			dinggan_7.itemX = 285;
			dinggan_7.itemY = 176;			
			dinggan_7.index = 0;
			dinggan_7.itemName = "dinggan_7";
			dinggan_7.bgImagePath = "assets/firstitems/dinggan_s_7.png";
			dinggan_7.inToolbarPath = "assets/firstitems/dinggan_s_7.png";
			dinggan_7.groupItemNum = 11;
			items.push(dinggan_7);
			
			var tianchuang_2:ItemVO = new ItemVO();
			tianchuang_2.itemX = 251;
			tianchuang_2.itemY = 327;			
			tianchuang_2.index = 0;
			tianchuang_2.itemName = "tianchuang_2";
			tianchuang_2.bgImagePath = "assets/firstitems/tianchuang_s_2_bg.png";
			tianchuang_2.inToolbarPath = "assets/firstitems/tianchuang_s_2_bg.png";
			tianchuang_2.groupItemNum = 2;
			items.push(tianchuang_2);
			
			var zhanzi_4:ItemVO = new ItemVO();
			zhanzi_4.itemX = 559;
			zhanzi_4.itemY = 299;			
			zhanzi_4.index = 0;
			zhanzi_4.itemName = "weizhan";
			zhanzi_4.bgImagePath = "assets/firstitems/zhanzi_s_4_bg.png";
			zhanzi_4.inToolbarPath = "assets/firstitems/zhanzi_s_4_bg.png";
			items.push(zhanzi_4);
			
			return items;
		}
		
		//剩余关用到的道具...
		
		
	} //end of class
}