#!/bin/bash
# This is an unsupported workaround please use at your own risk.
# This is an unsupported workaround please use at your own risk.
# This is an unsupported workaround please use at your own risk.
# Usage: just run the script as the adlumin user there are no switches or other considerations
#
# Written by Brian Grant
# brian.grant@n-able.com
# 
# The purpose of this script is to act as an refactor and update script 
# for the adlumin_forwarder.py script so that it can run properly under 
# python 3.10 which is supported until October 2026, it seemed like the
# logical choice as the version of Ubuntu the log forwarder images are 
# using by default right now is 22.04 LTS which comes with 3.10 as its
# preinstalled version of python3
#
# As for the edits to adlumin_forwarder.py to get it working with python
# 3.10 they were relatively minor. At the top of the script there is a 
# shebang that is setting the script to run as 3.6 that is being changed
# to 3.10. Further more there were issues importing the zstd module in
# 3.10 so it's line was changed from "import ztd" to "import zstandard as ztd".
# Lastly I am commenting out the updater function in the script as this was 
# causing some issues overwriting the file and making the service fail to start.
# Just for good measure I'm using chattr to make the file immutable once changed
# so that nothing on the system can change it.
#
# This of course raises the problem that the script can no longer be updated.
# I've set this script to first unlock the adlumin_forwarder.py script and then
# run the updater.py script to update it. From there re-edits the forwarder script
# with sed to include the above edits and relocks the file.
#
echo "###########################################################################################"
echo "This is an unsupported workaround to enable python 3.10 instead of 3.6 USE AT YOUR OWN RISK"
echo "###########################################################################################"
# Check if the script is running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script must NOT be run as root or sudo. Please run it as the Adlumin user. The script will call sudo itself where required." 
   exit 1
fi

# Check if the script is running as the adlumin user
if [[ $USER != "adlumin" ]]; then
   echo "This script must be run as the adlumin user."
   exit 1
fi

#Set filepath to updater.py
file_path="/usr/local/adlumin/updater.py"

# Check if the file is executable
if [[ -x "$file_path" ]]; then
    echo "The file '$file_path' is already executable."
else
    echo "The file '$file_path' is not executable or does not exist."
    echo "Attempting to show '$file_path' permissions"
    ls -lh $(file_path)
    chmod +x $(file_path)
fi

echo "Setting adlumin_forwarder.py to be mutable so we can update it."
echo "WARNING: You may be prompted for your sudo password here if it has not yet been entered this session"
sudo chattr -i /usr/local/adlumin/adlumin_forwarder.py

#Running the Adlumin Script Updater
echo "Running the Adlumin Script Updater, you will be prompted for your sudo password to restart the service."
/usr/local/adlumin/updater.py
echo "The Adlumin Script Updater has exited, please read above to ensure it was successfull"

echo "Stopping the adlumin service that was started during the update"
sudo systemctl stop adlumin.service

echo "Changing the script to use python 3.10 instead of 3.6"
sed -i '1s|python3.6|python3.10|' /usr/local/adlumin/adlumin_forwarder.py

echo 'Correcting "import zstd" to "import zstandard as zstd" instead to avoid issues with running under python3.10'
sed -i 's|import zstd|import zstandard as zstd|' /usr/local/adlumin/adlumin_forwarder.py

echo 'Commenting out the update function of the script so it does not get overwritten'
sed -i '/updater = threading.Thread(target=update/,+1 s/^/#/' /usr/local/adlumin/adlumin_forwarder.py

echo "Setting adlumin_forwarder.py to be immutable so it definitly can't be changed."
sudo chattr +i /usr/local/adlumin/adlumin_forwarder.py

echo "Starting the Adlumin Service"
sudo systemctl start adlumin.service

echo "waiting 5 seconds and checking Adlumin Service Status"
sleep 5
sudo systemctl status adlumin.service
