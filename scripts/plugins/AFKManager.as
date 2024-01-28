/*
Copyright (c) 2017 Drake "MrOats" Denston
Updated 2024 by gvazdas:
1) Added memory retention of client AFK time after map change
2) Player activity is detected with chat messages, movement, weapon firing, sprays and mouse movement
3) Players are no longer gibbed on respawn after coming back from AFK

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

/*
Current Status: Unstable/Under Development, report bugs on forums.
Documentation: https://github.com/MrOats/AngelScript_SC_Plugins/wiki/AFKManager.as
*/

const string g_warningsound = "vox/woop.wav";
array<int> g_WarnIntervals_Sub;
CClientCommand g_afk("afk", "Print version", @afk_command);
CClientCommand g_respawnall("respawnall", "Lets admin respawn all players", @respawnall, ConCommandFlag::AdminOnly);

void PluginInit()
{

  g_Module.ScriptInfo.SetAuthor("MrOats,gvazdas");
  g_Module.ScriptInfo.SetContactInfo("http://forums.svencoop.com/showthread.php/44666-Plugin-AFK-Manager,https://knockout.chat/user/3022");
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
  g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack);
  g_Hooks.RegisterHook(Hooks::Weapon::WeaponSecondaryAttack, @WeaponPrimaryAttack);
  g_Hooks.RegisterHook(Hooks::Weapon::WeaponTertiaryAttack, @WeaponPrimaryAttack);
  g_Hooks.RegisterHook(Hooks::Player::PlayerPreDecal, @PlayerPreDecal);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  g_Hooks.RegisterHook(Hooks::Player::PlayerEnteredObserver, PlayerEnteredObserver);
  g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, PlayerKilled);
  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);

  @g_ShouldSpec = CCVar("bShouldSpec", true, "Should player be moved to spectate for being AFK?", ConCommandFlag::AdminOnly);
  @g_SecondsUntilSpec = CCVar("secondsUntilSpec", 120, "Seconds until player should be moved to Spectate for AFK", ConCommandFlag::AdminOnly);
  @g_ShouldKick = CCVar("bShouldKick", true, "Should player be kicked for being AFK?", ConCommandFlag::AdminOnly);
  @g_SecondsUntilKick = CCVar("secondsUntilKick", 1800, "Seconds until player is kicked for AFK", ConCommandFlag::AdminOnly);
  @g_KickAdmins = CCVar("bKickAdmins", false, "Should admins/owners be kicked for being AFK?", ConCommandFlag::AdminOnly);
  @g_WarnInterval = CCVar("secondsWarnInterval", 40, "How many seconds between AFK warnings", ConCommandFlag::AdminOnly);

}

dictionary g_ActivityList;
dictionary g_SecondsTracker;

void respawnall(const CCommand@ pArgs)
{
   g_PlayerFuncs.RespawnAllPlayers(false,true);
}

void afk_command(const CCommand@ pArgs)
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	afk(@pArgs, @pPlayer);
}

void afk(const CCommand@ pArgs, CBasePlayer@ pPlayer)
{
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[AFK] version 2024-01-27\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "For the latest version go to https://github.com/gvazdas/svencoop\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "For the latest version go to https://github.com/gvazdas/svencoop\n");
    
    //CBasePlayer@ pBot = g_PlayerFuncs.CreateBot("Dipshit");
    
}

final class AFK_Data
{

  private Vector m_lastAngle;
  private float m_lastMove;
  private bool m_isAdmin = false;
  private int m_secondsLastWarn = 0;
  private int m_secondsAFK=0;
  private CBasePlayer@ m_pPlayer;
  private string m_szPlayerName = "";
  private string m_szSteamID = "";
  private Status m_afkstatus;
  private bool m_justStarted = true;
  private int secondsUntilSpec = g_SecondsUntilSpec.GetInt();
  private int secondsUntilKick = g_SecondsUntilKick.GetInt();

  private CScheduledFunction@ initTimer = null;

  //AFK Data Properties
  
  bool isAdmin 
  {
    get const { return m_isAdmin; }
    set { m_isAdmin = value; }
  }
  
  bool justStarted 
  {
    get const { return m_justStarted; }
    set { m_justStarted = value; }
  }
  
  Vector lastAngle
  {
    get const { return m_lastAngle; }
    set { m_lastAngle = value; }
  }
  
  float lastMove
  {
    get const { return m_lastMove; }
    set { m_lastMove = value; }
  }
  
  int secondsAFK
  {
    get const { return m_secondsAFK; }
    set { m_secondsAFK = value; }
  }
  
  int secondsLastWarn
  {
    get const { return m_secondsLastWarn; }
    set { m_secondsLastWarn = value; }
  }
  CBasePlayer@ pPlayer
  {
    get const { return m_pPlayer; }
    set { @m_pPlayer = value; }
  }
  string szSteamID
  {
    get const { return m_szSteamID; }
  }
  string szPlayerName
  {
    get const { return m_szPlayerName; }
  }
  Status afkstatus
  {
    get const { return m_afkstatus; }
    set { m_afkstatus = value; }
  }


  //AFK Data Functions

  void ClearInitTimer()
  {
    g_Scheduler.RemoveTimer(@initTimer);
    @initTimer = null;
  }

  void Initiate()
  {
    g_ActivityList[szSteamID] = false;
    UpdateLastMove();
    UpdateLastAngle();
    @initTimer = g_Scheduler.SetInterval(this, "CheckAFK", 1, g_Scheduler.REPEAT_INFINITE_TIMES);
  }
  
  void UpdateLastAngle()
  {
   lastAngle = pPlayer.GetAutoaimVector(0.0f);
  }

  void UpdateLastMove()
  {
   lastMove = pPlayer.m_flLastMove;
  }

  bool CheckPlayerActive()
  {
      
    bool playerActive=false;
    while (!playerActive)
    {
        
          if (lastMove != pPlayer.m_flLastMove)
          {
            //MessageWarnPlayer(pPlayer, "movement");
            playerActive=true;
            break;
          }
          
          if (g_ActivityList.exists(szSteamID))
          {
             playerActive = bool(g_ActivityList[szSteamID]);
             if (playerActive)
             {
                //MessageWarnPlayer(pPlayer, "activity list");
                break;
             }
          }
          
          //if not spectating, check changes in view angle as well
          //checking for juststarted flag to ignore consistent angle change when a player connects and spawns
          //if (!pPlayer.GetObserver().IsObserver() && !justStarted)
          if (!justStarted)
          {
              float angle_diff = lastAngle.opSub(pPlayer.GetAutoaimVector(0.0f)).Length();
              //MessageWarnPlayer(pPlayer, "angle " + string(angle_diff) + "\n");
              if (angle_diff>0.1)
              {
                 //MessageWarnPlayer(pPlayer, "angle " + string(angle_diff) + "\n");
                 playerActive=true;
                 break;
              }
          }
          
          break;
        
    }
    
     return playerActive;

   }

   void CheckAFK()
   {
   
        if ( (pPlayer !is null) && (pPlayer.IsConnected()) )
        {
          
          bool playerActive = CheckPlayerActive();
          bool playerObserving = pPlayer.GetObserver().IsObserver();
          bool sub_interval = false;
          
          // Player is active
          if (playerActive)
          {
            
            justStarted=false;
            secondsAFK=0;
            secondsLastWarn=0;
            g_SecondsTracker[szSteamID] = secondsAFK;
            afkstatus = NOTAFK;
            
            if (playerObserving)
            {
              pPlayer.m_flRespawnDelayTime = 0;
              pPlayer.pev.nextthink = g_Engine.time;
              g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "");
            }
          
          }
          
          // Player is not active
          else
          {
            
            if (playerObserving)
               afkstatus=AFKSPEC;
            else
               afkstatus=AFKALIVE;
            
            secondsAFK+=1;
            g_SecondsTracker[szSteamID] = secondsAFK;
            secondsLastWarn+=1;
            if (g_ShouldKick.GetBool())
            {
               secondsUntilKick = g_SecondsUntilKick.GetInt()-secondsAFK;
               
                if (secondsUntilKick < g_WarnInterval.GetInt())
                {
                    if (g_WarnIntervals_Sub.find(secondsUntilKick)!=-1)
                       sub_interval=true;
                }
            }
            
            //If not observing, and should be observing: force observe
            if ( afkstatus!=AFKSPEC && g_ShouldSpec.GetBool())
            {
              
              secondsUntilSpec = g_SecondsUntilSpec.GetInt()-secondsAFK;
              if (secondsUntilSpec < g_WarnInterval.GetInt())
              {
                  if (g_WarnIntervals_Sub.find(secondsUntilSpec)!=-1)
                     sub_interval=true;
              }
              
              if (secondsUntilSpec<=0)
              {
                
                g_AdminControl.KillPlayer(pPlayer, 0);
                MoveToSpectate();
                MessageWarnAllPlayers(pPlayer, (szPlayerName) + " is AFK.");
                secondsLastWarn = 0;
                
                if (g_ShouldKick.GetBool() && (g_KickAdmins.GetBool() || !isAdmin))
                {
                    MessageWarnPlayer(pPlayer, GetStringTimeAuto(secondsUntilKick) + " until you are kicked.");
                    
                    //If they're about to be kicked, give them 20 seconds to do something
                    if (secondsUntilKick<=20)
                    {
                       secondsLastWarn=g_WarnInterval.GetInt();
                       secondsAFK=g_SecondsUntilKick.GetInt()-20;
                    }
                }
        
              }
              else if (secondsLastWarn >= g_WarnInterval.GetInt() || secondsUntilSpec<=3 || sub_interval)
              {
                MessageWarnPlayer(pPlayer, GetStringTimeAuto(secondsUntilSpec) + " until you become a spectator.");
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, GetStringTimeAuto(secondsUntilSpec) + " until you become a spectator.");
                if (secondsUntilSpec<=3 || sub_interval)
                   g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, g_warningsound, 1.0f, 0.0f, 0, 100, pPlayer.entindex());
                secondsLastWarn = 0;
              }
        
            
            }
            // Check for kick conditions
            else if (g_ShouldKick.GetBool() && (g_KickAdmins.GetBool() || !isAdmin))
            {
              
                 if (secondsUntilKick<=0)
                 {
                     MessageWarnAllPlayers(pPlayer, (szPlayerName) + " was kicked.");
                     g_SecondsTracker[szSteamID] = 0;
                     secondsAFK=0;
                     g_EngineFuncs.ServerCommand("kick #" + szSteamID + "  You were AFK for too long." + "\n");
                 }
                 else if (secondsLastWarn >= g_WarnInterval.GetInt() || secondsUntilKick<=3 || sub_interval)
                 {
                   MessageWarnPlayer(pPlayer, GetStringTimeAuto(secondsUntilKick) + " until you are kicked.");
                   if (secondsUntilKick<=3 || sub_interval)
                      g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, g_warningsound, 1.0f, 0.0f, 0, 100, pPlayer.entindex());
                   secondsLastWarn = 0;
                 }
            
            }
            
            if (afkstatus==AFKSPEC && g_ShouldSpec.GetBool())
              g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, GetActionText());
          
          }
          
          g_ActivityList[szSteamID] = false;
          UpdateLastMove();
          UpdateLastAngle();
        
        }
        else
        {
           ClearInitTimer();
        }
   
   
   }
   
  
  string GetActionText()
  {
      if (justStarted)
         return "To respawn, move around.";
      return "To respawn, move or look around.";
  }


  void MoveToSpectate()
  {
    afkstatus = AFKSPEC;
    pPlayer.m_flRespawnDelayTime = Math.FLOAT_MAX;
    pPlayer.GetObserver().StartObserver( pPlayer.GetOrigin(), pPlayer.pev.angles, false);
    pPlayer.pev.nextthink = Math.FLOAT_MAX;
    g_Scheduler.SetTimeout("SetRespawnTime", 0.75f, @pPlayer);
  }

  //Constructor

  AFK_Data(CBasePlayer@ pPlr)
  {

    @m_pPlayer = pPlr;
    m_szSteamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
    m_szPlayerName = pPlayer.pev.netname;
    m_lastMove = pPlayer.m_flLastMove;
    m_justStarted = true;
    m_isAdmin = bool(g_PlayerFuncs.AdminLevel(pPlayer) >= ADMIN_YES);
    
    if (g_SecondsTracker.exists(m_szSteamID))
       m_secondsAFK = int(g_SecondsTracker[m_szSteamID]);
    else
       m_secondsAFK  = 0;
    
    if (m_secondsAFK<0)
       m_secondsAFK = 0;
    
    m_secondsLastWarn = 0;
    
    if (g_ShouldSpec.GetBool() && m_secondsAFK>=g_SecondsUntilSpec.GetInt())
    {
       MoveToSpectate();
       m_afkstatus = AFKSPEC;
    }
    else
       m_afkstatus = NOTAFK;

  }

  //Adding a default constructor for the SetInterval @ Initiate();
  AFK_Data()
  {
  
  }

}

//Global Vars

array<AFK_Data@> afk_plr_data;

CCVar@ g_ShouldSpec;
CCVar@ g_SecondsUntilSpec;
CCVar@ g_ShouldKick;
CCVar@ g_SecondsUntilKick;
CCVar@ g_KickAdmins;
CCVar@ g_WarnInterval;

enum Status
{
  NOTAFK,
  AFKALIVE,
  AFKSPEC
}

void MapInit()
{
  g_Game.PrecacheGeneric("sound/" + g_warningsound);
  g_SoundSystem.PrecacheSound(g_warningsound);
  
  g_WarnIntervals_Sub.resize(0);
  int temp_interval = g_WarnInterval.GetInt();
  while (temp_interval > 3)
  {
     temp_interval = int(temp_interval/2);
     if (temp_interval <=3)
        break;
     g_WarnIntervals_Sub.insertLast(temp_interval);
  }
  
}

void MapActivate()
{
  g_ActivityList.deleteAll();
  afk_plr_data.resize(g_Engine.maxClients);
  for (uint i = 0; i < afk_plr_data.length(); i++)
     @afk_plr_data[i] = null;
}

HookReturnCode ClientSay(SayParameters@ pParams)
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    g_ActivityList[steamId]=true;
    
    const CCommand@ pArguments = pParams.GetArguments();
    const int numArgs = pArguments.ArgC();
    
    if (numArgs > 0)
    {
        
        const string firstArg = pArguments.Arg(0).ToLowercase();
    
        if (firstArg==".afk")
        {
           afk(@pArguments, @pPlayer);
           g_PlayerFuncs.SayText(pPlayer, "[AFK] See console.\n");
           pParams.ShouldHide = true;
           return HOOK_HANDLED;
        }
    
    }
    
    return HOOK_CONTINUE;
}

HookReturnCode PlayerPreDecal(CBasePlayer@ pPlayer, const TraceResult& in in1, bool& out in2)
{
    const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    g_ActivityList[steamId]=true;
    return HOOK_CONTINUE;
}

HookReturnCode WeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWep)
{
    const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    g_ActivityList[steamId]=true;
    return HOOK_CONTINUE;
}

HookReturnCode WeaponSecondaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWep)
{
    const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    g_ActivityList[steamId]=true;
    return HOOK_CONTINUE;
}

HookReturnCode WeaponTertiaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWep)
{
    const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    g_ActivityList[steamId]=true;
    return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{

  if (g_ShouldSpec.GetBool() || g_ShouldKick.GetBool())
  {

    AFK_Data@ afkdataobj = AFK_Data(pPlayer);
    @afk_plr_data[pPlayer.entindex() - 1] = @afkdataobj;
    afkdataobj.Initiate();
    
    if (afkdataobj.secondsAFK>=g_SecondsUntilSpec.GetInt() && g_ShouldSpec.GetBool())
      afkdataobj.MoveToSpectate();
    
    if (g_ShouldKick.GetBool())
    {
        if (afkdataobj.secondsAFK>=(g_SecondsUntilKick.GetInt()-20))
          afkdataobj.secondsAFK=g_SecondsUntilKick.GetInt()-20;
    }

  }
  
  return HOOK_CONTINUE;

}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{

  if (g_ShouldSpec.GetBool())
  {
  
      AFK_Data@ afkdataobj = @afk_plr_data[pPlayer.entindex() - 1];
    
      if (afkdataobj !is null && pPlayer.IsConnected())
      {
        string steamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        if (g_SecondsTracker.exists(steamID))
        {
            if (int(g_SecondsTracker[steamID])>=g_SecondsUntilSpec.GetInt())
                 afkdataobj.MoveToSpectate();
            else
               g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "");
        }
      }
  
  }
  
  return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
{
  AFK_Data@ afkdataobj = @afk_plr_data[pPlayer.entindex() - 1];
  afkdataobj.ClearInitTimer();
  @afkdataobj = null;
  return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pEnt, int temp_int)
{
    
    if (g_ShouldSpec.GetBool())
    {
        string steamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        if (g_SecondsTracker.exists(steamID))
        {
            if (int(g_SecondsTracker[steamID])>=g_SecondsUntilSpec.GetInt())
                 pPlayer.m_flRespawnDelayTime = Math.FLOAT_MAX;
        }
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerEnteredObserver(CBasePlayer@ pPlayer)
{
    
    if (g_ShouldSpec.GetBool())
    {
        string steamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        if (g_SecondsTracker.exists(steamID))
        {
            if (int(g_SecondsTracker[steamID])>=g_SecondsUntilSpec.GetInt())
                 pPlayer.m_flRespawnDelayTime = Math.FLOAT_MAX;
        }
    
    }

    return HOOK_CONTINUE;   
    
}

HookReturnCode MapChange()
{
  g_ActivityList.deleteAll();
  for (uint i = 0; i < afk_plr_data.length(); i++)
  {
    if (afk_plr_data[i] !is null)
      afk_plr_data[i].ClearInitTimer();
  }
  //g_Scheduler.ClearTimerList();
  return HOOK_CONTINUE;
}

void MessageWarnPlayer(CBasePlayer@ pPlayer, string msg)
{
   g_PlayerFuncs.SayText(pPlayer, "[AFK] " + msg + "\n");
}

string GetStringTimeAuto(int seconds)
{
    
    string final_str = "second";
    string multiple_str = "s";
    int final_time = int(seconds);

    if (final_time >= 120)
    {
       
       final_time = int(seconds/60);
       final_str = "minute";
       
       if (final_time >= 120)
       {
         final_time = int(seconds/3600);
         final_str = "hour";
       }
    
    }
    
    if (final_time==1)
       multiple_str = "";

  return string(final_time) + " " + final_str + multiple_str;
  
}

void MessageWarnAllPlayers(CBasePlayer@ pPlayer, string msg)
{
  g_PlayerFuncs.SayTextAll(pPlayer, "[AFK] " + msg + "\n");
  g_EngineFuncs.ServerPrint("[AFK] " + msg + "\n");
}

void SetRespawnTime(CBasePlayer@ pPlayer)
{
  pPlayer.m_flRespawnDelayTime = Math.FLOAT_MAX;
  return;
}