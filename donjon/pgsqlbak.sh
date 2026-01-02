#!/bin/bash
# inkVerb donjon asset, verb.ink
## This script backs up the postgres directory based with automatic preference for what drives are mounted

if [ -z "$1" ]; then
  /usr/bin/echo "Must argue the backup suffix"
  exit 5
fi

backsuffix="$1"

if [ -e "/mnt/hdd" ]; then
  backdir="/mnt/hdd/sql.bak.d"
elif [ -e "/mnt/ssd" ]; then
  backdir="/mnt/ssd/sql.bak.d"
else
  backdir="/var/lib/sql.bak.d"
fi

/usr/bin/mkdir -p ${backdir}
  
if /usr/bin/systemctl is-active postgresql; then
  # Service check
  /usr/bin/systemctl stop postgresql
  
  # Remove any old backup from yesterday
  if [ -d "${backdir}/pgsql.${backsuffix}.yesterday" ]; then
    /usr/bin/rm -rf "${backdir}/pgsql.${backsuffix}.yesterday"
  fi
  
  # Displace any backup
  if [ -d "${backdir}/pgsql.${backsuffix}" ]; then
    /usr/bin/mv "${backdir}/pgsql.${backsuffix}" "${backdir}/pgsql.${backsuffix}.yesterday"
  fi

  # Copy the directory
  /usr/bin/cp -r /var/lib/postgres "${backdir}/pgsql.${backsuffix}"
  /usr/bin/systemctl start postgresql
fi

