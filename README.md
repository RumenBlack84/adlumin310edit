# This script can be used to refactor the Adlumin log forwarder to use python 3.10 instead of 3.6 https://adlumin.com
# This is an unsupported workaround please use at your own risk. 
Usage: just run the script as the adlumin user there are no switches or other considerations
#
Written by Brian Grant
brian.grant@n-able.com
# 
The purpose of this script is to act as an refactor and update script 
for the adlumin_forwarder.py script so that it can run properly under 
python 3.10 which is supported until October 2026, it seemed like the
logical choice as the version of Ubuntu the log forwarder images are 
using by default right now is 22.04 LTS which comes with 3.10 as its
preinstalled version of python3.
#
As for the edits to adlumin_forwarder.py to get it working with python
3.10 they were relatively minor. At the top of the script there is a 
shebang that is setting the script to run as 3.6 that is being changed
to 3.10. Further more there were issues importing the zstd module in
3.10 so it's line was changed from "import ztd" to "import zstandard as ztd".
Lastly I am commenting out the updater function in the script as this was 
causing some issues overwriting the file and making the service fail to start.
Just for good measure I'm using chattr to make the file immutable once changed
so that nothing on the system can change it.
#
This of course raises the problem that the script can no longer be updated.
I've set this script to first unlock the adlumin_forwarder.py script and then
run the updater.py script to update it. From there re-edits the forwarder script
with sed to include the above edits and relocks the file.
