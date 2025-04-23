#!/bin/sh
# This is intended to be run by crontab to automatically renew inkCert Proper certs

# Include settings
. /opt/verb/conf/servernameip

# Renew
### Put the inkCert Proper renew script here!!!!!

# Restart the web server
if [ ${ServerType} = "laemp" ]; then
  /usr/bin/systemctl restart nginx; wait
  /usr/bin/systemctl restart httpd; wait
elif [ ${ServerType} = "lemp" ]; then
  /usr/bin/systemctl restart nginx; wait
elif [ ${ServerType} = "lamp" ]; then
  /usr/bin/systemctl restart httpd; wait
fi

# Recompile Postfix for SNI
if [ -f "/etc/postfix/virtual_ssl.map" ]; then
  /usr/bin/postmap -F lmdb:/etc/postfix/virtual_ssl.map
  /usr/bin/systemctl restart postfix
fi

# Finish
exit 0
