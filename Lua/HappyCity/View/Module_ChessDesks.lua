
local cjson = require "cjson"
local this = LuaObject:New()
Module_ChessDesks = this


DeskSeatInfo = LuaObject:New()
DeskSeatInfo.deskId = "0";
DeskSeatInfo.seatId = -1;
function DeskSeatInfo:New()
	local o ={};    --初始化self，如果没有这句，那么类所建立的对象改变，其他对象都会改变
	setmetatable(o, self);  --将self的元表设定为Class
	self.__index = self 
	return o;    --返回自身
end

function this:Init()
	this.m_ReconnectCount = 0;
	this.mGameType =  GameType.Poker;
	this.mDeskType = DeskType.DeskType_2;
	this.mCurrentPage = 0;
	this.m_LabBetMoney = this.transform:FindChild("UIPanel (Window)/Lab_Bet").gameObject:GetComponent("UILabel");
	this.Desks = this.transform:FindChild("UIPanel (Window)/UIGrid");
	this.m_BtnSetting = this.transform:FindChild("UIPanel (Window)/UIGrid/Cell_1/Button").gameObject;
	this.mDeskCell ={}
	for i=1,6 do 
		local tCellObj = this.transform:FindChild('UIPanel (Window)/UIGrid/Cell_'..i).gameObject
		local tCell = {}
		tCell.Num  = i
		tCell.RoomID =tCellObj.transform:FindChild('Lab_ID').gameObject:GetComponent('UILabel') 
		tCell.RoomMoney= tCellObj.transform:FindChild('LabelMoney').gameObject:GetComponent('UILabel')
		tCell.RoomLock = tCellObj.transform:FindChild('Lock').gameObject:GetComponent('UISprite')
		tCell.RoomState= tCellObj.transform:FindChild('State').gameObject:GetComponent('UISprite')
		tCell.EnterBtn = tCellObj.transform:FindChild('Button').gameObject:GetComponent('UISprite')
		table.insert(this.mDeskCell,tCell)
	end
	this.MyRoomCell = this.mDeskCell[1]


	this._DeskSeat = {};
	this.passwordError = false;
end

function this:handleBtnsFunc()
	local imageButton = this.transform:FindChild("Background Top - Anchor/Button_Back - Anchor/BtnBack").gameObject
	this.mono:AddClick(imageButton, this.OnClickBack,this)
	this.mono:AddClick(this.kQuickPlayButton, this.OnQuickPlayButtonClick,this )
end

function this:Awake()
	
	
	this:Init();
	this:handleBtnsFunc()
	--lxtd004 牌桌 排布 适配 
	local sceneRoot = find('GUI'):GetComponent("UIRoot")
    if sceneRoot then 
        sceneRoot.fitWidth = true 
        sceneRoot.fitHeight = false 
        sceneRoot.manualHeight = 1080;
		sceneRoot.manualWidth = 1920;
        -- sceneRoot.Broadcast("UpdateAnchors")
	    -- this.mono:ResetScreenResize()  
    end
end
-- Use this for initialization
function this:Start () 
	this.mGameType = Util.ObjToInt(PlatformGameDefine.game.GameIconType);
	this.mDeskType = Util.ObjToInt(PlatformGameDefine.game.GameDeskType);
	coroutine.start(this.DoSocketConnect,this);
	LobbyMsgReceiver:startSocket();

	this:GetInitData()
end

function this:clearLuaValue()
	this.mono = nil
	this.gameObject = nil
	this.transform  = nil

	this.m_ReconnectCount = 0;
	this.mGameType = GameType.Poker;
	this.mDeskType = DeskType.DeskType_3;

	this.vDesks = nil;
	this.kQuickPlayButton = nil;  
	this.passwordError = false;
	LuaGC()
end

function this:OnDestroy()
	this:clearLuaValue()
	EginProgressHUD.Instance:HideHUD();
end 

function this:GetInitData()

	 local tStartJson = {}
   tStartJson['type'] = 'xq'
   tStartJson['tag'] = 'ulist'
   tStartJson['body'] =1
   this.mono:SendPackage(cjson.encode(tStartJson))
  
end

function this:GetDeskSeat(tbName)
	
	local temp = this._DeskSeat[tbName]
	if temp == nil then
		-- this._DeskSeat[tbName] = DeskSeatInfo:New(tbObj);
		temp = this._DeskSeat[tbName]
	end
	return temp
end
function this:ReplaceNameDeskSeat(oldName,newName) 
	if oldName ~= newName then
		local temp = this._DeskSeat[oldName]
		if temp ~= nil then
			this._DeskSeat[newName] = temp
			this._DeskSeat[oldName] = nil
		end
	end
end
function this:RemoveDeskSeat(tbName) 
	this._DeskSeat[tbName] = nil;
end 
function this:OnClickBack () 
	SocketManager.Instance.socketListener = nil;
	SocketManager.Instance:Disconnect("Exit from the table.");
	if this.mono ~= nil  then 
		this.mono:EginLoadLevel("Hall");
	end 
end

function this:OnQuickPlayButtonClick () 
	-- shawn.debug IsConnect
	this:DoSitDownClick("0", -1);
end
function this:OnSeatButtonClick (seat) 
	local seatInfo = this:GetDeskSeat(seat.name); 
	if(PlatformGameDefine.game.GameID == "1006" and PlatformGameDefine.game.GameTypeIDs == "20")then
		if(seat.transform:GetChild(0):GetComponent("UISprite").alpha == 1)then
			this:observerSitDownClick(seatInfo.deskId, seatInfo.seatId);
		else
			this:DoSitDownClick(seatInfo.deskId, seatInfo.seatId);
		end
	else
		this:DoSitDownClick(seatInfo.deskId, seatInfo.seatId);
	end
end
function this:DoSitDownClick (deskId,  seatId) 
    EginProgressHUD.Instance:ShowWaitHUD("正在进入游戏...",true);
	local messageObj = {type="seatmatch",tag= "sit",body= {deskId,seatId}} 
	SocketManager.Instance:SendPackage(cjson.encode(messageObj));
	
end

--lxtd003 add for 131 ddz live version observer feature
function this:observerSitDownClick (deskId,  seatId) 
	EginProgressHUD.Instance:ShowWaitHUD("正在进入游戏...",true);
	local messageObj = {type="seatmatch",tag= "view_sit",body= {deskId,seatId}} 
	SocketManager.Instance:SendPackage(cjson.encode(messageObj));
end
 
function this:SocketReceiveMessage(message)
	local message = self;
	local messageObj = cjson.decode(message);
	local typeL = messageObj["type"];
	local tag = messageObj["tag"]    
	
	if ("account" ==typeL) then
		if tag == "login_success"  then
			-- this:ProcessAccountSucess(messageObj);
		elseif ( string.find( tag,"login_failed_") ~= nil)  then
			local errorInfo = "";
			if ("login_failed_auth" ==tag)  then
				errorInfo = ZPLocalization.Instance:Get("Socket_login_failed_auth");
			elseif ("login_failed_inactive" ==tag)  then 
				errorInfo = ZPLocalization.Instance:Get("Socket_login_failed_inactive");
			elseif ("login_failed_otherroom" ==tag)   then
				errorInfo = ZPLocalization.Instance:Get("Socket_login_failed_otherroom");
			elseif ("login_failed_nomoney" ==tag)  then
				errorInfo = ZPLocalization.Instance:Get("Socket_login_failed_nomoney");
				errorInfo = errorInfo.."\n";
				errorInfo = errorInfo..ZPLocalization.Instance:Get("Socket_login_failed_nomoney_min");
				errorInfo = errorInfo..SocketConnectInfo.Instance.roomMinMoney;
			elseif ("login_failed_nousemoney" ==tag)  then
				errorInfo = ZPLocalization.Instance:Get("Socket_login_failed_nousemoney");
				errorInfo = errorInfo.."\n";
				errorInfo = errorInfo..ZPLocalization.Instance:Get("Socket_login_failed_nomoney_min");
				errorInfo = errorInfo..SocketConnectInfo.Instance.roomMinMoney;
			elseif ("login_failed_notexist" ==tag)   then
				errorInfo = ZPLocalization.Instance:Get("Socket_login_failed_notexist");
			elseif ("login_failed_guest" ==tag)   then
				errorInfo = ZPLocalization.Instance:Get("Socket_login_failed_guest"); 
			
			elseif ("login_failed_online" ==tag) then
				errorInfo = ZPLocalization.Instance:Get("Socket_login_failed_online");
			elseif ("login_failed_closed" ==tag)  then
				errorInfo = ZPLocalization.Instance:Get("Socket_login_failed_closed");
				if (messageObj["body"] ~= nil  and   string.len(tostring(messageObj["body"]))  > 0) then
					errorInfo = errorInfo..ZPLocalization.Instance:Get("Socket_login_failed_closed_reason");
					errorInfo = errorInfo..System.Text.RegularExpressions.Regex.Unescape( tostring(messageObj["body"]) );
				end
			else 
				errorInfo = ZPLocalization.Instance:Get("Socket_Unkonw");
			end
			this:ProcessAccountFailed(errorInfo);
		elseif ("login_from_somewhere" ==tag)   then
			this:ProcessAccountFailed(ZPLocalization.Instance:Get("Socket_login_from_somewhere"));
		elseif ("update_intomoney" ==tag)   then
			-- shawn.debug
		elseif("room_entry_failed_auth" == tag) then
			-- EginProgressHUD.Instance:ShowPromptHUD("房间密码错误");
			this.passwordError = true;
			this:ProcessAccountFailed("房间密码错误");
		else 
			this:ProcessAccountFailed(ZPLocalization.Instance:Get("Socket_Unkonw"));
		end
	elseif ("seatmatch" ==typeL)   then
		if ("seatlist" ==tag)   then
			-- this:ProcessSeatlist(messageObj);
		elseif ("on_sitdown" ==tag) then
			this:ProcessSitdown(messageObj);
		elseif ("on_situp" ==tag)   then
			this:ProcessSitup(messageObj);
		elseif ("on_begin" ==tag)   then
			this:ProcessGameBegin(messageObj);
		elseif ("on_end" ==tag)  then
			this:ProcessGameEnd(messageObj);
		elseif ("sit_fail" ==tag)  then
			this:ProcessSitFail(messageObj);
		elseif ("newober" ==tag)  then
			if(PlatformGameDefine.game.GameID == "1006" and PlatformGameDefine.game.GameTypeIDs == "20")then
				this.obTargetMsg = message;
			end
		end
	elseif ("game" ==typeL)  then
		if ("enter" ==tag)  then
			SocketManager.Instance.socketListener = nil;
			SocketManager.Instance:SocketMessageRollback(message);
			if(this.obTargetMsg ~= nil)then
				SocketManager.Instance:SocketMessageRollback(this.obTargetMsg);
			end
			PlatformGameDefine.game:StartGame();
		end
	elseif 'xq' then
		if tag == 'ulist' then
			this:InitSeatlist ( messageObj) 
		else
			print(messageObj)
		end

	end
end

function this.SocketDisconnect (disconnectInfo) 
	 
end
function this:DoSocketDisconnect ( promptTime) 
	coroutine.wait(promptTime);
	EginProgressHUD.Instance:HideHUD();
	this:OnClickBack();
end

function this.OnSocketDisconnect(disconnectInfo)

end
 
function this:ProcessAccountFailed (errorInfo) 
	SocketManager.Instance.socketListener = nil;
 
	EginProgressHUD.Instance:ShowPromptHUD(errorInfo);

	coroutine.start(this.DoSocketDisconnect,this ,(2));
end

-- function this:ProcessAccountSucess ( messageObj) 
-- 	Activity.is_award = false;
-- 	if messageObj["body"]["is_award"] ~= nil then
-- 		if messageObj["body"]["is_award"] == 1 then
-- 			--开启红包活动
-- 			log("============开启红包活动")
-- 			Activity.is_award = true; 
-- 		end
-- 	else
-- 		Activity.is_award = true; 
-- 	end
-- 	-- （百人类游戏  or  玩家为断开重进） 则直接进入游戏toBoolean
-- 	if (this.mDeskType == DeskType.DeskType_All  or  toBoolean(messageObj["body"]["re_enter"]))  then 
-- 		this:ProcessSitSucess();
-- 	end
-- end

function this:InitSeatlist ( pMsg) 
	print('In this function    ')
	printf(pMsg)
	local tMyInfo = messageObj["body"]["u"];
	local tMyID = tMyInfo[1]
	local tMyName = tMyInfo[2]
	local tMyState = tMyInfo[3]
	local tIsLock = tMyInfo[4]
	local tIsBet = tMyInfo[5]

	local tPageInfo  = messageObj["body"]["u"];
	local tPageUnitNum = tPageInfo[1]
	mCurrentPage = tPageInfo[2]
	local tTotalNum = tPageInfo[3]
	local tTotalPageNum = tPageInfo[4]

	local tOtherInfo = messageObj["body"]["m"];
	local tMinBet = tOtherInfo[1]
	local tMinGuideFee = tOtherInfo[2]
end


function this:ProcessSeatlist ( messageObj) 
	local tempDeskInfos = messageObj["body"]["desks"];

	table.sort(tempDeskInfos,function(a,b) return tonumber(a[1])<tonumber(b[1]) end )
	
	local deskPrefab = this:DeskPrefab();
	local desksGrid =  this.vDesks:GetComponent("UIGrid");
	local tDeskAnchor = this.vDesks:GetComponent('UIAnchor')
	this:ResetAnchor(tDeskAnchor)
	local padding = this:DeskPadding();
	desksGrid.cellWidth = padding.x;
	desksGrid.cellHeight = padding.y;
	desksGrid.maxPerLine = this:DeskRowCount();
		
	for   k, deskInfo in pairs(tempDeskInfos)    do
		if (type(deskInfo) == "nil") then  break; end
		
		local deskId = tostring( deskInfo[1]) ;
		local isPlaying = toBoolean(deskInfo[2]);
		local seatInfos = deskInfo[3];
		
		local desk =  GameObject.Instantiate(deskPrefab);
		desk.name = "Desk_"..deskId;
		desk.transform.parent = this.vDesks;
		desk.transform.localScale = Vector3.one;
		
		desk.transform:FindChild("ID/Label"):GetComponent("UILabel").text = deskId;
		this:UpdateDeskState(desk.transform, isPlaying,deskId);
		for j=0, #(seatInfos) do
			local deskSeat = desk.transform:Find("Seat_"..j); 
			if (deskSeat ~= nil) then
				deskSeat.name = desk.name.."_Seat_"..j;
				local seatInfo = this:GetDeskSeat(deskSeat.name);
				seatInfo.deskId = deskId;
				seatInfo.seatId = j;
				
				this.mono:AddClick(deskSeat.gameObject, this.OnSeatButtonClick,this)
				
				if (type(seatInfos[j+1])  == "table")  then
					this:DoSitdown(deskSeat,  tostring(seatInfos[j+1][1]) , j, tonumber(seatInfos[j+1][2]) );
				else 
					this:DoSitup(deskSeat);
				end
			end 
		end
	end
	desksGrid.repositionNow = true;
end
function this:ProcessSitdown ( messageObj) 
	local body = messageObj["body"];
	local deskId =  tostring(body[1]) ;
	local uid =  tostring(body[2]) ;
	local desk = this.vDesks:Find("Desk_"..deskId);
	if (desk ~= nil)  then
		local seatNo = tonumber(body[4]) ;
		local deskSeat = desk:Find(desk.name.."_Seat_"..seatNo);
		this:DoSitdown(deskSeat, uid, seatNo, tonumber(body[3]) );
	end
	if (uid ==SocketConnectInfo.Instance.userId) then
		this:ProcessSitSucess();
	end
end
function this:DoSitdown ( deskSeat,  uid,  seatNo,  avatarNo) 
	if (deskSeat ~= nil)  then
		local seatBoxCollider = deskSeat:GetComponent("BoxCollider");
		if(PlatformGameDefine.game.GameID == "1006" and PlatformGameDefine.game.GameTypeIDs == "20")then
			log("allow observer.");
		else
			seatBoxCollider.enabled = false;
		end
		
		
		local playerAvatar = deskSeat:GetChild(0):GetComponent("UISprite");
		playerAvatar.spriteName = this:DeskAvatar(seatNo, avatarNo);
		playerAvatar.alpha = 1; 
		
		local temp = this:GetDeskSeat(deskSeat.name); 
		this:ReplaceNameDeskSeat(deskSeat.name,"Desk_"..temp.deskId.."_Seat_"..uid)
		deskSeat.name = "Desk_"..temp.deskId.."_Seat_"..uid;
	end
end

function this:ProcessSitup ( messageObj) 
	local body = messageObj["body"];
	local deskId =  tostring(body[1]) ;
	local desk = this.vDesks:Find("Desk_"..deskId);
	if (desk ~= nil) then
		local uid =  tostring(body[2]) ;
		local deskSeat = desk:Find(desk.name.."_Seat_"..uid);
		this:DoSitup(deskSeat);
	end
end
function this:DoSitup ( deskSeat) 
	if (deskSeat ~= nil)  then
		deskSeat:GetChild(0):GetComponent("UISprite").alpha = 0;
		 
		local seatInfo = this:GetDeskSeat(deskSeat.name);  
		
		this:ReplaceNameDeskSeat(deskSeat.name,"Desk_"..seatInfo.deskId.."_Seat_"..seatInfo.seatId) 
		deskSeat.name = "Desk_"..seatInfo.deskId.."_Seat_"..seatInfo.seatId; 
		
		local seatBoxCollider = deskSeat:GetComponent("BoxCollider");
		seatBoxCollider.enabled = true;
	end
end

function this:ProcessGameBegin ( messageObj) 
	local deskId =  tostring(messageObj["body"]) ;
	local desk = this.vDesks:Find("Desk_"..deskId);
	this:UpdateDeskState(desk, true,deskId);
end

function this:ProcessGameEnd ( messageObj) 
	local deskId =  tostring(messageObj["body"]) ;
	local desk = this.vDesks:Find("Desk_"..deskId);
	this:UpdateDeskState(desk, false,deskId);
end

function this:ProcessSitFail ( messageObj) 
	local errorCode = tonumber(messageObj["body"])  ;
	local errorInfo = "";
	 
	if errorCode == 1 or errorCode == 2 or errorCode == 3  then
		errorInfo = ZPLocalization.Instance:Get("Socket_sit_fail_"..errorCode);
	else
		errorInfo = ZPLocalization.Instance:Get("Socket_sit_Unkonw");
	end
	EginProgressHUD.Instance:ShowPromptHUD(errorInfo);
end

function this:ProcessSitSucess () 
	SocketManager.Instance.socketListener = nil;

	--PC version shuihu houzhuan
	-- if(PlatformGameDefine.game.GameID == "1078")then
	-- 	Utils.loadScene("GameScene");
	-- else
		PlatformGameDefine.game:StartGame();
	-- end
end
 
function this:DeskPrefab () 
	local filePath = "Prefabs/Desk_".. tonumber(this.mDeskType); 
	local prefab = Util.LoadAsset("happycity/Module_Desks", "Desk_".. tonumber(this.mDeskType));
	return prefab;
end

--lxtd004 change 20160703
function this:DeskAvatar ( sitNo, avatarNo) 
	local tAvatarName = 'avatar_'..avatarNo
	return tAvatarName;
end





function this:DeskPadding () 
	local padding = Vector2.New(580, 500);
	if this.mDeskType ==DeskType.DeskType_2  then
		padding = Vector2.New(580, 400);
	elseif this.mDeskType == DeskType.DeskType_3 then
		padding = Vector2.New(580, 450);
	elseif this.mDeskType == DeskType.DeskType_4 or this.mDeskType == DeskType.DeskType_6 or this.mDeskType ==DeskType.DeskType_5 or this.mDeskType == DeskType.DeskType_7  then 
		padding = Vector2.New(580, 500);
    elseif this.mDeskType == DeskType.DeskType_16 then
		padding = Vector2.New(900, 500);
	end   
	 
	return padding;
end

function this:ResetAnchor(pAnchor)
		pAnchor.relativeOffset  = Vector2.New(0.05,-0.25);
	if this.mDeskType ==DeskType.DeskType_2 or this.mDeskType == DeskType.DeskType_4 then
		pAnchor.relativeOffset  = Vector2.New(0.05,-0.2);
    elseif this.mDeskType == DeskType.DeskType_16  then 
	 	pAnchor.relativeOffset  = Vector2.New(0.13,-0.32);
		pAnchor.enabled=true;
	-- elseif this.mDeskType == DeskType.DeskType_3  then 
	-- 	pAnchor.relativeOffset  = Vector2.New(0.05,-0.25);
	end

end


--lxtd004 change 20160703
function this:DeskGameSprite( pIsPlaying)
	local spriteName = "game_poker";
	if (pIsPlaying) then
	  	spriteName ="game_poker_p"
	end
	if this.mGameType == GameType.Mahjong then
		spriteName = "game_mahjong";
		if (pIsPlaying) then
	  		spriteName ="game_mahjong_p"
		end
	end 
	
	return spriteName;
end

function this:DeskRowCount () 
	local count = 3;
	if this.mDeskType ==DeskType.DeskType_16 then
		count = 2;
	end 
	
	return count;
end

function this:DoSocketConnect () 
	local connectInfo = SocketConnectInfo.Instance;
	if (connectInfo:ValidInfo())  then
		local socketManager = SocketManager.Instance; 
		coroutine.wait(0.1);
		
		if( PlatformGameDefine.game.GameTypeIDs == "6") then
			EginProgressHUD.Instance:ShowWaitHUD("正在进入比赛场...",true);
		

		end

		socketManager.socketListener = this.mono;
		socketManager:Connect(connectInfo,nil,true);
	else 
		EginProgressHUD.Instance:ShowPromptHUD(ZPLocalization.Instance:Get("Socket_Valid"));
	end
end


--lxtd004 change 20160703
function this:UpdateDeskState ( pDesk,  pIsPlaying,pDeskID) 
	if (pDesk ~= nil)  then
		local gameSprite = pDesk:Find("Game"):GetComponent("UISprite");
		gameSprite.spriteName = this:DeskGameSprite(pIsPlaying);
		local tDeskBg =	pDesk:FindChild('Background'):GetComponent('UISprite')
		if pIsPlaying then
			tDeskBg.spriteName = 'desk_'..tonumber(this.mDeskType)
		else
			tDeskBg.spriteName = 'desk_'..tonumber(this.mDeskType)..'_1'
		end

		gameSprite:MakePixelPerfect();
	end
end
