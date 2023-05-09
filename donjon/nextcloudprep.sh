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
/usr/bin/printf "Creating possible missing Directories\n"
/usr/bin/mkdir -p $nxcpath/data
#/usr/bin/mkdir -p $nxcpath/assets
/usr/bin/mkdir -p $nxcpath/updater

/usr/bin/printf "chmod Files and Directories\n"
/usr/bin/find ${nxcpath}/ -type f -print0 | xargs -0 chmod 0640
/usr/bin/find ${nxcpath}/ -type d -print0 | xargs -0 chmod 0750
/usr/bin/chmod 755 ${nxcpath}

/usr/bin/printf "chown Directories\n"
/usr/bin/chown -R ${rootuser}:${htgroup} ${nxcpath}/
/usr/bin/chown -R ${htuser}:${htgroup} ${nxcpath}/apps/
#chown -R ${htuser}:${htgroup} ${nxcpath}/assets/
/usr/bin/chown -R ${htuser}:${htgroup} ${nxcpath}/config/
/usr/bin/chown -R ${htuser}:${htgroup} ${nxcpath}/data/
/usr/bin/chown -R ${htuser}:${htgroup} ${nxcpath}/themes/
/usr/bin/chown -R ${htuser}:${htgroup} ${nxcpath}/updater/

/usr/bin/chmod ug+x ${nxcpath}/occ

/usr/bin/printf "chmod/chown .htaccess\n"
if [ -f ${nxcpath}/.htaccess ]
 then
  /usr/bin/chmod 0644 ${nxcpath}/.htaccess
  /usr/bin/chown ${rootuser}:${htgroup} ${nxcpath}/.htaccess
fi
if [ -f ${nxcpath}/data/.htaccess ]
 then
  /usr/bin/chmod 0644 ${nxcpath}/data/.htaccess
  /usr/bin/chown ${rootuser}:${htgroup} ${nxcpath}/data/.htaccess
fi

# Finish
/usr/bin/touch /opt/verb/conf/.nextcloudscript
/usr/bin/echo "Nextcloud settings script completed."

