# Quick setup
1. Copy scripts, sound and sprites folders into svencoop_addon/.
2. Open svencoop/default_plugins.txt, add the scripts there to activate them.
An example default_plugins.txt that activates all the scripts in this repository is provided.

# ChatSounds

A heavily modified version of a script originally made by incognico and w00tguy.

https://github.com/incognico/svencoop-plugins/blob/master/twlz/ChatSounds.as

## Syntax and custom features

Watch the YouTube showcase video here:

[![YouTube showcase video](http://img.youtube.com/vi/BJFLUdxYZV0/0.jpg)](https://www.youtube.com/watch?v=BJFLUdxYZV0 "YouTube showcase video")

syntax: trigger pitch s delay.

pitch: a number between 50 and 255; controls sound pitch.

s: hides overhead sprite and text message in chat but still plays the sound.

delay: in seconds, how long to wait before emitting the sound.

Some triggers do more than just play sound files;
some will randomize sounds from a preset list, others will change player glow,
a few will make nearby players emit sounds, a couple will mess with the game engine, heal players, etc.
Here is a full list of these custom triggers:

random nishiki trap desperate careless dental sciteam scream petition zombie
bimbos payne speed caramel wtfboom standing bug imded hammy stalker nomatter
lamour weartie mymovie doot basedcringe fku nou fuckbees

## Commands (chat or console)
.cs - display chatsounds tutorial.

.csmenu - display chatsounds in a menu.

.listsounds - display chatsounds in console.

.csvolume - set chatsounds volume.

## Adding your own sound files

Go to scripts/plugins/ChatSounds.txt.
Each line contains a trigger and its corresponding filepath.
Sounds can be located in either svencoop/sound/ or svencoop_addon/sound/
(you should place custom content in svencoop_addon).

Multiple files can be assigned to a trigger. A random sound from all assigned files will play.

## Recommended audio file format

For goldsrc, <=22khz mono .wav audio is ideal; it preloads much faster than equivalent quality .mp3 or .ogg files.
For .wav, I suggest compressing the files using IMA ADPCM or GSM compression (available in Audacity).
From my experience, GSM provides the best compression but some software like Discord cannot play it natively.

See https://github.com/wootguy/ChatSounds for more information about audio files in Sven Co-op and performance.

## Modifying script settings

A control panel is provided to customize script behavior to your taste.
Open ChatSounds.as, starting at line 15 you will find settings that can be changed.
Various features can be enabled or disabled by setting their flags to true or false.
You will also find additional audio de-clutter and player interruption flags that are disabled by default.

# AFKManager

A heavily modified version of a script originally made by MrOats.
Player activity detection is expanded: player mouse movement and typing in chat is detected.

https://github.com/MrOats/AngelScript_SC_Plugins

# Loading music

Shuffles a list of .mp3 files provided in the script. All clients hear the same songs. Track changes on map change.

## Adding your own music

Add more entries to the array "music_filepaths" inside loadingmusic.as.
Music files can be located either in svencoop or svencoop_addon. The latter is recommended for custom sounds.

# Custom votes

Allows admin to run votes with up to 9 voting options. Top 3 results are printed when voting is over.

## Commands (console)
.vote "Question" "Answer 1" "Answer 2" "Answer 3" ...

## Editing parameters

Edit Admin_custom_votes.as to change autopass threshold, autopass grace period, and vote time.

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