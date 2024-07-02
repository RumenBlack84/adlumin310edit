# This script can be used to refactor the Adlumin log forwarder to use python 3.10 instead of 3.6 https://adlumin.com
# This is an unsupported workaround please use at your own risk. 
Usage: 
Ensure you've already put your tenantid into the adlumin_config.txt on the desktop of the system
Download the script on the Adlumin Ubuntu 22.04 VM, ensure you are logged in as the adlumin user.
~~~ bash
git clone https://github.com/RumenBlack84/adlumin310edit
cd adlumin310edit
chmod +x adlumin310edit.sh
./adlumin310edit.sh
~~~
Run the script in order to update, refactor and lock the adlumin_forwarder.py file so that it will work with python 3.10
There are no switches or parameters for this script. This script will intentionally break autoupdating. Rerun this script to update the log forwarder.
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
# 
The updater.py script is also being updated. Normally the updater script pulls it's 
creds from the session variables set in .bashrc of the adlumin user. This does not 
translate well to scripting or automation such as ansible so we are editing that script
to plug in the values from the bashrc directly to the updater script rather than have 
to pull them from the environment variables. The updater script itself is alot being
set to use python 3.10
