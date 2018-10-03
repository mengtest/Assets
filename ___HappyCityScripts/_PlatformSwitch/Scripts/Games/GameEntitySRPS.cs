﻿using UnityEngine;
using System.Collections;

public class GameEntitySRPS : GameEntity {
	
	// 
	public GameEntitySRPS () {
		versionCode = 41;
		versionName = "V3.1.1";
        gameName = "sr5m";
		gameID = "1065";
		gameTypeIDs = "1";
        gameScene = "GameSRPS";
		gameIconType = GameType.Poker;
		gameDeskType = DeskType.DeskType_All;
		gameGuideScene = "GuideDialog";
		gameGuideContent = "    四人拚十主要流行在湖南、广东、广西地区，它是一款地方性、游戏速度极快、刺激的棋牌游戏。游戏可以由2人到6人同时进行，总共52张牌（除大小王），不分庄闲，系统发给玩家每人5张牌，用户将根据5张牌进行排列组合，牌型大的一方获胜。通比牛牛使用固定注（即大家押注金额相同），没有下注，公平公正，游戏节奏快，深得广大玩家的喜爱。";
	}
}
