#!/bin/bash
# inkVerb donjon asset, verb.ink
## This script creates a Postfix vmail user account based on a config
## This is intended to be run by cron regularly to ensure that the email account used by the backend of web apps remains and does not change

# Set the account
accountConfig="$1"

. /opt/verb/conf/vsysmail.${accountConfig}
. /opt/verb/conf/siteurilist

# Remove the email directory (it's not for receiving anyway)
/usr/bin/rm -rf /srv/vmail/${inkvmaildirectory}

# Update the password
Password=$(/usr/bin/pwgen -s1 24)
password="$(/bin/echo $Password | /usr/bin/openssl passwd -1 -stdin)"

# Make the database entry
## We need the alias entry for the mailbox to be active
/usr/bin/mariadb --defaults-extra-file=/opt/verb/conf/sql/mysqldb.vmail.cnf -e "
INSERT INTO mailbox
  (username, password, name, maildir, quota, local_part, domain, created, modified, active)
VALUES
  ('$username', '$password', '$name', '$inkvmaildirectory', '$mailboxsize', '$user', '$maildomain', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1)
ON DUPLICATE KEY UPDATE
  username = VALUES(username),
  password = VALUES(password),
  name = VALUES(name),
  maildir = VALUES(maildir),
  quota = VALUES(quota),
  local_part = VALUES(local_part),
  domain = VALUES(domain),
  modified = VALUES(modified),
  active = VALUES(active);

INSERT INTO alias
  (address, goto, domain, created, modified, active)
VALUES
  ('$username', '$username', '$maildomain', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1)
ON DUPLICATE KEY UPDATE
  address = VALUES(address),
  goto = VALUES(goto),
  domain = VALUES(domain),
  modified = VALUES(modified),
  active = VALUES(active);"

if [ "$?" = 0 ]; then
  # Update password in config
  sed -i "s/Password=.*/Password=\"${Password}\"/" /opt/verb/conf/vsysmail.${accountConfig}
  # Refresh the msmtp config
  if [ "${accountConfig}" = "msmtp" ]; then
  /usr/bin/cat <<EOF >  /etc/msmtprc
defaults
auth           on
tls            on
logfile        /var/log/msmtp.log
account default
host smtp.${nameURI}
from noreply@${nameURI}
user ${user}@${nameURI}
password ${Password}
EOF
/bin/chmod 0600 /etc/msmtprc
/bin/chown www:www /etc/msmtprc
/usr/bin/ln -sfn /etc/msmtprc /opt/verb/conf/
  fi
  exit 0;
else
  exit 1;
fi
