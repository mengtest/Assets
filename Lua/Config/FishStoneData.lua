
local FishStoneData = {
	[2035] = {ID=2035, No=1, Name="小黄鱼碎片", CombName="小黄鱼", Type=1, Lv=0, SpriteName="小黄鱼", CombNum=5, RecyclePrice=5, Gain="倍率游戏场", Special="可兑换精灵小巧调皮可爱的小黄鱼", UseTime="0", SpriteScale=1},
	[2036] = {ID=2036, No=2, Name="小海龟碎片", CombName="小海龟", Type=1, Lv=0, SpriteName="小海龟", CombNum=5, RecyclePrice=25, Gain="倍率游戏场", Special="可兑换寿命最长其中之一的小海龟", UseTime="0", SpriteScale=1},
	[2037] = {ID=2037, No=3, Name="小水母碎片", CombName="小水母", Type=1, Lv=0, SpriteName="水母", CombNum=5, RecyclePrice=50, Gain="倍率游戏场", Special="可兑换晶莹剔透小公主般的水母", UseTime="0", SpriteScale=0.75},
	[2038] = {ID=2038, No=4, Name="小丑鱼碎片", CombName="小丑鱼", Type=1, Lv=0, SpriteName="小丑鱼", CombNum=5, RecyclePrice=100, Gain="倍率游戏场", Special="可兑换活泼爱四处串游的小丑鱼", UseTime="0", SpriteScale=1},
	[2039] = {ID=2039, No=5, Name="比目鱼碎片", CombName="比目鱼", Type=1, Lv=0, SpriteName="比目鱼", CombNum=5, RecyclePrice=170, Gain="倍率游戏场", Special="可兑换如湖水般莹蓝安静的比目鱼", UseTime="0", SpriteScale=0.95},
	[2040] = {ID=2040, No=6, Name="河豚碎片", CombName="河豚", Type=1, Lv=1, SpriteName="河豚", CombNum=10, RecyclePrice=300, Gain="倍率游戏场", Special="可兑换调皮捣蛋表情丰富的河豚", UseTime="0", SpriteScale=0.9},
	[2041] = {ID=2041, No=7, Name="鸭嘴冰鱼碎片", CombName="鸭嘴冰鱼", Type=1, Lv=1, SpriteName="鸭嘴冰鱼", CombNum=10, RecyclePrice=500, Gain="倍率游戏场", Special="可兑换能散发冰雪奇缘般美景的鸭嘴冰鱼", UseTime="0", SpriteScale=0.8},
	[2042] = {ID=2042, No=8, Name="灯笼鱼碎片", CombName="灯笼鱼", Type=1, Lv=1, SpriteName="灯笼鱼", CombNum=10, RecyclePrice=1000, Gain="倍率游戏场", Special="可兑换外观独特霸气的灯笼鱼", UseTime="0", SpriteScale=0.9},
	[2043] = {ID=2043, No=9, Name="海龟碎片", CombName="海龟", Type=1, Lv=2, SpriteName="海龟", CombNum=20, RecyclePrice=1000, Gain="倍率游戏场", Special="可兑换大海龟", UseTime="0", SpriteScale=0.9},
	[2044] = {ID=2044, No=10, Name="电鳗碎片", CombName="电鳗", Type=1, Lv=2, SpriteName="电鳗", CombNum=20, RecyclePrice=1000, Gain="倍率游戏场", Special="可兑换神奇的电鳗", UseTime="0", SpriteScale=0.9},
	[2045] = {ID=2045, No=11, Name="魔鬼鱼碎片", CombName="魔鬼鱼", Type=1, Lv=2, SpriteName="魔鬼鱼", CombNum=20, RecyclePrice=1000, Gain="倍率游戏场", Special="可兑换魔鬼鱼", UseTime="0", SpriteScale=0.9},
	[2046] = {ID=2046, No=12, Name="剑鱼碎片", CombName="剑鱼", Type=1, Lv=2, SpriteName="剑鱼", CombNum=20, RecyclePrice=1000, Gain="倍率游戏场", Special="可兑换霸气剑鱼", UseTime="0", SpriteScale=0.9},
	[2047] = {ID=2047, No=13, Name="鲨鱼碎片", CombName="鲨鱼", Type=1, Lv=2, SpriteName="鲨鱼", CombNum=20, RecyclePrice=1000, Gain="倍率游戏场", Special="可兑换值钱的大鲨鱼", UseTime="0", SpriteScale=0.9},
	[2019] = {ID=2019, No=2, Name="风暴双雄碎片", CombName="风暴双雄", Type=2, Lv=0, SpriteName="风暴双雄", CombNum=20, RecyclePrice=2, Gain="倍率游戏场", Special="可兑换双重攻击的风暴双雄炮", UseTime="1天", SpriteScale=1},
	[2020] = {ID=2020, No=3, Name="霹雳旋风碎片", CombName="霹雳旋风", Type=2, Lv=0, SpriteName="霹雳旋风", CombNum=20, RecyclePrice=2, Gain="倍率游戏场", Special="可兑换旋飞鱼网具有回旋功能的霹雳旋风炮", UseTime="1天", SpriteScale=1},
	[2021] = {ID=2021, No=4, Name="一飞冲天碎片", CombName="一飞冲天", Type=2, Lv=0, SpriteName="一飞冲天", CombNum=20, RecyclePrice=2, Gain="倍率游戏场", Special="可兑换火箭式极速射击的一飞冲天炮", UseTime="1天", SpriteScale=1},
	[2022] = {ID=2022, No=5, Name="寒冰碎片碎片", CombName="寒冰碎片", Type=2, Lv=0, SpriteName="寒冰碎片", CombNum=20, RecyclePrice=2, Gain="倍率游戏场", Special="可兑换独特的寒冰威力具备减速更能的寒冰碎片炮", UseTime="1天", SpriteScale=1},
	[2023] = {ID=2023, No=6, Name="火焰风暴碎片", CombName="火焰风暴", Type=2, Lv=0, SpriteName="火焰风暴", CombNum=20, RecyclePrice=3, Gain="倍率游戏场", Special="可兑换在海中喷出大范围的火焰的火焰风暴炮", UseTime="2小时", SpriteScale=1},
	[2024] = {ID=2024, No=7, Name="幻象法球碎片", CombName="幻象法球", Type=2, Lv=0, SpriteName="幻象法球", CombNum=20, RecyclePrice=3, Gain="倍率游戏场", Special="可兑换具备魔法能量大范围攻击的幻象法球炮", UseTime="2小时", SpriteScale=1},
	[2025] = {ID=2025, No=8, Name="幽冥剧毒碎片", CombName="幽冥剧毒", Type=2, Lv=0, SpriteName="幽冥剧毒", CombNum=20, RecyclePrice=3, Gain="倍率游戏场", Special="可兑换能放射出毒气大范围眩晕毒击的幽冥剧毒炮", UseTime="2小时", SpriteScale=1},
	[2026] = {ID=2026, No=9, Name="苍穹轰击碎片", CombName="苍穹轰击", Type=2, Lv=0, SpriteName="苍穹轰击", CombNum=20, RecyclePrice=3, Gain="倍率游戏场", Special="可兑换激光般闪亮独特的苍穹轰击炮", UseTime="1小时", SpriteScale=0.85},
	[2027] = {ID=2027, No=10, Name="闪电之链碎片", CombName="闪电之链", Type=2, Lv=0, SpriteName="闪电之链", CombNum=20, RecyclePrice=3, Gain="倍率游戏场", Special="可兑换能发射闪电反射穿梭在鱼群中的闪电之链炮", UseTime="1小时", SpriteScale=0.85},
	[2028] = {ID=2028, No=11, Name="1元话费碎片", CombName="1元话费兑换卡", Type=3, Lv=0, SpriteName="1yuan", CombNum=10, RecyclePrice=5, Gain="倍率游戏场", Special="集满一定数量可兑换1元话费兑换卡", UseTime="0", SpriteScale=1},
	[2029] = {ID=2029, No=12, Name="5元话费碎片", CombName="5元话费兑换卡", Type=3, Lv=0, SpriteName="5yuan", CombNum=5, RecyclePrice=5, Gain="倍率游戏场", Special="集满一定数量可兑换5元话费兑换卡", UseTime="0", SpriteScale=1},
	[2030] = {ID=2030, No=13, Name="10元话费碎片", CombName="10元话费兑换卡", Type=3, Lv=0, SpriteName="10yuan", CombNum=10, RecyclePrice=5, Gain="倍率游戏场", Special="集满一定数量可兑换10元话费兑换卡", UseTime="0", SpriteScale=1},
	[2031] = {ID=2031, No=14, Name="金闪光石碎片", CombName="元宝", Type=3, Lv=0, SpriteName="yuan_bao", CombNum=20, RecyclePrice=2, Gain="倍率游戏场", Special="集满规定的数量可兑换1元宝", UseTime="0", SpriteScale=1},
	[2032] = {ID=2032, No=15, Name="银闪光石碎片", CombName="金币", Type=3, Lv=0, SpriteName="jin_bi", CombNum=20, RecyclePrice=2, Gain="倍率游戏场", Special="集满规定的数量可兑换1000金币", UseTime="0", SpriteScale=1},
	[2034] = {ID=2034, No=16, Name="藏宝图碎片", CombName="初级藏宝图", Type=3, Lv=0, SpriteName="藏宝图", CombNum=20, RecyclePrice=1, Gain="倍率游戏场", Special="集满一定的数量可兑换初级的宝藏", UseTime="0", SpriteScale=1},
	[2034] = {ID=2034, No=17, Name="藏宝图碎片", CombName="中级藏宝图", Type=3, Lv=0, SpriteName="藏宝图", CombNum=50, RecyclePrice=1, Gain="倍率游戏场", Special="集满一定的数量可兑换中级的宝藏", UseTime="0", SpriteScale=1},
	[2034] = {ID=2034, No=18, Name="藏宝图碎片", CombName="高级藏宝图", Type=3, Lv=0, SpriteName="藏宝图", CombNum=80, RecyclePrice=1, Gain="倍率游戏场", Special="集满一定的数量可兑换高级的宝藏", UseTime="0", SpriteScale=1},
	
}

return FishStoneData