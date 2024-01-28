array<string> music_filepaths = {"sound/demonprey/funkymusicshort.mp3",
                                 "sound/turretfortress/n2.mp3",
                                 "sound/snd/ambience.mp3",
                                 "sound/bridge/chill.mp3",
                                 "media/Half-Life03.mp3",
                                 "sound/fortified/callme.mp3"};

dictionary g_mp3Played;

CClientCommand g_loadingmusic("loadingmusic", "Print version", @loadingmusic);

void PluginInit()
{
  g_Module.ScriptInfo.SetAuthor("gvazdas");
  g_Module.ScriptInfo.SetContactInfo("https://knockout.chat/user/3022");
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @ClientConnected);
}

void MapInit()
{
   g_mp3Played.deleteAll();
}

void loadingmusic(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "loadingmusic version 2024-01-21\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "For the latest version go to https://github.com/gvazdas/svencoop\n");
}

HookReturnCode ClientConnected(edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason)
{
  if (!g_mp3Played.exists(szPlayerName))
  {
      int i_song = Math.RandomLong(0,music_filepaths.length());
      string mp3_filepath = music_filepaths[i_song];
      NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pEntity );
      msg.WriteString("mp3fadetime 100; mp3 play " + mp3_filepath);
      msg.End();
      g_mp3Played[szPlayerName]=true;
  }
  return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
  NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
  msg.WriteString("mp3 play");
  msg.End();
  g_mp3Played.delete(pPlayer.pev.netname);
  return HOOK_CONTINUE;
}