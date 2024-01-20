const string g_SoundFile = "scripts/plugins/cfg/ChatSounds.txt";
const float g_Delay = 0.08; //minimum time in seconds between chat sounds for the same player
//const uint max_latest_sounds=50;
//int i_latest=0;
const string g_SpriteName = 'sprites/bubble.spr';

//dictionary g_LatestSounds;
dictionary g_SoundList;
dictionary g_ChatTimes;
dictionary g_Volumes;

array<string> @g_SoundListKeys;

CClientCommand g_cs("cs", "List all chatsounds console commands", @cs);
CClientCommand g_ListSounds("listsounds", "List all chat sounds", @listsounds);
CClientCommand g_CSVolume("csvolume", "Set volume (0-1) for all chat sounds", @csvolume);
//CClientCommand g_CSClear("csclear", "Stop all chatsounds", @csclear);

void cs(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    g_PlayerFuncs.SayText(pPlayer, "[chatsounds] To control pitch, say trigger pitch. For example, tom 150" + "\n");
    g_PlayerFuncs.SayText(pPlayer, "[chatsounds] To hide chatsounds text, add ' s'. For example, tom s or tom ? s" + "\n");
    g_PlayerFuncs.SayText(pPlayer, "[chatsounds] Other console commands: .listsounds .csvolume" + "\n");
}

//void csclear(const CCommand@ pArgs)
//{
//    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
//    g_PlayerFuncs.SayText(pPlayer, "[chatsounds] Sounds cleared" + "\n");
//    for (uint i = 0; i < max_latest_sounds; ++i)
//    {
//      if (g_LatestSounds.exists(i)) {
//         g_PlayerFuncs.SayText(pPlayer, "[chatsounds] " + string(g_LatestSounds[i]) + "\n");
//         g_SoundSystem.StopSound(pPlayer.edict(), CHAN_MUSIC, string(g_LatestSounds[i]), true);
//         }
//      else
//         break;
//    }
//}

void csvolume(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    float volume = 1.0;

    if (pArgs.ArgC() < 2)
    {
        if (g_Volumes.exists(steamId))
           volume = float(g_Volumes[steamId]);
        g_PlayerFuncs.SayText(pPlayer, "csvolume is " + volume + "\n");
        return;
    }
        
    volume = atof(pArgs.Arg(1));
    if (volume<0)
       volume=0;
    else if (volume>1)
       volume=1;

    g_Volumes[steamId] = volume;
    g_PlayerFuncs.SayText(pPlayer, "chatsounds volume set to " + volume + ".\n");
}

void PluginInit()
{

  g_Module.ScriptInfo.SetAuthor("incognico,gvazdas");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd,https://knockout.chat/user/3022");

  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
  //g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  //g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  //g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @ClientConnected);

  ReadSounds();
}

void MapInit()
{
  //g_LatestSounds.deleteAll();
  g_ChatTimes.deleteAll();
  //ReadSounds();

  for (uint i = 0; i < g_SoundListKeys.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + string(g_SoundList[g_SoundListKeys[i]]));
    g_SoundSystem.PrecacheSound(string(g_SoundList[g_SoundListKeys[i]]));
  }

  g_Game.PrecacheGeneric(g_SpriteName);
  g_Game.PrecacheModel(g_SpriteName);
}

void ReadSounds()
{
  File@ file = g_FileSystem.OpenFile(g_SoundFile, OpenFile::READ);
  if (file !is null && file.IsOpen()) {
    g_SoundList.deleteAll();
    while(!file.EOFReached()) {
      string sLine;
      file.ReadLine(sLine);
      if (sLine.SubString(0,1) == "#" || sLine.IsEmpty())
        continue;

      array<string> parsed = sLine.Split(" ");
      if (parsed.length() < 2)
        continue;

      g_SoundList[parsed[0]] = parsed[1];
    }
    file.Close();
    @g_SoundListKeys = g_SoundList.getKeys();
    g_SoundListKeys.sortAsc();
  }
}

void listsounds(const CCommand@ pArgs)
{
  CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

  g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "AVAILABLE SOUND TRIGGERS\n");
  g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");

  string sMessage = "";

  for (uint i = 1; i < g_SoundListKeys.length()+1; ++i) {
    sMessage += g_SoundListKeys[i-1] + " | ";

    if (i % 5 == 0) {
      sMessage.Resize(sMessage.Length() -2);
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, sMessage);
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n");
      sMessage = "";
    }
  }
 
  if (sMessage.Length() > 2) {
    sMessage.Resize(sMessage.Length() -2);
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, sMessage + "\n");
  }

  g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n");
}


HookReturnCode ClientSay(SayParameters@ pParams)
{
  const CCommand@ pArguments = pParams.GetArguments();
  const int numArgs = pArguments.ArgC();

  if (numArgs > 0) {
    
    const string soundArg = pArguments.Arg(0).ToLowercase();

    if (g_SoundList.exists(soundArg))
    {
      
      CBasePlayer@ pPlayer = pParams.GetPlayer();
      const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
 
      if (!g_ChatTimes.exists(steamId))
        g_ChatTimes[steamId] = 0.0f;

      float t = g_EngineFuncs.Time();
      float d = t - float(g_ChatTimes[steamId]);
      g_ChatTimes[steamId] = t;
      //g_PlayerFuncs.SayText(pPlayer, string(d) + "\n");

      if (d >= g_Delay)
      {
      
            int pitch = 100;
            
            if (numArgs > 1)
            {
              
              const string pitchArg = pArguments.Arg(1).ToLowercase();
              
              if (pitchArg=="s")
                 pParams.ShouldHide = true;
              else
              {
              
                  if (pitchArg=="?")
                     pitch = Math.RandomLong(50,200);
                  else
                  {
                  
                    pitch = atoi(pitchArg);
                    
                    if (pitch==0 && pitchArg!="0")
                       pitch=100;
                    else
                    {
                        
                        if (pitch < 25)
                        {
                            pitch = 25;
                            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "chatsounds minimum pitch is 25");
                        }
                                          
                        else if (pitch > 255)
                        {
                            pitch = 255;
                            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "chatsounds maximum pitch is 255");
                        }       
                    }
                   }
              }
            }
            
            string snd_file = string(g_SoundList[soundArg]);
          
            
            if (soundArg == 'medic' || soundArg == 'meedic') {
              pPlayer.ShowOverheadSprite('sprites/saveme.spr', 51.0f, 5.0f);
              g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, snd_file, 1.0f, 0.2f,0, Math.RandomLong(80,120), 0, true, pPlayer.pev.origin);
            }
            else
            {
            
                if (!pParams.ShouldHide && numArgs > 2)
                {
                    if (pArguments.Arg(2).ToLowercase()=="s")
                       pParams.ShouldHide = true;
                }
                
                //if (i_latest>=max_latest_sounds)
                //   i_latest=0;
                //g_LatestSounds[i_latest]=snd_file;
                //i_latest+=1;
            	
            	for (int i = 1; i <= g_Engine.maxClients; i++)
            	{
            		CBasePlayer@ plr_receiving = g_PlayerFuncs.FindPlayerByIndex(i);
            		
            		if (plr_receiving is null or !plr_receiving.IsConnected())
            			continue;
            		
            		string plr_receiving_steamId = g_EngineFuncs.GetPlayerAuthId(plr_receiving.edict());
            		
            		float localVol = 1.0;
            		if (g_Volumes.exists(plr_receiving_steamId))
            		   localVol = float(g_Volumes[plr_receiving_steamId]);
            		
            		if (localVol > 0)
                       g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, snd_file, localVol, 0.3f, 0, pitch, plr_receiving.entindex(),true,pPlayer.pev.origin);
            	}
            	pPlayer.ShowOverheadSprite(g_SpriteName, 56.0f, 2.25f);
            
            }

      }
      else
      {
         pParams.ShouldHide = true;
         g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "500 000 angry bees are coming for you");
         g_PlayerFuncs.ShowMessage(pPlayer, "and they like jazz");
      }
    }
  }
  return HOOK_CONTINUE;
}