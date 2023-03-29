#!/bin/bash
# inkVerb donjon asset, verb.ink
## This script backs up all vapp MySQL databases


# Verify  backup structure
mkdir -p /opt/verb/backups

# Backup each by vapp
cd /opt/verb/conf
for f in vapp.*; do
/opt/verb/serfs/mysqlvappout $f; wait
. /opt/verb/conf/$f
mv ${APPDBASE} $f.sql
cp -f $f.sql /opt/verb/backups/
rm -f $f.sql
done
