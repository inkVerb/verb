#!/bin/bash
# inkVerb donjon asset, verb.ink
## This script is written for Nextcloud installation, to ensure all users, folders, and settings are correct
## DEV This is no longer used as of Arch, but kept for reference, it can be deleted from the Verber software

# Check if run previously
if [ -f /opt/verb/conf/.nextcloudscript ]; then
echo "Nextcloud settings script was already run previously.
You shouldn't need to run it again. But, if you do, delete:
verb/conf/.nextcloudscript"
exit 0
fi

# Run the script from Nextcloud
nxcpath='/srv/www/vapps/nextcloud'
htuser='www'
htgroup='www'
rootuser='root'

##NOTE: the "assets" directory breaks the web updater 
printf "Creating possible missing Directories\n"
mkdir -p $nxcpath/data
#mkdir -p $nxcpath/assets
mkdir -p $nxcpath/updater

printf "chmod Files and Directories\n"
find ${nxcpath}/ -type f -print0 | xargs -0 chmod 0640
find ${nxcpath}/ -type d -print0 | xargs -0 chmod 0750
chmod 755 ${nxcpath}

printf "chown Directories\n"
chown -R ${rootuser}:${htgroup} ${nxcpath}/
chown -R ${htuser}:${htgroup} ${nxcpath}/apps/
#chown -R ${htuser}:${htgroup} ${nxcpath}/assets/
chown -R ${htuser}:${htgroup} ${nxcpath}/config/
chown -R ${htuser}:${htgroup} ${nxcpath}/data/
chown -R ${htuser}:${htgroup} ${nxcpath}/themes/
chown -R ${htuser}:${htgroup} ${nxcpath}/updater/

chmod ug+x ${nxcpath}/occ

printf "chmod/chown .htaccess\n"
if [ -f ${nxcpath}/.htaccess ]
 then
  chmod 0644 ${nxcpath}/.htaccess
  chown ${rootuser}:${htgroup} ${nxcpath}/.htaccess
fi
if [ -f ${nxcpath}/data/.htaccess ]
 then
  chmod 0644 ${nxcpath}/data/.htaccess
  chown ${rootuser}:${htgroup} ${nxcpath}/data/.htaccess
fi

# Finish
touch /opt/verb/conf/.nextcloudscript
echo "Nextcloud settings script completed."

