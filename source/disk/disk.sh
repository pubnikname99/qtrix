#! /bin/bash

# This part of the script is designed to extract data only and pass it along
# to the Python script that will handle the template building.

# Retrieve the information that we normally do when performing disk breakdown:
read -r -d '' -a df_info < <( df -BG -h / )
root_dirs="$(du -sh --exclude='/home/virtfs/*' /* | grep G | sort -rh)"
backup_dirs="$(du -sh /backup/* | grep G | sort -rh && du -sh /backup/weekly/* | grep G | sort -rh)"
large_files_found="$(find /home -maxdepth 7 -type f -size +200M -exec du -hsxc {} + | sort -rh | grep -v total && find /backup -maxdepth 7 -type f -size +200M -exec du -hsxc {} + | sort -rh | grep -v total)"

# Check if JB4/5 are installed on the server and capture them in variables:
if ( jetbackup --version || jetbackup5 --version ) >/dev/null 2>&1
then
        jb_status="jb"
else
        jb_status=""
fi

# Execute python script and pass along the info as variables:
python3 "$DIR/source/disk/disk.py" "${df_info[*]}" "${df_info[8]}" "$root_dirs" "$backup_dirs" "$large_files_found" "$jb_status" "$admin_name"

