#!/usr/bin/bash
# Copy (default) or move Ghost content media into a WordPress uploads folder.
# Ghost originals live under content/images/YYYY/MM/; size/ variants are skipped.
# Files land at wp-content/uploads/YYYY/MM/ so rewritten post HTML can see them.
#
# This only places files on disk. Register them in the Media Library with:
#   php /opt/verb/conf/lib/vapptools/ghost2wp.php --media-only --wp-root=... --ghost-db=...
#
# Usage:
#   ghost2wp-media.sh [ ghost-content-dir ] [ wp-uploads-dir ] [ copy | move ]
#
# Example:
#   /opt/verb/conf/lib/vapptools/ghost2wp-media.sh \
#     /srv/ghost/formosan.dog/content \
#     /srv/www/vapps/wp.formosan.dog/wp-content/uploads \
#     copy

set -euo pipefail

ghost_content="${1:-}"
wp_uploads="${2:-}"
mode="${3:-copy}"

if [ -z "${ghost_content}" ] || [ -z "${wp_uploads}" ] || [ "${ghost_content}" = "-h" ] || [ "${ghost_content}" = "--help" ]; then
  /usr/bin/cat <<TXT
Copy or move Ghost media into the WordPress uploads folder.

  $0 [ ghost-content-dir ] [ wp-uploads-dir ] [ copy | move ]

  ghost-content-dir   Ghost content/ (contains images/, files/, media/)
  wp-uploads-dir      WordPress wp-content/uploads
  copy | move         Default copy (Ghost files stay). move removes sources.

Skip: size/ (Ghost responsive variants), cache/, .git/

After this, run ghost2wp with --media-only so items appear in the Media Library.
TXT
  exit 5
fi

if [ ! -d "${ghost_content}" ]; then
  /usr/bin/echo "Ghost content dir not found: ${ghost_content}"
  exit 8
fi
if [ "${mode}" != "copy" ] && [ "${mode}" != "move" ]; then
  /usr/bin/echo "Mode must be copy or move, got: ${mode}"
  exit 5
fi

/usr/bin/mkdir -p "${wp_uploads}"

rsync_base=( /usr/bin/rsync -a --exclude 'size/' --exclude 'cache/' --exclude '.git/' --exclude '.DS_Store' --exclude 'Thumbs.db' )
if [ "${mode}" = "move" ]; then
  rsync_base+=( --remove-source-files )
fi

copied=0
if [ -d "${ghost_content}/images" ]; then
  "${rsync_base[@]}" "${ghost_content}/images/" "${wp_uploads}/"
  copied=1
  /usr/bin/echo "images/ → ${wp_uploads}/"
fi
if [ -d "${ghost_content}/media" ]; then
  "${rsync_base[@]}" "${ghost_content}/media/" "${wp_uploads}/"
  copied=1
  /usr/bin/echo "media/ → ${wp_uploads}/"
fi
if [ -d "${ghost_content}/files" ]; then
  /usr/bin/mkdir -p "${wp_uploads}/files"
  "${rsync_base[@]}" "${ghost_content}/files/" "${wp_uploads}/files/"
  copied=1
  /usr/bin/echo "files/ → ${wp_uploads}/files/"
fi

if [ "${copied}" = "0" ]; then
  /usr/bin/echo "No images/, media/, or files/ under ${ghost_content}"
  exit 8
fi

if /usr/bin/id -u www >/dev/null 2>&1; then
  /usr/bin/chown -R www:www "${wp_uploads}" || true
fi

if [ "${mode}" = "move" ]; then
  /usr/bin/echo "Moved Ghost media into ${wp_uploads} (source files removed; empty dirs may remain)."
else
  /usr/bin/echo "Copied Ghost media into ${wp_uploads} (Ghost originals left in place)."
fi
