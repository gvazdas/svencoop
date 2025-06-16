# Quick setup
1. Copy scripts, sound and sprites into svencoop_addon/.
2. Open svencoop/default_plugins.txt, add the scripts there to activate them.
An example default_plugins.txt that activates all the scripts in this repository is provided.

# ChatSounds

A heavily modified version of a script originally made by incognico and w00tguy.

https://github.com/incognico/svencoop-plugins/blob/master/twlz/ChatSounds.as

## Syntax and custom features

Watch the YouTube showcase video here:

[![YouTube showcase video](http://img.youtube.com/vi/BJFLUdxYZV0/0.jpg)](https://www.youtube.com/watch?v=BJFLUdxYZV0 "YouTube showcase video")

syntax (chat): trigger pitch s delay.

pitch (default 100): a number between 50 and 255; controls sound pitch.

s: hides overhead sprite and text message in chat but still plays the sound.

delay (default 0): in seconds, how long to wait before emitting the sound.

Some triggers do more than just play sound files;
some will randomize sounds from a preset list, others will change player glow,
a few will make nearby players emit sounds, a couple will mess with the game engine, heal players, etc.
Here is a full list of these custom triggers:

random nishiki trap desperate careless dental sciteam scream petition zombie
bimbos payne speed caramel wtfboom standing bug imded hammy stalker nomatter
lamour weartie mymovie doot basedcringe fku nou fuckbees bazinga urdead truck

## Commands (chat or console)
.cs - display chatsounds tutorial.

.csmenu page - display chatsounds menu (default page 1); .csmenu hgrunt to show only HECU sounds.

.listsounds - display chatsounds in console; .listsounds hgrunt to show only HECU sounds.

.csvolume number - set chatsounds volume between 0.0 and 1.0 (default 1.0).

.csadmin - front panel for admins. Some settings can be toggled between ON/OFF.

## Adding your own sound files

Modify scripts/plugins/ChatSounds.txt. Each line contains a trigger and its path.

Sounds can be located in svencoop/sound/ or svencoop_addon/sound/
(you should place custom content in svencoop_addon).

Multiple files can be assigned to a trigger. A random sound from all assigned files will play.

## Recommended audio file format

<=22khz mono .wav audio files are ideal; they preload much faster than equivalent quality .mp3 or .ogg files.
For .wav, I suggest compressing the files using IMA ADPCM or GSM compression (available in Audacity).
From my experience, GSM provides the best compression but some software like Discord cannot play it natively.

See https://github.com/wootguy/ChatSounds for more information about audio performance in Sven Co-op.

## Modifying script settings

A control panel is provided to customize script behavior to your taste.
Open ChatSounds.as, starting at line 18 you will find settings that can be changed.
Various features can be enabled or disabled by setting their flags to true or false.
You will also find additional audio de-clutter and player interruption flags that are disabled by default.

# AFKManager

A heavily modified version of a script originally made by MrOats.
Player mouse movement and chat messages will reset the AFK timer.

https://github.com/MrOats/AngelScript_SC_Plugins

## Commands

.respawnall - admin command to respawn all players (if there is a valid spawn point).

.reviveall - admin command to revive all players. If they die within 1 second of being revived, they are teleported to a player that is alive and revived again.

# Loading music

Shuffles a list of .mp3 files provided in the script. All clients hear the same songs. Track changes on map change.

## Adding your own music

Add more entries to the array "music_filepaths" inside loadingmusic.as.
Music files can be located in svencoop/ or svencoop_addon/ (you should place custom content in svencoop_addon). 

# Custom votes

Allows admin to run votes with up to 9 voting options. Top 3 results are printed when voting is over.

## Commands (console)
.vote "Question" "Answer 1" "Answer 2" "Answer 3" ...

## Editing parameters

Edit Admin_custom_votes.as to change autopass threshold (75%), autopass grace period (3 seconds), vote time (30 seconds).

# RTV

Slightly modified version of a script originally credited to MrOats.
Fixed some bugs, added fvox countdown sounds. Votes can end prematurely if a threshold of players is met.

https://github.com/MrOats/AngelScript_SC_Plugins/blob/master/RockTheVote.as

## Commands (chat)
rtv

nominate

# Goto

Slightly modified version of Duk0's script to integrate the chatsounds speed (i.e. racing) feature.

https://github.com/Duk0/AngelScript-SvenCoop/blob/master/plugins/Goto.as

## Commands (chat)
!goto menu

!goto player