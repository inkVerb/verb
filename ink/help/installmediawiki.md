# install mediawiki

## This installs MediaWiki on wiki.inkURI
- Lives in `www/vapps/mediawiki`
- After the web installer, put `LocalSettings.php` in vip and run `postinstallmediawiki`
- On failure, leftovers this install created are removed; pre-existing domain and certs stay

## Usage
- `ink install mediawiki [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
  - Same as `./installmediawiki`
