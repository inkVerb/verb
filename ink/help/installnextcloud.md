# install nextcloud

## This installs Nextcloud on kit.blueURI (or cloud.blueURI)
- Lives in `www/vapps/nextcloud`
- `-s kit` (default) or `-s cloud`
- On failure, leftovers this install created are removed; pre-existing domain and certs stay

## Usage
- `ink install nextcloud [ -s kit|cloud ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
  - Same as `./installnextcloud kit`
  - `ink install nextcloud -s cloud` is `./installnextcloud cloud`
