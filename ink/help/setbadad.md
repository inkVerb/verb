# set badad

## This modifies settings for badAd already installed on a hosted domain
- Writes `verb/conf/vapps/badad.DOMAIN.config` (`BADAD_CONFIG`)
- Syncs db_* into `verb/conf/vapps/vapp.badad.DOMAIN`
- Restarts the systemd unit
- Payment keys stay SysAdmin-only in this file (`-k stripe_secret -s ...`)

## Usage
- `ink set badad -d [ domain.tld ] [ -b database ] [ -u dbuser ] [ -p dbpassword ] [ -k key -s value ]`
  - `-d` is required
  - Other flags are optional; omitted flags are left unchanged

- `ink set badad -d inkisaverb.com -k web_url -s https://inkisaverb.com`
  - Same as `./setbadad inkisaverb.com web_url=https://inkisaverb.com`

- `ink set badad -d inkisaverb.com -b somedb -u someuser -p somepass`
  - Same as `./setbadad inkisaverb.com db_name=somedb db_user=someuser db_pass=somepass`
