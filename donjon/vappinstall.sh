#!/usr/bin/bash
#inkVerbDonjon! verb.ink
# Soft snapshot + fail-undo for vapp installers (ink install *).
# What existed before the installer stays. What this installer created is removed on non-zero exit.
# Source after "already installed" / prereq checks, before mutating.
#
#   . /opt/verb/donjon/vappinstall.sh
#   vappinst_begin
#   vappinst_note KIND args...
#   vappinst_html_link DOMAIN TARGET   # refuses a real directory (old BIMI / leftover)
#   vappinst_adddomain_if_missing DOMAIN
#   vappinst_commit                    # success; call before the finish message
#
# Journal kinds (space-separated; paths must not contain spaces — verb convention):
#   mysql DB USER
#   pgsql DB USER
#   mysqlboss USER
#   dir PATH
#   file PATH
#   conf PATH
#   html DOMAIN OLDTARGET|MISSING
#   symlink PATH OLDTARGET|MISSING
#   systemd UNIT
#   user NAME
#   domain DOMAIN          # we ran adddomain
#   subdomain SUB DOMAIN   # we ran addsubdomain
#   vhostbak CONF BAK      # pre-existing vhost copied aside
#   ghosted DOMAIN
#   mailbox USER DOMAIN
#   portline FILE DOMAIN
#   pkg NAME               # pacman package we installed (rare)

VAPPINST_JOURNAL=""
VAPPINST_ACTIVE=""

vappinst_begin() {
  VAPPINST_JOURNAL="/run/verb-vappinst.$$"
  VAPPINST_ACTIVE="true"
  /usr/bin/mkdir -p /run
  : > "${VAPPINST_JOURNAL}"
  trap 'vappinst_on_exit $?' EXIT
}

vappinst_note() {
  [ "${VAPPINST_ACTIVE}" = "true" ] || return 0
  [ -n "${VAPPINST_JOURNAL}" ] || return 0
  /usr/bin/printf '%s\n' "$*" >> "${VAPPINST_JOURNAL}"
}

vappinst_commit() {
  if [ -f "${VAPPINST_JOURNAL}" ]; then
    while read -r kind a b _rest; do
      if [ "${kind}" = "vhostbak" ] && [ -n "${b}" ] && [ -f "${b}" ]; then
        /bin/rm -f "${b}"
      fi
    done < "${VAPPINST_JOURNAL}"
  fi
  trap - EXIT
  VAPPINST_ACTIVE=""
  /bin/rm -f "${VAPPINST_JOURNAL}"
}

vappinst_on_exit() {
  local st=$1
  trap - EXIT
  [ "${VAPPINST_ACTIVE}" = "true" ] || return 0
  VAPPINST_ACTIVE=""
  if [ "${st}" = "0" ]; then
    /bin/rm -f "${VAPPINST_JOURNAL}"
    return 0
  fi
  /usr/bin/echo "Install failed (exit ${st}); undoing what this install created. Pre-existing domain, certs, and html directories are left."
  vappinst_rollback
  /bin/rm -f "${VAPPINST_JOURNAL}"
}

vappinst_rollback() {
  [ -f "${VAPPINST_JOURNAL}" ] || return 0
  /usr/bin/tac "${VAPPINST_JOURNAL}" 2>/dev/null | while read -r kind a b c; do
    case "${kind}" in
      mysql)
        /usr/bin/mariadb --defaults-extra-file=/opt/verb/conf/sql/mysqlboss.cnf -e "DROP DATABASE IF EXISTS ${a}; DROP USER IF EXISTS '${b}'@'localhost'; FLUSH PRIVILEGES;" >/dev/null 2>&1 || true
        ;;
      pgsql)
        /usr/bin/sudo -u postgres psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${a}';" >/dev/null 2>&1 || true
        /usr/bin/sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${a};" >/dev/null 2>&1 || true
        /usr/bin/sudo -u postgres psql -c "DROP USER IF EXISTS ${b};" >/dev/null 2>&1 || true
        /bin/rm -f "/opt/verb/conf/sql/pgsqldb.${a}" "/opt/verb/conf/sql/pgsqldb.${a}.pgpass"
        ;;
      mysqlboss)
        /usr/bin/mariadb --defaults-extra-file=/opt/verb/conf/sql/mysqlboss.cnf -e "DROP USER IF EXISTS '${a}'@'localhost'; FLUSH PRIVILEGES;" >/dev/null 2>&1 || true
        /bin/rm -f "/opt/verb/conf/sql/mysqlnewboss.${a}.cnf"
        ;;
      dir)
        [ -n "${a}" ] && /bin/rm -rf "${a}"
        ;;
      file|conf)
        [ -n "${a}" ] && /bin/rm -f "${a}"
        ;;
      html)
        # Restore symlink we replaced, or remove the symlink we created. Never rm -rf a directory.
        if [ -d "/srv/www/html/${a}" ] && [ ! -L "/srv/www/html/${a}" ]; then
          continue
        fi
        if [ "${b}" = "MISSING" ] || [ -z "${b}" ]; then
          /bin/rm -f "/srv/www/html/${a}"
        else
          /bin/ln -sfn "${b}" "/srv/www/html/${a}"
        fi
        ;;
      symlink)
        if [ -d "${a}" ] && [ ! -L "${a}" ]; then
          continue
        fi
        if [ "${b}" = "MISSING" ] || [ -z "${b}" ]; then
          /bin/rm -f "${a}"
        else
          /bin/ln -sfn "${b}" "${a}"
        fi
        ;;
      systemd)
        /usr/bin/systemctl disable --now "${a}" >/dev/null 2>&1 || true
        /bin/rm -f "/etc/systemd/system/${a}.service"
        if [[ "${a}" == ghost_* ]]; then
          /bin/rm -f "/lib/systemd/system/${a}.service" "/usr/lib/systemd/system/${a}.service"
        fi
        /usr/bin/systemctl daemon-reload >/dev/null 2>&1 || true
        ;;
      svcstop)
        /usr/bin/systemctl disable --now "${a}" >/dev/null 2>&1 || true
        ;;
      user)
        /usr/bin/id -u "${a}" >/dev/null 2>&1 && /usr/bin/userdel "${a}" >/dev/null 2>&1 || true
        ;;
      domain)
        /opt/verb/serfs/killdomainsoft "${a}" >/dev/null 2>&1 || true
        ;;
      subdomain)
        /opt/verb/serfs/killsubdomain "${a}" "${b}" >/dev/null 2>&1 || true
        ;;
      vhostbak)
        if [ -n "${a}" ] && [ -n "${b}" ] && [ -f "${b}" ]; then
          /bin/mv -f "${b}" "${a}"
        fi
        ;;
      ghosted)
        if [ -f "/opt/verb/conf/webserver/sites-available/nginx/${a}-ghosted.conf" ]; then
          /bin/cp -f "/opt/verb/conf/webserver/sites-available/nginx/${a}-ghosted.conf" "/opt/verb/conf/webserver/sites-available/nginx/${a}.conf"
        fi
        if [ -f "/opt/verb/conf/webserver/sites-available/httpd/${a}-ghosted.conf" ]; then
          /bin/mv -f "/opt/verb/conf/webserver/sites-available/httpd/${a}-ghosted.conf" "/opt/verb/conf/webserver/sites-available/httpd/${a}.conf"
        fi
        ;;
      mailbox)
        if [ -x /opt/verb/serfs/inkvmaildelbox ]; then
          /opt/verb/serfs/inkvmaildelbox "${a}" "${b}" >/dev/null 2>&1 || true
        fi
        if [ -x /opt/verb/serfs/inkemaildelbox ]; then
          /opt/verb/serfs/inkemaildelbox "${a}" "${b}" >/dev/null 2>&1 || true
        fi
        ;;
      portline)
        if [ -f "${a}" ] && [ -n "${b}" ]; then
          /usr/bin/awk -v d="${b}" '$1 != d { print }' "${a}" > "${a}.vappinsttmp" && /bin/mv -f "${a}.vappinsttmp" "${a}"
        fi
        ;;
      pkg)
        /usr/bin/pacman -Qq "${a}" >/dev/null 2>&1 && /usr/bin/pacman -R --noconfirm "${a}" >/dev/null 2>&1 || true
        ;;
    esac
  done
}

# Point html/DOMAIN at TARGET. Refuses a real directory (old BIMI lived here; current BIMI is /srv/www/email/bimi/).
vappinst_html_link() {
  local domain="$1"
  local target="$2"
  local html="/srv/www/html/${domain}"
  if [ -d "${html}" ] && [ ! -L "${html}" ]; then
    /usr/bin/echo "${html} is a directory, not a symlink. Move or remove it, then retry."
    /usr/bin/echo "Current BIMI is /srv/www/email/bimi/${domain}/bimi.svg — not html/${domain}."
    return 8
  fi
  if [ -L "${html}" ]; then
    vappinst_note html "${domain}" "$(/usr/bin/readlink -n "${html}")"
  elif [ -e "${html}" ]; then
    /usr/bin/echo "${html} exists and is not a symlink. Move or remove it, then retry."
    return 8
  else
    vappinst_note html "${domain}" MISSING
  fi
  /bin/ln -sfn "${target}" "${html}"
}

# Remove html/DOMAIN only if it is a symlink (Ghost). Leave a real directory alone.
vappinst_html_unlink() {
  local domain="$1"
  local html="/srv/www/html/${domain}"
  if [ -L "${html}" ]; then
    vappinst_note html "${domain}" "$(/usr/bin/readlink -n "${html}")"
    /bin/rm -f "${html}"
  elif [ -d "${html}" ]; then
    /usr/bin/echo "Leaving directory ${html} in place (not removing a real folder)."
  elif [ -e "${html}" ]; then
    vappinst_note html "${domain}" MISSING
    /bin/rm -f "${html}"
  fi
}

vappinst_adddomain_if_missing() {
  local domain="$1"
  if [ -d "/srv/www/domains/${domain}" ]; then
    return 0
  fi
  /opt/verb/serfs/adddomain "${domain}"
  local e="$?"
  [[ "${e}" = "0" ]] || return "${e}"
  vappinst_note domain "${domain}"
}

# Copy a pre-existing vhost aside so fail-undo can restore it. Does not touch inkCert.
vappinst_vhost_backup() {
  local conf="$1"
  [ -f "${conf}" ] || return 0
  local bak="${conf}.pre-vappinst.$$"
  /bin/cp -a "${conf}" "${bak}"
  vappinst_note vhostbak "${conf}" "${bak}"
}

vappinst_symlink() {
  local path="$1"
  local target="$2"
  if [ -L "${path}" ]; then
    vappinst_note symlink "${path}" "$(/usr/bin/readlink -n "${path}")"
  elif [ -e "${path}" ]; then
    vappinst_note symlink "${path}" MISSING
  else
    vappinst_note symlink "${path}" MISSING
  fi
  /bin/ln -sfn "${target}" "${path}"
}

# If a previous attempt left a vapp file or tree without the health file, drop that
# leftover DB/tree/conf and continue. If health exists, return 1 (caller exits "already").
# VFILE VDIR HEALTH
vappinst_clear_partial() {
  local vfile="$1"
  local vdir="$2"
  local health="$3"
  if [ -e "${health}" ]; then
    return 1
  fi
  if [ ! -f "${vfile}" ] && [ ! -d "${vdir}" ]; then
    return 0
  fi
  /usr/bin/echo "Incomplete previous install found; removing leftovers from that attempt."
  if [ -f "${vfile}" ]; then
    local db usr engine
    db="$(/usr/bin/awk -F= '/^appDBase/{gsub(/"/,""); print $2; exit}' "${vfile}")"
    usr="$(/usr/bin/awk -F= '/^appDDBUsr/{gsub(/"/,""); print $2; exit}' "${vfile}")"
    engine="$(/usr/bin/awk -F= '/^appEngine/{gsub(/"/,""); print $2; exit}' "${vfile}")"
    if [ -n "${db}" ]; then
      if [ "${engine}" = "postgres" ]; then
        /usr/bin/sudo -u postgres psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${db}';" >/dev/null 2>&1 || true
        /usr/bin/sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${db};" >/dev/null 2>&1 || true
        [ -n "${usr}" ] && /usr/bin/sudo -u postgres psql -c "DROP USER IF EXISTS ${usr};" >/dev/null 2>&1 || true
        /bin/rm -f "/opt/verb/conf/sql/pgsqldb.${db}" "/opt/verb/conf/sql/pgsqldb.${db}.pgpass"
      else
        if [ -n "${usr}" ]; then
          /usr/bin/mariadb --defaults-extra-file=/opt/verb/conf/sql/mysqlboss.cnf -e "DROP DATABASE IF EXISTS ${db}; DROP USER IF EXISTS '${usr}'@'localhost'; FLUSH PRIVILEGES;" >/dev/null 2>&1 || true
        else
          /usr/bin/mariadb --defaults-extra-file=/opt/verb/conf/sql/mysqlboss.cnf -e "DROP DATABASE IF EXISTS ${db}; FLUSH PRIVILEGES;" >/dev/null 2>&1 || true
        fi
      fi
    fi
    /bin/rm -f "${vfile}" "/opt/verb/conf/vapps/orig/$(/usr/bin/basename "${vfile}")"
  fi
  if [ -n "${vdir}" ] && [ -d "${vdir}" ]; then
    /bin/rm -rf "${vdir}"
  fi
  return 0
}

