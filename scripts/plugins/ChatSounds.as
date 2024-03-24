const string g_SoundFile = "scripts/plugins/cfg/ChatSounds.txt";
const float g_Delay = 0.1f; //minimum time in seconds between chat sounds for the same player
const string g_SpriteName = 'sprites/bubble.spr';

dictionary g_SoundList;
dictionary g_ChatTimes;

array<float> arr_volumes(g_Engine.maxClients, 1.0f);

bool desperate; //deus ex meme
bool dental; //simpsons meme
bool all_volumes_1 = true; //track if all connected players .csvolume is 1
//bool payne_music = false;

// Input event type sound triggers here and how long a player must wait before they can trigger again.
// BENEFIT: these sounds will play in CHAN_STREAM, they are less likey to get cut off.
const dictionary interrupt_dict =
{
{'duke',20.0f},
{'caramel',15.0f},
{'funky',11.0f},
{'zombie',9.0f},
{'speed',20.0f},
{'isdead',3.0f},
{'chocobo',5.0f},
{'war!',10.0f},
{'hero',25.0f},
{'kickgum',17.0f},
{'vengabus',14.0f},
{'bandit',14.0f},
{'scha',15.0f},
{'onlything',13.0f},
{'godhand',13.0f},
{'dracula',7.0f},
{'wombo',8.0f},
{'tbc',11.0f},
{'wtfboom',8.0f},
{'iamthestorm',8.0f},
{'ps2',15.0f},
{'ps1',14.0f},
{'duke2',12.0f},
{'rick',10.0f},
{'rules',9.0f},
{'damedane',6.0f},
{'suicide',9.0f},
{'standing',12.0f}
};

//array for tracking when to ignore player chatsounds for certain events
array<bool> array_event(g_Engine.maxClients, false);

void pPlayer_event(CBasePlayer@ pPlayer,bool state=true)
{
    if (pPlayer.IsConnected() and pPlayer !is null)
       array_event[pPlayer.entindex()-1] = state;

} 

//nishiki timing game
bool nishiki = false;
bool nishiki_timing = false;
bool nishiki_stage = false;
array<bool> nishiki_fail(g_Engine.maxClients, false);
int nishiki_pitch;

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

const array<string> g_soundfiles_ppk =
{
"chat/up3/ppk.wav",
"chat/up9/ppk1.wav",
"chat/up9/ppk2.wav",
"chat/up9/ppk3.wav"
};

const array<string> g_soundfiles_zombiegoasts =
{
"chat/up9/zombiegoasts1.wav",
"chat/up9/zombiegoasts2.wav"
};

const array<string> g_soundfiles_funky =
{
"chat/up9/funky1.wav",
"chat/up9/funky2.wav",
"chat/up9/funky3.wav"
};

const array<string> g_soundfiles_desperate =
{
"chat/up7/desperate1.wav",
"chat/up7/desperate2.wav"
};

const array<string> g_soundfiles_dental =
{
"chat/up9/dental1.wav",
"chat/up9/dental2.wav"
};

const string g_soundfile_secret = "chat/up8/Secret.wav";
const string g_soundfile_zombie_autotune = "chat/up9/zombie_autotune.wav";

const array<string> g_soundfiles_meow =
{
"chat/up8/meow1.wav",
"chat/up8/meow2.wav",
"chat/up8/meow3.wav"
};

//All of these must have 5 seconds of intro padding before race start, and be 19.3 secs in total length.
const array<string> g_soundfiles_speed =
{
"chat/up7/speed.wav",
"chat/up7/speed2.wav",
"chat/up7/speed3.wav",
"chat/up7/speed4.wav",
"chat/up9/speed5.wav"
};

const array<string> g_soundfiles_scream =
{
"chat/scientist/scream1.wav",
"chat/scientist/scream01.wav",
"chat/scientist/scream02.wav",
"chat/scientist/scream2.wav",
"chat/scientist/scream3.wav",
"chat/scientist/scream04.wav",
"chat/scientist/scream05.wav",
"chat/scientist/scream06.wav",
"chat/scientist/scream6.wav",
"chat/scientist/scream07.wav",
"chat/scientist/scream7.wav",
"chat/scientist/scream08.wav",
"chat/scientist/scream20.wav",
"chat/scientist/scream22.wav",
"chat/scientist/scream24.wav",
"chat/scientist/scream25.wav"
//"chat/scientist/cough.wav",
//"chat/scientist/sneeze.wav"
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

/////

// Race stuff

const float race_updatetime = 0.05f; //higher number will result in less hitching.
const float race_maxspeed = 5000.0f; //if speed is higher than this, ignore it
bool race_happening = false;
array<Vector> arr_race_origins;
array<float> arr_race_distances;
array<bool> clients_ignorespeed(g_Engine.maxClients, false);

array<bool> array_imded(g_Engine.maxClients, false);



array<bool> array_sciteam(g_Engine.maxClients, false);

void set_sciteam(CBasePlayer@ pPlayer, bool state=true)
{
   array_sciteam[pPlayer.entindex()-1] = state;
}


// disables Goto script functionality during race if desired
// set to false if Goto.as is not being used.
const bool speed_disableGoto = true;

////

array<string> @g_SoundListKeys;
array<uint> arr_active_players;

////

// Caramelldansen stuff

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

////

CClientCommand g_cs("cs", "List all chatsounds console commands", @cs_command);
CClientCommand g_ListSounds("listsounds", "List all chat sounds", @listsounds_command);
CClientCommand g_CSVolume("csvolume", "Set volume (0-1) for all chat sounds", @csvolume_command);

// Credits:
// Thanks Vent Xekart, IronBar, zyiks, ngh, mumblzz, ShaunOfTheLive for testing

void PluginInit()
{
  g_Module.ScriptInfo.SetAuthor("incognico,gvazdas");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd,https://knockout.chat/user/3022");
  //incognico wrote the readsounds and listsounds functions, everything else is my own

  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
  g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
  g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @PlayerKilled);

  ReadSounds();
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
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[chatsounds] version 2024-03-23\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "For the latest version go to https://github.com/gvazdas/svencoop\n");
    //CBasePlayer@ pBot = g_PlayerFuncs.CreateBot("Dipshit"); 
    
}

void SetPlayerGlowColor(CBasePlayer@ pPlayer, Vector rgb)
{
  if (pPlayer !is null && pPlayer.IsConnected())
  {
      pPlayer.pev.rendercolor = rgb;
      pPlayer.pev.renderfx = kRenderFxGlowShell;
  }
}

void TogglePlayerGlow(CBasePlayer@ pPlayer, bool toggle)
{
   if (pPlayer !is null && pPlayer.IsConnected())
   {
       if (toggle)
          pPlayer.pev.renderfx = kRenderFxGlowShell;
       else
          pPlayer.pev.renderfx = kRenderFxNone;
   }
}

void csvolume_command(const CCommand@ pArgs)
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	csvolume(pArgs, pPlayer);
}

void csvolume(const CCommand@ pArgs, CBasePlayer@ pPlayer)
{
    
    if (pPlayer !is null && pPlayer.IsConnected() && pPlayer.IsPlayer())
    {
    
        const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        
        uint pPlayer_index = pPlayer.entindex()-1;
        float volume = arr_volumes[pPlayer_index];
    
        if (pArgs.ArgC() < 2)
        {
            g_PlayerFuncs.SayText(pPlayer, "csvolume is " + string(volume) + "\n");
            return;
        }
            
        float volume_new = atof(pArgs.Arg(1));
        if (volume_new<0)
           volume_new=0;
        else if (volume_new>1)
           volume_new=1;
    
        arr_volumes[pPlayer_index] = volume_new;
        g_PlayerFuncs.SayText(pPlayer, "csvolume is " + volume_new + "\n");
        
        if (volume_new<volume)
        {
            NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
            msg.WriteString("cl_stopsound");
            msg.End();
        }
        
        GetActivePlayerIndices();
        if (volume_new<1)
        {
           all_volumes_1=false;
        }
        else
           CheckAllVolumes();
    
    }
}

void MapInit()
{
  
  g_ChatTimes.deleteAll();
  ReadSounds();

  for (uint i = 0; i < g_SoundListKeys.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + string(g_SoundList[g_SoundListKeys[i]]));
    g_SoundSystem.PrecacheSound(string(g_SoundList[g_SoundListKeys[i]]));
  }
  
  // Code below inspired by YandereDev
  
  for (uint i = 0; i < g_soundfiles_duke.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_duke[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_duke[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_dracula.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_dracula[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_dracula[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_speed.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_speed[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_speed[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_meow.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_meow[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_meow[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_ppk.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_ppk[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_ppk[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_funky.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_funky[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_funky[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_zombiegoasts.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_zombiegoasts[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_zombiegoasts[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_scream.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_scream[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_scream[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_desperate.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_desperate[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_desperate[i]);
  }
  
  for (uint i = 0; i < g_soundfiles_dental.length(); ++i) {
    g_Game.PrecacheGeneric("sound/" + g_soundfiles_dental[i]);
    g_SoundSystem.PrecacheSound(g_soundfiles_dental[i]);
  }
  
  g_Game.PrecacheGeneric("sound/" + g_soundfile_secret);
  g_SoundSystem.PrecacheSound(g_soundfile_secret);
  
  g_Game.PrecacheGeneric("sound/" + g_soundfile_zombie_autotune);
  g_SoundSystem.PrecacheSound(g_soundfile_zombie_autotune);
  
  g_Game.PrecacheGeneric(g_SpriteName);
  g_Game.PrecacheModel(g_SpriteName);
  
  array_imded = array<bool>(g_Engine.maxClients, false);
  array_sciteam = array<bool>(g_Engine.maxClients, false);
  array_event = array<bool>(g_Engine.maxClients, false);
  nishiki_fail = array<bool>(g_Engine.maxClients, false);
  
  all_volumes_1=true;
  race_happening = false;
  nishiki = false;
  nishiki_timing = false;
  //payne_music = false;
  if (speed_disableGoto)
  {
      g_EngineFuncs.ServerCommand("as_command .goto_endrace\n");
      g_EngineFuncs.ServerExecute();
  }
  
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
    g_SoundListKeys.insertLast("speed");
    g_SoundListKeys.insertLast("meow");
    g_SoundListKeys.insertLast("funky");
    g_SoundListKeys.insertLast("zombiegoasts");
    g_SoundListKeys.insertLast("scream");
    g_SoundListKeys.insertLast("dental");
    
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

void nishiki_sweet()
{
nishiki_timing=true;
}

void nishiki_end_sweet()
{
nishiki_timing=false;
nishiki_stage=false;
}

void nishiki_end()
{
nishiki = false;
nishiki_timing=false;
}


void race_prep()
{
   race_happening=true;
   arr_race_origins = array<Vector>(g_Engine.maxClients);
   arr_race_distances = array<float>(g_Engine.maxClients, 0.0f);
   clients_ignorespeed = array<bool>(g_Engine.maxClients, false); 
}

void race_start()
{
   race_happening=true;
   if (speed_disableGoto)
   {
       g_EngineFuncs.ServerCommand("as_command .goto_startrace\n");
       g_EngineFuncs.ServerExecute();
   }
   
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
      if (!pPlayer.GetObserver().IsObserver() && pPlayer.IsAlive())
      {
          Vector pPlayer_origin = pPlayer.GetOrigin();
          float dist = pPlayer_origin.opSub(arr_race_origins[pPlayer_index-1]).Length();
          if (dist/race_updatetime > race_maxspeed)
             g_EngineFuncs.ServerPrint("[chatsounds] " + string(pPlayer.pev.netname) + " is too fast " + string(dist/race_updatetime) + "\n");
          else if (clients_ignorespeed[pPlayer_index-1])
             g_EngineFuncs.ServerPrint("[chatsounds] " + string(pPlayer.pev.netname) + " ignorespeed \n");
          else
             arr_race_distances[pPlayer_index-1] += dist;
          arr_race_origins[pPlayer_index-1] = pPlayer_origin;
          clients_ignorespeed[pPlayer_index-1]=false;
      }
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
 		   
 		 float localVol = arr_volumes[pPlayer_index-1];
 		
 		 if (localVol > 0)
 	     {
             g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTNOTIFY, "Your score: " + string(int(arr_race_distances[pPlayer_index-1])) + "\n");
             g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[chatsounds] Your score: " + string(arr_race_distances[pPlayer_index-1]) + "\n");
         }
         
         
      }
   
   }
   
   array<float> distances_sorted = arr_race_distances;
   distances_sorted.sortDesc();
   
   if (distances_sorted[0]>0)
   {
   
       g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[chatsounds] Winners:\n");
       
       int index_temp = 0;
       for (uint i_rank = 0; i_rank<3; i_rank++)
       {
       
          if ( i_rank >= arr_active_players.length() )
             break;
       
          index_temp = arr_race_distances.find(distances_sorted[i_rank]);
          if (index_temp==-1)
             continue;
          CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(index_temp+1);
          
          if (arr_race_distances[index_temp]>0)
          {
              g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[chatsounds] #"+string(i_rank+1)+" "+string(pPlayer.pev.netname)+" "+string(int(arr_race_distances[index_temp]))+"\n");
              
              if (g_SoundList.exists("nice"))
              {
         		   
         		 float localVol = arr_volumes[index_temp];
         		
         		 if (localVol > 0)
         	     {
         	        g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, string(g_SoundList["nice"]), localVol, 0.0f, 0, 100, pPlayer.entindex());
                 }
                  
              }
          }
          
        }
   
   }
   else
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,"[chatsounds] everybody lost, the end.\n");
   
   race_happening=false;
   if (speed_disableGoto)
   {
       g_EngineFuncs.ServerCommand("as_command .goto_endrace\n");
       g_EngineFuncs.ServerExecute();
   }
   
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
    
    if (pPlayer is null or !pPlayer.IsConnected())
       return HOOK_CONTINUE;

    if ( (g_SoundList.exists(soundArg) or soundArg=="secret") and (arr_volumes[pPlayer.entindex()-1]>0) )
    {
      
      // If player is being spammy with event-like sounds, interrupt them
      if (interrupt_dict.exists(soundArg) and array_event[pPlayer.entindex()-1])
      {
        pParams.ShouldHide = true;
        return HOOK_HANDLED;
      }
    
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
            float volume = 1.0f;
            bool silent_mode = false; //hide chat message if true
            bool hide_sound = false; //do not play sound if true
            bool interrupt_player = false; //exit hook prematurely if true
            
            if (numArgs > 1)
            {
              
              const string pitchArg = pArguments.Arg(1).ToLowercase();
              
              if (pitchArg=="s")
              {
                 silent_mode = true;
              }
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
                            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "chatsounds minimum pitch is 50\n");
                        }
                                          
                        else if (pitch > 255)
                        {
                            pitch = 255;
                            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "chatsounds maximum pitch is 255\n");
                        }       
                    }
                   }
              }
            }
            
            string snd_file = "";
            if (soundArg=="desperate")
            {
               if (desperate)
                  snd_file = g_soundfiles_desperate[0];
               else
                  snd_file = g_soundfiles_desperate[1];
               desperate = !desperate;
            }
            else if (soundArg=="dental")
            {
               if (dental)
                  snd_file = g_soundfiles_dental[1];
               else
                  snd_file = g_soundfiles_dental[0];
               dental = !dental;
            }
            else if (soundArg=="duke")
            {
               snd_file = g_soundfiles_duke[uint(Math.RandomLong(0,g_soundfiles_duke.length()-1))];
            }
            else if (soundArg=="dracula")
            {
               snd_file = g_soundfiles_dracula[uint(Math.RandomLong(0,g_soundfiles_dracula.length()-1))];
            }
            else if (soundArg=="speed")
            {
               snd_file = g_soundfiles_speed[uint(Math.RandomLong(0,g_soundfiles_speed.length()-1))];
            }
            else if (soundArg=="meow")
               snd_file = g_soundfiles_meow[uint(Math.RandomLong(0,g_soundfiles_meow.length()-1))];
            else if (soundArg=="secret")
               snd_file = g_soundfile_secret;
            else if (soundArg=="funky")
            {
               snd_file = g_soundfiles_funky[uint(Math.RandomLong(0,g_soundfiles_funky.length()-1))];
            }
            else if (soundArg=="zombiegoasts")
               snd_file = g_soundfiles_zombiegoasts[uint(Math.RandomLong(0,g_soundfiles_zombiegoasts.length()-1))];
            else if (soundArg=="scream")
               snd_file = g_soundfiles_scream[uint(Math.RandomLong(0,g_soundfiles_scream.length()-1))];   
            else
            {
               snd_file = string(g_SoundList[soundArg]);
            }
               
            float attenuation = 0.3f;
            bool setOrigin=true;
            SOUND_CHANNEL audio_channel = CHAN_AUTO;
            if (interrupt_dict.exists(soundArg))
            {
               audio_channel = CHAN_STREAM;
            }
            
            if (soundArg=="speed")
            {
               pitch = 100;
               attenuation = 0.0f;
               setOrigin = false;
               audio_channel = CHAN_MUSIC;
               if (race_happening or !pPlayer.IsAlive())
                  interrupt_player=true;
               
            }
            else if (soundArg=="standing")
            {
               if (!pPlayer.IsAlive())
                  interrupt_player=true;
               audio_channel = CHAN_STREAM;
            }
            else if (soundArg=="nishiki")
            {
                if (nishiki)
                  interrupt_player=true;
                else
                {
                    nishiki_fail = array<bool>(g_Engine.maxClients, false);
                    nishiki=true;
                    nishiki_pitch = pitch;
                    nishiki_timing=false;
                    nishiki_stage=true;
                    float t_nishiki_randomdelay = Math.RandomFloat(0.0f,1.0f);
                    float t_nishiki_delay = 2.31f*(100/float(pitch));
                    float t_nishiki_hold = 0.32f*(100/float(pitch));
                    float t_nishiki_total = 3.0f*(100/float(pitch));
                    
                    g_Scheduler.SetTimeout("play_sound_nishiki",t_nishiki_randomdelay,@pPlayer,pitch);
                    g_Scheduler.SetTimeout("nishiki_sweet", t_nishiki_delay+t_nishiki_randomdelay);
                    g_Scheduler.SetTimeout("nishiki_end_sweet", t_nishiki_delay+t_nishiki_hold+t_nishiki_randomdelay);
                    g_Scheduler.SetTimeout("nishiki_end", t_nishiki_total+t_nishiki_randomdelay);
                    
                    hide_sound = true;
                }
               
            }
            else if (soundArg=="pussy")
            {
               if (nishiki_timing and !nishiki_fail[pPlayer.entindex()-1])
               {
                    pitch = nishiki_pitch;
                    
                    if (pPlayer.IsAlive())
                    {
                        
                        float points = 20.0f / ( 100 / float(pitch) )**2;
                        
                        if (pPlayer.pev.health<100.0f)
                        {
                            float d_health = 100.0f-pPlayer.pev.health;
                            pPlayer.TakeHealth(points,0,100.0f);
                            points -= d_health;
                        }
                        
                        if (pPlayer.pev.armorvalue<100.0f and points>0)
                        {
                            pPlayer.TakeArmor(points/float(2),0,100.0f);
                        }
                    }
                
               }
               else if (nishiki)
               {
                   if (!nishiki_fail[pPlayer.entindex()-1])
                   {
                      if (nishiki_stage)
                         g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTNOTIFY, "Too early!\n");
                      else
                         g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTNOTIFY, "Too late!\n");
                      nishiki_fail[pPlayer.entindex()-1] = true;
                   }
                   return HOOK_HANDLED;
               }
               
            }
            
            if (interrupt_dict.exists(soundArg))
            {
               float hold_interrupt = float(interrupt_dict[soundArg])*(100.0/float(pitch));
               pPlayer_event(pPlayer,true);
               g_Scheduler.SetTimeout("pPlayer_event",hold_interrupt,@pPlayer,false);
            }
            
            if (interrupt_player)
            {
               pParams.ShouldHide = true;
               return HOOK_HANDLED;
            }
            
            if (soundArg == 'medic' || soundArg == 'meedic') {
              pPlayer.ShowOverheadSprite('sprites/saveme.spr', 51.0f, 5.0f);
              g_SoundSystem.PlaySound(pPlayer.edict(), audio_channel, snd_file, 1.0f, 0.2f,0, Math.RandomLong(80,120), 0, true, pPlayer.pev.origin);
            }
            else
            {
            
                if (numArgs > 2)
                {
                    if (pArguments.Arg(2).ToLowercase()=="s")
                       silent_mode = true;
                }
            	
            	// Players near pPlayer should join in the color cycle.
            	if (soundArg == 'caramel')
            	{
            	
            	   float t_caramel_delaystart = 1.3f*(100/float(pitch));
            	   float t_caramel =  1/float(2.75)*(100/float(pitch));
            	   float t_caramel_length = 15.0f*(100/float(pitch));
            	   float caramel_distance = 1000.0f;
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
            	
            	// Turbo charge melee speed
            	else if (soundArg == 'standing')
            	{
            	   if ( ( pPlayer.HasNamedPlayerItem("weapon_crowbar") !is null) and pPlayer.IsAlive() )
            	   {
            	   
            	     float standing_updatetime = 0.09f + Math.RandomFloat(-0.02f,0.01f);
            	     standing_updatetime *= (100/float(pitch));
            	     float standing_delay = 2.9f*(100/float(pitch));
            	     float standing_total = 11.5f*(100/float(pitch));
            	     
            	     CBasePlayerWeapon@ pPlayer_crowbar = pPlayer.HasNamedPlayerItem("weapon_crowbar").GetWeaponPtr();
            	     //CBasePlayerWeapon@ pPlayer_wrench = pPlayer.HasNamedPlayerItem("weapon_wrench").GetWeaponPtr();
            	     
            	     float temp_time = standing_delay;
            	     g_Scheduler.SetTimeout("weapon_swap",temp_time/float(2),@pPlayer,@pPlayer_crowbar); 
                     while (temp_time<=standing_total)
                     {
                        g_Scheduler.SetTimeout("crowbar_fast",temp_time,@pPlayer,@pPlayer_crowbar); 
                        temp_time += standing_updatetime;
                     }
                     g_Scheduler.SetTimeout("crowbar_end",temp_time,@pPlayer,@pPlayer_crowbar); 
            	     
            	   }
            	}
            	
            	// Start race
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
            	
            	// Make player scale glitch for a split second
            	else if (soundArg=="bug")
            	{
            	
            	   float bug_distance = 2000.0f;
            	   float t_bug_delay = 1.0f*(100/float(pitch));
            	   float t_bug_hold = 0.5f*(100/float(pitch));
            	   for (uint i = 0; i < arr_active_players.length(); i++)
            	   {
            	     CBasePlayer@ pPlayer_bug = g_PlayerFuncs.FindPlayerByIndex(arr_active_players[i]);
                     if (pPlayer_bug is null or !pPlayer_bug.IsConnected() or pPlayer_bug.GetObserver().IsObserver() or !pPlayer_bug.IsAlive())
                         continue;
            	      
            	      if (pPlayer_origin.opSub(pPlayer_bug.GetOrigin()).Length() <= bug_distance)
            	      {
            	      
            	        if (Math.RandomLong(0,1)==int32(0))
            	           g_Scheduler.SetTimeout("pPlayer_setscale",t_bug_delay,@pPlayer_bug,Math.RandomFloat(0,0.5f));
        	            else
        	               g_Scheduler.SetTimeout("pPlayer_setscale",t_bug_delay,@pPlayer_bug,Math.RandomFloat(1.5f,4.0f)); 
	        
            	        g_Scheduler.SetTimeout("pPlayer_setscale",t_bug_delay+t_bug_hold,@pPlayer_bug,1.0f); 
            	      
            	      }
            	   }
            	
            	}
            	
            	// If nearby player model is zombie, respond with hard hitting social commentary
            	else if (soundArg == 'zombie' and (g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict()).GetValue("model") != "zombie") )
            	{
            	
            	   float zombie_distance = 2000.0f;
            	   float t_zombie_delaystart = 1.0f + Math.RandomFloat(-0.2f,0.2f);
            	   t_zombie_delaystart *= (100/float(pitch));
            	   
            	   for (uint i = 0; i < arr_active_players.length(); i++)
                   {
                      CBasePlayer@ pPlayer_zombie = g_PlayerFuncs.FindPlayerByIndex(arr_active_players[i]);
                      if (pPlayer_zombie is null or !pPlayer_zombie.IsConnected() || pPlayer_zombie.GetObserver().IsObserver() || !pPlayer_zombie.IsAlive())
                         continue;
                      
                      Vector pPlayer_zombie_origin = pPlayer_zombie.GetOrigin();
                      if (pPlayer_origin.opSub(pPlayer_zombie_origin).Length() <= zombie_distance and g_EngineFuncs.GetInfoKeyBuffer(pPlayer_zombie.edict()).GetValue("model") == "zombie")
                      	 g_Scheduler.SetTimeout("play_sound_zombie",t_zombie_delaystart,@pPlayer_zombie,pitch); 
                         
                   }
            	
            	}
            	
            	// Make nearby players emit scream sounds
            	else if (soundArg == 'sciteam')
            	{
            	   
            	   if (array_sciteam[pPlayer.entindex()-1])
            	      interrupt_player=true;
            	   else
            	      set_sciteam(@pPlayer,true);
            	
            	   float scream_distance = 3000.0f;
            	   float t_scream_delaystart;
            	   float t_scream_total = 2.5f * (100/float(pitch));
            	   g_Scheduler.SetTimeout("set_sciteam",t_scream_total,@pPlayer,false); 
            	   
            	   for (uint i = 0; i < arr_active_players.length(); i++)
                   {
                      CBasePlayer@ pPlayer_scream = g_PlayerFuncs.FindPlayerByIndex(arr_active_players[i]);
                      if (pPlayer_scream is null or !pPlayer_scream.IsConnected() or pPlayer_scream.GetObserver().IsObserver() or !pPlayer_scream.IsAlive())
                         continue;
                         
                      t_scream_delaystart = 1.85f + Math.RandomFloat(-0.05f,0.2f);
                      t_scream_delaystart *= (100/float(pitch));
                      
                      Vector pPlayer_scream_origin = pPlayer_scream.GetOrigin();
                      if ( (pPlayer_origin.opSub(pPlayer_scream_origin).Length() <= scream_distance) and (i!=uint((pPlayer.entindex()-1))) )
                      	 g_Scheduler.SetTimeout("play_sound_scream",t_scream_delaystart,@pPlayer_scream,pitch); 
                         
                   }
            	
            	}
            	
            	// Make npcs around the player spin and emit pain sounds
            	//else if (soundArg == "funky" or soundArg == "speen" or soundArg == "speeen")
            	//{
            	//   
            	//   float funky_distance = 3000.0f;
            	//   
            	//   float funky_duration;
            	//   if (soundArg == "funky")
            	//      funky_duration = 11.0f;
            	//   else
            	//      funky_duration = 3.5f;
            	//   
            	//   funky_duration *= (100/float(pitch));
            	//   float funky_updatetime = 0.2f;
            	//   
            	//   for (int i = 1; i < (g_Engine.maxEntities); i++)
                //   {
                //      edict_t@ temp_edict = g_EngineFuncs.PEntityOfEntIndex(i);
                //      CBaseEntity@ pEntity = g_EntityFuncs.Instance(temp_edict);
                //      if (pEntity !is null and !pEntity.IsPlayer() and pEntity.IsAlive())
                //      {
                //            if (pPlayer_origin.opSub(pEntity.GetOrigin()).Length() <= funky_distance)
                //            {
                //            CBaseMonster@ pMonster = cast<CBaseMonster@>(pEntity);
                //            
                //            if (Math.RandomLong(0,1)==int32(0))
                //            {
                //               pMonster.pev.avelocity.y = Math.RandomFloat(500.0f,2000.0f);
                //            }
                //            else
                //            {
                //               pMonster.pev.avelocity.y = Math.RandomFloat(-500.0f,-2000.0f);
                //            }
                //            
                //            pMonster.pev.avelocity.y /= (100/float(pitch));
                //            
                //            float temp_time = funky_updatetime;
                //            while (temp_time<=funky_duration)
                //            {
                //               
                //               g_Scheduler.SetTimeout("monster_rotate",temp_time,@pMonster,pMonster.pev.avelocity.y); 
                //               temp_time += funky_updatetime;
                //               
                //            }
                //            g_Scheduler.SetTimeout("monster_restore",temp_time,@pMonster); 
                //            }
                //      }
                //   }
                //   
            	//}
            	
            	else if (soundArg == "imded" and pPlayer.IsAlive())
            	{
            	   g_Scheduler.SetTimeout("gib_player",2.0f*(100/float(pitch)),@pPlayer);
            	   if (array_imded[pPlayer.entindex()-1])
                      interrupt_player=true;
                   else
            	      array_imded[pPlayer.entindex()-1] = true; 
        	    }
            	
            	if (!silent_mode and !hide_sound and !interrupt_player)
            	   pPlayer.ShowOverheadSprite(g_SpriteName, 56.0f, 2.25f);
        	    
        	    if (!hide_sound and !interrupt_player)
                   play_sound(pPlayer,audio_channel,snd_file,volume,attenuation,pitch,setOrigin);
                
                if (silent_mode or interrupt_player)
            	   pParams.ShouldHide = true;

            
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
          //g_EngineFuncs.ServerPrint("[chatsounds] " + string(pPlayer.pev.netname) + " csvolume chat\n");
          csvolume(pArguments,pPlayer);
          pParams.ShouldHide = true;
          return HOOK_HANDLED;
       }
       
       else if (soundArg==".listsounds" )
       {
          listsounds(pArguments, pPlayer);
          g_PlayerFuncs.SayText(pPlayer, "[chatsounds] See console.\n");
          g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTNOTIFY, "See console.\n");
          pParams.ShouldHide = true;
          return HOOK_HANDLED;
       }
    }
  }
  return HOOK_CONTINUE;
}

void weapon_swap(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pPlayer_crowbar)
{
   if ( (pPlayer !is null) and (pPlayer_crowbar !is null) and pPlayer.IsAlive() )
   {
      SetPlayerGlowColor(pPlayer, Vector(100,255,255));
      if (pPlayer.m_hActiveItem.GetEntity().entindex() != pPlayer_crowbar.entindex())
      {
      pPlayer.SwitchWeapon(pPlayer_crowbar);
      }
   }
}

void crowbar_fast(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pPlayer_crowbar)
{
   if ( (pPlayer !is null) and (pPlayer_crowbar !is null) and (pPlayer.m_hActiveItem.GetEntity().entindex() == pPlayer_crowbar.entindex())  )
   {
   
      if (pPlayer.IsAlive())
      {
      pPlayer_crowbar.PrimaryAttack();
      SetPlayerGlowColor(pPlayer, Vector(100,255,255));
      }
   }
   else
      TogglePlayerGlow(pPlayer,false);
      
}

void crowbar_end(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pPlayer_crowbar)
{
   if ( (pPlayer !is null) )
   {
       TogglePlayerGlow(pPlayer,false);
       if (pPlayer.m_hActiveItem.GetEntity().entindex() == pPlayer_crowbar.entindex() and pPlayer.IsAlive() and pPlayer_crowbar !is null)
       {
           pPlayer_crowbar.m_flNextPrimaryAttack = g_EngineFuncs.Time()+0.01f;
           pPlayer_crowbar.PrimaryAttack();
       }
   
   }
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
{
  arr_volumes[pPlayer.entindex()-1] = 1.0f;
  GetActivePlayerIndices();
  CheckAllVolumes();
  pPlayer_event(pPlayer,false);
  
  if (race_happening)
     arr_race_distances[pPlayer.entindex()-1] = 0.0f;
  return HOOK_CONTINUE;
}

void pPlayer_setscale(CBasePlayer@ pPlayer, float scale = 1.0f)
{
   pPlayer.pev.scale = scale;
}

void monster_rotate(CBaseMonster@ pMonster, float avelocity_y)
{
   if (pMonster !is null && pMonster.IsAlive())
   {
       
       //g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,"\n");
       //g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,string(pMonster.pev.sequence) + "\n");
       //g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,string(pMonster.m_GaitActivity) + "\n");
       //g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,string(pMonster.m_Activity) + " " + string(pMonster.m_IdealActivity) + "\n");
       //g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,string(pMonster.m_MonsterState) + " " + string(pMonster.m_IdealMonsterState) + " " + string(pMonster.GetIdealState())  + "\n");
       //g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, string(pMonster.pev.angles.y) + " " +  string(pMonster.pev.ideal_yaw) + " " + string(pMonster.FlYawDiff()) + "\n");
       
       // pMonster.m_MonsterState == MONSTERSTATE_SCRIPT
       // pMonster.m_MonsterState=MONSTERSTATE_IDLE
       // pMonster.m_Activity=ACT_IDLE
       // MONSTERSTATE_SCRIPT
              
       if( pMonster.m_Activity==ACT_WALK or pMonster.m_Activity==ACT_RUN or pMonster.m_Activity==ACT_WALK_HURT
           or pMonster.m_Activity==ACT_RUN_HURT or pMonster.m_Activity==ACT_WALK_SCARED or pMonster.m_Activity==ACT_RUN_SCARED)
       {
           pMonster.pev.angles.y = pMonster.pev.ideal_yaw;
           pMonster.pev.avelocity.y = 0.0f;
       }
       else
       {
           pMonster.pev.avelocity.y = avelocity_y;
       }
       
       
       if (pMonster.FlYawDiff()!=0.0f)
       {
          if (Math.RandomLong(0,100) <= 50)
          {
             g_Scheduler.SetTimeout("monster_pain",Math.RandomFloat(0,0.1f),@pMonster);
          } 
          
       }
   
   }
}

void monster_restore(CBaseMonster@ pMonster)
{
   if (pMonster !is null && pMonster.IsAlive())
   {
      pMonster.pev.angles.y = pMonster.pev.ideal_yaw;
      //pMonster.pev.ideal_yaw = 0.0f;
      pMonster.pev.avelocity.y = 0.0f;
      //pMonster.m_MonsterState = MONSTERSTATE_SCRIPT;
      //pMonster.m_IdealMonsterState = MONSTERSTATE_SCRIPT;
      //pMonster.ChangeSchedule(restore_schedule);
   }
}

void monster_pain(CBaseMonster@ pMonster)
{
   if (pMonster !is null)
   {
       if (pMonster.IsAlive())
          pMonster.PainSound();
   }
}

void gib_player(CBasePlayer@ pPlayer)
{

    if (pPlayer.IsConnected() and pPlayer !is null)
    {
        g_EntityFuncs.SpawnRandomGibs(pPlayer.pev,Math.RandomLong(10,100), 1);
        if (pPlayer.IsAlive())
           g_AdminControl.KillPlayer(pPlayer,0);
    }

} 

//SetTimeout didn't work with play_sound lol idk why
void play_sound_zombie(CBasePlayer@ pPlayer,int in_pitch)
{
   if (pPlayer.IsConnected() and pPlayer !is null)
   {
       play_sound(pPlayer,CHAN_AUTO,g_soundfile_zombie_autotune,1.0f,0.3f,in_pitch,true);
       pPlayer.ShowOverheadSprite(g_SpriteName, 56.0f, 2.25f);
   }
}

void play_sound_nishiki(CBasePlayer@ pPlayer,int in_pitch)
{
   if (pPlayer.IsConnected() and pPlayer !is null)
   {
       play_sound(pPlayer,CHAN_AUTO,string(g_SoundList["nishiki"]),1.0f,0.3f,in_pitch,true);
       pPlayer.ShowOverheadSprite(g_SpriteName, 56.0f, 2.25f);
   }
}

void play_sound_scream(CBasePlayer@ pPlayer,int in_pitch)
{
   if (pPlayer.IsConnected() and pPlayer !is null)
   {
       string snd_file = g_soundfiles_scream[uint(Math.RandomLong(0,g_soundfiles_scream.length()-1))];  
       play_sound(pPlayer,CHAN_AUTO,snd_file,1.0f,0.3f,in_pitch,true);
       pPlayer.ShowOverheadSprite(g_SpriteName, 56.0f, 2.25f);
   }
}

//Emit sound centered at pPlayer
void play_sound(CBasePlayer@ pPlayer,SOUND_CHANNEL audio_channel,string snd_file,float volume=1.0f,float attenuation=0.3f,int pitch=100,bool setOrigin=true)
{

    //g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "playsound " + snd_file + "\n");
    if (all_volumes_1)
    {
       g_SoundSystem.PlaySound(pPlayer.edict(),audio_channel,snd_file,volume,attenuation,0,pitch,0,setOrigin,pPlayer.pev.origin);
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
    		
            float localVol = arr_volumes[arr_active_players[i]-1];
    		if (localVol > 0)
    	    {
    		   g_SoundSystem.PlaySound(pPlayer.edict(), audio_channel, snd_file,
                                       localVol*volume, attenuation, 0, pitch, plr_receiving.entindex(),setOrigin,pPlayer.pev.origin);
            }
    	}


    }
    
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
  GetActivePlayerIndices();
  CheckAllVolumes();
  pPlayer_event(pPlayer,false);
  if (race_happening)
  {
     arr_race_distances[pPlayer.entindex()-1] = 0.0f;
     clients_ignorespeed[pPlayer.entindex()-1]=true;
  }
  array_imded[pPlayer.entindex()-1] = false;
  array_sciteam[pPlayer.entindex()-1] = false;
  pPlayer_setscale(pPlayer);
  return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
  if (race_happening)
     clients_ignorespeed[pPlayer.entindex()-1]=true;
  
  if (pPlayer.HasNamedPlayerItem("weapon_9mmhandgun") !is null or pPlayer.HasNamedPlayerItem("weapon_glock") !is null)
  {
      play_sound(pPlayer,CHAN_AUTO,g_soundfiles_ppk[uint(Math.RandomLong(0,g_soundfiles_ppk.length()-1))],1.0f,0.3f,100,true);
  }
  
  array_imded[pPlayer.entindex()-1]=false;
  array_sciteam[pPlayer.entindex()-1] = false;
  
  return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if (race_happening)
       clients_ignorespeed[pPlayer.entindex()-1]=true;
    return HOOK_CONTINUE;
}


HookReturnCode MapChange()
{
  g_Scheduler.ClearTimerList();
  return HOOK_CONTINUE;
}

void GetActivePlayerIndices()
{
   arr_active_players.resize(0);
   for (int i = 1; i <= (g_Engine.maxClients); i++)
   {
      //g_EngineFuncs.ServerPrint("[chatsounds] GetActivePlayerIndices " + string(i) + "/" + string(g_Engine.maxClients) +"\n");
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
      if (pPlayer !is null && pPlayer.IsConnected() && pPlayer.IsPlayer())
        arr_active_players.insertLast(i);
      if (int(arr_active_players.length())>=g_PlayerFuncs.GetNumPlayers())
         break;
   }
   //g_EngineFuncs.ServerPrint("[chatsounds] in-game players: " + string(arr_active_players.length()) + "\n");   

}

void CheckAllVolumes()
{
   
   //debug (array method)
   //for (uint i = 0; i < arr_active_players.length(); i++)
   //{
   //   CBasePlayer@ pPlayer2 = g_PlayerFuncs.FindPlayerByIndex(arr_active_players[i]);
   //   float localVol2 = arr_volumes[arr_active_players[i]-1];
   //   g_EngineFuncs.ServerPrint("[chatsounds] " + string(arr_active_players[i]) + " " + pPlayer2.pev.netname + " " + string(localVol2) + "\n");   
   //}
   
   all_volumes_1 = true;
   if (arr_active_players.length()>0)
   {
      for (uint i = 0; i < arr_active_players.length(); i++)
      { 
         CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(arr_active_players[i]);
         if (pPlayer is null or !pPlayer.IsConnected())
            continue;
         //string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
         //float localVol = arr_volumes[arr_active_players[i]-1];
         if (arr_volumes[arr_active_players[i]-1]<1)
         {
            all_volumes_1 = false;
            //g_EngineFuncs.ServerPrint("[chatsounds] all_volumes_1 is false\n");   
            return;
         }
      }
   
   }
   //g_EngineFuncs.ServerPrint("[chatsounds] all_volumes_1 is true\n");  

}