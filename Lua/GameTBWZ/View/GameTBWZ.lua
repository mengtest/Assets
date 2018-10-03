require "GameTBWZ/TBWZPlayerCtrl"
 
local cjson = require "cjson"

local this = LuaObject:New()
GameTBWZ = this
local _nnPlayerName = "NNPlayer_"		--动态生成的玩家实例名字的前缀	
local _userIndex = 0					--玩家的位置
local _isPlaying = false			
local _late = false
local _reEnter = false
local keynum = 0;
local isgameover=false;

function this:clearLuaValue()
	
	this.mono = nil
	this.gameObject = nil
	this.transform = nil
	
	this.tbwzPlayerPrefab = nil		--GameObject同桌其他玩家的预设
	this.UserPlayerCtrl =nil			--TBWZPlayerCtrl游戏玩家的控制脚本
	this.userPlayerObj = nil			--GameObject
	this.userCardScore = nil			--GameObject
	
	this.btnBegin = nil				--GameObject
	this.btnShow = nil				--GameObject
	
	
	this.msgWaitNext =	nil	--GameObject
	this.msgQuit = nil				--GameObject
	this.msgAccountFailed = nil		--GameObject
	this.msgNotContinue =nil			--GameObject

	--音效
	this.soundStart = nil				--AudioClip
	this.soundWanbi = nil;				--AudioClip
	this.soundXiazhu = nil;			--AudioClip
	this.soundTanover =nil;			--AudioClip
	this.soundWin = nil;				--AudioClip
	this.soundFail = nil;				--AudioClip	
	this.soundEnd = nil;				--AudioClip
	this.soundNiuniu = nil;			--AudioClip
	
	this._playingPlayerList = nil			--List<GameObject>游戏开始时正在游戏的玩家
	this._waitPlayerList = nil				--List<GameObject>游戏开始时等待的玩家
	this._readyPlayerList = nil			--List<GameObject>正常进入游戏时已经准备的玩家(wait=true ready=true)，需要在游戏开始时加入_playingPlayerList，并清空
	this.soundCount = nil
	self.isStart = false;
	this._currTime = 0;
	this._num = 20;
	this._numMax = 0;
	this.endTargetPosition = nil	
	this._tbwzPlayerCtrl = nil
	this.alreadyOver=false;
	isgameover=false;
	this.lateMessage=nil;
	this.jiangchiBtn=nil;
	this.jiangchiShow=false;
	this:RemoveAllTbwzPlayerCtrl();
	coroutine.Stop()
	LuaGC();
end
function this:Init()
	--初始化变量
	_userIndex = 0		
	_isPlaying = false			
	_late = false
	_reEnter = false
	
	--GameObject同桌其他玩家 
	this.tbwzPlayerPrefab = {}
	for i = 1 ,5 do
		this.tbwzPlayerPrefab[i] = this.transform:FindChild("Content/TBNNPlayer_"..i).gameObject
	end 
	
	this.UserPlayerCtrl =0			--TBWZPlayerCtrl游戏玩家的控制脚本
	this.userPlayerObj = this.transform:FindChild("Content/User").gameObject			--GameObject
	this.userCardScore = this.transform:FindChild("Content/User/Output/CardScore").gameObject			--GameObject
	--初始化NNCountLua 
	this.NNCount = this.transform:FindChild("NNCount/NNCount").gameObject:GetComponent("Animator")	
	this.NNCountNum = this.transform:FindChild("NNCount/NNCount/Sprite").gameObject:GetComponent("UILabel")	
	this.btnBegin = this.transform:FindChild("Content/User/Button_begin").gameObject				--GameObject
	this.btnShow = this.transform:FindChild("Content/User/Button_show").gameObject				--GameObject
	
	
	this.msgWaitNext =	this.transform:FindChild("Content/MsgContainer/MsgWaitNext").gameObject;	--GameObject
	this.msgQuit = this.transform:FindChild("Content/MsgContainer/MsgQuit").gameObject				--GameObject
	this.msgAccountFailed = this.transform:FindChild("Content/MsgContainer/MsgAccountFailed").gameObject		--GameObject
	this.msgNotContinue = this.transform:FindChild("Content/MsgContainer/MsgNotContinue").gameObject			--GameObject
	
	--音效
	this.soundStart = ResManager:LoadAsset("gamenn/Sound","GAME_START") 
	this.soundWanbi = ResManager:LoadAsset("gamenn/Sound","wanbi") 
	this.soundXiazhu = ResManager:LoadAsset("gamenn/Sound","xiazhu") 
	this.soundTanover = ResManager:LoadAsset("gamenn/Sound","tanover") 
	this.soundWin = ResManager:LoadAsset("gamenn/Sound","win") 
	this.soundFail = ResManager:LoadAsset("gamenn/Sound","fail") 
	this.soundEnd = ResManager:LoadAsset("gamenn/Sound","GAME_END")
	this.soundNiuniu = ResManager:LoadAsset("gamenn/Sound","niuniu") 
	this.soundCount = ResManager:LoadAsset("gamenn/Sound","djs1") 
	this.but = ResManager:LoadAsset("gamenn/gameTB","but") 
	this.betFly=ResManager:LoadAsset("gamenn/sound","nbet") ;
	this.betSound=ResManager:LoadAsset("gamenn/sound","Pool_Win") ;
	self.isStart = false;
	this._currTime = 0;
	this._num = 20;
	this.Module_RechargeLua = Module_Recharge;
	if (Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer) then
		if(PlatformGameDefine.playform.IOSPayFlag)then
			this.Module_Recharge = ResManager:LoadAsset(Utils._hallResourcesName.."/Module_Recharge","Module_Recharge")
		else
			this.Module_Recharge = ResManager:LoadAsset(Utils._hallResourcesName.."/Module_Recharge_iOS","Module_Recharge_iOS")
			this.Module_RechargeLua = Module_Recharge_iOS;
		end
	else
		this.Module_Recharge = ResManager:LoadAsset(Utils._hallResourcesName.."/Module_Recharge","Module_Recharge")
	end
	
	
	this._playingPlayerList = {}			--List<GameObject>游戏开始时正在游戏的玩家
	this._waitPlayerList = {}				--List<GameObject>游戏开始时等待的玩家
	this._readyPlayerList = {}				--List<GameObject>正常进入游戏时已经准备的玩家(wait=true ready=true)，需要在游戏开始时加入_playingPlayerList，并清空
	this._tbwzPlayerCtrl = {}				--存放Lua对象
	this.endTargetPosition = 0
	this.lateMessage={};
	this.alreadyOver=false;
	this.jiangchiShow=false;
end
function this:Awake()
	log("------------------awake of GameTBWZ-------------")
	
	this:Init();
	
	----------绑定按钮事件--------
	--退出按钮
	--local btn_back = this.transform:FindChild("Setting_btn/bg/Button_back").gameObject
	local btn_back = this.transform:FindChild("Panel_button/Button_back").gameObject
	this.mono:AddClick(btn_back, this.OnClickBack);
	--开始按钮
	this.mono:AddClick(this.btnBegin, this.UserReady);
	--摊牌按钮
	this.mono:AddClick(this.btnShow, this.UserShow);
	--确认退出按钮
	local btn_MsgQuit = this.transform:FindChild("Content/MsgContainer/MsgQuit/Button_yes").gameObject
	this.mono:AddClick(btn_MsgQuit, this.UserQuit);
	
	------------逻辑代码------------
	local sceneRoot = this.transform.root:GetComponent("UIRoot")
	
	if sceneRoot then 
		sceneRoot.manualHeight = 1920;
		sceneRoot.manualWidth = 1080;
	end
	local footInfoPrb = ResManager:LoadAsset("gamenn/verticalprefab","VerticalFootInfo")
	--local settingPrb = ResManager:LoadAsset("gametbwz/settingprb","SettingPrb")
	GameObject.Instantiate(footInfoPrb)
	--GameObject.Instantiate(settingPrb)
	 --ccc
	 --log("11111111是否开奖池")
	--log(PlatformGameDefine.playform.IsPool);
	if PlatformGameDefine.playform.IsPool then
		local jiangChiPrb = ResManager:LoadAsset("gamenn/verticalprefab","VerticalJiangChiPrb")
		GameObject.Instantiate(jiangChiPrb)
		local JiangChi=GameObject.Find("VerticalJiangChiPrb(Clone)")
		--local firstJiangChi=JiangChi.transform:FindChild("PoolInfo/firstView").gameObject;
		--firstJiangChi.transform.localPosition=Vector3.New(-310,1000,0);
		local anchortarget=JiangChi.transform:FindChild('PoolInfo/firstView').gameObject:GetComponent("UIWidget");
		this.jiangchiBtn=JiangChi.transform:FindChild('PoolInfo/firstView').gameObject;
		anchortarget.leftAnchor.absolute = -450;
		anchortarget.rightAnchor.absolute = -142;
		anchortarget.bottomAnchor.absolute = -138;
		anchortarget.topAnchor.absolute = -14;
		anchortarget.bottomAnchor.relative = 1;
		anchortarget.topAnchor.relative = 1;
	end
	 
	
	local footInfo = GameObject.Find("FootInfo")
	local btn_AddMoney = footInfo.transform:FindChild("MsgAddMoney/Button_yes").gameObject
	this.mono:AddClick(btn_AddMoney, this.OnAddMoney); 
	this.mono:AddClick(footInfo.transform:FindChild("MsgAddMoney/Button_no").gameObject, this.PlayButEffect);
	this.mono:AddClick(footInfo.transform:FindChild("MsgAddMoney/Button_close").gameObject, this.PlayButEffect);
	this.mono:AddClick(footInfo.transform:FindChild("Foot - Anchor/Info/Btn_Recharge").gameObject, this.PlayButEffect);
	 
	 
	 
	this.mono:AddClick(this.transform:FindChild("Content/MsgContainer/MsgQuit/Button_no").gameObject, this.PlayButEffect);
	this.mono:AddClick(this.transform:FindChild("Content/MsgContainer/MsgQuit/Button_close").gameObject, this.PlayButEffect);

	this.btnXiala=this.transform:FindChild("Panel_button/Button_xiala").gameObject;
	this.btnXiala_bg=this.btnXiala.transform:FindChild("Background"):GetComponent("UISprite");
	this.mono:AddClick(this.btnXiala,this.OnButtonClick,this);
	this.btn_setting=this.transform:FindChild("Panel_button/Button_xiala/panel/Button_setting").gameObject;
	this.btn_help=this.transform:FindChild("Panel_button/Button_xiala/panel/Button_help").gameObject;
	this.btn_emotion=this.transform:FindChild("Panel_button/Button_xiala/panel/Button_emotion").gameObject;
	this.btn_shelet=this.transform:FindChild("Panel_button/Button_xiala/panel/shelet").gameObject;
	this.mono:AddClick(this.btn_setting,this.OnButtonClick,this);
	this.mono:AddClick(this.btn_help,this.OnButtonClick,this);
	this.mono:AddClick(this.btn_emotion,this.OnButtonClick,this);
	this.mono:AddClick(this.btn_shelet,this.OnButtonClick,this);
end
function this.PlayButEffect()
	EginTools.PlayEffect(this.but);
end
function this:Start()

	if SettingInfo.Instance.autoNext == true or SettingInfo.Instance.deposit == true then
		this.btnBegin:SetActive (false);  
	end
	
	local info = GameObject.Find ("GameSettingManager");
	
	if not IsNil(info) then
		GameSettingManager:setDepositVisible(true);
	end
	this.mono:StartGameSocket();
	
	coroutine.start(this.Update);
	 
	
end

function this:OnDisable()
	this:clearLuaValue()
	
end
--获取_tbwzPlayerCtrl对象
function this:GetTbwzPlayerCtrl(tbName,tbObj)
	
	local tbwzTemp = this._tbwzPlayerCtrl[tbName]
	if tbwzTemp == nil then
		
		if not IsNil(tbObj) then
			this._tbwzPlayerCtrl[tbName] = TBWZPlayerCtrl:New(tbObj);
			tbwzTemp = this._tbwzPlayerCtrl[tbName]
			
		else
		end
		
	end
	return tbwzTemp
end
function this:ReplaceNameTbwzPlayerCtrl(oldName,newName)
	
	if oldName ~= newName then
		local tbwzTemp = this._tbwzPlayerCtrl[oldName]
		if tbwzTemp ~= nil then
			this._tbwzPlayerCtrl[newName] = tbwzTemp
			this._tbwzPlayerCtrl[oldName] = nil
		end
	end

end

--删除_tbwzPlayerCtrl对象
function this:RemoveTbwzPlayerCtrl(tbName)
	
	local tbwzTemp = this._tbwzPlayerCtrl[tbName];
	if tbwzTemp then
		tbwzTemp._alive = false;
		tbwzTemp:clearLuaValue();
		this._tbwzPlayerCtrl[tbName] = nil;
		tbwzTemp = nil;
	end
end
function this:RemoveAllTbwzPlayerCtrl()
	if this._tbwzPlayerCtrl then
		for key,v in pairs(this._tbwzPlayerCtrl) do
			v._alive = false;
			v:clearLuaValue();
		end
		this._tbwzPlayerCtrl = nil;
	end
end


function this.ShowPromptHUD(errorInfo)
	this.btnBegin:SetActive(false);
	this.msgAccountFailed:SetActive(true)
	this.msgAccountFailed:GetComponentInChildren(Type.GetType("UILabel",true)).text = errorInfo;
end


function this:OnDestroy()
	
	
end

function this:Update()
    while this._tbwzPlayerCtrl do
		this:TimeUpdate()
		coroutine.wait(0.1);
	end
end 
local chazhiTime = 0;
function this:TimeUpdate()
	if this.isStart then
		this._num = this._num -0.1
		if this._num > 0 then 
			chazhiTime =  math.floor(this._num)
			this.NNCountNum.text = chazhiTime<10 and "0"..chazhiTime or tostring(chazhiTime); 
				
			if this._num <= 5   then
				this.NNCount:Play("time_anima");
				if this._currTime == 1 then
					EginTools.PlayEffect(this.soundCount);	 
				end
				this._currTime = this._currTime -0.1
				if this._currTime < 0 then
					this._currTime = 1;
				end
			else
				this.NNCount:Play("time_anima_default");
			end 
		else
			this.isStart = false;
		end
	
	end
end

function this:UpdateHUD( _time)
	_time = _time-1;

	this._currTime = 1;
	this._num =  math.floor(_time); 
	this._numMax = this._num; 
	this.isStart = true;
	
	this.NNCount.gameObject:SetActive(true)
	
	 --this.NNCount.fillAmount = 1;
	 
	local timerStr = this._num<10 and "0"..this._num or tostring(this._num);
	this.NNCountNum.text = timerStr;  
end


function this:AfterDoing(offset,run)
	coroutine.wait(offset);	
	if this.mono then
		run();
	end
end

----解析JSON
function this:SocketReceiveMessage(Message)
	local Message = self;
	
	if  Message then
		--log("---------------Message="..Message) 
		--解析json字符串
		local messageObj = cjson.decode(Message);
		local typeC = messageObj["type"];
		local tag = messageObj["tag"];
		if typeC=="game" then
			if tag=="enter" then
				this:ProcessEnter(messageObj);		
			elseif tag=="ready" then
				if isgameover then
					table.insert(this.lateMessage,messageObj);
				else
					this:ProcessReady(messageObj);
				end					
			elseif tag=="come" then		
				if isgameover then
					table.insert(this.lateMessage,messageObj);
				else
					this:ProcessCome(messageObj);	
				end		
			elseif tag=="leave" then
				if isgameover then
					table.insert(this.lateMessage,messageObj);
				else
					this:ProcessLeave(messageObj);
				end		
			elseif tag=="deskover" then
				this:ProcessDeskOver(messageObj);
			elseif tag=="notcontinue" then
				coroutine.start(this.ProcessNotcontinue,this);
			elseif tag=="newactfinish" then
				this:ProcessNewactfinish(messageObj);
			end
		elseif typeC=="tbwz" then
			if tag=="time" then
				local t = messageObj["body"]
				this:UpdateHUD(t);
			elseif tag=="late" then
				this:ProcessLate(messageObj)
			elseif tag=="deal" then 
				log(Message)
				coroutine.start(this.ProcessDeal,this,messageObj);
			elseif tag=="ok" then
				log(Message)
				this:ProcessOk(messageObj);
			elseif tag=="end" then 
				log(Message)
				coroutine.start(this.ProcessEnd,this,messageObj);
			end
		elseif typeC=="seatmatch" then
			if tag=="on_update" then
				this:ProcessUpdateAllIntomoney(messageObj);
			end
		elseif typeC=="niuniu" then 
			log(Message)
			--log("是否开奖池")
			--log(PlatformGameDefine.playform.IsPool);
			if tag=="pool" then
				if PlatformGameDefine.playform.IsPool then
				    --log("11111111111")
					local info = GameObject.Find("PoolInfo")
					local chiFen = messageObj["body"]["money"];
					local infos = messageObj ["body"]["msg"]
					if info then
						PoolInfo:show(chiFen,infos);
						this.jiangchiShow=true;
					end
				end
			elseif tag=="mypool" then
			--log("2222222222")
				if PlatformGameDefine.playform.IsPool then
					local info = GameObject.Find("PoolInfo")
					local chiFen = messageObj["body"];
					if info then
						PoolInfo:setMyPool(chiFen);
					end
				end
				
			elseif tag=="mylott" then
			--log("333333333333333")
				if PlatformGameDefine.playform.IsPool then
					local info = GameObject.Find("PoolInfo")
					if(messageObj["body"]["msg"] ~= nil)then
						local msg = messageObj["body"]["msg"]
					else
						local msg = messageObj["body"]
					end
					if info then
						PoolInfo:setMyPool(msg);
					end
				end
			end
		end
	else
		log("---------------Message=nil")
	end

end

function this:ChuLiXiaoXi()
	if isgameover then
		if #(this.lateMessage)>0 then
			local message=this.lateMessage[1];	
			log("后续消息");
			printf(this.lateMessage);
			printf(message);
			
			iTableRemove(this.lateMessage,this.lateMessage[1]);
			local typeC=message["type"];
			local tag=message["tag"];
			if tag=="leave" then
				this:ProcessLeave(message);
			elseif tag=="come" then
				this:ProcessCome(message);
			elseif tag=="ready" then
				this:ProcessReady(message);
			end
			coroutine.wait(0.1);
			this.ChuLiXiaoXi();
		else
			isgameover=false;
			this.lateMessage={};
		end
	end
end

function this:ProcessNewactfinish(messageObj) 
	local body = messageObj["body"];
	
	local props = body["props"];
	  
	for index,value in pairs(props) do
		if value[1] == 104 then 
			Activity:SetAddBg(value[4]);
		end
	end 
end
----JSON解析后分发函数----
function this:ProcessEnter(messageObj)
	local body = messageObj["body"];
	local memberinfos = body["memberinfos"]
	this.UserPlayerCtrl = this:GetTbwzPlayerCtrl(this.userPlayerObj.name,this.userPlayerObj);
		
	for key,memberinfo in ipairs(memberinfos) do
		if memberinfo then
			if tostring(memberinfo["uid"])  == EginUser.Instance.uid then
				_userIndex = memberinfo["position"];
				local waiting = memberinfo["waiting"]; 
				Activity:SetCountBgLabel(memberinfo["keynum"]);
				if waiting then
					table.insert(this._waitPlayerList,this.userPlayerObj);
				else
					table.insert(this._playingPlayerList,this.userPlayerObj)
					_reEnter = true;
				end

				local bagmoney=memberinfo["bag_money"];
				this.UserPlayerCtrl.MyMoney=tonumber(bagmoney);

				local height = this.userPlayerObj.transform.root:GetComponent("UIRoot").manualHeight;
				--this.userCardScore.transform.localPosition = Vector3.New(0, (-0.07*height-52) - this.userPlayerObj.transform.localPosition.y, 0)
				this:ReplaceNameTbwzPlayerCtrl(this.userPlayerObj.name,_nnPlayerName..EginUser.Instance.uid);				
				this.userPlayerObj.name = _nnPlayerName..EginUser.Instance.uid;
				if SettingInfo.Instance.autoNext ==true or SettingInfo.Instance.deposit == true then
					this:UserReady();
				end
				break;
			end
		end
	end
	
	for key,memberinfo in ipairs(memberinfos) do
		if memberinfo then
			if tostring(memberinfo["uid"]) ~= EginUser.Instance.uid then
				this:AddPlayer(memberinfo,_userIndex);
			end
		end
	end

	local deskinfo = body["deskinfo"]
	local t = deskinfo["continue_timeout"]
	this:UpdateHUD(t);
end
function this:AddPlayer(memberinfo,_userIndex)
	local uid = memberinfo["uid"]
	local bag_money = memberinfo["bag_money"]
	local nickname = memberinfo["nickname"]
	local avatar_no = memberinfo["avatar_no"]
	local position = memberinfo["position"]
	local ready = memberinfo["ready"]
	local waiting = memberinfo["waiting"]
	local level = memberinfo["level"]
	
	--local content = this.transform:FindChild("Content").gameObject
	--local player = NGUITools.AddChild(content,this.tbwzPlayerPrefab);
	
	
	local player =this:SetAnchorPosition(_userIndex,position);
	player.name = _nnPlayerName..uid;
	local ctrl = this:GetTbwzPlayerCtrl(player.name,player)
	ctrl:SetPlayerInfo(avatar_no,nickname,bag_money,level);
	
	
	if waiting then
		if ready then
			ctrl:SetReady(true)
			ctrl:SetWait(false)
			table.insert(this._readyPlayerList,player);
		end
		table.insert(this._waitPlayerList,player);
	else
		table.insert(this._playingPlayerList,player);
	end
	
	return player;
end
function this:ProcessLate(messageObj)
	if not _reEnter then
		_late = true
		this.msgWaitNext:SetActive(true)
	end
	
	this.btnBegin:SetActive(false)
	local body = messageObj["body"]
	local chip = body["chip"]
	if tonumber(chip) > 0 then
		local infos	= body["infos"]
		for key,info in pairs(infos) do
			local uid = info[1]
			local waitting = info[2]
			local show = info[3]
			local cards = info[4]
			local cardType = info[5]
			
			local player = GameObject.Find(_nnPlayerName..uid)
			if not IsNil(player) then
				local ctrl = this:GetTbwzPlayerCtrl(player.name);
				if tonumber(waitting) == 0 then
					ctrl:SetBet(chip);
					if player == this.userPlayerObj then
						ctrl:SetLate(cards);
						if tonumber(show) == 1 then
							ctrl:SetCardTypeUser(cards,cardType)
						else
							if SettingInfo.Instance.deposit == true then
								coroutine.wait(2);	
								if this.mono==nil then
									return;
								end
								this:UserShow();
							end
							this.btnShow:SetActive(true)
						end
					else
						ctrl:SetLate(nil);
						if tonumber(show) == 1 then
							ctrl:SetShow(true)
						end
					end
				else
					ctrl:SetWait(true)
				end
				
			end
		
		end

	end
	
	local t = body["t"]
	this:UpdateHUD(t)
end
function this:SetAnchorPosition(_userIndex,playerIndex)
	local position_span = playerIndex-_userIndex; 
	local player = nil
	if position_span == 1 or position_span == -5 then 
		player = this.tbwzPlayerPrefab[1];
	elseif position_span == 2 or position_span == -4 then 
		player = this.tbwzPlayerPrefab[2];
	elseif position_span == 3 or position_span == -3 then 
		player = this.tbwzPlayerPrefab[3];
	elseif position_span == 4 or position_span == -2 then 
		player = this.tbwzPlayerPrefab[4];
	elseif position_span == 5 or position_span == -1 then 
		player = this.tbwzPlayerPrefab[5];
	else
		log("数据错误==SetAnchorPosition=="..position_span)
		return player;
	end
	player:SetActive(true);
	return player;
end
function this:ProcessReady(messageObj)
	local uid = messageObj["body"]
	local player = GameObject.Find(_nnPlayerName..uid);
	local ctrl = this:GetTbwzPlayerCtrl(player.name);
	
	
	if tostring(uid) == EginUser.Instance.uid then
		ctrl:SetCardTypeUser(nil,0);
		ctrl:SetScore(-1);
		coroutine.start(ctrl.SetDeal,ctrl,false,nil);
	else
		if this.alreadyOver then
			log("已经结束");
			ctrl:SetCardTypeOther(nil,0);
			ctrl:SetScore(-1);
			ctrl:SetWait(false)
			coroutine.start(ctrl.SetDeal,ctrl,false,nil);
		end
	end
	
	ctrl:SetReady(true);
	
	table.insert(this._playingPlayerList,player);
end
--Processes the deal.(带发牌动画)
function this:ProcessDeal(messageObj)
	--游戏已经开始
	_isPlaying = true;
	for key,player in ipairs(this._readyPlayerList) do
		if not tableContains(this._playingPlayerList,player) then
			table.insert(this._playingPlayerList,player)
		end
	end
	this._readyPlayerList = {};
	
	--清除未被清除的牌
	for key,player in ipairs(this._playingPlayerList) do
		if not IsNil(player) and player ~= this.userPlayerObj then
			
			local ctrl = this:GetTbwzPlayerCtrl(player.name)
			
			coroutine.start(ctrl.SetDeal,ctrl,false,nil);
			ctrl:SetCardTypeOther(nil,0);
			ctrl:SetScore(-1);
		end
	end
	--去掉“准备”
	for key,player in ipairs(this._playingPlayerList) do
		if not IsNil(player) then
			local ctrl = this:GetTbwzPlayerCtrl(player.name)
			ctrl:SetReady(false)
		end
	end
	--去掉筹码显示
	for key,player in ipairs(this._playingPlayerList) do
		if not IsNil(player) then
			local ctrl = this:GetTbwzPlayerCtrl(player.name)
			ctrl:SetBet(0)
		end
	end
	EginTools.PlayEffect(this.soundXiazhu);

	local body = messageObj["body"];
	local cards = body ["cards"];
	local chip = body ["chip"];
	local t = body ["t"];
	this:UpdateHUD(t);
	--下注
	for key,player in ipairs(this._playingPlayerList) do
		if not IsNil(player) then
			if player==this.userPlayerObj then
				local ctrl = this:GetTbwzPlayerCtrl(player.name)
				ctrl:SetBet(chip)
				ctrl:SetUserChip(chip)
			end
		end
	end
	
	--发牌
	for key,player in ipairs(this._playingPlayerList) do
		if not IsNil(player) then
			local ctrl = this:GetTbwzPlayerCtrl(player.name)
			if player == this.userPlayerObj then
				coroutine.start(ctrl.SetDeal,ctrl,true,cards);
			else
				coroutine.start(ctrl.SetDeal,ctrl,true,nil);
			end
			if this.mono==nil then
				return;
			end
		end
	end
	
	coroutine.wait(2.5);
	if this.mono==nil then
		return;
	end
	
	--非late进入时才显示摊牌按钮
	if not _late then
		if SettingInfo.Instance.deposit==true then
			coroutine.wait(2);
			if this.mono==nil then
				return;
			end
			this:UserShow();
		else
			this.btnShow:SetActive(true)
		end
		
	end
	
end
function this:ProcessOk(messageObj)
	local body = messageObj["body"];
	local uid = body["uid"]
	if tostring(uid) ~=EginUser.Instance.uid then
		this:GetTbwzPlayerCtrl(_nnPlayerName..uid):SetShow(true);
	else
		local cards = body["cards"]
		local cardType = body["type"];
		this.UserPlayerCtrl:SetCardTypeUser(cards,cardType);
	end
	EginTools.PlayEffect(this.soundTanover);
end

function this:ProcessEnd(messageObj)
	--去掉下注额
	for key,player in ipairs(this._playingPlayerList) do
		if player ~= this.userPlayerObj then
			if not IsNil(player) then
				local ctrl = this:GetTbwzPlayerCtrl(player.name)
				ctrl:SetShow(false)
			end
		end
	end
	
	if this.msgWaitNext.activeSelf then
		this.msgWaitNext:SetActive(false)
	end
	
	this._playingPlayerList = {}
	
	local body = messageObj["body"]
	local infos_2 = body["gold_nn"]
	local infos_1=body["infos"];
	
	local infos;
	local has_gold=false;
	if infos_2~=nil then
		infos=infos_2;
		has_gold=true;
	else
		infos=infos_1;
		has_gold=false;
	end
	for key,info in ipairs(infos) do
		local jos = info
		local uid = jos[1]
		local uiAnchor = GameObject.Find(_nnPlayerName..uid)
		local score = jos[4]
		if tonumber(score) >0 then
			local sideposition_1 = uiAnchor:GetComponent("UIAnchor").side:ToString(); 
			log(sideposition_1);
			local sideposition = this:GetTbwzPlayerCtrl(uiAnchor.name).movetarget.transform.position;
			log(sideposition);
			log("胜利玩家的位置");
			this.endTargetPosition = sideposition;
		end
	end

	--玩家扑克牌信息
	for key,info in ipairs(infos) do
		local jos = info
		local uid = jos[1] 
		local ctrl = this:GetTbwzPlayerCtrl(_nnPlayerName..uid)
		
		local cards = jos[2]
		local cardType = jos[3] --牌型 
		 
		--名牌
		if tostring(uid)  ~= EginUser.Instance.uid then
			if ctrl ~= nil then 
				ctrl:SetCardTypeOther(cards,cardType) 
				coroutine.wait(0.1)
				if this.mono==nil then
					return;
				end
			end
		end  
	end
	
	for key,info in ipairs(infos) do
		local jos = info
		local uid = jos[1]
		local uiAnchor = GameObject.Find(_nnPlayerName..uid)
		if uiAnchor ~= nil then 
			local ctrl = this:GetTbwzPlayerCtrl(uiAnchor.name)
			local cards = jos[2]
			local cardType = jos[3] --牌型
			local score = jos[4]	--得分
			local jiangli_money;
			if has_gold then
				jiangli_money=tonumber(jos[5]);  --奖励金钱数
			end
			if tostring(uid)  == EginUser.Instance.uid then 
				if this.btnShow.activeSelf then
					this.btnShow:SetActive(false)
					ctrl:SetCardTypeUser(cards,cardType)
				end	
				if has_gold and tonumber(cardType)==9 then
					ctrl:SetJiangLi(jiangli_money)
				end
				
				if tonumber(cardType) ==10 then
					EginTools.PlayEffect(this.soundNiuniu)
				end
				if tonumber(score)  > 0 then
					EginTools.PlayEffect(this.soundWin)
				else
					EginTools.PlayEffect(this.soundFail)
				end 		
			end 
		end
	end
	coroutine.wait(1);
	for key,info in ipairs(infos) do
		local jos = info
		local uid = tostring(jos[1])
		local uiAnchor = GameObject.Find(_nnPlayerName..uid)
		local score = jos[4]	--得分
		local ctrl=nil;
		--local sideposition="";
		if uiAnchor~=nil then
			ctrl = this:GetTbwzPlayerCtrl(uiAnchor.name)
			if has_gold then
				if uid==EginUser.Instance.uid then
					ctrl:SetScore(score,jos[7],this.endTargetPosition,true)
				else
					log(this.endTargetPosition);
					log("赢家位置");
					ctrl:SetScore(score,jos[7],this.endTargetPosition,false)
				end
			else
				if uid==EginUser.Instance.uid then
					ctrl:SetScore(score,jos[5],this.endTargetPosition,true)
				else
					ctrl:SetScore(score,jos[5],this.endTargetPosition,false)
				end
			end
		end	
	end
	
	coroutine.start(this.AfterDoing,this, 0.2, function()
			--[[
			for i=1,8 do
				if(this.gameObject == nil)then
					return;
				end
				EginTools.PlayEffect(this.betFly);	
				coroutine.wait(0.02)
			end
			]]
			EginTools.PlayEffect(this.betSound);	
		end)	
	
	coroutine.wait(1.8);
	this.alreadyOver=true;
	this.ChuLiXiaoXi();

	if this.mono==nil then
		return;
	end
	
	
	for key,player in ipairs(this._waitPlayerList) do
		if player ~= this.userPlayerObj then
			this:GetTbwzPlayerCtrl(player.name):SetWait(false)
		end
	end	
	this._waitPlayerList = {}
	
	if _late then
		EginTools.PlayEffect(this.soundEnd)
		_late = false;
	else
		--this.btnBegin.transform.localPosition = Vector3.New(300, 0, 0)
	end
	
	if SettingInfo.Instance.autoNext == true or SettingInfo.Instance.deposit == true then
		coroutine.wait(2)
		if this.mono==nil then
			return;
		end
		this:UserReady();
	else
		this.btnBegin:SetActive(true)
	end
	
	local t = body["t"]
	this:UpdateHUD(t);
	
	_isPlaying = false;
	
end
function this:ProcessDeskOver(messageObj)
	--C#中代码被注释 Lua中暂不添加
end
function this:ProcessUpdateAllIntomoney(messageObj)
	local jsonStr = cjson.encode(messageObj);
	local a11=string.find(jsonStr,EginUser.Instance.uid);
	if not a11 then return nil; end
	
	local infos = messageObj["body"]
	for key,info in ipairs(infos) do
		local uid = info[1]
		local intoMoney = info[2]
		local player  = GameObject.Find(_nnPlayerName..uid);
		if not IsNil(player) then
			this:GetTbwzPlayerCtrl(player.name):UpdateIntoMoney(intoMoney);
		end
	end
end
function this.ProcessUpdateIntomoney(messageStr)
	
	local messageObj = cjson.decode(messageStr);
	local intoMoney = tostring(messageObj["body"]);
	local info = GameObject.Find("FootInfo");
	if not IsNil(info) then
		FootInfo:UpdateIntomoneyString(EginTools.HuanSuanMoney(tonumber(intoMoney)));
	end
end
function this:ProcessCome(messageObj)
	local body = messageObj["body"];
	local memberinfo = body["memberinfo"];
	local player = this:AddPlayer(memberinfo,_userIndex);
	
	if _isPlaying then
		local ctrl = this:GetTbwzPlayerCtrl(player.name);
		ctrl:SetWait(true);
	end

end
function this:ProcessLeave(messageObj)
	local uid = messageObj["body"]
	if tostring(uid) ~= EginUser.Instance.uid then
		local player = GameObject.Find(_nnPlayerName..uid);
		local ctrl = this:GetTbwzPlayerCtrl(player.name);
		ctrl:SetChongzhi();
		this:RemoveTbwzPlayerCtrl(player.name);
		if tableContains(this._playingPlayerList,player) then
			tableRemove(this._playingPlayerList,player);
		end
		
		if tableContains(this._waitPlayerList,player) then
			tableRemove(this._waitPlayerList,player);
		end
		player:SetActive(false) 
	end
end
function this:ProcessNotcontinue()
	this.msgNotContinue:SetActive(true);
	--等待3秒
	coroutine.wait(3);	
	if this.mono==nil then
		return;
	end
	this:UserQuit()
end

---------end---------
-------向服务器发送消息---------
function this:UserReady()
	--组装好数据调用C#发送函数
	local startJson = {["type"]="tbwz",tag="start"};    --最终产生json的表
	--将表数据编码成json字符串
	local jsonStr = cjson.encode(startJson);
	this.mono:SendPackage(jsonStr);
	
	EginTools.PlayEffect(this.soundStart);
	EginTools.PlayEffect(this.but);
	this.btnBegin:SetActive(false);
end
function this:UserShow()
	
	local ok = {type="tbwz",tag="ok"};    --最终产生json的表
	--将表数据编码成json字符串
	local jsonStr = cjson.encode(ok);
	this.mono:SendPackage(jsonStr);
	
	this.btnShow:SetActive(false);
	EginTools.PlayEffect(this.but);
end
function this:UserLeave()
	local userLeave = {type="game",tag="leave",body=EginUser.Instance.uid};    --最终产生json的表
	--将表数据编码成json字符串
	local jsonStr = cjson.encode(userLeave);
	this.mono:SendPackage(jsonStr);
end
function this:UserQuit()
	
	SocketConnectInfo.Instance.roomFixseat = true;
	
	local userQuit = {type="game",tag="quit"};    --最终产生json的表
	--将表数据编码成json字符串
	local jsonStr = cjson.encode(userQuit);
	this.mono:SendPackage(jsonStr);
	this.mono:OnClickBack();
	
	this._tbwzPlayerCtrl = nil
	
	EginTools.PlayEffect(this.but);
end

----------end-------------
function this:OnClickBack()
	if not _isPlaying then
		this:UserQuit();
	else
		this.msgQuit:SetActive(true);
	end
	EginTools.PlayEffect(this.but);
end
local rechatge = nil;
function this:GameFunction()  
	 local sceneRoot = this.transform.root:GetComponent("UIRoot")
	if sceneRoot then 
		sceneRoot.manualHeight = 1920;
		sceneRoot.manualWidth = 1080;
	end 
	sceneRoot = GameSettingManager.transform.root:GetComponent("UIRoot")
	if sceneRoot then 
		sceneRoot.manualHeight = 1920;
		sceneRoot.manualWidth = 1080;
	end 
	destroy(rechatge) 
end
function this:OnAddMoney()  
	rechatge =  GameObject.Instantiate(this.Module_Recharge) 
	local rechatgeTrans = rechatge.transform;
	
	rechatgeTrans.parent = this.transform;
	rechatgeTrans.localScale = Vector3.one;
	
	rechatge:GetComponent("UIPanel").depth = 30; 
	
	local sceneRoot = this.transform.root:GetComponent("UIRoot")
	
	if sceneRoot then 
		sceneRoot.manualHeight = 1920;
		sceneRoot.manualWidth = 1080;
	end 
	this.Module_RechargeLua.GameFunction = this.GameFunction;
	 
	
	EginTools.PlayEffect(this.but);
end
function this:OnButtonClick(target)
	if target==this.btnXiala then	
		log("点击下拉按钮");
		if this.btnXiala_bg.spriteName=="button_up" then
			log("隐藏");
			this.btnXiala.transform:FindChild("panel").gameObject:SetActive(false);
			this.btnXiala_bg.spriteName="button_down";	
			this.btnXiala:GetComponent("UIButton").normalSprite="button_down";
		else
			log("显示");
			this.btnXiala_bg.spriteName="button_up";
			this.btnXiala.transform:FindChild("panel").gameObject:SetActive(true);
			this.btnXiala:GetComponent("UIButton").normalSprite="button_up";
		end	
		if this.jiangchiBtn~=nil and this.jiangchiShow  then
			this.jiangchiBtn:SetActive(false);
		end
	elseif target==this.btn_setting or target==this.btn_help or target==this.btn_emotion or target==this.btn_shelet then
		this.btnXiala_bg.spriteName="button_down";
		this.btnXiala:GetComponent("UIButton").normalSprite="button_down";
		if this.jiangchiBtn~=nil and this.jiangchiShow  then
			this.jiangchiBtn:SetActive(true);
		end
	end
end


function this:LengNameSub( text)
	
	if   LengthUTF8String(text) > 6 then
		return SubUTF8String(text,18);
	end
	return text;
end
