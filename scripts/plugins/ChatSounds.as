const string g_SoundFile = "scripts/plugins/cfg/ChatSounds.txt";
const float g_Delay = 0.08; //minimum time in seconds between chat sounds for the same player
//const uint max_latest_sounds=50;
//int i_latest=0;
const string g_SpriteName = 'sprites/bubble.spr';

//dictionary g_LatestSounds;
dictionary g_SoundList;
dictionary g_ChatTimes;
dictionary g_Volumes;
bool desperate; //deus ex meme
bool all_volumes_1 = true; //track if all connected players .csvolume is 1

const array<string> g_soundfiles_duke =
{
"chat/up7/duke1.wav",
"chat/up7/duke2.wav",
"chat/up7/duke3.wav",
"chat/up7/duke4.wav",
"chat/up7/duke5.wav",
"chat/up7/duke6.wav",
"chat/up7/duke7.wav",
"chat/up7/duke8.wav",
"chat/up7/duke9.wav",
"chat/up7/duke10.wav",
"chat/up7/duke11.wav",
"chat/up7/duke12.wav",
"chat/up7/duke13.wav",
"chat/up7/duke14.wav",
"chat/up7/duke15.wav"
};

const array<string> g_soundfiles_dracula =
{
"chat/up7/dracula1.wav",
"chat/up7/dracula2.wav",
"chat/up7/dracula3.wav",
"chat/up7/dracula4.wav",
"chat/up7/dracula5.wav",
"chat/up7/dracula6.wav"
};

const float race_updatetime = 0.05f; //higher number will result in less hitching.
const float race_maxspeed = 5000.0f; //if speed is higher than this, ignore it
bool race_happening = false;
array<Vector> arr_race_origins;
array<float> arr_race_distances;

array<string> @g_SoundListKeys;
array<uint> arr_active_players;

//red
const array<Vector> g_caramel_colors_group1 =
{
Vector(255,160,122),
Vector(128,0,0),
Vector(255,60,20),
Vector(255,0,0)
};

//green
const array<Vector> g_caramel_colors_group2 =
{
Vector(110,180,10),
Vector(240,240,80),
Vector(0,255,0)
};

//light blue
const array<Vector> g_caramel_colors_group3 =
{
Vector(100,240,250),
Vector(0,120,120),
Vector(0,255,255)
};

//orange
const array<Vector> g_caramel_colors_group4 =
{
Vector(255,255,0),
Vector(255,215,0),
Vector(255,165,0),
Vector(255,140,0)
};

//dark blue
const array<Vector> g_caramel_colors_group5 =
{
Vector(0,0,255),
Vector(120,210,255),
Vector(10,50,190),
Vector(20,120,255)
};

//purple
const array<Vector> g_caramel_colors_group6 =
{
Vector(255,139,255),
Vector(255,0,255),
Vector(193,50,175),
Vector(128,0,128)
};

const dictionary g_caramel_all_groups =
{
{'0',g_caramel_colors_group1},
{'1',g_caramel_colors_group2},
{'2',g_caramel_colors_group3},
{'3',g_caramel_colors_group4},
{'4',g_caramel_colors_group5},
{'5',g_caramel_colors_group6}
};

CClientCommand g_cs("cs", "List all chatsounds console commands", @cs_command);
CClientCommand g_ListSounds("listsounds", "List all chat sounds", @listsounds_command);
CClientCommand g_CSVolume("csvolume", "Set volume (0-1) for all chat sounds", @csvolume_command);
//CClientCommand g_CSClear("csclear", "Stop all chatsounds", @csclear);

void PluginInit()
{
  g_Module.ScriptInfo.SetAuthor("incognico,gvazdas");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd,https://knockout.chat/user/3022");

  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
  g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @ClientConnected);
  g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);

  ReadSounds();
  GetActivePlayerIndices();
  CheckAllVolumes();
}

void cs_command(const CCommand@ pArgs )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	print_cs(pArgs, pPlayer);
}

void print_cs(const CCommand@ pArgs, CBasePlayer@ pPlayer)
{
    g_PlayerFuncs.SayText(pPlayer, "[chatsounds] To control pitch, say trigger pitch. For example, hello 150 (normal pitch is 100)" + "\n");
    g_PlayerFuncs.SayText(pPlayer, "[chatsounds] To hide chatsounds text, add ' s'. For example, hello s or hello ? s" + "\n");
    g_PlayerFuncs.SayText(pPlayer, "[chatsounds] Other commands: .listsounds .csvolume" + "\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[chatsounds] version 2024-01-27\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "For the latest version go to https://github.com/gvazdas/svencoop\n");
}

void SetPlayerGlowColor(CBasePlayer@ pPlayer, Vector rgb)
{
  pPlayer.pev.rendercolor = rgb;
  pPlayer.pev.renderfx = kRenderFxGlowShell;
}

void TogglePlayerGlow(CBasePlayer@ pPlayer, bool toggle)
{
   if (toggle)
      pPlayer.pev.renderfx = kRenderFxGlowShell;
   else
      pPlayer.pev.renderfx = kRenderFxNone;
}

// this does not work if the audio channel is CHAN_AUTO.
// To have the ability to clear chat sounds you would have to use one of the constant audio channels
// And that means no overlapping chatsounds.
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

void csvolume_command(const CCommand@ pArgs)
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	g_EngineFuncs.ServerPrint("[chatsounds] " + string(pPlayer.pev.netname) + " csvolume console\n");
	csvolume(@pArgs, @pPlayer);
}

void csvolume(const CCommand@ pArgs, CBasePlayer@ pPlayer)
{
    const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    float volume = 1.0;

    if (pArgs.ArgC() < 2)
    {
        if (g_Volumes.exists(steamId))
           g_PlayerFuncs.SayText(pPlayer, "csvolume is " + string(float(g_Volumes[steamId])) + "\n");
        else
           g_PlayerFuncs.SayText(pPlayer, "csvolume is 1\n");
        return;
    }
    
    float volume_old = 1;
    if (g_Volumes.exists(steamId))
       volume_old = float(g_Volumes[steamId]);
        
    volume = atof(pArgs.Arg(1));
    if (volume<0)
       volume=0;
    else if (volume>1)
       volume=1;

    g_Volumes[steamId] = volume;
    g_PlayerFuncs.SayText(pPlayer, "chatsounds volume set to " + volume + "\n");
    
    if (volume<volume_old)
    {
        NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
        msg.WriteString("cl_stopsound");
        msg.End();
    }
    
    g_EngineFuncs.ServerPrint("[chatsounds] " + string(pPlayer.pev.netname) + " " + steamId + " changed csvolume to " + string(volume) + "\n");
    
    GetActivePlayerIndices();
    CheckAllVolumes();
}

void MapInit()
{
  
  //g_LatestSounds.deleteAll();
  g_ChatTimes.deleteAll();
  ReadSounds();

  for (uint i = 0; i < g_SoundListKeys.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + string(g_SoundList[g_SoundListKeys[i]]));
    g_SoundSystem.PrecacheSound(string(g_SoundList[g_SoundListKeys[i]]));
  }
  
  for (uint i = 0; i < g_soundfiles_duke.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_duke[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_duke[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_dracula.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_dracula[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_dracula[i]);
  }
  
  g_Game.PrecacheGeneric("sound/chat/up7/desperate1.wav");
  g_SoundSystem.PrecacheSound("chat/up7/desperate1.wav");
  
  g_Game.PrecacheGeneric("sound/chat/up7/desperate2.wav");
  g_SoundSystem.PrecacheSound("chat/up7/desperate2.wav");

  g_Game.PrecacheGeneric(g_SpriteName);
  g_Game.PrecacheModel(g_SpriteName);
  
  GetActivePlayerIndices();
  CheckAllVolumes();
  race_happening = false;
  
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
    
    // multi-sound triggers go here
    g_SoundListKeys.insertLast("desperate");
    g_SoundListKeys.insertLast("duke");
    g_SoundListKeys.insertLast("dracula");
    
    g_SoundListKeys.sortAsc();
  }
}

void listsounds_command(const CCommand@ pArgs)
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	listsounds(pArgs, pPlayer);
}

void listsounds(const CCommand@ pArgs, CBasePlayer@ pPlayer)
{

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

void race_prep()
{
   race_happening=true;
   arr_race_origins = array<Vector>(g_Engine.maxClients);
   arr_race_distances = array<float>(g_Engine.maxClients);
}

void race_start()
{
   race_happening=true;
   
   for (uint i = 0; i < arr_active_players.length(); i++)
   {
      uint pPlayer_index = arr_active_players[i];
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(pPlayer_index);
      arr_race_origins[pPlayer_index-1] = pPlayer.GetOrigin();
   }
}

void race_update()
{
   
   for (uint i = 0; i < arr_active_players.length(); i++)
   {
      uint pPlayer_index = arr_active_players[i];
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(pPlayer_index);
      Vector pPlayer_origin = pPlayer.GetOrigin();
      if (!pPlayer.GetObserver().IsObserver() && pPlayer.IsAlive())
      {
          float dist = pPlayer_origin.opSub(arr_race_origins[pPlayer_index-1]).Length();
          //g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, string(dist/race_updatetime) + "\n");
          if (dist/race_updatetime > race_maxspeed)
             g_EngineFuncs.ServerPrint("[chatsounds] " + string(pPlayer.pev.netname) + " is too fast " + string(dist/race_updatetime) + "\n");
          else
             arr_race_distances[pPlayer_index-1] += dist;
          //g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, string(arr_race_distances[pPlayer_index-1]) + "\n");
      }
      arr_race_origins[pPlayer_index-1] = pPlayer_origin;
   }

}

void race_end()
{
   
   if (Math.RandomLong(0,100)<10)
   {
       g_PlayerFuncs.ShowMessageAll("Directed by Speed Weed");  
   }
   
   for (uint i = 0; i < arr_active_players.length(); i++)
   {
      
      uint pPlayer_index = arr_active_players[i];
      if (arr_race_distances[pPlayer_index-1]>0)
      {
         CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(pPlayer_index);
         
         float localVol = 1.0;
         string pPlayer_steamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
 		 if (g_Volumes.exists(pPlayer_steamID))
 		   localVol = float(g_Volumes[pPlayer_steamID]);
 		
 		 if (localVol > 0)
 	     {
 	         //g_PlayerFuncs.SayText(pPlayer, "[chatsounds] Your score: " + string(int(arr_race_distances[pPlayer_index-1])) + "\n");
             g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "Your score: " + string(int(arr_race_distances[pPlayer_index-1])));
             g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[chatsounds] Your score: " + string(arr_race_distances[pPlayer_index-1]) + "\n");
         }
         
         
      }
   
   }
   
   array<float> distances_sorted = arr_race_distances;
   distances_sorted.sortDesc();
   
   g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[chatsounds] Winners:\n");
   
   int index_temp = 0;
   for (uint i_rank = 0; i_rank<2; i_rank++)
   {
   
      if ( i_rank >= arr_active_players.length() )
         break;
   
      index_temp = arr_race_distances.find(distances_sorted[i_rank]);
      if (index_temp==-1)
         continue;
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(index_temp+1);
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,"[chatsounds] #"+string(i_rank+1)+" "+string(pPlayer.pev.netname)+" "+string(int(arr_race_distances[index_temp]))+"\n");
      
      if (g_SoundList.exists("nice"))
      {
         
         float localVol = 1.0;
         string pPlayer_steamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
 		 if (g_Volumes.exists(pPlayer_steamID))
 		   localVol = float(g_Volumes[pPlayer_steamID]);
 		
 		 if (localVol > 0)
 	     {
 	        g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_MUSIC, string(g_SoundList["nice"]), localVol, 0.0f, 0, 100, pPlayer.entindex());
         }
          
      }
   
   }
   
   race_happening=false;
   
}

void print_all_chat(string msg)
{
g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,msg+"\n");
}

void print_all_hud(string msg)
{
g_PlayerFuncs.CenterPrintAll(msg);
}


HookReturnCode ClientSay(SayParameters@ pParams)
{
  const CCommand@ pArguments = pParams.GetArguments();
  const int numArgs = pArguments.ArgC();

  if (numArgs > 0) {
    
    const string soundArg = pArguments.Arg(0).ToLowercase();
    CBasePlayer@ pPlayer = pParams.GetPlayer();

    if (g_SoundList.exists(soundArg))
    {
    
      const Vector pPlayer_origin = pPlayer.GetOrigin();
      const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
 
      if (!g_ChatTimes.exists(steamId))
        g_ChatTimes[steamId] = 0.0f;

      float t = g_EngineFuncs.Time();
      float d = t - float(g_ChatTimes[steamId]);
      g_ChatTimes[steamId] = t;

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
                        
                        if (pitch < 50)
                        {
                            pitch = 50;
                            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "chatsounds minimum pitch is 50");
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
            
            string snd_file = "";
            if (soundArg=="desperate")
            {
               if (desperate)
                  snd_file = "chat/up7/desperate1.wav";
               else
                  snd_file = "chat/up7/desperate2.wav";
               desperate = !desperate;
            }
            else if (soundArg=="duke")
               snd_file = g_soundfiles_duke[uint(Math.RandomLong(0,g_soundfiles_duke.length()-1))];
            else if (soundArg=="dracula")
               snd_file = g_soundfiles_dracula[uint(Math.RandomLong(0,g_soundfiles_dracula.length()-1))];
            else
               snd_file = string(g_SoundList[soundArg]);
               
            float attenuation = 0.3f;
            bool setOrigin=true;
            SOUND_CHANNEL audio_channel = CHAN_AUTO;
            if (soundArg=="speed")
            {
               pitch = 100;
               attenuation = 0.0f;
               setOrigin = false;
               audio_channel = CHAN_MUSIC;
               if (race_happening)
                  return HOOK_HANDLED;
               race_happening = true;
            }
            
            if (soundArg == 'medic' || soundArg == 'meedic') {
              pPlayer.ShowOverheadSprite('sprites/saveme.spr', 51.0f, 5.0f);
              g_SoundSystem.PlaySound(pPlayer.edict(), audio_channel, snd_file, 1.0f, 0.2f,0, Math.RandomLong(80,120), 0, true, pPlayer.pev.origin);
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
                
                if (all_volumes_1)
                {
                   //g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, snd_file, 0.00f, 0.3f,0, pitch, 0, true, pPlayer.pev.origin);
                   // this is utterly idiotic but it's the only way I could prevent audio being cut off by the crowbar :)
                   g_SoundSystem.PlaySound(pPlayer.edict(), audio_channel, snd_file, 1.0f, attenuation, 0, pitch, 0, setOrigin, pPlayer.pev.origin);
                }
                else
                {
                	for (uint i = 0; i < arr_active_players.length(); i++)
                	{
                		
                		CBasePlayer@ plr_receiving = g_PlayerFuncs.FindPlayerByIndex(arr_active_players[i]);
                		
                		if (plr_receiving is null or !plr_receiving.IsConnected())
                		{  
                		   g_EngineFuncs.ServerPrint("ChatSounds: " + string(arr_active_players[i]) + " skipped\n");
                		   continue;
                		}
                		
                		string plr_receiving_steamId = g_EngineFuncs.GetPlayerAuthId(plr_receiving.edict());
                		
                		float localVol = 1.0;
                		if (g_Volumes.exists(plr_receiving_steamId))
                		   localVol = float(g_Volumes[plr_receiving_steamId]);
                		
                		if (localVol > 0)
                	    {
                		   //g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, snd_file, 0.00f, 0.3f, 0, pitch, plr_receiving.entindex(),true,pPlayer.pev.origin);
                           g_SoundSystem.PlaySound(pPlayer.edict(), audio_channel, snd_file,
                                                   localVol, attenuation, 0, pitch, plr_receiving.entindex(),setOrigin,pPlayer.pev.origin);
                        }
                	}
            	}
            	
            	if (soundArg == 'caramel')
            	{
            	
            	   float t_caramel_delaystart = 1.3f*(100/float(pitch));
            	   float t_caramel =  1/float(2.75)*(100/float(pitch));
            	   float t_caramel_length = 15.0f*(100/float(pitch));
            	   float caramel_distance = 700.0f;
            	   uint i_colorgroup_start = Math.RandomLong(0,g_caramel_all_groups.getSize()-1);
            	   array<Vector> colorgroup;
            	   Vector color;
            	   uint i_colorgroup;
            	   uint i_color;
            	   
            	   for (uint i = 0; i < arr_active_players.length(); i++)
                   {
                      CBasePlayer@ pPlayer_caramel = g_PlayerFuncs.FindPlayerByIndex(arr_active_players[i]);
                      if (pPlayer_caramel is null or !pPlayer_caramel.IsConnected() || pPlayer_caramel.GetObserver().IsObserver() || !pPlayer_caramel.IsAlive())
                         continue;
                      
                      Vector pPlayer_caramel_origin = pPlayer_caramel.GetOrigin();
                      float current_distance = pPlayer_origin.opSub(pPlayer_caramel_origin).Length();
                      if (current_distance <= caramel_distance)
                      {
                      
                         float t_track = t_caramel_delaystart;
                         i_colorgroup = i_colorgroup_start;
                         colorgroup = array<Vector>(g_caramel_all_groups[i_colorgroup]);
                         i_color = Math.RandomLong(0,colorgroup.length()-1);
                         color = colorgroup[i_color];
                         
                      	 g_Scheduler.SetTimeout("SetPlayerGlowColor", t_track, @pPlayer_caramel, color); 
                      	 t_track+=t_caramel;
                      	 i_colorgroup+=1;
                      	   
                      	 while (t_track<=t_caramel_length)
                      	 {
                      	     if (i_colorgroup>=g_caramel_all_groups.getSize())
                      	        i_colorgroup = 0;

                             colorgroup = array<Vector>(g_caramel_all_groups[i_colorgroup]);
                             i_color = Math.RandomLong(0,colorgroup.length()-1);
                             color = colorgroup[i_color];
                  	         g_Scheduler.SetTimeout("SetPlayerGlowColor", t_track, @pPlayer_caramel, color);
                      	   
                      	     t_track+=t_caramel;
                      	     i_colorgroup+=1;
                      	 }
                  	     g_Scheduler.SetTimeout("TogglePlayerGlow", t_track, @pPlayer_caramel, false);
                      
                      
                      }
                         
                   }
            	
            	}
            	else if (soundArg == 'speed')
            	{
            	   
            	   GetActivePlayerIndices();
            	   race_prep();
            	   float race_startdelay = 5.0f;
            	   float race_endtime = 19.0f;
            	   
            	   g_Scheduler.SetTimeout("race_start", race_startdelay);
            	   
            	   g_Scheduler.SetTimeout("print_all_chat", race_startdelay, "[chatsounds] GO!");
            	   g_Scheduler.SetTimeout("print_all_hud", race_startdelay, "GO!");
            	   
            	   g_Scheduler.SetTimeout("print_all_chat", race_startdelay-3, "[chatsounds] Race starts in 3 seconds!");
            	   g_Scheduler.SetTimeout("print_all_hud", race_startdelay-3, "Race starts in 3 seconds!");
            	   
            	   g_Scheduler.SetTimeout("print_all_chat", race_startdelay-2, "[chatsounds] Race starts in 2 seconds!");
            	   g_Scheduler.SetTimeout("print_all_hud", race_startdelay-2, "Race starts in 2 seconds!");
            	   
            	   g_Scheduler.SetTimeout("print_all_chat", race_startdelay-1, "[chatsounds] Race starts in 1 second!");
            	   g_Scheduler.SetTimeout("print_all_hud", race_startdelay-1, "Race starts in 1 second!");
            	   
            	   float t_update = race_startdelay+race_updatetime;
            	   while (t_update<race_endtime)
            	   {
            	      g_Scheduler.SetTimeout("race_update", t_update);
            	      t_update+=race_updatetime;
            	   }
            	   
            	   g_Scheduler.SetTimeout("race_end", race_endtime+race_updatetime);
            	   
            	
            	}
            	//else if (soundArg=="bug")
            	//{
            	//
            	//   float bug_distance = 800.0f;
            	//   float t_bug_delay = 0.0f;
            	//   for (uint i = 0; i < arr_active_players.length(); i++)
            	//   {
            	//      CBasePlayer@ pPlayer_bug = g_PlayerFuncs.FindPlayerByIndex(arr_active_players[i]);
                //      if (pPlayer_bug is null or !pPlayer_bug.IsConnected() || pPlayer_bug.GetObserver().IsObserver() || !pPlayer_bug.IsAlive())
                //         continue;
            	//      
            	//      if (pPlayer_origin.opSub(pPlayer_bug.GetOrigin()).Length() <= bug_distance)
            	//      {
            	//        pPlayer_bug.pev.sequence = 10;
            	//        pPlayer_bug.pev.gaitsequence = 10;
            	//        pPlayer_bug.pev.frame = 0;
            	//        //pPlayer_bug.SetAnimation(PLAYER_DIE,0);
            	//        //pPlayer_bug.StopAnimation();
            	//        //pPlayer_bug.ResetSequenceInfo();
            	//        g_PlayerFuncs.SayText(pPlayer, string(pPlayer_bug.pev.netname) + "\n");
            	//      }
            	//   }
            	//
            	//}
            	else
            	   pPlayer.ShowOverheadSprite(g_SpriteName, 56.0f, 2.25f);
            
            }

      }
      else
      {
         pParams.ShouldHide = true;
         string bees = string(Math.RandomLong(100000,999999));
         bees = bees.SubString(0,3) + " " + bees.SubString(3,3);
         g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, bees + " angry bees are coming for you");
         g_PlayerFuncs.ShowMessage(pPlayer, "and they like jazz");
         //g_AdminControl.SlapPlayer(pPlayer,0.0,0);
      }
    }
    else
    {
       if (soundArg==".cs" )
       {
          print_cs(pArguments, pPlayer);
          pParams.ShouldHide = true;
          return HOOK_HANDLED;
       }
       
       else if (soundArg==".csvolume" )
       {
          g_EngineFuncs.ServerPrint("[chatsounds] " + string(pPlayer.pev.netname) + " csvolume chat\n");
          csvolume(@pArguments, @pPlayer);
          //pParams.ShouldHide = true;
          return HOOK_HANDLED;
       }
       
       else if (soundArg==".listsounds" )
       {
          listsounds(pArguments, pPlayer);
          g_PlayerFuncs.SayText(pPlayer, "[chatsounds] See console.\n");
          pParams.ShouldHide = true;
          return HOOK_HANDLED;
       }
    }
  }
  return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
{
  GetActivePlayerIndices();
  CheckAllVolumes();
  if (race_happening)
     arr_race_distances[pPlayer.entindex()-1] = 0.0f;
  return HOOK_CONTINUE;
}

HookReturnCode ClientConnected(edict_t@ pEntity, const string& in szPlayerName,
                               const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason)
{
  GetActivePlayerIndices();
  CheckAllVolumes();
  return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
  GetActivePlayerIndices();
  CheckAllVolumes();
  if (race_happening)
  {
     arr_race_origins[pPlayer.entindex()-1] = pPlayer.GetOrigin();
     arr_race_distances[pPlayer.entindex()-1] = 0.0f;
  }
  return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
  if (race_happening)
     arr_race_origins[pPlayer.entindex()-1] = pPlayer.GetOrigin();
  return HOOK_CONTINUE;
}

HookReturnCode MapChange()
{
  g_Scheduler.ClearTimerList();
  race_happening = false;
  return HOOK_CONTINUE;
}

void GetActivePlayerIndices()
{

   arr_active_players.resize(0);
   for (int i = 1; i <= g_Engine.maxClients; i++)
   {
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
      if (pPlayer !is null && pPlayer.IsConnected() && pPlayer.IsPlayer())
        arr_active_players.insertLast(i);
         
   }

}

void CheckAllVolumes()
{

   //debug purposes only
   if (!g_Volumes.isEmpty())
   {
       array<string> g_Volumes_keys = g_Volumes.getKeys();
       for (uint i = 0; i < g_Volumes_keys.length(); ++i)
       {
          string steamid_temp = g_Volumes_keys[i];
          g_EngineFuncs.ServerPrint("[chatsounds] " + steamid_temp + " " + string(float(g_Volumes[steamid_temp])) + "\n");   
       }
   }
   
   all_volumes_1 = true;
   if (!g_Volumes.isEmpty() && arr_active_players.length()>0)
   {
      for (uint i = 0; i < arr_active_players.length(); i++)
      {
         CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(arr_active_players[i]);
         if (pPlayer is null or !pPlayer.IsConnected())
            continue;
         string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
         //g_PlayerFuncs.SayTextAll(pPlayer, string(i) + " " + string(steamId) + "\n");
         if (float(g_Volumes[steamId])<1)
         {
            all_volumes_1 = false;
            g_EngineFuncs.ServerPrint("[chatsounds] all_volumes_1 is false\n");   
            return;
         }
      }
   
   }
   g_EngineFuncs.ServerPrint("[chatsounds] all_volumes_1 is true\n");  

}