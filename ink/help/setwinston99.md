# set winston99

## This modifies settings for Winston 99 already installed on a hosted domain
- Writes `www/vapps/winston99.DOMAIN.TLD/config.php`
- Syncs db_* into `verb/conf/vapps/vapp.winston99.DOMAIN`

## Usage
- `ink set winston99 -d [ domain.tld ] [ -b database ] [ -u dbuser ] [ -p dbpassword ] [ -k key -s value ]`
- `ink set winston99 -d 99.write.pink -k github -s https://github.com/JesseSteele/Winston99.git`
- `ink set winston99 -d 99.write.pink -k allow_create_super -s false`
- `ink set pw99` still works (alias)
