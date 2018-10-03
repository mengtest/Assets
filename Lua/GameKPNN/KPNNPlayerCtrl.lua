local this = LuaObject:New()
KPNNPlayerCtrl = this

function this:New( gameObj)
    local obj = {}
    setmetatable(obj,self )
    self.__index = self 
    obj.gameObject = gameObj
    obj.transform = gameObj.transform
    obj:Awake()
    obj:Start()
    return obj
end

-- local m_ReadyObj            --提示字“准备”
-- local m_ShowObj             --提示字 攤牌
-- local m_CallBankerObj       --提示字 叫庒中
-- local m_WaitObj             -- 提示字 等待中
-- local m_CardTypeTrans       -- 提示字比牌結果
-- local m_UserAvatar          --玩家头像
-- local m_UserNickNameSp       --玩家昵称
-- local m_UserIntoMoneyLab     --玩家现金
-- local m_CardArraySps = {}    --玩家的扑克牌
-- local m_CardTrans            --玩家的牌的 父物体
-- local m_CardScoreObj         -- 玩家得分
-- local m_CardScoreSp           
-- local m_BankerSpObj
-- local m_BankerBgObj
-- local m_JettonObj
-- local m_InfoDetail
-- local m_DetailNickNameLab
-- local m_DetailLevelLab
-- local m_DetailBagMoneyLab
-- local m_SoundSend;
-- local m_CardScoreV
-- local m_CardTypeV
-- local m_ShopV
-- local m_CallBankerV
-- local m_InfoDetailV

this.m_ParentX = 0
this.m_ParentY = 30
this.m_ParentZ = 0
this.m_CardInterval = 40
this.m_CardPreStr = 'card_'
this.m_TimeInterval =3
this.m_TimeLasted =0
this.Const_R_Side_Offset = -15

function this:init( )
    print('KPNN player ctrl init ')
    this.m_TimeLasted =0
    self.m_CardTrans = self.transform:FindChild('Output/Cards')
    self.cardsTransAnima = self.transform:FindChild("Output/Cards").gameObject:GetComponent("Animator");
    self.m_CardTypeTrans = self.transform:FindChild('Output/Cards/CardType')
    self.m_cardscoreParent = self.transform:FindChild("Output/CardScore").gameObject;
    self.m_cardScoreObj = self.transform:FindChild("Output/CardScore/CardScore").gameObject
    self.m_plusLabel = self.transform:FindChild("Output/CardScore/CardScore/win").gameObject:GetComponent("UILabel");
    self.m_minusLabel = self.transform:FindChild("Output/CardScore/CardScore/lose").gameObject:GetComponent("UILabel");
    self.m_InfoDetail = nil 
    self.anchorRight=false;
    if(self.gameObject.name ~= "User" and self.gameObject.name ~= ("NNPlayer_"..tostring(EginUser.Instance.uid)) )then
        self.m_ShowObj = self.transform:FindChild("Output/Cards/Sprite_Over/Sprite_show").gameObject
        self.m_InfoDetail  = self.transform:FindChild("PlayerInfo/Info_detail").gameObject
        self.m_ReadyObj  = self.transform:FindChild("PlayerInfo/Panel/Sprite_ready").gameObject
        self.m_WaitObj    = self.transform:FindChild("PlayerInfo/Panel/Sprite_waitting").gameObject
        self.m_UserAvatar = self.transform:FindChild("PlayerInfo/Panel/Sprite (avatar_6)").gameObject:GetComponent("UISprite");
        self.m_UserNickNameLab  = self.transform:FindChild("PlayerInfo/Label_nickname").gameObject:GetComponent("UILabel");
        self.m_UserIntoMoneyLab = self.transform:FindChild("PlayerInfo/Label_bagmoney").gameObject:GetComponent("UILabel");
        self.m_DetailNickNameLab  = self.transform:FindChild("PlayerInfo/Info_detail/Label1/Nickname").gameObject:GetComponent("UILabel");   
        self.m_DetailLevelLab =  self.transform:FindChild("PlayerInfo/Info_detail/Label2/Level").gameObject:GetComponent("UILabel");
        self.m_DetailBagMoneyLab  =  self.transform:FindChild("PlayerInfo/Info_detail/Label3/BagMoney").gameObject:GetComponent("UILabel");
        self.jiangliMoney=nil;
        self.m_BankerSpObj  = self.transform:FindChild("PlayerInfo/Panel_Head/Sprite_banker").gameObject
        self.m_CallBankerObj  = self.transform:FindChild("PlayerInfo/Sprite_callBanker").gameObject
        self.movePanel={};
        for i=1,24 do
          table.insert(self.movePanel,self.transform:FindChild("PlayerInfo/Label_bagmoney/bet_1/bet_"..i).gameObject);
        end
        self.chipParent=self.transform:FindChild("Output/chipBet").gameObject;
        self.movetarget=self.transform:FindChild("PlayerInfo/Label_bagmoney/bet").gameObject
    else
        self.m_ReadyObj   = self.transform:FindChild("Output/Sprite_ready").gameObject
        self.m_BankerSpObj = self.transform:FindChild("Output/Sprite_banker").gameObject
        self.m_InfoDetail  = nil
        local gold_type=self.m_CardTypeTrans.transform:FindChild("CardType_gold").gameObject;
        self.jiangliMoney=self.transform:FindChild("Output/Label").gameObject:GetComponent("UILabel");
        self.movePanel={};
        local info = GameObject.Find("FootInfo");
        for i=1,24 do
          table.insert(self.movePanel,info.transform:FindChild("Foot - Anchor/Info/Money/Sprite_1/Sprite_"..i).gameObject);
        end
        self.chipParent = self.transform:FindChild("Output/chipBet").gameObject
        log(self.chipParent.name);
        self.movetarget=info.transform:FindChild("Foot - Anchor/Info/Money/Sprite").gameObject;
    end
  
    self.m_SoundSend = ResManager:LoadAsset("gamenn/Sound","SEND_CARD") --resLoad("Sound/SEND_CARD");

    self.m_JettonObj  = ResManager:LoadAsset("gamenn/prefabs","JettonPrefab") 

    if(self.gameObject.name ~= "User" and self.gameObject.name ~= ("NNPlayer_"..tostring(EginUser.Instance.uid)) )then
        local btn_Avatar = self.transform:FindChild("PlayerInfo/Panel/Sprite (avatar_6)").gameObject
        GameKPNN.mono:AddClick(btn_Avatar,self.OnClickInfoDetail,self)
  
    end
  
    self.m_CardArraySps = {}
    for i=1,5 do
        table.insert(self.m_CardArraySps,self.m_CardTrans:FindChild("Sprite_"..i).gameObject:GetComponent("UISprite"));
    end
    self.jiesuanMoney=0;
end

function this:Awake()
    self:init()
    self.m_ParentX = 0
    self.m_ParentY = self.m_CardTrans.localPosition.y
    self.m_ParentZ = self.m_CardTrans.localPosition.z
end

function this:Start( )
    self:UpdateSkinColor()
    if self.m_CardScoreObj ~= nil and self.m_CardTypeTrans ~= nil and self.m_ShowObj ~= nil and self.m_CallBankerObj~= nil then
        self.m_CardScoreV   = self.m_CardScoreObj.transform.localPosition
        self.m_CardTypeV    = self.m_CardTypeTrans.localPosition
        self.m_ShopV        = self.m_ShowObj.transform.localPosition
        self.m_CallBankerV  = self.m_CallBankerObj.transform.localPosition
        self.m_InfoDetailV  = self.m_InfoDetail.transform.localPosition
    end
    local tAnchor = self.gameObject:GetComponent('UIAnchor')
    if tAnchor.side == UIAnchor.Side.Right then
        self.anchorRight=true;
        local outputAnchor=self.transform:FindChild("Output");
		outputAnchor.transform.localPosition=Vector3.New(-500,18,0);
		--self.chipParent.transform.localPosition=Vector3.New(-100,-250,0);
		self.m_CallBankerObj.transform.localPosition=Vector3.New(-40,-260,0);
		--self.m_BankerSpObj.transform.localPosition =Vector3.New(0,94,0);
    elseif tAnchor.side == UIAnchor.Side.Top then
        local outputAnchor=self.transform:FindChild("Output");
		outputAnchor.transform.localPosition=Vector3.New(-235,-320,0);
		--self.chipParent.transform.localPosition=Vector3.New(0,-500,0);
        self.m_CallBankerObj.transform.localPosition=Vector3.New(0,-470,0);
    elseif tAnchor.side == UIAnchor.Side.Left then
       local outputAnchor=self.transform:FindChild("Output");
		outputAnchor.transform.localPosition=Vector3.New(0,18,0);
		--self.chipParent.transform.localPosition=Vector3.New(100,-250,0);
		self.m_CallBankerObj.transform.localPosition=Vector3.New(40,-260,0);
		--self.m_BankerSpObj.transform.localPosition =Vector3.New(0,94,0);
    end
end



function this:clearLuaValue(  )
    self.gameObject= nil 
    self.transform = nil 

    self.m_CardTrans = nil
    self.m_ReadyObj  =nil           --提示字“准备”
    self.m_ShowObj   =nil           --提示字 攤牌
    self.m_CallBankerObj  =nil       --提示字 叫庒中
    self.m_WaitObj        =nil      -- 提示字 等待中
    self.m_CardTypeTrans  =nil      -- 提示字比牌結果
    self.m_UserAvatar     =nil     --玩家头像
    self.m_UserNickNameSp     =nil  --玩家昵称
    self.m_UserIntoMoneyLab     =nil--玩家现金

    self.m_CardArraySps = {}    --玩家的扑克牌
    self.m_CardTrans    =nil        --玩家的牌的 父物体
    self.m_CardScoreObj  =nil       -- 玩家得分     
    
    self.m_BankerSpObj=nil
    
    self.m_JettonObj=nil
    self.m_InfoDetail=nil
    self.m_DetailNickNameLab=nil
    self.m_DetailLevelLab=nil
    self.m_DetailBagMoneyLab=nil

    self.m_TimeLasted =nil

    self.m_SoundSend=nil
    self.m_CardScoreV=nil
    self.m_CardTypeV=nil
    self.m_ShopV=nil
    self.m_CallBankerV=nil
    self.m_InfoDetailV =nil
    self.anchorRight=false;
    self.jiesuanMoney=0;
end


function this:OnDestroy( )
    self:clearLuaValue()
end

function this:UpdateSkinColor()
    for k,v in pairs(self.m_CardArraySps) do
        v.spriteName = this.m_CardPreStr .. "yellow";
    end
end

function this:SetPlayerInfo(pAvatar,pNickname,pIntoMoney,pLevel )
    if tonumber(pAvatar) ==0 then
        self.m_UserAvatar.spriteName = 'avatar_'..tostring((tonumber(pAvatar)+2))
    else
        self.m_UserAvatar.spriteName = 'avatar_'..tostring(pAvatar)
    end
    self.m_UserNickNameLab.text = pNickname
    if(LengthUTF8String(self.m_UserNickNameLab.text)>5)then
        self.m_UserNickNameLab.text = SubUTF8String(self.m_UserNickNameLab.text,15) .. "..."
    end
    --self.m_UserIntoMoneyLab.text = "¥ "..EginTools.NumberAddComma(pIntoMoney)
    self.m_UserIntoMoneyLab.text = EginTools.HuanSuanMoney(pIntoMoney)
    self.m_DetailNickNameLab.text = pNickname
    if(LengthUTF8String(self.m_DetailNickNameLab.text)>5)then
        self.m_DetailNickNameLab.text = SubUTF8String(self.m_DetailNickNameLab.text,15) .. "..."
    end
    self.m_DetailLevelLab.text = pLevel
    self.m_DetailBagMoneyLab.text = pIntoMoney
end


function this:OnClickInfoDetail()
    if self.m_InfoDetail.activeSelf then
        self.m_InfoDetail:SetActive(false)
        self.m_TimeLasted = 0
    else
        self.m_InfoDetail:SetActive(true)
    end
end
  
function this:UpdateInLua()
    if self.m_InfoDetail ~= nil then
        if  self.m_InfoDetail.activeSelf then
            self.m_TimeLasted = self.m_TimeLasted + 0.5 --Time.deltaTime
            if self.m_TimeLasted>= this.m_TimeInterval then
                self.m_InfoDetail:SetActive(false)
                self.m_TimeLasted = 0
            end
        end
      end
end


function this:UpdateIntomoney(pIntoMoney )
    if self.m_UserIntoMoneyLab == nil then
        GameObject.Find('Label_Bagmoney'):GetComponent('UILabel').text = EginTools.HuanSuanMoney(pIntoMoney)
    else
        self.m_UserIntoMoneyLab.text = EginTools.HuanSuanMoney(pIntoMoney)
    end
end

function this:SetBanker(pToShow)
    if pToShow then
        self.m_BankerSpObj:SetActive(true)       
    else
        self.m_BankerSpObj:SetActive(false)
    end
end



function this:SetDeal(pIsToShow,pInfos)
    if  pIsToShow ==false then
        self.cardsTransAnima:Play("setcard_5");
    else
        if pInfos ~= nil then 
            for i=1,#pInfos do 
                if pInfos[i] ~= nil then
                    self.m_CardArraySps[i].spriteName = this.m_CardPreStr .. tostring(pInfos[i])
                end
            end
        end        
        if self.chipParent.activeSelf or self.m_BankerSpObj.activeSelf then
			self.cardsTransAnima.enabled=true;
			self.cardsTransAnima:Play("setcard_6");		
		end
    end
end

function this:SetTwoDeal(pIsToShow,infos)
    self:UpdateSkinColor()
    if  pIsToShow == false then
        self.cardsTransAnima:Play("setcard_5");
    else
        local isown=false;
        if self.m_SoundSend ~= nil then
          EginTools.PlayEffect(self.m_SoundSend)
        end
      
        if infos ~= nil  then
            isown=true;
            for k,v in pairs(infos) do
                if v ~= nil then
                    self.m_CardArraySps[k].spriteName = this.m_CardPreStr .. tostring(infos[k])
                end
            end
        end

		self.cardsTransAnima.enabled=true;

        if isown then
			self.cardsTransAnima:Play("setcard_1");
		else
			if self.anchorRight then
				local count = math.random(12,13);
				self.cardsTransAnima:Play("setcard_"..count);
			else
				local count = math.random(8,11);
				self.cardsTransAnima:Play("setcard_"..count);
			end
		end

        for i=1,24 do
            self.movePanel[i].transform.localPosition=Vector3.zero;
        end
    end
end

function this:SetLate( pCards )
    for k,v in pairs(self.m_CardArraySps) do 
    -- for i =0 ,self.m_CardArraySps.Length-1 do 
        v.gameObject:SetActive(true)
        if pCards ~= nil and #pCards > 0 then
            v.spriteName = this.m_CardPreStr..tostring(pCards[k])
        end
    end
    self.m_CardTrans.gameObject:SetActive(true)
	self.cardsTransAnima.enabled=true;
	self.cardsTransAnima:Play("setcard_6");
end

function this:SetCardTypeUser(pCardsList,pCardType,isgold)
    if pCardsList == nil then
        self.m_CardTypeTrans.gameObject:SetActive(false)
        local cardTypeSprite=self.m_CardTypeTrans.transform:FindChild("Sprite"):GetComponent("UISprite");
        local gold_type=self.m_CardTypeTrans.transform:FindChild("CardType_gold").gameObject;
        cardTypeSprite.gameObject:SetActive(false);
        gold_type:SetActive(false);
    else
        self.m_CardTypeTrans.gameObject:SetActive(true)
        for k,v in ipairs(self.m_CardArraySps) do
            v.spriteName = this.m_CardPreStr..tostring(pCardsList[k])
        end
        local tCardTypeSp=self.m_CardTypeTrans.transform:FindChild("Sprite"):GetComponent("UISprite");
        local gold_type=self.m_CardTypeTrans.transform:FindChild("CardType_gold").gameObject;
        if tonumber(pCardType) ==0 then
            local tLen = #(self.m_CardArraySps)
            tCardTypeSp.spriteName = 'type_0'
            tCardTypeSp.gameObject:SetActive(true);
            gold_type:SetActive(false);
            self.cardsTransAnima:Play("setcard_3");
        else           
            if isgold==1 then
                tCardTypeSp.gameObject:SetActive(false);
                gold_type:SetActive(true);
                local huangjin=gold_type.transform:FindChild("Sprite_1"):GetComponent("UISprite");
				local niuniu=gold_type.transform:FindChild("Sprite_2"):GetComponent("UISprite");
				huangjin.spriteName="type_15";
				niuniu.spriteName="type_10";
            else
                tCardTypeSp.spriteName = 'type_'..pCardType
                tCardTypeSp.gameObject:SetActive(true);
                gold_type:SetActive(false);
            end
            self.cardsTransAnima:Play("setcard_4");
        end
    end
end

function this:SetJiangLi(jiangliMoney)	
    self.jiangliMoney.text="大奖"..jiangliMoney.."游戏币到银行了";
    self.jiangliMoney.gameObject:SetActive(true);
    coroutine.start(self.AfterDoing,self,2,function()
        self.jiangliMoney.gameObject:SetActive(false);
    end); 
end

function this:SetCardTypeOther(pCardsList,pCardType,isgold )
    if pCardsList == nil then      
        self:UpdateSkinColor()
        local tCardTypeSp=self.m_CardTypeTrans.transform:FindChild("Sprite"):GetComponent("UISprite");
        local gold_type=self.m_CardTypeTrans.transform:FindChild("CardType_gold").gameObject;
        tCardTypeSp.gameObject:SetActive(false);
        gold_type:SetActive(false)

    else
        self.m_CardTypeTrans.gameObject:SetActive(true)
        for k,v in pairs(self.m_CardArraySps) do 
            v.spriteName = this.m_CardPreStr ..tostring(pCardsList[k]);
        end

        local tCardTypeSp=self.m_CardTypeTrans.transform:FindChild("Sprite"):GetComponent("UISprite");
        local gold_type=self.m_CardTypeTrans.transform:FindChild("CardType_gold").gameObject;
        if tonumber(pCardType) ==0 then
            tCardTypeSp.spriteName = 'type_0'
            tCardTypeSp.gameObject:SetActive(true);
            gold_type:SetActive(false)
      elseif tonumber(pCardType) >0 then
              if isgold==1 then
                    tCardTypeSp.gameObject:SetActive(false);
                    gold_type:SetActive(true)
                    local huangjin=gold_type.transform:FindChild("Sprite_1"):GetComponent("UISprite");
                    local niuniu=gold_type.transform:FindChild("Sprite_2"):GetComponent("UISprite");
                    huangjin.spriteName="type_15";
                    niuniu.spriteName="type_10";
              else
                  tCardTypeSp.spriteName = 'type_'..pCardType
                  tCardTypeSp.gameObject:SetActive(true);
                  gold_type:SetActive(false)
              end
              self.cardsTransAnima:Play("setcard_4");
       end

    end
end

function this:SetScore(pScore )
    self.jiesuanMoney=tonumber(pScore);
    if tonumber(pScore) == -1  then
        self.m_cardScoreObj:SetActive(false)
	  	  self.m_cardscoreParent:SetActive(false);
    else
        if self.m_cardScoreObj~=nil then
            self.m_cardScoreObj:SetActive(true)
            self.m_cardscoreParent:SetActive(true);
            if(tonumber(pScore) >= 0)then
                self.m_plusLabel.gameObject:SetActive(true)
                self.m_minusLabel.gameObject:SetActive(false)
                self.m_plusLabel.text ="+"  .. pScore
            elseif(tonumber(pScore)<0)then
                self.m_plusLabel.gameObject:SetActive(false)
                self.m_minusLabel.gameObject:SetActive(true)
                self.m_minusLabel.text = pScore
            end
	  	  end
    end  
end

function this:SetBet(pJetton ) 
    log(pJetton.."====下注筹码");
    if( (tonumber(pJetton) > 0) and (not self.m_cardScoreObj.activeSelf) )then
      self.chipParent:SetActive(true);
      self.chipParent.transform:FindChild("BetLabel"):GetComponent("UILabel").text=tostring(pJetton);
    else
      self.chipParent:SetActive(false);
    end
end

function this:SetStartChip(pParent,pJetton )
    local tSpr = pParent:GetComponentsInChildren(Type.GetType('UISprite',true))
    local tDelList = {}
    if tSpr.Length >1 then
       --for k,v in pairs(tSpr) do
        for i=0,tSpr.Length-1 do
            if tSpr[i].gameObject.name ~= 'Sprite_bg' then
                destroy(tSpr[i].gameObject);
            end
        end
    end

    if tonumber(pJetton) >0 then 
        EginTools.AddNumberSpritesCenter(self.m_JettonObj,pParent.transform,tostring(pJetton),'plus_',0.8)  
    else
        self.m_CardScoreObj:SetActive(false)
    end
end

function this:SetReady(pToShow )
    if pToShow and self.m_ReadyObj.activeSelf == false then
        self.m_ReadyObj:SetActive(true)
    else
        self.m_ReadyObj:SetActive(false)
    end
end

function this:SetShow(pToShow )
    if self.m_ShowObj~= nil then 
        if pToShow and self.m_ShowObj.activeSelf == false then
            self.m_ShowObj:SetActive(true)
        else
            self.m_ShowObj:SetActive(false)
        end
    end
end


function this:SetCallBanker( pToShow)
    if self.m_CallBankerObj ~= nil then 
        if pToShow== true and self.m_CallBankerObj.activeSelf == false then
            self.m_CallBankerObj:SetActive(true)
        else
            self.m_CallBankerObj:SetActive(false)
        end
    end
end


function this:SetWait( pToShow )
    if self.m_WaitObj ~= nil then
        if pToShow and self.m_WaitObj.activeSelf == false then 
            self.m_WaitObj:SetActive(true)
        else
            self.m_WaitObj:SetActive(false)
        end
    end
end

function this:SetFlyBetAnimation(positionList,uid)
	local isown=false;
	if uid==EginUser.Instance.uid then
		isown=true;
	end
    log("结束位置");
	for i=1,#(positionList) do
        log("结束位置");
        log(positionList[i]);
		self:MoveBet(positionList[i],isown,i-1);
	end
	if self.jiesuanMoney<0 then
        local tCardTypeSp=self.m_CardTypeTrans.transform:FindChild("Sprite"):GetComponent("UISprite"); 
		tCardTypeSp.spriteName="gray"..tCardTypeSp.spriteName;
        --[[
        local gold_type=self.m_CardTypeTrans.transform:FindChild("CardType_gold").gameObject;
		local huangjin=gold_type.transform:FindChild("Sprite_1"):GetComponent("UISprite");
		local niuniu=gold_type.transform:FindChild("Sprite_2"):GetComponent("UISprite");
		huangjin.spriteName="gray"..huangjin.spriteName;
		niuniu.spriteName="gray"..niuniu.spriteName;
        ]]
	end	
end

function this:MoveBet(targetPosition,isown,index)
		local x=self.movetarget.transform.position.x;
		local y=self.movetarget.transform.position.y;
		local xx=targetPosition.x;
		local yy=targetPosition.y;
		local paths={};
		paths[1]=self.movetarget.transform.position;
		if isown then
			paths[2]=Vector3.New(xx,yy,0);
		else
			paths[2]=Vector3.New(x+(xx-x)*0.5,y+0.02,0);
			paths[3]=Vector3.New(xx,yy,0);
		end
		
		local pathse=Utils.Zhuanhuan(paths);
		local v = 0;	
		for i=1+(8*index),8+(8*index) do	
			local temp = v;
            log(temp);
            log("时间值");
			coroutine.start(self.AfterDoing,self,temp,function()
				if isown then
					log(i.."=============zhi");
				end
				if self.movePanel[i]~=nil then
					self.movePanel[i]:SetActive(true);
					iTween.MoveTo(self.movePanel[i],GameKPNN.mono:iTweenHashLua("path",pathse,"time", 1.2-temp*0.5,"easeType", iTween.EaseType.easeOutCubic));
					iTween.ScaleTo(self.movePanel[i],GameKPNN.mono:iTweenHashLua("scale",Vector3.New(1.2,1.2,1.2),"time",0.2,"easeType", iTween.EaseType.linear,"delay",1.2-temp*0.5));
					iTween.ScaleTo(self.movePanel[i],GameKPNN.mono:iTweenHashLua("scale",Vector3.New(1,1,1),"time",0.2,"easeType", iTween.EaseType.linear,"delay",1.2-temp*0.5));
					coroutine.start(self.AfterDoing,self,1.4-temp*0.5,function()
						if self.movePanel[i]~=nil then
							self.movePanel[i]:SetActive(false);		
						end
					end); 				
				end	
			end);
			v=v+0.03;		
		end
end


function this:AfterDoing(offset, run)
    coroutine.wait(offset);
    if self.gameObject==nil then
        return;
    end
    run();
end

