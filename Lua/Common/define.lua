
CtrlName = {
	Prompt = "PromptCtrl",
	Message = "MessageCtrl",
	Loading = "LoadingCtrl"
}

--协议类型--
ProtocalType = {
	BINARY = 0,
	PB_LUA = 1,
	PBC = 2,
	SPROTO = 3,
}
--当前使用的协议类型--
TestProtoType = ProtocalType.BINARY;

Util = SimpleFramework.Util;
AppConst = SimpleFramework.AppConst;
LuaHelper = SimpleFramework.LuaHelper;
ByteBuffer = SimpleFramework.ByteBuffer;
ArrayList = System.Collections.ArrayList

ResManager = LuaHelper.GetResManager();
NetManager = LuaHelper.GetNetManager();
PanelManager = LuaHelper.GetPanelManager();
MusicManager = LuaHelper.GetMusicManager();