# install wp

## This downloads and installs WordPress on a hosted domain
- Uses `inkget wp` (ZJZ dragon `donjon/repoupdate/wp.updaterepo`) to fetch WordPress
- Lives in `www/vapps/wp.DOMAIN.TLD`, linked from `www/html/DOMAIN.TLD`
- Writes MariaDB credentials to `verb/conf/vapps/vapp.wp.DOMAIN.TLD`
- Adds the domain with `adddomain` if it is not already hosted
- Does not run inkCert; obtain certs separately with `ink cert do`

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
