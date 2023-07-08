#!/bin/bash
# inkVerb donjon asset, verb.ink
## This script backs up the mysql directory based with automatic preference for what drives are mounted

if [ -z "$1" ]; then
  /usr/bin/echo "Must argue the backup suffix"
  exit 5
fi

backsuffix="$1"

if [ -e "/mnt/hdd" ]; then
  backdir="/mnt/hdd/mysql.bak.d"
elif [ -e "/mnt/ssd" ]; then
  backdir="/mnt/ssd/mysql.bak.d"
else
  backdir="/var/lib/mysql.bak.d"
fi

/usr/bin/mkdir -p ${backdir}
  
if /usr/bin/systemctl is-active mysql; then
  # Service check
  /usr/bin/systemctl stop mysql
  
  # Remove any old backup from yesterday
  if [ -d "${backdir}/mysql.${backsuffix}.yesterday" ]; then
    /usr/bin/rm -rf "${backdir}/mysql.${backsuffix}.yesterday"
  fi
  
  # Displace any backup
  if [ -d "${backdir}/mysql.${backsuffix}" ]; then
    /usr/bin/mv "${backdir}/mysql.${backsuffix}" "${backdir}/mysql.${backsuffix}.yesterday"
  fi

  # Copy the directory
  /usr/bin/cp -r /var/lib/mysql "${backdir}/mysql.${backsuffix}"
  /usr/bin/systemctl start mysql
fi

