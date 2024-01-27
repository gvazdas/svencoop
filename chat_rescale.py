import os
import sys
from pydub import AudioSegment
sys.path.append('.')
import numpy as np
from scipy.io.wavfile import read
# import matplotlib.pyplot as plt

## Rescales .wav files to rms target

rms_target = 7000
mean_target = 7000

def get_filepaths(extension, target="", scan_subdirectories=True):

    #Return a list of full filepaths for given target.
    #The target can be empty, a folder or a .h5 file.
    #Scan can include sub-directories."
    
    if not("." in extension): extension = "." + extension
    extension = extension.lower()

    if target is None: target = os.getcwd()
    elif len(target) < 1: target = os.getcwd()
    elif target[-len(extension):] == extension: return [target] 
    elif "\\" not in target: target = os.getcwd() + "\\" + target

    folders_stack = [target]
    file_paths = []
    while len(folders_stack)>0:
        temp_folder = folders_stack.pop(0)
        for obj in os.scandir(temp_folder):
            full_path = str(obj.path)
            if obj.is_dir() and scan_subdirectories: folders_stack.append(full_path)
            elif full_path.lower().endswith(extension): file_paths.append(full_path)

    return file_paths

filepaths = get_filepaths(".wav")
for i_f,f_input in enumerate(filepaths):
    
    temp_split = f_input.split("\\")
    temp_filename = temp_split[-1]
    temp_dirs = "\\".join(temp_split[:-1])
    
    temp_name, temp_filetype = temp_filename.split(".")

    if temp_filetype =="mp3": sound = AudioSegment.from_mp3(f_input)
    elif temp_filetype =="ogg": sound = AudioSegment.from_ogg(f_input)
    elif temp_filetype =="wav": sound = AudioSegment.from_wav(f_input)
    else: raise ValueError("unexpected filetype", temp_filetype)
    
    sound.set_channels(1)
    sound = sound.set_frame_rate(22050)                
    sound = sound.set_channels(1)    
    sound = sound.set_sample_width(2)
    
    print("\n", f_input, sep='')
    print("max_dBFS:", sound.max_dBFS)
    print("max_possible_amplitude:", sound.max_possible_amplitude)
    print("max:", sound.max)
    print(sound.dBFS)
    print("rms:", sound.rms)
    
    input_data = read(f_input)
    audio = np.abs(input_data[1])
    quiet_thresh = np.max(audio)/10
    # print("quiet_thresh", quiet_thresh)
    mean = np.mean(audio[audio>quiet_thresh])
    print("mean:", mean)
    gain_mean = 20*np.log10(mean_target/mean)
    
    gain_rms = 20*np.log10(rms_target/sound.rms)
    gain_amp = 20*np.log10((sound.max_possible_amplitude-1)/sound.max)
    gain_dbfs = -sound.max_dBFS

    print("gain_rms",gain_rms)    
    print("gain_amp",gain_amp)  
    print("gain_dbfs",gain_dbfs)  
    print("gain_mean",gain_mean)  

    gain = np.min([gain_rms,gain_amp,gain_dbfs,gain_mean])
    
    sound = sound.apply_gain(gain)
    print("max after Gain:", sound.max)
    print("rms after Gain:", sound.rms)
    
    filepath_new = f_input.replace("chat", "chat_renormalized")
    temp_dirs_new = temp_dirs.replace("chat", "chat_renormalized")
    
    if not os.path.exists(temp_dirs_new): os.makedirs(temp_dirs_new,exist_ok=True)
    sound.export(filepath_new,format="wav")
    
    input_data = read(filepath_new)
    audio = np.abs(input_data[1])
    quiet_thresh = np.max(audio)/10
    # print("quiet_thresh", quiet_thresh)
    mean = np.mean(audio[audio>quiet_thresh])
    print("mean after Gain:", mean)
    
    # if f_input.endswith("mymovie.wav"): 
        # asdf
        # plt.figure()
        # plt.plot(audio)
        # audio_filtered = audio.copy()
        # audio_filtered[audio_filtered<=quiet_thresh]=0
        # plt.plot(audio_filtered, color='red')
        # asdf