# install wp

## This downloads and installs WordPress on a hosted domain
- Uses `inkget wp` (ZJZ dragon `donjon/repoupdate/wp.updaterepo`) to fetch WordPress
- Lives in `www/vapps/wp.DOMAIN.TLD`, linked from `www/html/DOMAIN.TLD`
- Writes MariaDB credentials to `verb/conf/vapps/vapp.wp.DOMAIN.TLD`
- Adds the domain with `adddomain` if it is not already hosted
- BIMI is not on the WP site; use `ink set bimi` (`https://${emailTLDURI}/domain.tld/bimi.svg`)
- `html/DOMAIN` must be a symlink (or missing). A real directory is refused — current BIMI is `/srv/www/email/bimi/DOMAIN/bimi.svg`, not html.
- If this install fails, it undoes what it created (vapp dir, DB, vapp conf, html symlink it made). Pre-existing domain and certs stay. An incomplete leftover is cleaned on the next run instead of “already installed.”
- To import an existing Ghost site on the same domain: `ink ghost 2wp -d DOMAIN` (after this install). Ghost's database is not reused.

## Usage
- `ink install wp -d [ domain.tld ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
  - `-d` is required
  - Database flags are optional and sequential at the serf; omit them to autogenerate

- `ink install wp -d inkisaverb.com`
  - Same as `./installwp inkisaverb.com`
  - Creates `www/vapps/wp.inkisaverb.com`
  - Autogenerates database, user, and password
  - Writes `verb/conf/vapps/vapp.wp.inkisaverb.com`
  - Finish setup at `https://inkisaverb.com/wp-admin/index.php`

- `ink install wp -d inkisaverb.com -b somedb -u someuser -p somepass`
  - Same as `./installwp inkisaverb.com somedb someuser somepass`
