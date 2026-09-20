# install winstonpress

## This downloads and installs Winston Press on a hosted domain
- Was pdt-news (`ink install pdt`, still an alias)
- Uses `inkget winstonpress` (`donjon/repoupdate/winstonpress.updaterepo`) — tarball from `github.com/JesseSteele/winstonpress`
- Lives in `www/vapps/winstonpress.DOMAIN.TLD`
- Nginx proxies to a localhost Go binary (`bin/pdt`)
- Writes PostgreSQL credentials to `verb/conf/vapps/vapp.winstonpress.DOMAIN.TLD`
- Writes the app config to `verb/conf/vapps/winstonpress.DOMAIN.config` (`PDT_CONFIG`)

## Usage
- `ink install winstonpress -d [ domain.tld ] [ -m single|network ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
- `ink install winstonpress -d inkisaverb.com`
  - Same as `./installwinstonpress inkisaverb.com`
- `ink install pdt` still works (alias)
