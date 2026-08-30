#!/bin/bash
# Grant User=maddy read on inkCert / Let's Encrypt trees.
# live/*/privkey.pem is a symlink to archive (0600, dirs 0700). setfacl is optional.

if ! /usr/bin/id -u maddy >/dev/null 2>&1; then
  exit 0
fi

grant_tree() {
  local root="$1"
  [ -d "${root}" ] || return 0
  /usr/bin/chmod 0755 "${root}"
  for d in live archive; do
    [ -d "${root}/${d}" ] || continue
    /usr/bin/chgrp -R maddy "${root}/${d}"
    /usr/bin/find "${root}/${d}" -type d -exec /usr/bin/chmod 0750 {} +
    /usr/bin/find "${root}/${d}" -type f \( -name 'privkey*' -o -name '*privkey*.pem' \) -exec /usr/bin/chmod 0640 {} +
    /usr/bin/find "${root}/${d}" -type f -name '*.pem' ! -name 'privkey*' ! -name '*privkey*.pem' -exec /usr/bin/chmod 0644 {} +
  done
  if [ -x /usr/bin/setfacl ]; then
    /usr/bin/setfacl -m u:maddy:--x "${root}"
    for d in live archive; do
      [ -d "${root}/${d}" ] || continue
      /usr/bin/setfacl -R -m u:maddy:rX "${root}/${d}"
      /usr/bin/setfacl -R -d -m u:maddy:rX "${root}/${d}"
    done
  fi
}

if [ -d /etc/inkcert ]; then
  /usr/bin/chmod 0755 /etc/inkcert
  if [ -x /usr/bin/setfacl ]; then
    /usr/bin/setfacl -m u:maddy:--x /etc/inkcert
  fi
fi

grant_tree /etc/letsencrypt
grant_tree /etc/inkcert/le
