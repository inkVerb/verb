# ghost 2wp

## Import Ghost posts, pages, menus, and media into WordPress
- Does **not** convert the Ghost database in place. Ghost stays as the backup.
- Requires WordPress already installed on the same domain (`ink install wp -d DOMAIN`).
- `installwp` creates a new empty MariaDB and `wp-config.php`. If WP tables are still missing, the importer runs `wp_install()` then loads content.
- Copies (does not move) `content/images`, `content/files`, and `content/media` into `wp-content/uploads`, skipping Ghost `size/` variants.
- Rewrites `__GHOST_URL__/content/images/` (and `/content/images/size/wN/`) to `/wp-content/uploads/`.
- Imports posts and pages from Ghost `html` (fallback: lexical, mobiledoc, plaintext), tags, authors, featured images, and navigation menus.
- Fits `<img>` to the post body (`max-width:100%;height:auto`) and keeps wrap/align / Ghost `kg-width-*`. Already-imported sites: `ink wp fitimages -d DOMAIN`.
- Restores nginx from `DOMAIN-ghosted.conf` so PHP can run (Ghost's vhost is proxy-only). Pass `-k` to skip.

## Usage
- `ink ghost 2wp -d [ domain.tld ]`
  - Same as `/opt/verb/serfs/ghost2wp domain.tld`
- `ink ghost 2wp -d formosan.dog -n`
  - Dry run
- `ink ghost 2wp -d formosan.dog -m`
  - Media only
- `ink ghost 2wp -d formosan.dog -k`
  - Keep the Ghost nginx proxy vhost
- `ink ghost 2wp -d formosan.dog -v`
  - Verbose (serf stdout). `-d` finds `vapp.wp.DOMAIN` / Ghost on that domain.

## Sequence for a down Ghost site (files + MariaDB still on the verber)
1. `ink install wp -d formosan.dog`  
   New WordPress files + **new** empty database. Do not reuse the Ghost DB.
2. `ink ghost 2wp -d formosan.dog`  
   Import, copy media, restore PHP nginx.
3. Log in at `https://formosan.dog/wp-admin/` (if `wp_install()` ran, the password is printed).
4. Optional: `systemctl disable --now ghost_formosan-dog`
5. Optional: `ink wp pagify -d formosan.dog -a` if the import should have been pages, not posts.
6. If pictures overflow the post: `ink wp fitimages -d formosan.dog`

## Direct PHP (any paths)
```
/usr/bin/php /opt/verb/conf/lib/vapptools/ghost2wp.php \
  --wp-root=/srv/www/vapps/wp.formosan.dog \
  --ghost-db=GHOST_DB_NAME \
  --ghost-content=/srv/ghost/formosan.dog/content \
  --ghost-config=/srv/ghost/formosan.dog/config.production.json \
  --site-url=https://formosan.dog
```
Ghost DB name is in `/opt/verb/conf/vapps/vapp.ghost.formosan.dog` (`appDBase=`) or `config.production.json`.
