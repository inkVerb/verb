#!/bin/bash
# inkVerb donjon asset, verb.ink
## This script backs up the LDAP database and configuration with automatic preference for what drives are mounted
## Restore with these commands:
### Database: /usr/bin/su ldap -c slapadd -v -n 1 -F /etc/openldap/slapd.d -l BACKUPNAME.ldif
### Config: /usr/bin/su ldap -c slapadd -v -n 0 -F /etc/openldap/slapd.d -l BACKUPNAME.conf.ldif


if [ -z "$1" ]; then
  /usr/bin/echo "Must argue the backup suffix"
  exit 5
fi

backsuffix="$1"

if [ -e "/mnt/hdd" ]; then
  backdir="/mnt/hdd/ldap.bak.d"
elif [ -e "/mnt/ssd" ]; then
  backdir="/mnt/ssd/ldap.bak.d"
else
  backdir="/var/lib/ldap.bak.d"
fi

ldapHost="$(hostname)"

/usr/bin/mkdir -p ${backdir}
  
if /usr/bin/systemctl is-active slapd; then
  # Service check
  /usr/bin/systemctl stop slapd
  
  # Database
  ## Remove any old backup from yesterday
  if [ -f "${backdir}/slapd.${ldapHost}.${backsuffix}.ldif.yesterday" ]; then
    /usr/bin/rm -rf "${backdir}/slapd.${ldapHost}.${backsuffix}.ldif.yesterday"
  fi
  ## Displace any backup
  if [ -f "${backdir}/slapd.${ldapHost}.${backsuffix}.ldif" ]; then
    /usr/bin/mv "${backdir}/slapd.${ldapHost}.${backsuffix}.ldif" "${backdir}/slapd.${ldapHost}.${backsuffix}.ldif.yesterday"
  fi
  ## Run the backup
  /usr/bin/su ldap -c "slapcat -v -n 1 -l ${backdir}/slapd.${ldapHost}.${backsuffix}.ldif"

  # Config
  ## Remove any old backup from yesterday
  if [ -f "${backdir}/slapd.${ldapHost}.${backsuffix}.conf.ldif.yesterday" ]; then
    /usr/bin/rm -rf "${backdir}/slapd.${ldapHost}.${backsuffix}.conf.ldif.yesterday"
  fi 
  ## Displace any backup
  if [ -f "${backdir}/slapd.${ldapHost}.${backsuffix}.conf.ldif" ]; then
    /usr/bin/mv "${backdir}/slapd.${ldapHost}.${backsuffix}.conf.ldif" "${backdir}/slapd.${ldapHost}.${backsuffix}.conf.ldif.yesterday"
  fi
  ## Run the backup
  /usr/bin/su ldap -c "slapcat -vF /etc/openldap/slapd.d -n 0 -l ${backdir}/slapd.${ldapHost}.${backsuffix}.conf.ldif"

  # Start the service
  /usr/bin/systemctl start slapd
fi

