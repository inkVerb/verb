#!/usr/bin/bash
#inkVerbDonjon! verb.ink
# Resolve a WordPress vapp and convert post_type post ↔ page (MariaDB only).
# Sourced by serfs/wppagify and serfs/wppostify.
#
#   . /opt/verb/donjon/wpptype.sh
#   wpptype_main FROM TO [ domain | vapp ] TARGET [ all | get | ID ]
#
# domain = extra checks (hosted domain + vapp.wp.DOMAIN + wp-config).
# vapp   = TARGET is wp.DOMAIN.TLD (vapp name).

wpptype_q() {
  /usr/bin/mariadb --defaults-extra-file=/opt/verb/conf/sql/mysqlboss.cnf "$@"
}

wpptype_usage() {
  /usr/bin/echo "Need: ${wpptype_cmd} [ domain | vapp ] [ domain.tld | wp.domain.tld ] [ all | get | ID ]"
  /usr/bin/echo "  domain does extra checks for vapp.wp.DOMAIN"
  /usr/bin/echo "  vapp is the wp.DOMAIN.TLD vapp name"
}

# Sets: wpptype_mode wpptype_target wpptype_domain wpptype_vapp wpptype_vfile
#       wpptype_root wpptype_db wpptype_prefix
wpptype_resolve() {
  local mode="$1"
  local target="$2"

  if [ -z "${mode}" ] || [ -z "${target}" ]; then
    wpptype_usage
    return 5
  fi

  target="${target#vapp.}"
  if [ "${mode}" = "vapp" ]; then
    if [[ "${target}" != wp.* ]]; then
      /usr/bin/echo "Vapp must look like wp.domain.tld (got ${target})."
      return 8
    fi
    wpptype_mode="vapp"
    wpptype_vapp="${target}"
    wpptype_domain="${target#wp.}"
  elif [ "${mode}" = "domain" ]; then
    wpptype_mode="domain"
    wpptype_domain="${target}"
    wpptype_vapp="wp.${target}"
  else
    wpptype_usage
    return 5
  fi

  wpptype_target="${target}"
  wpptype_vfile="/opt/verb/conf/vapps/vapp.${wpptype_vapp}"
  wpptype_root="/srv/www/vapps/${wpptype_vapp}"

  if [ "${wpptype_mode}" = "domain" ]; then
    if [ ! -d "/srv/www/domains/${wpptype_domain}" ] && [ ! -e "/srv/www/html/${wpptype_domain}" ]; then
      /usr/bin/echo "Domain ${wpptype_domain} is not hosted (no domains/ or html/ entry)."
      return 8
    fi
    if [ ! -f "${wpptype_vfile}" ]; then
      /usr/bin/echo "No WordPress vapp config at ${wpptype_vfile}."
      /usr/bin/echo "Install with: ink install wp -d ${wpptype_domain}"
      return 8
    fi
    if [ ! -d "${wpptype_root}" ]; then
      /usr/bin/echo "WordPress vapp directory missing: ${wpptype_root}"
      return 8
    fi
    if [ ! -f "${wpptype_root}/wp-config.php" ]; then
      /usr/bin/echo "wp-config.php missing at ${wpptype_root} (incomplete WP install)."
      return 8
    fi
  else
    if [ ! -f "${wpptype_vfile}" ]; then
      /usr/bin/echo "No vapp config at ${wpptype_vfile}."
      return 8
    fi
    if [ ! -f "${wpptype_root}/wp-config.php" ]; then
      /usr/bin/echo "wp-config.php missing at ${wpptype_root}."
      return 8
    fi
  fi

  # shellcheck disable=SC1090
  . "${wpptype_vfile}"
  wpptype_db="${appDBase}"
  if [ -z "${wpptype_db}" ]; then
    /usr/bin/echo "appDBase empty in ${wpptype_vfile}."
    return 8
  fi

  wpptype_prefix="$(/usr/bin/sed -n "s/^[[:space:]]*\$table_prefix[[:space:]]*=[[:space:]]*['\"]\\([^'\"]*\\)['\"].*/\\1/p" "${wpptype_root}/wp-config.php" | /usr/bin/head -1)"
  if [ -z "${wpptype_prefix}" ]; then
    wpptype_prefix="wp_"
  fi
  if [[ ! "${wpptype_prefix}" =~ ^[A-Za-z0-9_]+$ ]]; then
    /usr/bin/echo "Refusing table prefix from wp-config.php: ${wpptype_prefix}"
    return 8
  fi
  if [[ ! "${wpptype_db}" =~ ^[A-Za-z0-9_]+$ ]]; then
    /usr/bin/echo "Refusing database name: ${wpptype_db}"
    return 8
  fi
}

wpptype_list() {
  local from="$1"
  wpptype_q --batch -e "
SELECT p.post_title AS Title, p.post_name AS slug, p.ID
FROM \`${wpptype_db}\`.\`${wpptype_prefix}posts\` p
WHERE p.post_type='${from}'
  AND p.post_status NOT IN ('auto-draft','inherit')
ORDER BY p.ID;
"
}

wpptype_convert() {
  local from="$1"
  local to="$2"
  local which="$3"
  local where n menus

  if [ "${which}" = "all" ]; then
    where="post_type='${from}' AND post_status NOT IN ('auto-draft','inherit')"
  else
    where="ID=${which} AND post_type='${from}' AND post_status NOT IN ('auto-draft','inherit')"
  fi

  n="$(wpptype_q -N -e "
UPDATE \`${wpptype_db}\`.\`${wpptype_prefix}posts\`
SET post_type='${to}'
WHERE ${where};
SELECT ROW_COUNT();
" | /usr/bin/tail -1 | /usr/bin/tr -d '[:space:]')"

  if [ -z "${n}" ]; then
    n="0"
  fi

  if [ "${n}" = "0" ]; then
    if [ "${which}" = "all" ]; then
      /usr/bin/echo "No ${from}s to convert to ${to}s on ${wpptype_domain}."
    else
      /usr/bin/echo "ID ${which} is not a convertible ${from} on ${wpptype_domain} (missing, wrong type, or auto-draft/revision)."
      return 8
    fi
    return 0
  fi

  menus="$(wpptype_q -N -e "
UPDATE \`${wpptype_db}\`.\`${wpptype_prefix}postmeta\` pm
INNER JOIN \`${wpptype_db}\`.\`${wpptype_prefix}postmeta\` pmid
  ON pmid.post_id = pm.post_id AND pmid.meta_key = '_menu_item_object_id'
INNER JOIN \`${wpptype_db}\`.\`${wpptype_prefix}posts\` tgt
  ON tgt.ID = CAST(pmid.meta_value AS UNSIGNED)
SET pm.meta_value = '${to}'
WHERE pm.meta_key = '_menu_item_object'
  AND pm.meta_value = '${from}'
  AND tgt.post_type = '${to}';
SELECT ROW_COUNT();
" | /usr/bin/tail -1 | /usr/bin/tr -d '[:space:]')"

  if [ "${which}" = "all" ]; then
    /usr/bin/echo "Converted ${n} ${from}(s) to ${to}(s) on ${wpptype_domain}."
  else
    /usr/bin/echo "Converted ${from} ID ${which} to ${to} on ${wpptype_domain}."
  fi
  if [ -n "${menus}" ] && [ "${menus}" != "0" ]; then
    /usr/bin/echo "Updated ${menus} menu item(s) to object ${to}."
  fi
}

wpptype_main() {
  local from="$1"
  local to="$2"
  shift 2
  local mode="" target="" op=""

  wpptype_cmd="$(/usr/bin/basename "$0")"

  if [ "$1" = "domain" ] || [ "$1" = "vapp" ]; then
    mode="$1"
    target="$2"
    op="$3"
  else
    target="$1"
    op="$2"
    if [[ "${target}" == wp.* ]]; then
      mode="vapp"
    else
      mode="domain"
    fi
  fi

  if [ -z "${target}" ] || [ -z "${op}" ]; then
    wpptype_usage
    return 5
  fi

  case "${op}" in
    all|get) ;;
    ''|*[!0-9]*)
      /usr/bin/echo "Third argument must be all, get, or a numeric ID (got ${op})."
      wpptype_usage
      return 5
      ;;
  esac

  wpptype_resolve "${mode}" "${target}" || return "$?"

  case "${op}" in
    get)
      wpptype_list "${from}"
      ;;
    all)
      wpptype_convert "${from}" "${to}" all
      ;;
    *)
      wpptype_convert "${from}" "${to}" "${op}"
      ;;
  esac
}
