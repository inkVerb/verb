#!/bin/bash
# inkVerb donjon asset, verb.ink
# certbot --manual-cleanup-hook for DNS-01 wildcard certs
# Deletes only this challenge value (apex + wildcard share the same name)

domain="${CERTBOT_DOMAIN#\*.}"
record="_acme-challenge.${domain}."
keyfile="/opt/verb/conf/inkcert/inkcertbot.key"

if [ -z "${CERTBOT_VALIDATION}" ] || [ ! -f "${keyfile}" ]; then
  exit 0
fi

. /opt/verb/conf/servernameip

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
