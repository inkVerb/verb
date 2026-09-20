# install pydio

## This installs Pydio Cells on base.blueURI (or cloud.blueURI)
- Binary at `/usr/local/bin/cells`, data in `/srv/cloud/pydio`
- Needs Nginx and an email server
- On failure, leftovers this install created are removed; pre-existing domain and certs stay

## Usage
- `ink install pydio [ -s base|cloud ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
  - Same as `./installpydio`
