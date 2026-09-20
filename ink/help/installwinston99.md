# install winston99

## This downloads and installs Winston 99 on a hosted domain
- Uses `inkget winston99` (`donjon/repoupdate/winston99.updaterepo`) — tarball from `github.com/JesseSteele/Winston99`
- Machine name: `www/vapps/winston99.DOMAIN.TLD`
- Front: `html/DOMAIN.TLD` links to that vapp
- Writes MariaDB credentials to `verb/conf/vapps/vapp.winston99.DOMAIN.TLD`
- In-app updater reads `config.php` `'github'`

## Usage
- `ink install winston99 -d [ domain.tld ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
- `ink install winston99 -d 99.write.pink`
  - Same as `./installwinston99 99.write.pink`
  - Creates `www/vapps/winston99.99.write.pink`
