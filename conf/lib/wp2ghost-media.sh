#!/usr/bin/bash
#inkVerb! verb.ink
#
# Copy (default) or move WordPress uploads into Ghost content/images.
# Skips WP generated thumbs (file-150x150.jpg) and index.php.
#
# Usage:
#   wp2ghost-media.sh <wp-uploads-dir> <ghost-content-dir> [copy|move]
#
# Example:
#   wp2ghost-media.sh \
#     /srv/www/vapps/wp.example.com/wp-content/uploads \
#     /srv/ghost/example.com/content \
#     copy

set -euo pipefail

src="${1:-}"
ghost_content="${2:-}"
mode="${3:-copy}"

if [ -z "${src}" ] || [ -z "${ghost_content}" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  /usr/bin/sed -n '2,16p' "$0"
  exit 0
fi

src="$(/usr/bin/readlink -f "${src}")"
ghost_content="$(/usr/bin/readlink -f "${ghost_content}")"
dest="${ghost_content}/images"

if [ ! -d "${src}" ]; then
  /usr/bin/echo "WordPress uploads not found: ${src}"
  exit 8
fi
/usr/bin/mkdir -p "${dest}"

if [ "${mode}" != "copy" ] && [ "${mode}" != "move" ]; then
  /usr/bin/echo "Mode must be copy or move."
  exit 5
fi

rsync_flags=(-a --exclude 'index.php' --exclude '.htaccess' --exclude '.git/' --exclude '*-[0-9][0-9][0-9]x[0-9][0-9][0-9].*' --exclude '*-[0-9][0-9]x[0-9][0-9].*' --exclude '*-[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9].*')
if [ "${mode}" = "move" ]; then
  rsync_flags+=(--remove-source-files)
fi

if [ -x /usr/bin/rsync ]; then
  /usr/bin/rsync "${rsync_flags[@]}" "${src}/" "${dest}/"
else
  /usr/bin/echo "rsync not found; using find+cp."
  /usr/bin/find "${src}" -type f ! -name 'index.php' ! -name '.htaccess' ! -name '*-*x*.jpg' ! -name '*-*x*.png' \
    -exec /usr/bin/bash -c 'rel="${1#"$2"/}"; mkdir -p "$3/$(dirname "$rel")"; cp -a "$1" "$3/$rel"' _ {} "${src}" "${dest}" \;
fi

if /usr/bin/id ghost >/dev/null 2>&1; then
  /usr/bin/chown -R ghost:ghost "${dest}" 2>/dev/null || true
fi

/usr/bin/echo "${mode}d WordPress uploads → ${dest}"
if [ "${mode}" = "copy" ]; then
  /usr/bin/echo "WordPress originals left in place."
fi
