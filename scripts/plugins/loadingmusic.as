array<string> music_filepaths = {
"sound/demonprey/funkymusicshort.mp3",
"sound/turretfortress/n2.mp3",
"sound/snd/ambience.mp3",
"sound/bridge/chill.mp3",
"media/Half-Life03.mp3",
"sound/fortified/callme.mp3"
};

const uint num_songs = music_filepaths.length();

dictionary g_mp3Played;
uint i_song = uint(Math.RandomLong(0,num_songs-1));
string mp3_filepath = music_filepaths[i_song];
array<uint> tracks_i_unplayed;

void reset_shuffle(bool initial=false)
{
    tracks_i_unplayed.resize(0);
    for (uint i = 0; i < num_songs; ++i)
    {
       if (i!=i_song or initial)
          tracks_i_unplayed.insertLast(i);
    }
}

void PluginInit()
{
  //g_EngineFuncs.ServerPrint("loadingmusic plugininit\n");
  g_Module.ScriptInfo.SetAuthor("gvazdas");
  g_Module.ScriptInfo.SetContactInfo("https://knockout.chat/user/3022");
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  //g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @ClientConnected);
  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
  reset_shuffle(true);
}

void MapInit()
{
   //g_EngineFuncs.ServerPrint("loadingmusic mapinit\n");
   g_mp3Played.deleteAll();
}

HookReturnCode ClientConnected(edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason)
{
  //g_EngineFuncs.ServerPrint("loadingmusic " + szPlayerName + " connected\n");
  if (!g_mp3Played.exists(szPlayerName))
  {
      //g_EngineFuncs.ServerPrint("current song: " + mp3_filepath+"\n");
      NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pEntity );
      msg.WriteString("mp3fadetime 100; mp3 play " + mp3_filepath);
      msg.End();
      g_mp3Played[szPlayerName]=true;
  }
  return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
  //g_EngineFuncs.ServerPrint("loadingmusic " + pPlayer.pev.netname + " in server\n");
  NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
  msg.WriteString("mp3 play");
  msg.End();
  g_mp3Played.delete(pPlayer.pev.netname);
  return HOOK_CONTINUE;
}

HookReturnCode MapChange()
{
  
  if (tracks_i_unplayed.length()<1)
     reset_shuffle();
  
  i_song = uint(tracks_i_unplayed[uint(Math.RandomLong(0,tracks_i_unplayed.length()-1))]);
  
  int i_remove = tracks_i_unplayed.find(i_song);
  if (i_remove >= 0)
     tracks_i_unplayed.removeAt(i_remove);
  
  mp3_filepath = music_filepaths[i_song];
  //g_EngineFuncs.ServerPrint("current song: " + mp3_filepath+"\n");
  
  return HOOK_CONTINUE;
}

//HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
//{
   
  //g_EngineFuncs.ServerPrint("loadingmusic " + pPlayer.pev.netname + " disconnected\n");
  //NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
  //msg.WriteString("mp3 play");
  //msg.End();
  //if (g_mp3Played.exists(pPlayer.pev.netname))
  //   g_mp3Played.delete(pPlayer.pev.netname);
//  return HOOK_CONTINUE;
//}