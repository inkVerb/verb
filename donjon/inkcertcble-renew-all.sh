#!/bin/sh
# This is intended to be run by crontab to automatically renew letsencrypt certs

# Include settings
. /opt/verb/conf/servernameip
. /opt/verb/conf/inkcertstatus

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
  /usr/bin/postmap -F lmdb:/etc/postfix/virtual_ssl.map
  /usr/bin/systemctl restart postfix
fi

# Maddy: recopy or re-ACL keys after certbot (User=maddy cannot read 0600 privkeys)
if [ -x /opt/verb/donjon/maddy-tls-grant.sh ] && [ -f /etc/systemd/system/maddy.service ]; then
  /opt/verb/donjon/maddy-tls-grant.sh
  if /usr/bin/systemctl is-active --quiet maddy.service; then
    /usr/bin/systemctl reload maddy.service || true
  fi
fi

# Finish
exit 0
