# install pdt

## This downloads and installs pdt-news on a hosted domain
- Uses `inkget pdt` (ZJZ dragon `donjon/repoupdate/pdt.updaterepo`) to fetch the GitHub tarball
- Lives in `www/vapps/pdt.DOMAIN.TLD` (machine name)
- Builds the Go binary, binds `127.0.0.1`, Nginx reverse-proxies the domain
- BIMI via `ink set bimi` at `https://${emailTLDURI}/domain.tld/bimi.svg` (not on the pdt proxy)
- Writes PostgreSQL credentials to `verb/conf/vapps/vapp.pdt.DOMAIN.TLD`
- Writes the app config to `verb/conf/vapps/pdt.DOMAIN.config` (`PDT_CONFIG`)
- Adds the domain with `adddomain` if it is not already hosted
- Needs LEMP or LAEMP (Nginx). Does not run inkCert; obtain certs separately with `ink cert do`
- Payment keys stay empty so the dashboard can set them unless a SysAdmin fills the config

## Usage
- `ink install pdt -d [ domain.tld ] [ -m single|network ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
  - `-d` is required
  - `-m` defaults to `single` (one blog at the host). `network` is the paper plus `/handle` author blogs
  - Database flags are optional and sequential at the serf; omit them to autogenerate

- `ink install pdt -d inkisaverb.com`
  - Same as `./installpdt inkisaverb.com`
  - Creates `www/vapps/pdt.inkisaverb.com`
  - Autogenerates database, user, and password
  - Writes `verb/conf/vapps/vapp.pdt.inkisaverb.com`
  - Finish setup at `https://inkisaverb.com/install`

- `ink install pdt -d inkisaverb.com -m network`
  - Same as `./installpdt inkisaverb.com network`
  - Network mode: paper at the host, `/@handle` bio, `/handle` author blog

- `ink install pdt -d news.inkisaverb.com`
  - Subdomain install. Needs the subdomain hosted and cert-covered:
    - Certbot wildcard (`DONE_CB`) already applies via `addsubdomain`, or
    - Letsencrypt (`DONE_LE`) with the subdomain listed in `inkcert/cli-ini` and refreshed

- `ink install pdt -d inkisaverb.com -m single -b somedb -u someuser -p somepass`
  - Same as `./installpdt inkisaverb.com single somedb someuser somepass`

