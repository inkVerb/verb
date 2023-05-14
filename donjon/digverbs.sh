#!/bin/bash
# inkVerb donjon asset, verb.ink
## This is run as a fast-repeating cron task at initial VPS setup to run inkCert for hosted verb domains as soon as their DNS records have populated

/usr/bin/mkdir -p /opt/verb/dig
/usr/bin/touch /opt/verb/dig/digverbs-$(date +'%Y-%m-%d_%H:%M:%S')

/opt/verb/serfs/inkdnsdigverbs

e="$?"; [[ "$e" = "0" ]] || exit "$e"

/opt/verb/serfs/inkcertdole-all-verbs

e="$?"; [[ "$e" = "0" ]] || exit "$e"

/usr/bin/rm -f /etc/cron.d/digverbs
