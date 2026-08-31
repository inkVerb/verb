#!/bin/bash
# Make TLS keys readable for User=maddy (never root, even at start).
# /etc/inkcert/le is a symlink to /etc/letsencrypt — same 0600 privkeys.
#
# ==== MADDY TLS HACK — SINGLE SWITCH (unplug here) ====
maddy_permissions_hack=true
# UNPLUG: set the line above to false. That is the whole switch.
# Every caller just runs this file (install, ExecStartPre, setinkcertmailcerts,
# inkcertcble-renew-all). They do not duplicate the flag.
# true  = copy live keys into /etc/maddy/certs as real files (acme.sh pattern)
# false = upstream: setfacl on /etc/letsencrypt/{live,archive} + symlink certs → live
#DEV delete maddy_permissions_hack and the if-true branch when maddy reads LE privkeys as User=maddy without a copy.
# ======================================================

if ! /usr/bin/id -u maddy >/dev/null 2>&1; then
  exit 0
fi

if [ "${maddy_permissions_hack}" = "true" ]; then
  ## HACK: copy (dereference) into /etc/maddy/certs
  /usr/bin/mkdir -p /etc/maddy/certs
  /usr/bin/chown root:maddy /etc/maddy /etc/maddy/certs
  /usr/bin/chmod 0750 /etc/maddy /etc/maddy/certs
  copy_live() {
    local live="$1"
    [ -d "${live}" ] || return 0
    local domainpath domain
    for domainpath in "${live}"/*; do
      [ -d "${domainpath}" ] || continue
      domain="$(/usr/bin/basename "${domainpath}")"
      [ "${domain}" = "README" ] && continue
      if [ -f "${domainpath}/fullchain.pem" ] && [ -f "${domainpath}/privkey.pem" ]; then
        /usr/bin/mkdir -p "/etc/maddy/certs/${domain}"
        /usr/bin/install -m 0644 -o root -g maddy "${domainpath}/fullchain.pem" "/etc/maddy/certs/${domain}/fullchain.pem"
        /usr/bin/install -m 0640 -o root -g maddy "${domainpath}/privkey.pem" "/etc/maddy/certs/${domain}/privkey.pem"
      fi
    done
  }
  copy_live /etc/letsencrypt/live
else
  ## NORMAL (maddy docs)
  if [ ! -x /usr/bin/setfacl ]; then
    /usr/bin/pacman -S --noconfirm --needed acl
  fi
  if [ -d /etc/letsencrypt/live ] && [ -d /etc/letsencrypt/archive ]; then
    /usr/bin/setfacl -R -m u:maddy:rX /etc/letsencrypt/live /etc/letsencrypt/archive
    /usr/bin/setfacl -R -d -m u:maddy:rX /etc/letsencrypt/live /etc/letsencrypt/archive
  fi
  if [ -d /etc/letsencrypt/live ]; then
    /usr/bin/ln -sfn /etc/letsencrypt/live /etc/maddy/certs
  fi
fi
