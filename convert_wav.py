import os
import sys
from pydub import AudioSegment
import traceback
import collections
sys.path.append('.')

## Converts mp3,ogg,wav audio files to 16bit 22khz mono wav

delete_old = True #delete succesfully converted files in original sound folder
base_path = "sound\\"
new_path = "sound_new\\"
file_chatsounds = "ChatSounds.txt"
file_chatsounds_new = "ChatSounds_new.txt"

with open(file_chatsounds, 'r', encoding='UTF-8') as file: lines = [line.rstrip() for line in file]
# extensions = []
filepaths = []
triggers=[]
lines_unmodified=[]
for line in lines:
    if len(line) > 0:
        trigger, path = line.split(" ")
        split_folders = path.split("/")
        first_dir = split_folders[0]
        temp_file = split_folders[-1]
        if first_dir == "chat":
            #custom sounds - add to list of files to process
            filepaths.append(path.replace("/", "\\"))
            triggers.append([trigger])
        else:
            #sound probably comes with sven coop, change nothing
            lines_unmodified.append(line)
            
            
        # print(line, end=' ')
        # print(line.split('.')[1])
        # extension = line.split('.')[1]
        # extensions.append(extension)
# extensions = set(extensions)
# print(extensions)

with open(file_chatsounds_new, "w") as outfile: outfile.write("\n".join(lines_unmodified))

new_chatsounds = []
for i_f,f_input in enumerate(filepaths):
    print(f_input)
    
    temp_split = f_input.split("\\")
    temp_filename = temp_split[-1]
    temp_dirs = "\\".join(temp_split[:-1])
    
    temp_name, temp_filetype = temp_filename.split(".")
    
    f_output = new_path + temp_dirs + "\\" + temp_name + ".wav"
    f_output_nosound = temp_dirs + "\\" + temp_name + ".wav"
    f_input = base_path + f_input
    
    fail=False
    try:
        
        if temp_filetype =="mp3": sound = AudioSegment.from_mp3(f_input)
        elif temp_filetype =="ogg": sound = AudioSegment.from_ogg(f_input)
        elif temp_filetype =="wav": sound = AudioSegment.from_wav(f_input)
        else: raise ValueError("unexpected filetype", temp_filetype)
        
        sound.set_channels(1)
        sound = sound.set_frame_rate(22050)                
        sound = sound.set_channels(1)    
        sound = sound.set_sample_width(2)
        
        temp_full_dir = new_path + "\\" + temp_dirs
        if not os.path.exists(temp_full_dir): os.makedirs(temp_full_dir,exist_ok=True)
        sound.export(f_output,format="wav")

    except:
        fail=True
        print(traceback.format_exc())
        try: os.remove(f_output)
        except: continue
    
    if not fail:
        trigger = triggers[i_f][0]
        chatsounds_line = trigger + " " + f_output_nosound.replace("\\", "/")
        with open(file_chatsounds_new, 'a') as file: file.write("\n"+chatsounds_line)
        if delete_old: os.remove(f_input)

#Check for duplicate triggers
with open(file_chatsounds_new, 'r', encoding='UTF-8') as file: lines = [line.rstrip() for line in file]
triggers_final = []
for line in lines:
    if len(line) > 0:
        trigger, path = line.split(" ")
        triggers_final.append(trigger)
print("\nDuplicate triggers:")
print([item for item, count in collections.Counter(triggers_final).items() if count > 1])