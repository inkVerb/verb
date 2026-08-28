# install pw99

## This downloads and installs PinkWrite 99 on a hosted domain
- Uses `inkget pw99` (ZJZ dragon `donjon/repoupdate/pw99.updaterepo`) to fetch the GitHub tarball
- Lives in `www/vapps/pw99.DOMAIN.TLD`, linked from `www/html/DOMAIN.TLD`
- Writes MariaDB credentials to `verb/conf/vapps/vapp.pw99.DOMAIN.TLD`
- Writes `pw99-config.php` in the vapp (host is the domain, no scheme)
- Adds the domain with `adddomain` if it is not already hosted
- Does not run inkCert; obtain certs separately with `ink cert do`

## Usage
- `ink install pw99 -d [ domain.tld ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
  - `-d` is required
  - Database flags are optional and sequential at the serf; omit them to autogenerate

- `ink install pw99 -d inkisaverb.com`
  - Same as `./installpw99 inkisaverb.com`
  - Creates `www/vapps/pw99.inkisaverb.com`
  - Autogenerates database, user, and password
  - Writes `verb/conf/vapps/vapp.pw99.inkisaverb.com`
  - Create the first Superintendent at `https://inkisaverb.com/install.php`
  - Then set `allow_create_super` to false in `pw99-config.php`

- `ink install pw99 -d inkisaverb.com -b somedb -u someuser -p somepass`
  - Same as `./installpw99 inkisaverb.com somedb someuser somepass`
