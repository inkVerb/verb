#!/bin/bash
# inkVerb donjon asset, verb.ink
# certbot --manual-cleanup-hook for DNS-01 wildcard certs
# Deletes only this challenge value (apex + wildcard share the same name)
# Zone file + nsupdate. Do not refreshbind.

domain="${CERTBOT_DOMAIN#\*.}"
record="_acme-challenge.${domain}."
keyfile="/etc/inkcert/inkcertbot.key"

if [ -z "${CERTBOT_VALIDATION}" ] || [ ! -f "${keyfile}" ]; then
  exit 0
fi

. /opt/verb/conf/servernameip

if [ -f "/opt/verb/conf/inkdns/inkzones/db.${domain}" ]; then
  /opt/verb/serfs/killinkdnsacme "${domain}" "${CERTBOT_VALIDATION}" verber || true
else
  /opt/verb/serfs/killinkdnsacme "${domain}" "${CERTBOT_VALIDATION}" || true
fi

/usr/bin/nsupdate -k "${keyfile}" <<EOF
server 127.0.0.1
zone ${domain}
update delete ${record} 60 TXT "${CERTBOT_VALIDATION}"
send
EOF

if [ "${RinkConfigured}" = "true" ] || [ "${RinkConfigured}" = "rink" ]; then
  /opt/verb/serfs/inkdnsslaveacme "${domain}" || true
fi

exit 0
