# set pw99

## This modifies settings for PinkWrite 99 already installed on a hosted domain
- Writes `www/vapps/pw99.DOMAIN.TLD/config.php`
- Syncs db_* into `verb/conf/vapps/vapp.pw99.DOMAIN`
- Host is everything after `https://` (no scheme); default front is `99.DOMAIN`
- `allow_create_super=false` after the first Superintendent is created

## Usage
- `ink set pw99 -d [ domain.tld ] [ -b database ] [ -u dbuser ] [ -p dbpassword ] [ -k key -s value ]`
  - `-d` is required
  - Other flags are optional; omitted flags are left unchanged
  - `-k` keys: `host`, `site_title`, `allow_create_super`, `db_host`, `mail_from`, `mail_transport`

- `ink set pw99 -d inkisaverb.com -k host -s 99.inkisaverb.com`
  - Same as `./setpw99 inkisaverb.com host=99.inkisaverb.com`

- `ink set pw99 -d inkisaverb.com -k allow_create_super -s false`
  - Same as `./setpw99 inkisaverb.com allow_create_super=false`
