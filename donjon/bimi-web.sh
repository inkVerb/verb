#!/bin/bash
#inkVerbDonjon! verb.ink
# BIMI files live under /srv/www/email/bimi/<domain>/bimi.svg
# Public URL: https://${emailTLDURI}/<domain>/bimi.svg
# Stock logo (nameURI only) is verb/conf/lib/cloud/bimi.svg
# Source from updatehtmlverbs / setbimi / installinkmailadmin.

. /opt/verb/conf/siteurilist

/usr/bin/mkdir -p /srv/www/email/bimi
/usr/bin/chown www:www /srv/www/email /srv/www/email/bimi 2>/dev/null || true
/usr/bin/chmod 755 /srv/www/email /srv/www/email/bimi

# Seed the Verber's own nameURI once; do not overwrite a custom upload.
if [ -n "${nameURI}" ] && [ -f /opt/verb/conf/lib/cloud/bimi.svg ]; then
  /usr/bin/mkdir -p "/srv/www/email/bimi/${nameURI}"
  if [ ! -f "/srv/www/email/bimi/${nameURI}/bimi.svg" ]; then
    /usr/bin/cp /opt/verb/conf/lib/cloud/bimi.svg "/srv/www/email/bimi/${nameURI}/bimi.svg"
  fi
  /usr/bin/chown -R www:www "/srv/www/email/bimi/${nameURI}"
  /usr/bin/chmod 644 "/srv/www/email/bimi/${nameURI}/bimi.svg"
fi

_bimi_inject_nginx() {
  local nconf="$1"
  [ -f "${nconf}" ] || return 0
  if /usr/bin/grep -q 'INKBIMI-start' "${nconf}"; then
    return 0
  fi
  /usr/bin/sed -i '/location \/ {/i\
  #INKBIMI-start\
  location ~ ^/([^/]+)/bimi\\.svg$ {\
    alias /srv/www/email/bimi/$1/bimi.svg;\
    default_type image/svg+xml;\
    add_header Access-Control-Allow-Origin *;\
  }\
  #INKBIMI-end
' "${nconf}"
}

for host in "${emailTLDURI}" "${emailURI}"; do
  [ -n "${host}" ] || continue
  _bimi_inject_nginx "/opt/verb/conf/webserver/sites-available/nginx/${host}.conf"
done

if /usr/bin/command -v nginx >/dev/null 2>&1; then
  /usr/bin/systemctl reload nginx 2>/dev/null || true
fi
