#!/bin/bash
# inkVerb donjon asset, verb.ink
## This is run as a fast-repeating cron task at initial VPS setup to run inkCert for hosted verb domains as soon as their DNS records have populated

/opt/verb/serfs/inkdnsdig "${1}" mail

e="$?"; [[ "$e" = "0" ]] || exit "$e"

if [ -n "$2" ] && [ "$2" = "multi" ]; then
  /opt/verb/serfs/inkcertdole "${1}"
  e="$?"; [[ "$e" = "0" ]] || exit "$e"
elif [ -n "$2" ] && [ "$2" = "wild" ]; then
  /opt/verb/serfs/inkcertdocb "${1}"
  e="$?"; [[ "$e" = "0" ]] || exit "$e"
fi

/usr/bin/rm -f "/etc/cron.d/digdomain-${1}"
