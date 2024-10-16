# Quick setup
1. Copy scripts, sound and sprites folders into Sven Co-op/svencoop_addon.
2. Edit Sven Co-op/svencoop/default_plugins.txt to activate the custom scripts. An example is provided which activates all scripts in this repository.

# ChatSounds

Based on a heavily modified version by incognico
https://github.com/incognico/svencoop-plugins/blob/master/twlz/ChatSounds.as

## Syntax and custom features

trigger pitch s delay

pitch: a number between 50 and 250; controls audio pitch.

s: add this to hide the text message in chat but still play the sound.

delay: in seconds, how long to wait before emitting the sound.

Some triggers do more than just play sound files; some will randomize sounds from a preset list, others will change player glow,
a few will make nearby players emit sounds, a couple will mess with the game engine, heal players, etc. Here is a full list of these custom triggers:

random nishiki trap desperate careless dental sciteam scream petition zombie
bimbos payne speed caramel wtfboom standing bug imded hammy stalker nomatter lamour weartie mymovie doot basedcringe

## Commands
.cs

.listsounds

.csvolume

## Adding your own sound files

Go to scripts/plugins/ChatSounds.txt. Each line contains a trigger and its corresponding filepath.

Multiple filepaths can be assigned to a trigger, which will make the trigger play a random sound from all the assigned filepaths.

## Recommended audio file format

Goldsrc prefers <=22khz mono .wav audio files: they preload much faster than equivalent .mp3 or .ogg files.
For .wav, I suggest compressing the files using IMA ADPCM or GSM compression (available in Audacity).

See https://github.com/wootguy/ChatSounds for more information about audio file formats.

## Modifying script settings

An extensive control panel is provided to customize script behavior to your taste.
Open ChatSounds.as, starting at line 49 you will find settings that can be changed. Various features can be enabled or disabled by setting their flags to "true" or "false".
You will also find additional audio de-clutter and player interruption flags that are disabled by default.

# AFKManager

A heavily modified version of a script originally made by MrOats. Player activity detection is much more sensitive, reacting to player mouse movement, typing in chat.
https://github.com/MrOats/AngelScript_SC_Plugins

# Loading music

Shuffles a list of .mp3 files provided in the script file. All clients hear the same songs. Tracks change when map changes.

## Adding your own music

Add more entries to the array "music_filepaths" inside loadingmusic.as. Music files can be placed either in svencoop or svencoop_addon.

# Custom votes

Allows admin to run votes with up to 9 voting options. Top 3 results are printed when voting is over.

## Commands
.vote "Question" "Answer 1" "Answer 2" "Answer 3" ...

## Editing parameters

Edit Admin_custom_votes.as to change autopass threshold, autopass grace period, and vote time.

# RTV

Slightly modified version originally made by MrOats
https://github.com/MrOats/AngelScript_SC_Plugins/blob/master/RockTheVote.as

## Commands
rtv

nominate

# Goto

Slightly modified version of Duk0's script to integrate the chatsounds racing feature.
https://github.com/Duk0/AngelScript-SvenCoop/blob/master/plugins/Goto.as

## Commands
!goto menu

!goto player