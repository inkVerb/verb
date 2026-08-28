#!/bin/bash
# inkVerb donjon asset, verb.ink
# certbot --manual-auth-hook for DNS-01 wildcard certs
# Env from certbot: CERTBOT_DOMAIN CERTBOT_VALIDATION
# Persist the TXT in the inkDNS zone file (inkdnsaddacme) AND nsupdate live.
# Do not inkdnsrefreshbind here — too slow for a certbot hook.

# Wildcard challenges still use _acme-challenge.domain.tld (strip leading *.)
domain="${CERTBOT_DOMAIN#\*.}"
record="_acme-challenge.${domain}."
keyfile="/opt/verb/conf/inkcert/inkcertbot.key"

if [ -z "${CERTBOT_VALIDATION}" ]; then
  /usr/bin/echo "inkcert-dns01-auth: CERTBOT_VALIDATION empty"
  exit 8
fi
if [ ! -f "${keyfile}" ]; then
  /usr/bin/echo "inkcert-dns01-auth: missing ${keyfile} — run inkcertsetdnskey"
  exit 8
fi

. /opt/verb/conf/servernameip

# Zone-file persistence (survives inkdnsrefreshbind). No keys copied to ns1/ns2.
if [ -f "/opt/verb/conf/inkdns/inkzones/db.${domain}" ]; then
  /opt/verb/serfs/inkdnsaddacme "${domain}" "${CERTBOT_VALIDATION}" verber || true
else
  /opt/verb/serfs/inkdnsaddacme "${domain}" "${CERTBOT_VALIDATION}" || true
fi

# Publish TXT on this Verber (Bind master)
/usr/bin/nsupdate -k "${keyfile}" <<EOF
server 127.0.0.1
zone ${domain}
update add ${record} 60 TXT "${CERTBOT_VALIDATION}"
send
EOF
e="$?"
if [ "$e" != "0" ]; then
  /usr/bin/echo "inkcert-dns01-auth: nsupdate failed ($e)"
  exit "$e"
fi

# Same SSH Host ns1/ns2 path as rinkadddomain: force slave AXFR now
if [ "${RinkConfigured}" = "true" ] || [ "${RinkConfigured}" = "rink" ]; then
  /opt/verb/serfs/inkdnsslaveacme "${domain}" || true
fi

# Wait until master, then ns1/ns2, answer with this TXT
tries=0
have_master=""
have_ns1=""
have_ns2=""
while [ "${tries}" -lt 30 ]; do
  gotloc="$(/usr/bin/dig @127.0.0.1 TXT ${record} +short +time=2 +tries=1 2>/dev/null | /usr/bin/tr -d '"')"
  /usr/bin/echo "${gotloc}" | /usr/bin/grep -Fq "${CERTBOT_VALIDATION}" && have_master="yes"

  if [ -n "${ServerNS1IPv4}" ] && [ "${ServerNS1IPv4}" != "NOT_SET" ]; then
    got1="$(/usr/bin/dig @${ServerNS1IPv4} TXT ${record} +short +time=2 +tries=1 2>/dev/null | /usr/bin/tr -d '"')"
    /usr/bin/echo "${got1}" | /usr/bin/grep -Fq "${CERTBOT_VALIDATION}" && have_ns1="yes"
  else
    have_ns1="skip"
  fi
  if [ -n "${ServerNS2IPv4}" ] && [ "${ServerNS2IPv4}" != "NOT_SET" ]; then
    got2="$(/usr/bin/dig @${ServerNS2IPv4} TXT ${record} +short +time=2 +tries=1 2>/dev/null | /usr/bin/tr -d '"')"
    /usr/bin/echo "${got2}" | /usr/bin/grep -Fq "${CERTBOT_VALIDATION}" && have_ns2="yes"
  else
    have_ns2="skip"
  fi

  if [ "${have_master}" = "yes" ] && [ "${have_ns1}" != "" ] && [ "${have_ns2}" != "" ]; then
    /usr/bin/echo "inkcert-dns01-auth: TXT live for ${domain}"
    exit 0
  fi
  /usr/bin/sleep 3
  tries=$((tries + 1))
done

# Master has it; slaves may still catch notify. Certbot/LE retry a few times.
/usr/bin/echo "inkcert-dns01-auth: TXT on master; slaves may still be transferring"
exit 0
