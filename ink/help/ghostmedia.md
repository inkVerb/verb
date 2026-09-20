# ghost media

## Copy Ghost media into the WordPress Media Library
- Copies `content/images` (and `files/`, `media/`) into `wp-content/uploads`, skipping Ghost `size/` variants.
- Then registers those files as WordPress attachments so they appear in the Media Library.
- Default is **copy** (Ghost originals stay). Pass `-m` to move.

## Usage
- `ink ghost media -d [ domain.tld ]`
  - Same as `/opt/verb/serfs/ghost2wpmedia domain.tld`
  - Same as `/opt/verb/conf/lib/vapptools/ghost2wp-media.sh /srv/ghost/DOMAIN/content /srv/www/vapps/wp.DOMAIN/wp-content/uploads copy` then `ghost2wp DOMAIN media-only`
- `ink ghost media -d formosan.dog -m`
  - Move instead of copy
