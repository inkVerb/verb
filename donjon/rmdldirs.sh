#!/bin/bash
# inkNet cron: drop expired one-shot subdirs under the serve download dir
. /opt/verb/conf/servernameip
[ -n "${ServerServeTLD}" ] && [ -n "${ServerServeDir}" ] || exit 0
sroot="/srv/www/verb/${ServerServeTLD}.serve/${ServerServeDir}"
[ -d "${sroot}" ] || exit 0
/usr/bin/find "${sroot}" -mindepth 1 -type d -mmin +30 -exec /usr/bin/rm -rf {} + 2>/dev/null || true
