# install badad

## This downloads and installs badAd on a hosted domain
- Uses `inkget badad` (ZJZ dragon `donjon/repoupdate/badad.updaterepo`) to fetch the GitHub tarball (golang branch until it is merged to main)
- Lives in `www/vapps/badad.DOMAIN.TLD`
- Builds the Go binary, binds `127.0.0.1`, Nginx reverse-proxies the domain
- Writes PostgreSQL credentials to `verb/conf/vapps/vapp.badad.DOMAIN.TLD`
- Writes the app config to `verb/conf/vapps/badad.DOMAIN.config` (`BADAD_CONFIG`)
- Adds the domain with `adddomain` if it is not already hosted
- Needs LEMP or LAEMP (Nginx). Does not run inkCert; obtain certs separately with `ink cert do`
- Payment keys are SysAdmin-only in the config file (no dashboard editor)

## Usage
- `ink install badad -d [ domain.tld ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
  - `-d` is required
  - Database flags are optional and sequential at the serf; omit them to autogenerate

- `ink install badad -d inkisaverb.com`
  - Same as `./installbadad inkisaverb.com`
  - Creates `www/vapps/badad.inkisaverb.com`
  - Autogenerates database, user, and password
  - Writes `verb/conf/vapps/vapp.badad.inkisaverb.com`
  - Open `https://inkisaverb.com/`

- `ink install badad -d inkisaverb.com -b somedb -u someuser -p somepass`
  - Same as `./installbadad inkisaverb.com somedb someuser somepass`
