# install owncloud

## This installs ownCloud OCIS on cab.blueURI (or cloud.blueURI)
- Binary at `/usr/local/bin/ocis`, data in `/srv/cloud/ocis`
- Needs Nginx and an email server
- On failure, leftovers this install created are removed; pre-existing domain and certs stay

## Usage
- `ink install owncloud [ -s cab|cloud ]`
  - Same as `./installowncloud`
