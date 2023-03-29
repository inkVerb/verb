#!/bin/sh
# This is intended to be run by crontab to automatically renew letsencrypt certs

# Include settings
. /opt/verb/conf/servernameip
. /opt/verb/conf/inkcertstatus

# Stop Apache
#/usr/sbin/apachectl -k graceful-stop
## Hard stop in case it doesn't work
#/bin/systemctl stop apache2

# Renew LE
/usr/bin/certbot renew

# Log
if [ $? -ne 0 ]
 then
        ERRORLOG=`tail /var/log/inkcert/inkcertle.log`
        echo -e "The Lets Encrypt verb.ink cert has not been renewed! \n \n" $ERRORLOG | mail -s "Lets Encrypt Cert Alert" ${InkCertEmail}
fi

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
  /usr/bin/postmap -F hash:/etc/postfix/virtual_ssl.map
  /usr/bin/systemctl restart postfix
fi

# Finish
exit 0
