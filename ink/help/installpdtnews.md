# install pdtnews

## This downloads and installs pdt-news on a hosted domain
- Uses `inkget pdtnews` (ZJZ dragon `donjon/repoupdate/pdtnews.updaterepo`) to fetch the GitHub tarball
- Lives in `www/vapps/pdtnews.DOMAIN.TLD`
- Builds the Go binary, binds `127.0.0.1`, Nginx reverse-proxies the domain
- Writes PostgreSQL credentials to `verb/conf/vapps/vapp.pdtnews.DOMAIN.TLD`
- Writes the app config to `verb/conf/vapps/pdtnews.DOMAIN.config` (`PDT_CONFIG`)
- Adds the domain with `adddomain` if it is not already hosted
- Needs LEMP or LAEMP (Nginx). Does not run inkCert; obtain certs separately with `ink cert do`
- Payment keys stay empty so the dashboard can set them unless a SysAdmin fills the config

## Usage
- `ink install pdtnews -d [ domain.tld ] [ -m single|network ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
  - `-d` is required
  - `-m` defaults to `single` (one blog at the host). `network` is the paper plus `/handle` author blogs
  - Database flags are optional and sequential at the serf; omit them to autogenerate

- `ink install pdtnews -d inkisaverb.com`
  - Same as `./installpdtnews inkisaverb.com`
  - Creates `www/vapps/pdtnews.inkisaverb.com`
  - Autogenerates database, user, and password
  - Writes `verb/conf/vapps/vapp.pdtnews.inkisaverb.com`
  - Finish setup at `https://inkisaverb.com/install`

- `ink install pdtnews -d inkisaverb.com -m network`
  - Same as `./installpdtnews inkisaverb.com network`
  - Network mode: paper at the host, `/@handle` bio, `/handle` author blog

- `ink install pdtnews -d inkisaverb.com -m single -b somedb -u someuser -p somepass`
  - Same as `./installpdtnews inkisaverb.com single somedb someuser somepass`
