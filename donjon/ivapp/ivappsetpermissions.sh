#!/bin/sh
# inkVerbDragon, verb.ink

# This sets permissions for users created by ivApp
## This is necessary since directory permissions can create errors that need to be quited and ignored, without interfering with outher needed error reporting

# How to use:
## ./ivappsetpermissions.sh


Conf=$1
ADDIVAPPUSERNAME=$2


# Include configs
. ${Conf}
. ${IvappConfLoc}

### Note: we add " > /dev/null 2>&1" because this may kick output errors that don't matter and filibuster other important messages.
setfacl -R -m user:${ADDIVAPPUSERNAME}:--- /home > /dev/null 2>&1
setfacl -R -m user:${ADDIVAPPUSERNAME}:--- /var/www > /dev/null 2>&1
setfacl -R -m user:${ADDIVAPPUSERNAME}:--- /etc/php > /dev/null 2>&1
setfacl -R -m user:${ADDIVAPPUSERNAME}:--- /etc/apache2 > /dev/null 2>&1
setfacl -R -m user:${ADDIVAPPUSERNAME}:--- /etc/letsencrypt > /dev/null 2>&1
setfacl -R -m user:${ADDIVAPPUSERNAME}:--- /etc/inkcert > /dev/null 2>&1
chmod 750 -R ${IvappBase}

