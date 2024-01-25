import os

def get_bsp_files(target="svencoop_addon//maps", scan_subdirectories=False):

    if target is None: target = os.getcwd() #if target is empty, set target to local directory
    elif len(target) < 1: target = os.getcwd() #if target is empty, set target to local directory
    elif target[-4:] == ".bsp": return [target] #if target is .h5, use it
    elif "\\" not in target: target = os.getcwd() + "\\" + target #if target is not formatted as a directory, assume it to be inside the local directory

    folders_stack = [target]
    file_paths = []
    while len(folders_stack)>0:
        temp_folder = folders_stack.pop(0)
        for obj in os.scandir(temp_folder):
            full_path = obj.path
            if obj.is_dir() and scan_subdirectories: folders_stack.append(full_path)
            elif full_path.endswith('.bsp'):
                file_no_bsp = os.path.basename(full_path).replace(".bsp","")
                file_paths.append(file_no_bsp)

    return file_paths

bsp_list = get_bsp_files()
bsp_list.sort()

with open('maplist_addons.txt', 'w') as f:
    for line in bsp_list:
        f.write(f"{line}\n")
        
with open('mapvote_addons.txt', 'w') as f:
    for line in bsp_list:
        line = "addvotemap " + line
        f.write(f"{line}\n")        