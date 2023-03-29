#!/bin/bash
# inkVerb donjon asset, verb.ink
## This script is written for ownCloud installation, to ensure all users, folders, and settings are correct


# Check if run previously
if [ -f /opt/verb/conf/.owncloudscript ]; then
echo "ownCloud settings script was already run previously.
You shouldn't need to run it again. But, if you do, delete:
verb/conf/.owncloudscript"
exit 0
fi

# Run the script from ownCloud
owcpath='/var/www/vapps/owncloud'
htuser='www-data'
htgroup='www-data'
rootuser='root'

##NOTE: the "assets" directory breaks the web updater 
printf "Creating possible missing Directories\n"
mkdir -p $owcpath/data
#mkdir -p $owcpath/assets
mkdir -p $owcpath/updater

printf "chmod Files and Directories\n"
find ${owcpath}/ -type f -print0 | xargs -0 chmod 0640
find ${owcpath}/ -type d -print0 | xargs -0 chmod 0750
chmod 755 ${owcpath}

printf "chown Directories\n"
chown -R ${rootuser}:${htgroup} ${owcpath}/
chown -R ${htuser}:${htgroup} ${owcpath}/apps/
#chown -R ${htuser}:${htgroup} ${owcpath}/assets/
chown -R ${htuser}:${htgroup} ${owcpath}/config/
chown -R ${htuser}:${htgroup} ${owcpath}/data/
chown -R ${htuser}:${htgroup} ${owcpath}/themes/
chown -R ${htuser}:${htgroup} ${owcpath}/updater/

chmod +x ${owcpath}/occ

printf "chmod/chown .htaccess\n"
if [ -f ${owcpath}/.htaccess ]
 then
  chmod 0644 ${owcpath}/.htaccess
  chown ${rootuser}:${htgroup} ${owcpath}/.htaccess
fi
if [ -f ${owcpath}/data/.htaccess ]
 then
  chmod 0644 ${owcpath}/data/.htaccess
  chown ${rootuser}:${htgroup} ${owcpath}/data/.htaccess
fi

# Finish
touch /opt/verb/conf/.owncloudscript
echo "ownCloud settings script completed."

