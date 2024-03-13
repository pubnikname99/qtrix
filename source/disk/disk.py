# Imports
from re import search
from sys import argv
from os import path

# Variables and lists:
disk_spaces = [80, 160, 320, 640, 1280, 1920]
df_info = argv[1].replace("Mounted on", "Mounted on\n") # df info
df_only_total_size = argv[2] # Only server size from df
df_only_total_size = int(df_only_total_size.replace('G', '')) # Remove G from server size
root_dirs = argv[3] # Largest directories in /
backup_dirs = argv[4] # All backup directories
backup_conf = argv[5] # Retrieve backup configuration
large_files_found = argv[6] # Largest files on the server
jb_status = argv[7] # Detect if JB is present
admin_name = argv[8] # The admin name that will appear in the ticket signature
my_path = path.abspath(path.dirname(__file__))

# Retrieve the mini templates:
file1 = open(path.join(my_path, "templates/handle_if_backups.txt"), "r")
file2 = open(path.join(my_path, "templates/if_large_files_found.txt"), "r")
file3 = open(path.join(my_path, "templates/upgrade_recommend.txt"), "r")
file4 = open(path.join(my_path, "templates/jb_template.txt"), "r")

try:
    handle_if_backups = file1.read()
    if_large_files_found = file2.read()
    upgrade_recommend = file3.read()
    upgrade_recommend = upgrade_recommend.replace("[current_space]", f"{df_only_total_size}G")
    upgrade_disk_space = disk_spaces.index(min(disk_spaces, key=lambda x:abs(x-df_only_total_size)))+1
    upgrade_recommend = upgrade_recommend.replace("[upgrade_server]", f"{disk_spaces[upgrade_disk_space]}G")
    jb_template = file4.read()
finally:
    file1.close()
    file2.close()
    file3.close()
    file4.close()

# Retrieve the main template and edit it accordingly:
with open(path.join(my_path, "templates/template.txt")) as file:
    chosen_template = file.read().strip()
    complete_template = chosen_template.replace("[df_info]", df_info)
    complete_template = complete_template.replace("[root_dirs]", root_dirs)
    # If there is a /backup dir found on the server, add it to the template and then combine templates
    if search("backup", root_dirs):
        handle_if_backups = handle_if_backups.replace("[backup_dirs]", backup_dirs)
        handle_if_backups = handle_if_backups.replace("[backup_conf]", backup_conf)
        complete_template = complete_template.replace("[handle_if_backups]", handle_if_backups)
    else:
        complete_template = complete_template.replace("[handle_if_backups]", "")
    # If there are large files found on the server, add them to the template and then combine templates
    if large_files_found != "":
        if_large_files_found = if_large_files_found.replace("[large_files_found]", large_files_found)
        complete_template = complete_template.replace("[if_files_found]", if_large_files_found)
    else:
        complete_template = complete_template.replace("[if_files_found]", "")
    complete_template = complete_template.replace("[upgrade_recommend]", upgrade_recommend)
    # If JetBackup 4/5 is found on the server add the template or empty space in its place:
    if jb_status == "jb":
        complete_template = complete_template.replace("[jb_template]", "")
    else:
        complete_template = complete_template.replace("[jb_template]", jb_template)
    complete_template = complete_template.replace("[admin_name]", admin_name)

print(f"--- Template below --- \n\n {complete_template}")
