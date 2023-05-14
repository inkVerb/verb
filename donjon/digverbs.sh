#!/bin/bash
# inkVerb donjon asset, verb.ink
## This is run as a fast-repeating cron task at initial VPS setup to run inkCert for hosted verb domains as soon as their DNS records have populated

/usr/bin/mkdir -p /opt/verb/dig

/opt/verb/serfs/inkdnsdigverbs > /opt/verb/dig/digverbs-$(date +'%Y-%m-%d_%H:%M:%S')

e="$?"; [[ "$e" = "0" ]] || exit "$e"

/opt/verb/serfs/inkcertdole-all-verbs

e="$?"; [[ "$e" = "0" ]] || exit "$e"

/usr/bin/rm -f /opt/verb/dig/digverbs-*
if [ "$(/usr/bin/ls /opt/verb/dig)" = "" ]; then /usr/bin/rm -rf /opt/verb/dig; fi
/usr/bin/rm -f /etc/cron.d/digverbs
