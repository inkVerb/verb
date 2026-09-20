# set winstonpress

## This modifies settings for Winston Press already installed on a hosted domain
- Writes `verb/conf/vapps/winstonpress.DOMAIN.config` (`PDT_CONFIG`)
- Syncs db_* into `verb/conf/vapps/vapp.winstonpress.DOMAIN`
- Restarts the systemd unit

## Usage
- `ink set winstonpress -d [ domain.tld ] [ -m single|network ] [ -b database ] [ -u dbuser ] [ -p dbpassword ] [ -k key -s value ]`
- `ink set winstonpress -d inkisaverb.com -m network`
- `ink set pdt` still works (alias)
