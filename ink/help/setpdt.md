# set pdt

## This modifies settings for pdt-news already installed on a hosted domain
- Writes `verb/conf/vapps/pdt.DOMAIN.config` (`PDT_CONFIG`)
- Syncs db_* into `verb/conf/vapps/vapp.pdt.DOMAIN`
- Restarts the systemd unit
- Does not migrate the database; change credentials only if the cluster already matches

## Usage
- `ink set pdt -d [ domain.tld ] [ -m single|network ] [ -b database ] [ -u dbuser ] [ -p dbpassword ] [ -k key -s value ]`
  - `-d` is required
  - Other flags are optional; omitted flags are left unchanged
  - `-k`/`-s` sets any config key (`web_url`, `theme`, `mail_from`, ...)

- `ink set pdt -d inkisaverb.com -m network`
  - Same as `./setpdt inkisaverb.com mode=network`

- `ink set pdt -d inkisaverb.com -k web_url -s https://inkisaverb.com`
  - Same as `./setpdt inkisaverb.com web_url=https://inkisaverb.com`
