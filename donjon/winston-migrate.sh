#!/usr/bin/bash
#inkVerbDonjon! verb.ink
# One-shot / idempotent: pw99.* → winston99.* and pdt.* → winstonpress.*
# Called by verb-update 0.90.10. Safe to re-run.

w99_github="https://github.com/JesseSteele/Winston99.git"

move_html_link() {
  local domain="$1"
  local oldhint="$2"
  local newdir="$3"
  local html="/srv/www/html/${domain}"
  if [ -L "${html}" ]; then
    local tgt
    tgt="$(/usr/bin/readlink -f "${html}" 2>/dev/null || /usr/bin/readlink "${html}")"
    case "${tgt}" in
      *"${oldhint}"*) /bin/ln -sfn "${newdir}" "${html}" ;;
    esac
  fi
}

migrate_pw99() {
  local dir base domain newdir oldv newv cfg vip
  if [ ! -d /srv/www/vapps ]; then
    return 0
  fi
  for dir in /srv/www/vapps/pw99.*; do
    [ -e "${dir}" ] || continue
    base="$(/usr/bin/basename "${dir}")"
    domain="${base#pw99.}"
    [ -n "${domain}" ] || continue
    newdir="/srv/www/vapps/winston99.${domain}"
    if [ -e "${newdir}" ]; then
      /usr/bin/echo "Skip ${base}: ${newdir} already exists."
      continue
    fi
    /bin/mv "${dir}" "${newdir}"
    /usr/bin/echo "Moved ${dir} -> ${newdir}"
    move_html_link "${domain}" "pw99.${domain}" "${newdir}"
    vip="/srv/vip/_webapps/pw99.${domain}"
    if [ -e "${vip}" ] || [ -L "${vip}" ]; then
      /bin/rm -f "${vip}"
      /bin/ln -sfn "${newdir}" "/srv/vip/_webapps/winston99.${domain}"
    fi
    oldv="/opt/verb/conf/vapps/vapp.pw99.${domain}"
    newv="/opt/verb/conf/vapps/vapp.winston99.${domain}"
    if [ -f "${oldv}" ]; then
      /bin/mv "${oldv}" "${newv}"
    fi
    if [ -f "${newv}" ]; then
      /usr/bin/sed -i "s|/srv/www/vapps/pw99\\.|/srv/www/vapps/winston99.|g" "${newv}"
    fi
    if [ -f "/opt/verb/conf/vapps/orig/vapp.pw99.${domain}" ]; then
      /bin/mv "/opt/verb/conf/vapps/orig/vapp.pw99.${domain}" "/opt/verb/conf/vapps/orig/vapp.winston99.${domain}"
    fi
    cfg="${newdir}/config.php"
    if [ -f "${cfg}" ]; then
      /usr/bin/sed -i "s|https://github.com/PinkWrite/99.git|${w99_github}|g" "${cfg}"
      if [ -x /opt/verb/serfs/setvappconfig ]; then
        /opt/verb/serfs/setvappconfig "vapp.winston99.${domain}" "${cfg}" || true
      fi
    fi
    /bin/chown -R www:www "${newdir}" 2>/dev/null || true
  done
}

migrate_pdt() {
  local dir base domain newdir oldv newv oldc newc svc unit
  if [ ! -d /srv/www/vapps ]; then
    return 0
  fi
  for dir in /srv/www/vapps/pdt.*; do
    [ -e "${dir}" ] || continue
    base="$(/usr/bin/basename "${dir}")"
    domain="${base#pdt.}"
    [ -n "${domain}" ] || continue
    newdir="/srv/www/vapps/winstonpress.${domain}"
    if [ -e "${newdir}" ]; then
      /usr/bin/echo "Skip ${base}: ${newdir} already exists."
      continue
    fi
    /bin/mv "${dir}" "${newdir}"
    /usr/bin/echo "Moved ${dir} -> ${newdir}"
    oldv="/opt/verb/conf/vapps/vapp.pdt.${domain}"
    newv="/opt/verb/conf/vapps/vapp.winstonpress.${domain}"
    if [ -f "${oldv}" ]; then
      /bin/mv "${oldv}" "${newv}"
    fi
    oldc="/opt/verb/conf/vapps/pdt.${domain}.config"
    newc="/opt/verb/conf/vapps/winstonpress.${domain}.config"
    if [ -f "${oldc}" ]; then
      /bin/mv "${oldc}" "${newc}"
    fi
    if [ -f "${newv}" ]; then
      /usr/bin/sed -i \
        -e "s|/srv/www/vapps/pdt\\.|/srv/www/vapps/winstonpress.|g" \
        -e "s|appConfig=/opt/verb/conf/vapps/pdt\\.|appConfig=/opt/verb/conf/vapps/winstonpress.|g" \
        "${newv}"
      svc="$(/usr/bin/grep -m1 '^appService=' "${newv}" | /usr/bin/sed 's/^appService=//;s/^["'\'']//;s/["'\'']$//')"
    fi
    if [ -n "${newc}" ] && [ -f "${newc}" ]; then
      /bin/ln -sfn "${newc}" "/etc/pdt/${domain}" 2>/dev/null || true
    fi
    if [ -f "/opt/verb/conf/vapps/orig/vapp.pdt.${domain}" ]; then
      /bin/mv "/opt/verb/conf/vapps/orig/vapp.pdt.${domain}" "/opt/verb/conf/vapps/orig/vapp.winstonpress.${domain}"
    fi
    if [ -n "${svc}" ]; then
      unit="/etc/systemd/system/${svc}.service"
      if [ -f "${unit}" ]; then
        /usr/bin/sed -i \
          -e "s|/srv/www/vapps/pdt\\.|/srv/www/vapps/winstonpress.|g" \
          -e "s|PDT_CONFIG=/opt/verb/conf/vapps/pdt\\.|PDT_CONFIG=/opt/verb/conf/vapps/winstonpress.|g" \
          "${unit}"
        /usr/bin/systemctl daemon-reload
        if /usr/bin/systemctl is-enabled --quiet "${svc}.service" 2>/dev/null; then
          /usr/bin/systemctl restart "${svc}.service" || true
        fi
      fi
    fi
    if [ -x /opt/verb/serfs/setvappconfig ] && [ -f "${newc}" ]; then
      /opt/verb/serfs/setvappconfig "vapp.winstonpress.${domain}" "${newc}" || true
    fi
    /bin/chown -R www:www "${newdir}" 2>/dev/null || true
  done
}

ensure_repover_keys() {
  local f="/opt/verb/conf/inklists/repoverlist"
  [ -f "${f}" ] || return 0
  if ! /usr/bin/grep -q '^winston99=' "${f}"; then
    /usr/bin/printf '\nwinston99="master"\nwinston99sha="SKIP"\n' >> "${f}"
  fi
  if ! /usr/bin/grep -q '^winstonpress=' "${f}"; then
    /usr/bin/printf '\nwinstonpress="main"\nwinstonpresssha="SKIP"\n' >> "${f}"
  fi
}

ensure_repover_keys
migrate_pw99
migrate_pdt
/usr/bin/echo "winston-migrate: done."
