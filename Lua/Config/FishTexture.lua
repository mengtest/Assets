
local FishTexture = {
	[1] = {ID=1, Rate="2", Name="小黄鱼", Desc="轻小可爱调皮胆小喜结群", width=140, height=74, type="G", winning="0", Cassify="0"},
	[2] = {ID=2, Rate="3", Name="小海龟", Desc="缩头缩脑胆小怕事", width=120, height=107, type="H", winning="0", Cassify="0"},
	[3] = {ID=3, Rate="5", Name="水母", Desc="美丽漂亮一幅羞羞答答的样子", width=104, height=94, type="B", winning="0", Cassify="0"},
	[4] = {ID=4, Rate="7", Name="小丑鱼", Desc="可爱活泼爱四处串游", width=101, height=88, type="C", winning="0", Cassify="0"},
	[5] = {ID=5, Rate="8", Name="比目鱼", Desc="低调喜欢浮居地面", width=127, height=61, type="I", winning="0", Cassify="0"},
	[6] = {ID=6, Rate="10", Name="河豚", Desc="调皮可爱喜欢捣蛋", width=104, height=91, type="D", winning="0", Cassify="0"},
	[7] = {ID=7, Rate="15", Name="鸭嘴冰鱼", Desc="嚣张跋扈暴脾气", width=137, height=87, type="J", winning="0", Cassify="0"},
	[8] = {ID=8, Rate="20", Name="灯笼鱼", Desc="充满斗志满腔热血", width=105, height=108, type="E", winning="0", Cassify="0"},
	[9] = {ID=9, Rate="30", Name="海龟", Desc="慢条斯理成熟稳重", width=113, height=88, type="A", winning="0", Cassify="0"},
	[10] = {ID=10, Rate="40", Name="电鳗", Desc="警惕性高易放电", width=136, height=76, type="0", winning="1", Cassify="1"},
	[11] = {ID=11, Rate="40", Name="魔鬼鱼", Desc="长者般炯炯有神", width=125, height=59, type="0", winning="0", Cassify="0"},
	[12] = {ID=12, Rate="55", Name="剑鱼", Desc="攻击力强隐藏强大的实力", width=181, height=86, type="0", winning="0", Cassify="0"},
	[13] = {ID=13, Rate="100", Name="鲨鱼", Desc="强大傲慢目中无人", width=150, height=150, type="0", winning="1", Cassify="0"},
	[14] = {ID=14, Rate="40~80", Name="黄金鸭嘴冰鱼", Desc="经时间洗礼的鸭嘴冰鱼金光闪闪", width=171, height=104, type="0", winning="1", Cassify="1"},
	[15] = {ID=15, Rate="75~150", Name="黄金灯笼鱼", Desc="经时间洗礼的灯笼鱼金光闪闪", width=101, height=97, type="0", winning="1", Cassify="1"},
	[16] = {ID=16, Rate="85~170", Name="黄金电鳗", Desc="经时间洗礼的电鳗鱼金光闪闪", width=149, height=84, type="0", winning="1", Cassify="1"},
	[17] = {ID=17, Rate="90~180", Name="黄金魔鬼鱼", Desc="经时间洗礼的魔鬼鱼金光闪闪", width=150, height=77, type="0", winning="1", Cassify="1"},
	[18] = {ID=18, Rate="100~200", Name="金鲨", Desc="威武强大闪闪发光", width=157, height=82, type="0", winning="2", Cassify="1"},
	[19] = {ID=19, Rate="300", Name="海怪", Desc="凶残强大彪悍凶猛", width=142, height=97, type="0", winning="2", Cassify="0"},
	[20] = {ID=20, Rate="30", Name="海龟王", Desc="受同类拥戴成为海龟王", width=122, height=110, type="A", winning="1", Cassify="2"},
	[21] = {ID=21, Rate="5", Name="水母鱼王", Desc="受同类拥戴成为水母鱼王", width=106, height=127, type="B", winning="1", Cassify="2"},
	[22] = {ID=22, Rate="7", Name="小丑鱼王", Desc="受同类拥戴成为小丑鱼王", width=115, height=103, type="C", winning="1", Cassify="2"},
	[23] = {ID=23, Rate="10", Name="河豚王", Desc="受同类拥戴成为河豚鱼王", width=103, height=110, type="D", winning="1", Cassify="2"},
	[24] = {ID=24, Rate="20", Name="灯笼鱼王", Desc="受同类拥戴成为灯笼鱼王", width=105, height=105, type="E", winning="1", Cassify="2"},
	[25] = {ID=25, Rate="125~250", Name="彩鲨", Desc="个性张扬散发五彩的光", width=154, height=94, type="F", winning="2", Cassify="1"},
	[26] = {ID=26, Rate="1", Name="小黄鱼王", Desc="受同类拥戴成为小黄鱼王", width=146, height=89, type="G", winning="1", Cassify="2"},
	[27] = {ID=27, Rate="3", Name="小海龟王", Desc="受同类拥戴成为小海龟王", width=120, height=114, type="H", winning="1", Cassify="2"},
	[28] = {ID=28, Rate="8", Name="比目鱼王", Desc="受同类拥戴成为比目鱼王", width=139, height=68, type="I", winning="1", Cassify="2"},
	[29] = {ID=29, Rate="15", Name="鸭嘴冰鱼王", Desc="受同类拥戴成为鸭嘴冰鱼王", width=136, height=93, type="J", winning="1", Cassify="2"},
	[30] = {ID=30, Rate="66", Name="河豚boss", Desc="双重技能，随时放大招", width=103, height=114, type="0", winning="2", Cassify="1"},
	[31] = {ID=31, Rate="88", Name="电鳗boss", Desc="暴戾的眼神充能能量", width=146, height=71, type="0", winning="2", Cassify="1"},
	[32] = {ID=32, Rate="99", Name="螃蟹boss", Desc="散发着一股彪悍的气息", width=125, height=84, type="0", winning="2", Cassify="1"},
	[33] = {ID=33, Rate="88", Name="剑鱼boss", Desc="尖锐的武器不容小视", width=188, height=87, type="0", winning="2", Cassify="1"},
	[34] = {ID=34, Rate="66", Name="水母boss", Desc="美与毒永远的相伴", width=99, height=109, type="0", winning="2", Cassify="1"},
	[35] = {ID=35, Rate="4", Name="鳉鱼", Desc="带着一份慵懒的表情", width=130, height=65, type="K", winning="0", Cassify="0"},
	[36] = {ID=36, Rate="6", Name="盖普提鱼", Desc="小身体里散发着大激情", width=133, height=63, type="L", winning="0", Cassify="0"},
	[37] = {ID=37, Rate="9", Name="金枪鱼", Desc="极速的游动闪躲攻击", width=129, height=89, type="M", winning="0", Cassify="0"},
	[38] = {ID=38, Rate="150~300", Name="美人鱼", Desc="公主般优雅的舞动着", width=108, height=184, type="0", winning="2", Cassify="1"},
	[39] = {ID=39, Rate="4", Name="鳉鱼王", Desc="受同类拥戴成为鳉鱼王", width=137, height=93, type="K", winning="1", Cassify="2"},
	[40] = {ID=40, Rate="6", Name="盖普提鱼王", Desc="受同类拥戴成为盖普提鱼王", width=130, height=86, type="L", winning="1", Cassify="2"},
	[41] = {ID=41, Rate="9", Name="金枪鱼王", Desc="受同类拥戴成为金枪鱼王", width=125, height=94, type="M", winning="1", Cassify="2"},
	[42] = {ID=42, Rate="30~60", Name="黄金枪鱼", Desc="经时间洗礼的金枪鱼金光闪闪", width=127, height=91, type="0", winning="1", Cassify="1"},
	[43] = {ID=43, Rate="50", Name="寒冰鱼", Desc="活泼的外表冰冷的身体", width=153, height=75, type="0", winning="2", Cassify="1"},
	[44] = {ID=44, Rate="25", Name="帝鲇鱼", Desc="平静的看待事情", width=118, height=116, type="N", winning="0", Cassify="0"},
	[45] = {ID=45, Rate="25", Name="帝鲇鱼王", Desc="受同类拥戴成为帝鲇鱼王", width=115, height=129, type="N", winning="1", Cassify="2"},
	[46] = {ID=46, Rate="35", Name="狮子鱼", Desc="老大般张扬拍动着翅膀", width=148, height=100, type="0", winning="0", Cassify="0"},
	[47] = {ID=47, Rate="200", Name="鲸鱼", Desc="温顺的外表内隐藏强大实力", width=154, height=73, type="0", winning="2", Cassify="0"},
	[48] = {ID=48, Rate="10", Name="燕尾鱼", Desc="小身体爆发力十足", width=123, height=79, type="0", winning="2", Cassify="1"},
	[49] = {ID=49, Rate="10", Name="炸弹", Desc="威力四射，片甲不留", width=87, height=125, type="0", winning="2", Cassify="1"},
	
}

return FishTexture