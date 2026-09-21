#!/usr/bin/bash
# inkVerb donjon: put a file on the setserve download URI
# Document root is /srv/www/verb/${ServerServeTLD}.serve  (nginx/apache serve.conf)
# Public URL is https://${ServerServePath}/NAME  (ServerServePath already includes ServeDir)

servedl_dir() {
  . /opt/verb/conf/servernameip
  /usr/bin/echo "/srv/www/verb/${ServerServeTLD}.serve/${ServerServeDir}"
}

# servedl_put SRC [subdir] [destname]
# Symlink into the serve dir; echo the https URL.
servedl_put() {
  . /opt/verb/conf/servernameip
  local src="${1}"
  local sub="${2:-}"
  local name="${3:-}"
  local dir real
  [ -z "${name}" ] && name=$(/usr/bin/basename "${src}")
  if [ -z "${ServerServeTLD}" ] || [ -z "${ServerServeDir}" ] || [ -z "${ServerServePath}" ]; then
    /usr/bin/echo "Serve download path is not set. Run setserve first." >&2
    return 8
  fi
  dir="/srv/www/verb/${ServerServeTLD}.serve/${ServerServeDir}"
  [ -n "${sub}" ] && dir="${dir}/${sub}"
  /usr/bin/mkdir -p "${dir}"
  real=$(/usr/bin/readlink -f "${src}" 2>/dev/null || /usr/bin/echo "${src}")
  /bin/ln -sfn "${real}" "${dir}/${name}"
  /bin/chown www:www "${dir}" 2>/dev/null || true
  /bin/chown -h www:www "${dir}/${name}" 2>/dev/null || true
  if [ -n "${sub}" ]; then
    /usr/bin/echo "https://${ServerServePath}/${sub}/${name}"
  else
    /usr/bin/echo "https://${ServerServePath}/${name}"
  fi
}
