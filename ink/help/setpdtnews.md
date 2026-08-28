# set pdtnews

## This modifies settings for pdt-news already installed on a hosted domain
- Writes `verb/conf/vapps/pdtnews.DOMAIN.config` (`PDT_CONFIG`)
- Syncs db_* into `verb/conf/vapps/vapp.pdtnews.DOMAIN`
- Restarts the systemd unit
- Does not migrate the database; change credentials only if the cluster already matches

## Usage
- `ink set pdtnews -d [ domain.tld ] [ -m single|network ] [ -b database ] [ -u dbuser ] [ -p dbpassword ] [ -k key -s value ]`
  - `-d` is required
  - Other flags are optional; omitted flags are left unchanged
  - `-k`/`-s` sets any config key (`web_url`, `theme`, `mail_from`, ...)

- `ink set pdtnews -d inkisaverb.com -m network`
  - Same as `./setpdtnews inkisaverb.com mode=network`

- `ink set pdtnews -d inkisaverb.com -k web_url -s https://inkisaverb.com`
  - Same as `./setpdtnews inkisaverb.com web_url=https://inkisaverb.com`
